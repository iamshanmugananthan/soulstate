import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:soulstate/app/home_shell.dart';
import 'package:soulstate/app/theme/app_tokens.dart';
import 'package:soulstate/core/i18n/l10n.dart';
import 'package:soulstate/core/utils/app_snackbar.dart';
import 'package:soulstate/features/settings/settings_actions.dart';
import 'package:soulstate/features/settings/state/settings_controller.dart';
import 'package:soulstate/features/vault/services/vault_manager.dart';
import 'package:soulstate/services/backup_service.dart';

class VaultSetupPage extends StatefulWidget {
  const VaultSetupPage({super.key});

  @override
  State<VaultSetupPage> createState() => _VaultSetupPageState();
}

class _VaultSetupPageState extends State<VaultSetupPage> {
  bool _busy = false;

  Future<void> _handleVault(bool isNew) async {
    if (_busy) return;
    final l10n = context.l10n;

    // Ensure storage access first so files in external folders like Movies can be read and written
    final hasAccess = await BackupService.ensureStorageAccess();
    if (!hasAccess && mounted) {
      final shouldOpenSettings = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: const Text('All Files Access Required'),
          content: const Text(
            'To store, read, and sync your vault directly on your device storage (such as in Movies, Documents, or Downloads), Soul State requires "All files access" permission.\n\nPlease enable "Allow access to manage all files" for Soul State in Settings.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Open Settings'),
            ),
          ],
        ),
      );
      if (shouldOpenSettings == true) {
        await openAppSettings();
      }
      return;
    }

    final dialogTitle = isNew ? l10n.dialog_select_new_vault : l10n.dialog_select_existing_vault;

    final picked = await FilePicker.getDirectoryPath(
      dialogTitle: dialogTitle,
    );
    if (picked == null || !mounted) return;

    setState(() => _busy = true);
    try {
      final settings = context.read<SettingsController>();
      final imported = await VaultManager.setupVault(
        settings: settings,
        path: picked,
        isNew: isNew,
      );

      if (!mounted) return;
      await SettingsActions.reloadAll(context);
      if (!mounted) return;

      AppSnackbar.success(
        context,
        isNew
            ? l10n.vault_created_success
            : (imported > 0
                ? l10n.vault_habits_loaded(imported)
                : l10n.vault_connected),
      );
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeShell()),
        (_) => false,
      );
    } catch (e) {
      if (mounted) {
        AppSnackbar.error(context, l10n.vault_failed('$e'));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final tokens = context.tokens;

    return Scaffold(
      backgroundColor: scheme.surface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: scheme.primary.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        LucideIcons.vault,
                        size: 42,
                        color: scheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    context.l10n.vault_title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      color: scheme.onSurface,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    context.l10n.vault_desc,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: tokens.muted,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 36),
                  if (_busy)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else ...[
                    _VaultOptionCard(
                      icon: LucideIcons.folderOpen,
                      title: context.l10n.vault_open_title,
                      subtitle: context.l10n.vault_open_desc,
                      buttonLabel: context.l10n.vault_open_button,
                      onTap: () => _handleVault(false),
                    ),
                    const SizedBox(height: 18),
                    _VaultOptionCard(
                      icon: LucideIcons.folderPlus,
                      title: context.l10n.vault_create_title,
                      subtitle: context.l10n.vault_create_desc,
                      buttonLabel: context.l10n.vault_create_button,
                      primary: true,
                      onTap: () => _handleVault(true),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _VaultOptionCard extends StatelessWidget {
  const _VaultOptionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
    required this.onTap,
    this.primary = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String buttonLabel;
  final VoidCallback onTap;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final tokens = context.tokens;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: primary ? scheme.primary.withValues(alpha: 0.4) : scheme.outlineVariant.withValues(alpha: 0.35),
          width: primary ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: primary
                      ? scheme.primary.withValues(alpha: 0.15)
                      : scheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  size: 22,
                  color: primary ? scheme.primary : scheme.onSurface,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: scheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 13.5,
              color: tokens.muted,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: FilledButton.tonal(
              onPressed: onTap,
              style: FilledButton.styleFrom(
                backgroundColor: primary ? scheme.primary : scheme.surfaceContainerHighest,
                foregroundColor: primary ? scheme.onPrimary : scheme.onSurfaceVariant,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                buttonLabel,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
