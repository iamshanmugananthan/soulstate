import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:soulstate/core/utils/app_dirs.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:soulstate/core/database/local_store.dart';
import 'package:soulstate/services/backup_archive.dart';
import 'package:soulstate/services/backup_crypto.dart';
import 'package:soulstate/services/s3_service.dart';
import 'package:soulstate/features/habits/data/category.dart';
import 'package:soulstate/features/habits/data/habit.dart';
import 'package:soulstate/features/habits/data/habit_note.dart';
import 'package:soulstate/features/meals/data/meal_entry.dart';
import 'package:soulstate/features/money/data/money_category.dart';
import 'package:soulstate/features/money/data/money_transaction.dart';
import 'package:soulstate/features/todos/data/todo.dart';
import 'package:soulstate/features/todos/data/todo_tag.dart';
import 'package:soulstate/services/vault_writer.dart';

const _kBackupVersion = 2;
const _kAutoBackupKeep = 5;
const _kAutoArchiveKeep = 3;
const _kSafetyKeep = 3;

class BackupData {
  const BackupData({
    required this.habits,
    required this.notes,
    required this.todos,
    required this.todoTags,
    required this.categories,
    required this.skipped,
    this.moneyCategories = const [],
    this.moneyTransactions = const [],
    this.meals = const [],
    this.exportedAt,
    this.settings = const {},
    this.device = '',
    this.changes = const {},
    this.deleted = const {},
    this.cleared = const {},
  });

  final List<Habit> habits;
  final List<HabitNote> notes;
  final List<Todo> todos;
  final List<TodoTag> todoTags;
  final List<Category> categories;
  final List<MoneyCategory> moneyCategories;
  final List<MoneyTransaction> moneyTransactions;
  final List<MealEntry> meals;
  final int skipped;
  final DateTime? exportedAt;
  final Map<String, Object?> settings;
  final String device;
  final Map<String, int> changes;
  final Map<String, int> deleted;
  final Map<String, int> cleared;

  bool get isEmpty =>
      habits.isEmpty &&
      notes.isEmpty &&
      todos.isEmpty &&
      moneyTransactions.isEmpty &&
      meals.isEmpty;
}

class BackupService {
  const BackupService._();

  static Map<String, Object?> createPayload([List<Habit>? habits]) =>
      _payload(habits ?? LocalStore.readHabits().values.toList());

  static Map<String, Object?> _payload(List<Habit> habits) => {
        'app': 'soulstate',
        'version': _kBackupVersion,
        'exportedAt': DateTime.now().toIso8601String(),
        'device': LocalStore.deviceId,
        'changes': LocalStore.changes,
        'deleted': LocalStore.deleted,
        'cleared': LocalStore.cleared,
        'habits': habits.map((h) => h.toMap()).toList(),
        'categories':
            LocalStore.readCategories().map((c) => c.toMap()).toList(),
        'notes': LocalStore.readNotes().map((n) => n.toMap()).toList(),
        'todos': LocalStore.readTodos().map((t) => t.toMap()).toList(),
        'todoTags': LocalStore.readTodoTags().map((t) => t.toMap()).toList(),
        'moneyCategories':
            LocalStore.readMoneyCategories().map((c) => c.toMap()).toList(),
        'moneyTransactions': LocalStore.readMoneyTransactions()
            .map((t) => t.toMap())
            .toList(),
        'meals': LocalStore.readMeals().map((m) => m.toMap()).toList(),
        'settings': {
          for (final key in backupSettingKeys)
            if (LocalStore.setting<Object?>(key, null) case final value?)
              key: value,
        },
      };

  static bool _hasContent(List<Habit> habits) =>
      habits.isNotEmpty ||
      LocalStore.readNotes().isNotEmpty ||
      LocalStore.readTodos().isNotEmpty ||
      LocalStore.readMoneyTransactions().isNotEmpty ||
      LocalStore.readMeals().isNotEmpty;

  static Future<void> safetyCopy() async {
    try {
      final habits = LocalStore.readHabits().values.toList();
      if (!_hasContent(habits)) return;
      final dir = await defaultBackupDir();
      if (dir == null) return;
      if (!dir.existsSync()) await dir.create(recursive: true);
      final stamp = DateFormat('yyyy-MM-dd_HH-mm-ss').format(DateTime.now());
      final target = '${dir.path}/soulstate_safety_$stamp.zip';
      await _settle(File('$target.part'), target, (part) async {
        await BackupArchive.pack(_payload(habits), part.path);
      });
      _prune(dir, 'soulstate_safety_', '.zip', _kSafetyKeep);
      _prune(dir, 'streak_safety_', '.zip', _kSafetyKeep);
    } catch (e) {
      debugPrint('Safety copy failed: $e');
    }
  }

  static Future<Directory?> defaultBackupDir() async {
    final root = Platform.isAndroid
        ? await getExternalStorageDirectory()
        : await appDataDir();
    if (root == null) return null;
    return Directory('${root.path}/backups');
  }

