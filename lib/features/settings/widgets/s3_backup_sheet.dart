import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:soulstate/app/theme/app_tokens.dart';
import 'package:soulstate/core/database/local_store.dart';
import 'package:soulstate/core/utils/app_snackbar.dart';
import 'package:soulstate/core/widgets/sheet_type.dart';
import 'package:soulstate/features/habits/state/habits_controller.dart';
import 'package:soulstate/features/settings/settings_actions.dart';
import 'package:soulstate/features/settings/state/settings_controller.dart';
import 'package:soulstate/features/vault/services/vault_manager.dart';
import 'package:soulstate/services/s3_service.dart';
import 'package:soulstate/services/s3_sync_service.dart';

class S3BackupSheet extends StatefulWidget {
  const S3BackupSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) => const S3BackupSheet(),
    );
  }

  @override
  State<S3BackupSheet> createState() => _S3BackupSheetState();
}

class _S3BackupSheetState extends State<S3BackupSheet> {
  late S3Config _config;

  late final TextEditingController _endpointCtrl;
  late final TextEditingController _bucketCtrl;
  late final TextEditingController _regionCtrl;
  late final TextEditingController _accessKeyCtrl;
  late final TextEditingController _secretKeyCtrl;
  late final TextEditingController _prefixCtrl;
  late final TextEditingController _encryptionPasswordCtrl;

  bool _obscureSecret = true;
  bool _obscurePassword = true;
  bool _testing = false;
  bool _saving = false;
  String? _testResult;
  bool _testOk = false;

  bool _backingUp = false;
  bool _pulling = false;
  bool _loadingBackups = false;
  List<S3BackupItem>? _backups;
  String? _restoreError;

  @override
  void initState() {
    super.initState();
    _config = S3Service.loadConfig();
    _endpointCtrl = TextEditingController(text: _config.endpoint);
    _bucketCtrl = TextEditingController(text: _config.bucket);
    _regionCtrl = TextEditingController(text: _config.region);
    _accessKeyCtrl = TextEditingController(text: _config.accessKey);
    _secretKeyCtrl = TextEditingController(text: _config.secretKey);
    _prefixCtrl = TextEditingController(text: _config.prefix);
    _encryptionPasswordCtrl = TextEditingController(text: _config.encryptionPassword);
  }

  @override
  void dispose() {
    _endpointCtrl.dispose();
    _bucketCtrl.dispose();
    _regionCtrl.dispose();
    _accessKeyCtrl.dispose();
    _secretKeyCtrl.dispose();
    _prefixCtrl.dispose();
    _encryptionPasswordCtrl.dispose();
    super.dispose();
  }