  static Future<bool> ensureStorageAccess() async {
    if (!Platform.isAndroid) return true;
    if (await Permission.manageExternalStorage.isGranted) return true;
    final manage = await Permission.manageExternalStorage.request();
    if (manage.isGranted || await Permission.manageExternalStorage.isGranted) {
      return true;
    }
    return false;
  }

  static Future<String?> pickBackupFolder() async {
    final path = await FilePicker.getDirectoryPath();
    if (path == null) return null;
    try {
      final probe = File('$path/.soulstate_write_test');
      await probe.writeAsString('ok');
      await probe.delete();
    } catch (_) {
      return '';
    }
    return path;
  }

  static Future<String?> runAuto({
    String folder = '',
    bool readable = true,
    bool archive = true,
  }) async {
    try {
      final habits = LocalStore.readHabits().values.toList();
      if (!_hasContent(habits)) return null;
      final dir = folder.isEmpty ? await defaultBackupDir() : Directory(folder);
      if (dir == null) return null;
      if (!dir.existsSync()) await dir.create(recursive: true);

      final stamp = DateFormat('yyyy-MM-dd_HH-mm-ss').format(DateTime.now());
      final base = '${dir.path}/soulstate_backup_${stamp}_${LocalStore.deviceId}';
      final payload = _payload(habits);
      final json = await Isolate.run(
        () => const JsonEncoder.withIndent('  ').convert(payload),
      );
      await _settle(File('$base.json.part'), '$base.json', (part) async {
        await part.writeAsString(json, flush: true);
      });
      if (archive) {
        await _settle(File('$base.zip.part'), '$base.zip', (part) async {
          await BackupArchive.pack(payload, part.path);
        });
      }

      if (readable) {
        try {
          final vault = LocalStore.setting('vaultFolder', '');
          final targetDir = (vault.isNotEmpty && vault == dir.path)
              ? dir
              : Directory('${dir.path}/$vaultFolder');
          await VaultWriter.write(
            targetDir,
            habits: habits,
            categories: LocalStore.readCategories(),
            notes: LocalStore.readNotes(),
            todos: LocalStore.readTodos(),
            meals: LocalStore.readMeals(),
            transactions: LocalStore.readMoneyTransactions(),
            moneyCategories: LocalStore.readMoneyCategories(),
          );
        } catch (e) {
          debugPrint('Could not write the readable copy: $e');
        }
      }

      _prune(dir, 'soulstate_backup_', '.json', _kAutoBackupKeep);
      _prune(dir, 'soulstate_backup_', '.zip', _kAutoArchiveKeep);
      _prune(dir, 'streak_backup_', '.json', _kAutoBackupKeep);
      _prune(dir, 'streak_backup_', '.zip', _kAutoArchiveKeep);
      return '$base.json';
    } catch (e) {
      debugPrint('Automatic backup failed: $e');
      return null;
    }
  }

  static Future<void> _settle(
    File part,
    String target,
    Future<void> Function(File part) write,
  ) async {
    try {
      await write(part);
      final targetFile = File(target);
      if (targetFile.existsSync()) {
        try {
          targetFile.deleteSync();
        } catch (_) {}
      }
      try {
        await part.rename(target);
      } catch (_) {
        if (part.existsSync()) {
          await part.copy(target);
          try {
            part.deleteSync();
          } catch (_) {}
        }
      }
    } finally {
      if (part.existsSync()) {
        try {
          part.deleteSync();
        } catch (_) {}
      }
    }
  }

  static void _prune(Directory dir, String prefix, String extension, int keep) {
    const stampLength = 19;
    final plain = prefix.length + stampLength + extension.length;
    final own = '_${LocalStore.deviceId}$extension';
    final files = dir
        .listSync()
        .whereType<File>()
        .where((f) {
          final name = f.uri.pathSegments.last;
          return name.startsWith(prefix) &&
              name.endsWith(extension) &&
              (name.length == plain || name.endsWith(own));
        })
        .toList()
      ..sort((a, b) => b.path.compareTo(a.path));
    final days = <String>{};
    for (final (index, file) in files.indexed) {
      final name = file.uri.pathSegments.last;
      final day = name.substring(prefix.length, prefix.length + 10);
      final daily = days.length < keep && days.add(day);
      if (index < keep || daily) continue;
      try {
        file.deleteSync();
      } catch (_) {}
    }
  }

  static Future<bool> export(List<Habit> habits, {Rect? origin}) async {
    final stamp = DateFormat('yyyy-MM-dd_HH-mm-ss').format(DateTime.now());
    final name = 'soulstate_backup_$stamp.zip';
    final dir = await Directory.systemTemp.createTemp('soulstate_backup');
    final zip = '${dir.path}/$name';
    await BackupArchive.pack(_payload(habits), zip);

    if (!isMobile) {
      final bytes = await File(zip).readAsBytes();
      final saved = await FilePicker.saveFile(
        dialogTitle: 'Save your Soul State backup',
        fileName: name,
        bytes: bytes,
        mimeType: 'application/zip',
      );
      return saved != null;
    }

    final result = await SharePlus.instance.share(
      ShareParams(
        files: [XFile(zip, mimeType: 'application/zip')],
        subject: 'Soul State backup',
        sharePositionOrigin: origin,
      ),
    );
    return result.status == ShareResultStatus.success ||
        result.status == ShareResultStatus.dismissed;
  }