  S3Config _currentConfig() {
    return _config.copyWith(
      endpoint: _endpointCtrl.text.trim(),
      bucket: _bucketCtrl.text.trim(),
      region: _regionCtrl.text.trim().isEmpty ? 'us-east-1' : _regionCtrl.text.trim(),
      accessKey: _accessKeyCtrl.text.trim(),
      secretKey: _secretKeyCtrl.text.trim(),
      prefix: _prefixCtrl.text.trim(),
      encryptionPassword: _encryptionPasswordCtrl.text.trim(),
    );
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      final updated = _currentConfig();
      if (updated.enabled && !updated.isConfigured) {
        AppSnackbar.error(
          context,
          'Bucket Name, Access Key, and Secret Key are required when S3 sync is enabled',
        );
        return;
      }
      await S3Service.saveConfig(updated);
      if (mounted) setState(() => _config = updated);
      if (mounted) {
        context.read<SettingsController>().notifyS3Changed();
        if (updated.isSyncActive) {
          final habits = context.read<HabitsController>();
          final pullRes = await S3Service.pullLatestBackup(
            controller: habits,
            customConfig: updated,
            password: updated.encryptionPassword,
          );
          if (!mounted) return;
          if (pullRes.updated) {
            await SettingsActions.reloadAll(context);
            if (mounted) {
              AppSnackbar.success(context, 'S3 configured & data pulled from S3');
              Navigator.of(context).pop();
            }
            return;
          } else if (!pullRes.ok) {
            AppSnackbar.error(context, 'S3 saved, but pull failed: ${pullRes.message}');
            return;
          } else {
            AppSnackbar.info(context, 'S3 saved. No existing vault backup found on S3 yet.');
            return;
          }
        }
        if (mounted) {
          AppSnackbar.success(context, 'S3 configuration saved');
        }
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _testConnection() async {
    setState(() {
      _testing = true;
      _testResult = null;
    });

    final cfg = _currentConfig();
    final res = await S3Service.testConnection(cfg);

    if (mounted) {
      setState(() {
        _testing = false;
        _testOk = res.ok;
        _testResult = res.message;
      });
      if (res.ok) {
        await S3Service.saveConfig(cfg);
        setState(() => _config = cfg);
        if (mounted) {
          context.read<SettingsController>().notifyS3Changed();
          if (cfg.isSyncActive) {
            final habits = context.read<HabitsController>();
            final pullRes = await S3Service.pullLatestBackup(
              controller: habits,
              customConfig: cfg,
              password: cfg.encryptionPassword,
            );
            if (pullRes.updated && mounted) {
              await SettingsActions.reloadAll(context);
              if (mounted) {
                AppSnackbar.success(context, 'S3 connected & data pulled from S3');
              }
            }
          }
        }
      }
    }
  }

  Future<void> _setInterval(int mins) async {
    final updated = _config.copyWith(syncIntervalMinutes: mins);
    await S3Service.saveConfig(updated);
    setState(() => _config = updated);
    if (mins > 0 && updated.isSyncActive) {
      unawaited(S3SyncService.checkAndRun());
    }
  }

  Future<void> _backupNow() async {
    setState(() => _backingUp = true);
    final res = await S3Service.performBackup(
      password: _encryptionPasswordCtrl.text.trim(),
    );
    if (mounted) {
      setState(() {
        _backingUp = false;
        _config = S3Service.loadConfig();
      });
      if (res.ok) {
        AppSnackbar.success(context, res.message);
        _fetchBackups();
      } else {
        AppSnackbar.error(context, res.message);
      }
    }
  }

  Future<void> _pullNow() async {
    setState(() => _pulling = true);
    final habits = context.read<HabitsController>();
    final res = await S3Service.pullLatestBackup(
      controller: habits,
      password: _encryptionPasswordCtrl.text.trim(),
      customConfig: _currentConfig(),
    );
    if (mounted) {
      setState(() => _pulling = false);
      if (res.updated) {
        await SettingsActions.reloadAll(context);
        if (mounted) {
          AppSnackbar.success(context, res.message);
        }
      } else if (res.ok) {
        AppSnackbar.info(context, res.message);
      } else {
        AppSnackbar.error(context, res.message);
      }
    }
  }

  Future<void> _fetchBackups() async {
    setState(() {
      _loadingBackups = true;
      _restoreError = null;
    });
    try {
      final items = await S3Service.listBackups(_currentConfig());
      if (mounted) {
        setState(() {
          _loadingBackups = false;
          _backups = items;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loadingBackups = false;
          _restoreError = e.toString().replaceFirst('Exception: ', '');
        });
      }
    }
  }

  Future<void> _promptRestore(S3BackupItem item) async {
    final habits = context.read<HabitsController>();
    final choice = await showDialog<String>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Restore from S3'),
        content: Text(
          'Choose how to restore "${item.displayName}":\n\n'
          '• Merge: Keep your existing habits and add data from the backup.\n'
          '• Replace: Overwrite current data completely with the backup.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
          OutlinedButton(
            onPressed: () => Navigator.pop(dialogCtx, 'merge'),
            child: const Text('Merge'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogCtx, 'replace'),
            child: const Text('Replace All'),
          ),
        ],
      ),
    );

    if (choice == null || !mounted) return;

    final replace = choice == 'replace';
    AppSnackbar.info(context, 'Downloading and restoring backup...');

    var res = await S3Service.restoreFromS3(
      key: item.key,
      replace: replace,
      controller: habits,
      password: _encryptionPasswordCtrl.text.trim(),
    );

    if (mounted && !res.ok && res.message.toLowerCase().contains('password')) {
      final pwdCtrl = TextEditingController();
      final entered = await showDialog<String>(
        context: context,
        builder: (pCtx) => AlertDialog(
          title: const Text('Encrypted Backup'),
          content: TextField(
            controller: pwdCtrl,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Encryption Password',
              hintText: 'Enter password to decrypt',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(pCtx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(pCtx, pwdCtrl.text.trim()),
              child: const Text('Decrypt & Restore'),
            ),
          ],
        ),
      );
      if (entered != null && entered.isNotEmpty && mounted) {
        res = await S3Service.restoreFromS3(
          key: item.key,
          replace: replace,
          controller: habits,
          password: entered,
        );
        if (res.ok) {
          _encryptionPasswordCtrl.text = entered;
          await _save();
        }
      }
    }

    if (mounted) {
      if (res.ok) {
        final vaultFolder = LocalStore.setting('vaultFolder', '');
        if (vaultFolder.isNotEmpty) {
          await VaultManager.syncVault(vaultFolder);
        }
        if (mounted) {
          await SettingsActions.reloadAll(context);
        }
        if (mounted) {
          AppSnackbar.success(context, res.message);
          Navigator.pop(context);
        }
      } else {
        AppSnackbar.error(context, res.message);
      }
    }
  }

  Future<void> _deleteBackup(S3BackupItem item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Delete Backup'),
        content: Text('Delete "${item.displayName}" from S3 permanently?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: context.colors.error,
            ),
            onPressed: () => Navigator.pop(dialogCtx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    final res = await S3Service.deleteFile(item.key, _currentConfig());
    if (mounted) {
      if (res.ok) {
        AppSnackbar.success(context, 'Backup deleted from S3');
        _fetchBackups();
      } else {
        AppSnackbar.error(context, res.message);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.colors;
    final tokens = context.tokens;

    final inputDecoration = InputDecoration(
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colors.outlineVariant),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colors.outlineVariant.withValues(alpha: 0.5)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colors.primary, width: 1.5),
      ),
      filled: true,
      fillColor: colors.surfaceContainerHighest.withValues(alpha: 0.3),
    );

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 6, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SheetTitle(
                'S3 Cloud Backup & Sync',
                subtitle: 'AWS S3 Cloud Storage.',
              ),
              const SizedBox(height: 16),

              // Enable / Disable S3 Sync Toggle Card
              Container(
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHighest.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _config.enabled
                        ? colors.primary.withValues(alpha: 0.4)
                        : colors.outlineVariant.withValues(alpha: 0.3),
                  ),
                ),
                child: SwitchListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  secondary: Icon(
                    LucideIcons.cloud,
                    color: _config.enabled ? colors.primary : tokens.muted,
                  ),
                  title: const Text(
                    'Enable AWS S3 Sync',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                  subtitle: Text(
                    _config.enabled
                        ? 'Pull from S3 on launch & sync on interval or manual push'
                        : 'Sync disabled (data stays local only)',
                    style: TextStyle(fontSize: 12, color: tokens.muted),
                  ),
                  value: _config.enabled,
                  onChanged: (val) async {
                    final settings = context.read<SettingsController>();
                    final updated = _config.copyWith(enabled: val);
                    await S3Service.saveConfig(updated);
                    if (!mounted) return;
                    setState(() => _config = updated);
                    settings.notifyS3Changed();
                    if (val && updated.isConfigured) {
                      unawaited(S3SyncService.onAppResume());
                    }
                  },
                ),
              ),
              const SizedBox(height: 20),

              // S3 Configuration Fields
              Text(
                'CREDENTIALS & BUCKET',
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                  color: tokens.muted,
                ),
              ),
              const SizedBox(height: 10),

              TextField(
                controller: _bucketCtrl,
                decoration: inputDecoration.copyWith(
                  labelText: 'Bucket Name *',
                  hintText: 'e.g. my-streak-backups',
                  prefixIcon: const Icon(LucideIcons.hardDrive, size: 18),
                ),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: _accessKeyCtrl,
                decoration: inputDecoration.copyWith(
                  labelText: 'Access Key ID *',
                  hintText: 'AKIA...',
                  prefixIcon: const Icon(LucideIcons.keyRound, size: 18),
                ),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: _secretKeyCtrl,
                obscureText: _obscureSecret,
                decoration: inputDecoration.copyWith(
                  labelText: 'Secret Access Key *',
                  prefixIcon: const Icon(LucideIcons.lock, size: 18),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureSecret ? LucideIcons.eye : LucideIcons.eyeOff,
                      size: 18,
                    ),
                    onPressed: () =>
                        setState(() => _obscureSecret = !_obscureSecret),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: TextField(
                      controller: _regionCtrl,
                      decoration: inputDecoration.copyWith(
                        labelText: 'Region',
                        hintText: 'us-east-1 or auto',
                        prefixIcon: const Icon(LucideIcons.globe, size: 18),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 5,
                    child: TextField(
                      controller: _prefixCtrl,
                      decoration: inputDecoration.copyWith(
                        labelText: 'Prefix / Folder',
                        hintText: 'e.g. vault/ (optional)',
                        prefixIcon: const Icon(LucideIcons.folder, size: 18),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              TextField(
                controller: _endpointCtrl,
                decoration: inputDecoration.copyWith(
                  labelText: 'Custom Endpoint (Optional)',
                  hintText: 'https://s3.<region>.amazonaws.com',
                  prefixIcon: const Icon(LucideIcons.link, size: 18),
                  helperText: 'Leave blank for standard AWS S3.',
                ),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: _encryptionPasswordCtrl,
                obscureText: _obscurePassword,
                decoration: inputDecoration.copyWith(
                  labelText: 'Backup Encryption Password',
                  hintText: 'Enter password to encrypt S3 data',
                  prefixIcon: const Icon(LucideIcons.shieldCheck, size: 18),
                  helperText: 'Encrypts your backups with AES-256 before uploading to S3.',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? LucideIcons.eye : LucideIcons.eyeOff,
                      size: 18,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Action buttons: Test & Save
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: (_testing || _saving) ? null : _testConnection,
                      icon: _testing
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(LucideIcons.wifi, size: 18),
                      label: Text(_testing ? 'Testing...' : 'Test Connection'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: (_saving || _testing) ? null : _save,
                      icon: _saving
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(LucideIcons.check, size: 18),
                      label: Text(_saving ? 'Connecting...' : 'Save Config'),
                    ),
                  ),
                ],
              ),

              if (_testResult != null) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _testOk
                        ? colors.primary.withValues(alpha: 0.12)
                        : colors.error.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _testOk
                          ? colors.primary.withValues(alpha: 0.3)
                          : colors.error.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _testOk ? LucideIcons.circleCheck : LucideIcons.circleAlert,
                        size: 20,
                        color: _testOk ? colors.primary : colors.error,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _testResult!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: _testOk ? colors.primary : colors.error,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const Divider(height: 32),

              // Auto Sync Interval Section
              Text(
                'AUTO-SYNC INTERVAL',
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                  color: tokens.muted,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Automatically back up your data to S3 at a regular interval.',
                style: theme.textTheme.bodySmall?.copyWith(color: tokens.muted),
              ),
              const SizedBox(height: 10),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final mins in S3SyncService.intervalOptions)
                    ChoiceChip(
                      label: Text(S3SyncService.intervalLabel(mins)),
                      selected: _config.syncIntervalMinutes == mins,
                      onSelected: (sel) {
                        if (sel) _setInterval(mins);
                      },
                    ),
                ],
              ),
              const SizedBox(height: 12),

              if (_config.lastBackupAt != null || (_config.lastBackupStatus?.isNotEmpty ?? false)) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerHighest.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(LucideIcons.history, size: 16, color: tokens.muted),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _config.lastBackupAt != null
                              ? 'Last sync: ${DateFormat('yyyy-MM-dd HH:mm').format(_config.lastBackupAt!)} (${_config.lastBackupStatus ?? "Success"})'
                              : 'Status: ${_config.lastBackupStatus}',
                          style: theme.textTheme.bodySmall?.copyWith(color: tokens.muted),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const Divider(height: 32),

              // Manual Actions Section
              Text(
                'BACKUP & RESTORE',
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                  color: tokens.muted,
                ),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: FilledButton.tonalIcon(
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _backingUp ? null : _backupNow,
                      icon: _backingUp
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(LucideIcons.cloudUpload, size: 18),
                      label: Text(_backingUp ? 'Uploading...' : 'Backup Now'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _pulling ? null : _pullNow,
                      icon: _pulling
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(LucideIcons.cloudDownload, size: 18),
                      label: Text(_pulling ? 'Pulling...' : 'Pull Now'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _loadingBackups ? null : _fetchBackups,
                  icon: _loadingBackups
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(LucideIcons.listFilter, size: 18),
                  label: Text(_loadingBackups ? 'Loading...' : 'List S3 Backups'),
                ),
              ),

              if (_restoreError != null) ...[
                const SizedBox(height: 12),
                Text(
                  _restoreError!,
                  style: theme.textTheme.bodySmall?.copyWith(color: colors.error),
                ),
              ],

              if (_backups != null) ...[
                const SizedBox(height: 16),
                Text(
                  'AVAILABLE S3 BACKUPS (${_backups!.length})',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                    color: tokens.muted,
                  ),
                ),
                const SizedBox(height: 8),
                if (_backups!.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: Text(
                        'No backups found in bucket folder.',
                        style: theme.textTheme.bodySmall?.copyWith(color: tokens.muted),
                      ),
                    ),
                  )
                else
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.4)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _backups!.length,
                      separatorBuilder: (_, __) => Divider(
                        height: 1,
                        color: colors.outlineVariant.withValues(alpha: 0.3),
                      ),
                      itemBuilder: (ctx, i) {
                        final item = _backups![i];
                        final dateStr = item.lastModified != null
                            ? DateFormat('yyyy-MM-dd HH:mm').format(item.lastModified!.toLocal())
                            : '';
                        return ListTile(
                          dense: true,
                          leading: const Icon(LucideIcons.fileArchive, size: 22),
                          title: Text(
                            item.displayName,
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            '$dateStr  ·  ${item.formattedSize}',
                            style: TextStyle(fontSize: 11, color: tokens.muted),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(LucideIcons.download, size: 18),
                                tooltip: 'Restore this backup',
                                onPressed: () => _promptRestore(item),
                              ),
                              IconButton(
                                icon: Icon(
                                  LucideIcons.trash2,
                                  size: 18,
                                  color: colors.error.withValues(alpha: 0.8),
                                ),
                                tooltip: 'Delete from S3',
                                onPressed: () => _deleteBackup(item),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