  static Future<BackupData> read() async {
    final file = await FilePicker.pickFile(
      dialogTitle: 'Select a Soul State backup file',
      type: FileType.any,
    );
    if (file == null) {
      throw Exception('No file selected');
    }

    final path = file.path;
    if (path == null) throw Exception('Could not read the selected file');
    final List<int> head;
    try {
      head = await _head(path);
    } catch (e) {
      debugPrint('Could not read $path: $e');
      throw Exception('That file could not be read');
    }
    if (BackupCrypto.isEncrypted(head)) {
      final fileBytes = await File(path).readAsBytes();
      final config = S3Service.loadConfig();
      final pwd = config.encryptionPassword.trim();
      if (pwd.isEmpty) {
        throw Exception(
          'This backup is encrypted. Configure your encryption password in S3 Cloud Sync settings to decrypt.',
        );
      }
      final decrypted = BackupCrypto.decrypt(fileBytes, pwd);
      final isZip = decrypted.length >= 4 &&
          decrypted[0] == 0x50 &&
          decrypted[1] == 0x4B &&
          decrypted[2] == 0x03 &&
          decrypted[3] == 0x04;
      if (isZip) {
        final tempDir = await Directory.systemTemp.createTemp('enc_restore_');
        final tempFile = File('${tempDir.path}/decrypted.zip');
        await tempFile.writeAsBytes(decrypted);
        try {
          final json = await BackupArchive.unpack(
            tempFile.path,
            (await appDataDir()).path,
          );
          if (json != null) return parse(json);
        } finally {
          try {
            tempDir.deleteSync(recursive: true);
          } catch (_) {}
        }
      }
      return parse(utf8.decode(decrypted));
    }

    if (head.length >= 4 && head[0] == 0x50 && head[1] == 0x4B && head[2] == 0x03 && head[3] == 0x04) {
      final json = await BackupArchive.unpack(path, (await appDataDir()).path);
      if (json != null) return parse(json);
    }

    return parse(
      const Utf8Decoder(allowMalformed: true)
          .convert(await File(path).readAsBytes()),
    );
  }

  static Future<List<int>> _head(String path) async {
    final file = await File(path).open();
    try {
      return await file.read(16);
    } finally {
      await file.close();
    }
  }

  static BackupData parse(String raw) {
    dynamic decoded;
    try {
      decoded = json.decode(raw);
    } catch (_) {
      throw Exception('That file is not a valid backup');
    }

    final List<dynamic> entries;
    final Map<String, dynamic> root;
    if (decoded is List) {
      entries = decoded;
      root = const {};
    } else if (decoded is Map && decoded['habits'] is List) {
      entries = decoded['habits'] as List;
      root = Map<String, dynamic>.from(decoded);
    } else {
      throw Exception('Unrecognised backup format');
    }

    var skipped = 0;
    List<T> collect<T>(Object? source, T Function(Map<String, dynamic>) build) {
      if (source is! List) return <T>[];
      final out = <T>[];
      for (final raw in source) {
        if (raw is! Map) {
          skipped++;
          continue;
        }
        try {
          out.add(build(Map<String, dynamic>.from(raw)));
        } catch (_) {
          skipped++;
        }
      }
      return out;
    }

    final habits = collect(entries, Habit.fromMap);
    final data = BackupData(
      habits: habits,
      notes: collect(root['notes'], HabitNote.fromMap),
      todos: collect(root['todos'], Todo.fromMap),
      todoTags: collect(root['todoTags'], TodoTag.fromMap),
      categories: collect(root['categories'], Category.fromMap),
      moneyCategories: collect(root['moneyCategories'], MoneyCategory.fromMap),
      moneyTransactions: collect(
        root['moneyTransactions'],
        MoneyTransaction.fromMap,
      ),
      meals: collect(root['meals'], MealEntry.fromMap),
      skipped: skipped,
      exportedAt: DateTime.tryParse((root['exportedAt'] ?? '') as String),
      settings: root['settings'] is Map
          ? Map<String, Object?>.from(root['settings'] as Map)
          : const {},
      device: root['device'] is String ? root['device'] as String : '',
      changes: _stamps(root['changes']),
      deleted: _stamps(root['deleted']),
      cleared: _stamps(root['cleared']),
    );

    if (data.isEmpty && data.deleted.isEmpty) {
      throw Exception('No habits found in that file');
    }
    return data;
  }

  static Map<String, int> _stamps(Object? source) => source is Map
      ? {
          for (final entry in source.entries)
            if (entry.value is int) '${entry.key}': entry.value as int,
        }
      : const {};
}
