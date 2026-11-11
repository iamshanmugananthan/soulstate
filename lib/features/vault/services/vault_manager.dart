import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:soulstate/core/database/local_store.dart';
import 'package:soulstate/core/extensions/date_extensions.dart';
import 'package:soulstate/core/utils/app_dirs.dart';
import 'package:soulstate/features/habits/data/category.dart';
import 'package:soulstate/features/habits/data/completion.dart';
import 'package:soulstate/features/habits/data/habit.dart';
import 'package:soulstate/features/habits/data/habit_note.dart';
import 'package:soulstate/features/habits/data/reminder.dart';
import 'package:soulstate/features/habits/data/substep.dart';
import 'package:soulstate/features/meals/data/meal_entry.dart';
import 'package:soulstate/features/money/data/money_transaction.dart';
import 'package:soulstate/features/settings/state/settings_controller.dart';
import 'package:soulstate/features/todos/data/todo.dart';
import 'package:soulstate/services/backup_archive.dart';
import 'package:soulstate/services/backup_service.dart';
import 'package:soulstate/services/s3_service.dart';
import 'package:soulstate/services/vault_writer.dart';
import 'package:uuid/uuid.dart';

class VaultManager {
  const VaultManager._();

  /// Recursively looks for backup files (.json or .zip) inside the selected folder
  /// and its subdirectories up to [maxDepth].
  static List<File> findBackups(Directory root, {int maxDepth = 5}) {
    if (!root.existsSync()) return const [];

    final candidates = <File>[];

    void scan(Directory dir, int depth) {
      if (depth > maxDepth) return;
      try {
        if (!dir.existsSync()) return;
        for (final entity in dir.listSync()) {
          if (entity is File) {
            final name = entity.uri.pathSegments.last.toLowerCase();
            if (name.endsWith('.json') || name.endsWith('.zip')) {
              // Ignore part files, s3.json, or internal hidden files
              if (!name.endsWith('.part') && !name.startsWith('.') && name != 's3.json') {
                try {
                  if (entity.lengthSync() > 0) {
                    candidates.add(entity);
                  }
                } catch (_) {}
              }
            }
          } else if (entity is Directory) {
            final dirName = entity.uri.pathSegments.where((s) => s.isNotEmpty).lastOrNull ?? '';
            if (!dirName.startsWith('.') &&
                dirName != 'Android' &&
                dirName != 'node_modules' &&
                dirName != 'cache') {
              scan(entity, depth + 1);
            }
          }
        }
      } catch (e) {
        debugPrint('Error scanning dir ${dir.path}: $e');
      }
    }

    scan(root, 0);

    // Sort: files starting with 'soulstate_backup_', 'streak_backup_', or named 'backup.json' first,
    // then by non-empty size, then by last modified descending
    candidates.sort((a, b) {
      final nameA = a.uri.pathSegments.last.toLowerCase();
      final nameB = b.uri.pathSegments.last.toLowerCase();
      final isPrefA = nameA.startsWith('soulstate_backup_') || nameA.startsWith('streak_backup_') || nameA == 'backup.json';
      final isPrefB = nameB.startsWith('soulstate_backup_') || nameB.startsWith('streak_backup_') || nameB == 'backup.json';

      if (isPrefA && !isPrefB) return -1;
      if (!isPrefA && isPrefB) return 1;

      try {
        final modA = a.lastModifiedSync();
        final modB = b.lastModifiedSync();
        return modB.compareTo(modA);
      } catch (_) {
        return nameB.compareTo(nameA);
      }
    });

    return candidates;
  }

  /// Parses markdown files (tasks.md, habits/*.md, meals.md, finances.md, notes.md)
  /// directly from an existing vault directory.
  static Future<int> importMarkdownVault(Directory root) async {
    if (!root.existsSync()) return 0;
    var importedCount = 0;
    const uuid = Uuid();

    // 1. Tasks: tasks.md (or SoulState/tasks.md)
    final tasksCandidates = [
      File('${root.path}/tasks.md'),
      File('${root.path}/$vaultFolder/tasks.md'),
    ];
    for (final tasksFile in tasksCandidates) {
      if (tasksFile.existsSync()) {
        try {
          final lines = await tasksFile.readAsLines();
          Todo? currentTodo;
          final currentSteps = <TodoStep>[];

          Future<void> flushCurrentTodo() async {
            if (currentTodo != null) {
              final existingTodos = LocalStore.readTodos();
              final isDup = existingTodos.any((t) =>
                  t.text.trim().toLowerCase() == currentTodo!.text.trim().toLowerCase() &&
                  (t.date == currentTodo!.date ||
                   (t.date.isNotEmpty &&
                    currentTodo!.date.isNotEmpty &&
                    parseDayKey(t.date).epochDay == parseDayKey(currentTodo!.date).epochDay)));
              if (!isDup) {
                final todoWithSteps = currentTodo!.copyWith(
                  steps: List.of(currentSteps),
                );
                await LocalStore.writeTodo(todoWithSteps);
                importedCount++;
              }
              currentTodo = null;
              currentSteps.clear();
            }
          }

          for (final line in lines) {
            final taskMatch = RegExp(r'^-\s*\[([ xX])\]\s*(.*)$').firstMatch(line);
            final stepMatch = RegExp(r'^\s{2,}-\s*\[([ xX])\]\s*(.*)$').firstMatch(line);

            if (stepMatch != null && currentTodo != null) {
              final stepDone = stepMatch.group(1)?.toLowerCase() == 'x';
              final stepText = (stepMatch.group(2) ?? '').trim();
              if (stepText.isNotEmpty) {
                currentSteps.add(TodoStep(
                  id: uuid.v4(),
                  text: stepText,
                  done: stepDone,
                ));
              }
            } else if (taskMatch != null) {
              await flushCurrentTodo();
              final done = taskMatch.group(1)?.toLowerCase() == 'x';
              var text = (taskMatch.group(2) ?? '').trim();

              // Parse (YYYY-MM-DD)
              String date = '';
              final dateMatch = RegExp(r'\(([0-9]{4}-[0-9]{2}-[0-9]{2})\)').firstMatch(text);
              if (dateMatch != null) {
                final parsed = DateTime.tryParse(dateMatch.group(1)!);
                date = parsed != null ? parsed.dayKey : dateMatch.group(1)!;
                text = text.replaceAll(dateMatch.group(0)!, '').trim();
              }

              // Parse ⏰ HH:MM
              int? minutes;
              final reminderMatch = RegExp(r'⏰\s*([0-9]{1,2}):([0-9]{2})').firstMatch(text);
              if (reminderMatch != null) {
                final h = int.tryParse(reminderMatch.group(1)!) ?? 0;
                final m = int.tryParse(reminderMatch.group(2)!) ?? 0;
                minutes = h * 60 + m;
                text = text.replaceAll(reminderMatch.group(0)!, '').trim();
              }

              currentTodo = Todo(
                id: uuid.v4(),
                text: text,
                createdAt: DateTime.now(),
                done: done,
                date: date,
                minutes: minutes,
              );
            }
          }
          await flushCurrentTodo();
        } catch (e) {
          debugPrint('Error reading tasks.md: $e');
        }
      }
    }

    // 2. Habits: habits/ and habits/archived/
    final habitDirs = [
      Directory('${root.path}/habits'),
      Directory('${root.path}/$vaultFolder/habits'),
    ];
    for (final habitsDir in habitDirs) {
      if (!habitsDir.existsSync()) continue;
      final habitFiles = <File>[];
      try {
        for (final entity in habitsDir.listSync(recursive: true)) {
          if (entity is File && entity.path.endsWith('.md')) {
            habitFiles.add(entity);
          }
        }
      } catch (e) {
        debugPrint('Error scanning habits dir: $e');
      }

      for (final file in habitFiles) {
        try {
          final content = await file.readAsString();
          if (!content.contains('---')) continue;
          final parts = content.split('---');
          if (parts.length < 3) continue;
          final frontmatter = parts[1];
          final body = parts.sublist(2).join('---');

          // Parse frontmatter
          String name = '';
          String id = '';
          HabitKind kind = HabitKind.positive;
          HabitInterval interval = HabitInterval.daily;
          List<int> scheduleWeekdays = const [];
          double target = 1;
          String unit = '';
          String categoryName = '';
          int colorValue = 0xFF5B67CA;
          DateTime? createdAt;
          DateTime? archivedAt;
          bool isArchived = file.path.contains('/archived/');

          for (final line in frontmatter.split('\n')) {
            final colon = line.indexOf(':');
            if (colon < 0) continue;
            final key = line.substring(0, colon).trim().toLowerCase();
            var val = line.substring(colon + 1).trim();
            if (val.startsWith('"') && val.endsWith('"') && val.length >= 2) {
              val = val.substring(1, val.length - 1).replaceAll(r'\"', '"');
            }

            switch (key) {
              case 'name':
                name = val;
                break;
              case 'id':
                id = val;
                break;
              case 'type':
                if (val == 'avoid') kind = HabitKind.negative;
                if (val == 'amount') kind = HabitKind.quantitative;
                break;
              case 'schedule':
                if (val.contains('weekdays')) {
                  interval = HabitInterval.weekdays;
                  scheduleWeekdays = [1, 2, 3, 4, 5];
                } else if (val.contains('every day')) {
                  interval = HabitInterval.daily;
                }
                break;
              case 'target':
                target = double.tryParse(val) ?? 1;
                break;
              case 'unit':
                unit = val;
                break;
              case 'category':
                categoryName = val;
                break;
              case 'color':
                if (val.startsWith('#')) {
                  final hex = val.substring(1);
                  final parsed = int.tryParse('0xFF$hex');
                  if (parsed != null) colorValue = parsed;
                }
                break;
              case 'created':
                createdAt = DateTime.tryParse(val);
                break;
              case 'archived':
                archivedAt = DateTime.tryParse(val);
                isArchived = true;
                break;
            }
          }

          if (name.isEmpty) {
            name = file.uri.pathSegments.last.replaceAll('.md', '');
          }
          if (id.isEmpty) {
            id = uuid.v4();
          }

          // Category
          String categoryId = '';
          if (categoryName.isNotEmpty) {
            final existing = LocalStore.readCategories();
            final match = existing
                .where((c) => c.name.toLowerCase() == categoryName.toLowerCase())
                .firstOrNull;
            if (match != null) {
              categoryId = match.id;
            } else {
              categoryId = uuid.v4();
              await LocalStore.writeCategory(
                Category(
                  id: categoryId,
                  name: categoryName,
                  color: const Color(0xFF5B67CA),
                ),
              );
            }
          }

          // Parse history table in body
          final completions = <String, Completion>{};
          final lines = body.split('\n');
          for (final line in lines) {
            final tableMatch = RegExp(
              r'^\|\s*([0-9]{4}-[0-9]{2}-[0-9]{2})\s*\|\s*[^|]*\|\s*([^|]+)\s*\|',
            ).firstMatch(line);
            if (tableMatch != null) {
              final rawDate = tableMatch.group(1)!;
              final rawVal = tableMatch.group(2)!.trim();
              final parsed = DateTime.tryParse(rawDate);
              final dayKey = parsed != null
                  ? '${parsed.day < 10 ? '0' : ''}${parsed.day}-${parsed.month < 10 ? '0' : ''}${parsed.month}-${parsed.year}'
                  : rawDate;
              final compactKey = rawDate.replaceAll('-', '');
              double count = 1;
              if (kind == HabitKind.quantitative) {
                final numMatch = RegExp(r'([0-9]+(?:\.[0-9]+)?)').firstMatch(rawVal);
                if (numMatch != null) {
                  count = double.tryParse(numMatch.group(1)!) ?? 1;
                }
              }
              completions[dayKey] = Completion(date: dayKey, count: count);
              completions[compactKey] = Completion(date: compactKey, count: count);
            }
          }

          // Parse substeps and reminders
          final substeps = <Substep>[];
          var inSteps = false;
          var inReminders = false;
          final reminders = <Reminder>[];

          for (final line in lines) {
            final trimmed = line.trim();
            if (trimmed.startsWith('## Steps')) {
              inSteps = true;
              inReminders = false;
              continue;
            } else if (trimmed.startsWith('## Reminders')) {
              inSteps = false;
              inReminders = true;
              continue;
            } else if (trimmed.startsWith('## ')) {
              inSteps = false;
              inReminders = false;
            }

            if (inSteps && trimmed.startsWith('- ')) {
              substeps.add(
                Substep(id: uuid.v4(), title: trimmed.substring(2).trim()),
              );
            } else if (inReminders && trimmed.startsWith('- ')) {
              final remMatch = RegExp(r'-\s*([0-9]{1,2}):([0-9]{2})').firstMatch(trimmed);
              if (remMatch != null) {
                final h = int.tryParse(remMatch.group(1)!) ?? 0;
                final m = int.tryParse(remMatch.group(2)!) ?? 0;
                reminders.add(Reminder(id: uuid.v4(), hour: h, minute: m, days: const []));
              }
            }
          }

          final habit = Habit(
            id: id,
            name: name,
            color: Color(colorValue),
            order: LocalStore.readHabits().length,
            kind: kind,
            perDayTarget: target,
            unitLabel: unit,
            category: categoryId,
            interval: interval,
            scheduleWeekdays: scheduleWeekdays,
            completions: completions,
            substeps: substeps,
            reminders: reminders,
            createdAt: createdAt ?? DateTime.now(),
            archivedAt: archivedAt ?? (isArchived ? DateTime.now() : null),
          );

          final existingHabits = LocalStore.readHabits();
          final existing = existingHabits[id] ??
              existingHabits.values.where(
                  (h) => h.name.trim().toLowerCase() == name.trim().toLowerCase()).firstOrNull;
          if (existing != null) {
            if (completions.isNotEmpty) {
              final merged = Map<String, Completion>.from(existing.completions);
              for (final entry in completions.entries) {
                merged.putIfAbsent(entry.key, () => entry.value);
              }
              await LocalStore.writeHabit(existing.copyWith(completions: merged));
            }
          } else {
            await LocalStore.writeHabit(habit);
            importedCount++;
          }
        } catch (e) {
          debugPrint('Error reading habit md file ${file.path}: $e');
        }
      }
    }

    // 3. Meals: meals.md
    final mealsCandidates = [
      File('${root.path}/meals.md'),
      File('${root.path}/$vaultFolder/meals.md'),
    ];
    for (final file in mealsCandidates) {
      if (file.existsSync()) {
        try {
          final lines = await file.readAsLines();
          for (final line in lines) {
            final match = RegExp(
              r'-\s*([0-9]{4}-[0-9]{2}-[0-9]{2})\s*·\s*.*?(\w+):\s*\*\*(.*?)\*\*(?:\s*\(([0-9]+)\s*kcal\))?\s*·\s*(.*)',
            ).firstMatch(line);
            if (match != null) {
              final dateStr = match.group(1)!;
              final typeStr = match.group(2)!.toLowerCase();
              final name = match.group(3)!.trim();
              final calories = match.group(4) != null ? int.tryParse(match.group(4)!) : null;
              final healthy = (match.group(5) ?? '').contains('Healthy');
              final date = DateTime.tryParse(dateStr) ?? DateTime.now();

              MealType type = MealType.lunch;
              if (typeStr.contains('breakfast')) {
                type = MealType.breakfast;
              } else if (typeStr.contains('dinner')) {
                type = MealType.dinner;
              } else if (typeStr.contains('snack')) {
                type = MealType.snack;
              }

              final existingMeals = LocalStore.readMeals();
              final isDup = existingMeals.any((m) =>
                  m.name.trim().toLowerCase() == name.trim().toLowerCase() &&
                  m.dateTime.year == date.year &&
                  m.dateTime.month == date.month &&
                  m.dateTime.day == date.day &&
                  m.type == type);
              if (!isDup) {
                final meal = MealEntry(
                  id: uuid.v4(),
                  name: name,
                  type: type,
                  isHealthy: healthy,
                  dateTime: date,
                  calories: calories,
                );
                await LocalStore.writeMeal(meal);
                importedCount++;
              }
            }
          }
        } catch (e) {
          debugPrint('Error importing meals.md: $e');
        }
      }
    }

    // 4. Finances: finances.md
    final financesCandidates = [
      File('${root.path}/finances.md'),
      File('${root.path}/$vaultFolder/finances.md'),
    ];
    for (final file in financesCandidates) {
      if (file.existsSync()) {
        try {
          final lines = await file.readAsLines();
          for (final line in lines) {
            final match = RegExp(
              r'^\|\s*([0-9]{4}-[0-9]{2}-[0-9]{2})\s*\|\s*(Expense|Income)\s*\|\s*([^|]+)\s*\|\s*([^|]+)\s*\|\s*(.*?)\s*\|',
            ).firstMatch(line);
            if (match != null) {
              final dateStr = match.group(1)!;
              final isExpense = match.group(2) == 'Expense';
              final catName = match.group(3)!.trim();
              final amountStr = match.group(4)!.replaceAll(',', '').trim();
              final note = match.group(5)!.trim();
              final amount = double.tryParse(amountStr) ?? 0.0;
              final date = DateTime.tryParse(dateStr) ?? DateTime.now();

              final existingTx = LocalStore.readMoneyTransactions();
              final isDup = existingTx.any((t) =>
                  (t.amount - amount).abs() < 0.001 &&
                  t.kind == (isExpense ? MoneyKind.expense : MoneyKind.income) &&
                  t.at.year == date.year &&
                  t.at.month == date.month &&
                  t.at.day == date.day &&
                  t.label.trim().toLowerCase() == catName.trim().toLowerCase());
              if (!isDup) {
                final tx = MoneyTransaction(
                  id: uuid.v4(),
                  kind: isExpense ? MoneyKind.expense : MoneyKind.income,
                  amount: amount,
                  categoryId: '',
                  label: catName,
                  at: date,
                  note: note,
                );
                await LocalStore.writeMoneyTransaction(tx);
                importedCount++;
              }
            }
          }
        } catch (e) {
          debugPrint('Error importing finances.md: $e');
        }
      }
    }

    // 5. Notes: notes.md
    final notesCandidates = [
      File('${root.path}/notes.md'),
      File('${root.path}/$vaultFolder/notes.md'),
    ];
    for (final file in notesCandidates) {
      if (file.existsSync()) {
        try {
          final content = await file.readAsString();
          final sections = content.split(RegExp(r'\n(?=## )'));
          final habits = LocalStore.readHabits();
          for (final sec in sections) {
            final trimmed = sec.trim();
            if (!trimmed.startsWith('## ')) continue;
            final headerLine = trimmed.split('\n').first.substring(3).trim();
            final body = trimmed.split('\n').sublist(1).join('\n').trim();
            if (body.isEmpty || body == '(empty)') continue;

            final parts = headerLine.split(' · ');
            final habitName = parts.first.trim();
            final dateStr = parts.length > 1 ? parts[1].trim() : '';

            // Find matching habit
            final matchHabit = habits.values
                .where((h) => h.name.toLowerCase() == habitName.toLowerCase())
                .firstOrNull;

            final existingNotes = LocalStore.readNotes();
            final isDup = existingNotes.any((n) =>
                n.habitId == (matchHabit?.id ?? '') &&
                n.date == dateStr.replaceAll('-', '') &&
                n.text.trim() == body);
            if (!isDup) {
              final note = HabitNote(
                id: uuid.v4(),
                habitId: matchHabit?.id ?? uuid.v4(),
                type: NoteType.note,
                text: body,
                date: dateStr.replaceAll('-', ''),
                createdAt: DateTime.tryParse(dateStr) ?? DateTime.now(),
              );
              await LocalStore.writeNote(note);
              importedCount++;
            }
          }
        } catch (e) {
          debugPrint('Error importing notes.md: $e');
        }
      }
    }

    return importedCount;
  }

  static Future<int> importExistingVault(String path) async {
    final isDir = FileSystemEntity.isDirectorySync(path);
    final isFile = FileSystemEntity.isFileSync(path);

    final dir = isDir ? Directory(path) : (isFile ? File(path).parent : Directory(path));
    if (!dir.existsSync()) {
      try {
        await dir.create(recursive: true);
      } catch (e) {
        debugPrint('Could not create directory $path: $e');
      }
    }

    // Clean up any lingering old archive files or legacy subfolders
    if (!isFile && dir.existsSync()) {
      try {
        final legacyDir = Directory('${dir.path}/$vaultFolder');
        if (legacyDir.existsSync()) {
          legacyDir.deleteSync(recursive: true);
        }
        for (final entity in dir.listSync()) {
          if (entity is File) {
            final name = entity.uri.pathSegments.last;
            if (name.startsWith('soulstate_backup_') ||
                name.startsWith('streak_backup_') ||
                name.startsWith('streak_safety_') ||
                name.endsWith('.part')) {
              entity.deleteSync();
            }
          }
        }
      } catch (_) {}
    }

    var count = 0;

    // 1. If canonical backup.json exists, IT IS THE EXACT REAL-TIME AUTHORITATIVE DATA!
    final canonicalFile = isFile ? File(path) : File('${dir.path}/backup.json');
    if (canonicalFile.existsSync() && canonicalFile.lengthSync() > 0 && canonicalFile.path.endsWith('.json')) {
      try {
        final content = await canonicalFile.readAsString();
        final data = BackupService.parse(content);
        for (final entry in data.deleted.entries) {
          await LocalStore.stampDeleted(entry.key, entry.value);
        }
        for (final entry in data.changes.entries) {
          await LocalStore.stampChange(entry.key, entry.value);
        }
        for (final habit in data.habits) {
          await LocalStore.writeHabit(habit);
          count++;
        }
        for (final category in data.categories) {
          await LocalStore.writeCategory(category);
        }
        for (final note in data.notes) {
          await LocalStore.writeNote(note);
        }
        for (final todo in data.todos) {
          await LocalStore.writeTodo(todo);
          count++;
        }
        for (final tag in data.todoTags) {
          await LocalStore.writeTodoTag(tag);
        }
        for (final meal in data.meals) {
          await LocalStore.writeMeal(meal);
          count++;
        }
        for (final moneyCat in data.moneyCategories) {
          await LocalStore.writeMoneyCategory(moneyCat);
        }
        for (final tx in data.moneyTransactions) {
          await LocalStore.writeMoneyTransaction(tx);
          count++;
        }
        debugPrint('Loaded existing vault data from canonical backup.json ($count items)');
        await _restoreS3ConfigFromPath(dir, isFile, path);
        return count;
      } catch (e) {
        debugPrint('Error inspecting canonical backup.json: $e');
      }
    }

    // 2. Only if backup.json was not present or had no data, fallback to archive backups or Markdown
    if (count == 0) {
      final backups = isFile ? [File(path)] : findBackups(dir);
      for (final file in backups) {
        try {
          if (!file.existsSync() || file.lengthSync() == 0) continue;
          BackupData? data;

          if (file.path.endsWith('.zip')) {
            final json = await BackupArchive.unpack(
              file.path,
              (await appDataDir()).path,
            );
            if (json != null && json.isNotEmpty) {
              data = BackupService.parse(json);
            }
          } else if (file.path.endsWith('.json')) {
            final content = await file.readAsString();
            data = BackupService.parse(content);
          }

          if (data != null && !data.isEmpty) {
            for (final habit in data.habits) {
              await LocalStore.writeHabit(habit);
              count++;
            }
            for (final category in data.categories) {
              await LocalStore.writeCategory(category);
            }
            for (final note in data.notes) {
              await LocalStore.writeNote(note);
            }
            for (final todo in data.todos) {
              await LocalStore.writeTodo(todo);
              count++;
            }
            for (final tag in data.todoTags) {
              await LocalStore.writeTodoTag(tag);
            }
            for (final meal in data.meals) {
              await LocalStore.writeMeal(meal);
              count++;
            }
            for (final moneyCat in data.moneyCategories) {
              await LocalStore.writeMoneyCategory(moneyCat);
            }
            for (final tx in data.moneyTransactions) {
              await LocalStore.writeMoneyTransaction(tx);
              count++;
            }

            if (count > 0) {
              debugPrint('Loaded existing vault data from: ${file.path} ($count items)');
              break;
            }
          }
        } catch (e) {
          debugPrint('Error inspecting file ${file.path}: $e');
        }
      }

      // If still no data from backup files, import directly from markdown files
      if (count == 0 && !isFile) {
        final mdCount = await importMarkdownVault(dir);
        count += mdCount;
        if (mdCount > 0) {
          debugPrint('Loaded existing vault data from markdown files ($mdCount items)');
        }
      }
    }

    // Also restore S3 configuration if present in the vault
    await _restoreS3ConfigFromPath(dir, isFile, path);

    return count;
  }

  static Future<void> _restoreS3ConfigFromPath(Directory dir, bool isFile, String path) async {
    final s3File = File(isFile ? '${File(path).parent.path}/s3.json' : '${dir.path}/s3.json');
    if (s3File.existsSync()) {
      try {
        final content = await s3File.readAsString();
        final map = jsonDecode(content);
        if (map is Map<String, dynamic>) {
          await S3Service.saveConfig(S3Config(
            enabled: map['enabled'] as bool? ?? false,
            endpoint: map['endpoint'] as String? ?? '',
            bucket: map['bucket'] as String? ?? '',
            region: map['region'] as String? ?? 'us-east-1',
            accessKey: map['accessKey'] as String? ?? '',
            secretKey: map['secretKey'] as String? ?? '',
            prefix: map['prefix'] as String? ?? '',
            syncIntervalMinutes: map['syncIntervalMinutes'] as int? ?? 0,
            encryptionPassword: map['encryptionPassword'] as String? ?? '',
          ));
          debugPrint('Loaded S3 config from vault: ${s3File.path}');
        }
      } catch (e) {
        debugPrint('Error loading s3.json from vault: $e');
      }
    }
  }

  static Future<int> setupVault({
    required SettingsController settings,
    required String path,
    required bool isNew,
  }) async {
    final dir = Directory(path);
    if (!dir.existsSync()) {
      try {
        await dir.create(recursive: true);
      } catch (e) {
        debugPrint('Error creating vault dir: $e');
      }
    }

    var imported = 0;
    if (!isNew) {
      imported = await importExistingVault(path);
    }

    // Freshly reload habits and todos from LocalStore to ensure memory matches disk
    await LocalStore.reloadHabits();
    await LocalStore.reloadTodos();

    await syncVault(path);

    await settings.setVaultFolder(path);
    await settings.setAutoBackupFolder(path);
    await settings.setAutoBackup(0);
    await settings.setAutoSync(true);
    await settings.completeOnboarding();

    return imported;
  }

  static bool _syncing = false;
  static bool _syncAgain = false;

  static Future<void> syncCurrentVault() async {
    final folder = LocalStore.setting('vaultFolder', '');
    if (folder.isNotEmpty) {
      await syncVault(folder);
    }
  }

  static Future<void> syncVault(String path) async {
    if (path.isEmpty) return;
    if (_syncing) {
      _syncAgain = true;
      return;
    }
    _syncing = true;
    try {
      do {
        _syncAgain = false;
        await _doSyncVault(path);
      } while (_syncAgain);
    } finally {
      _syncing = false;
    }
  }

  static Future<void> _doSyncVault(String path) async {
    final dir = Directory(path);
    if (!dir.existsSync()) {
      try {
        dir.createSync(recursive: true);
      } catch (e) {
        debugPrint('Could not create vault dir: $e');
        return;
      }
    }

    final habits = LocalStore.readHabits().values.toList();
    final categories = LocalStore.readCategories();
    final notes = LocalStore.readNotes();
    final todos = LocalStore.readTodos();
    final meals = LocalStore.readMeals();
    final transactions = LocalStore.readMoneyTransactions();
    final moneyCategories = LocalStore.readMoneyCategories();

    try {
      await VaultWriter.write(
        dir,
        habits: habits,
        categories: categories,
        notes: notes,
        todos: todos,
        meals: meals,
        transactions: transactions,
        moneyCategories: moneyCategories,
      );
    } catch (e) {
      debugPrint('Could not write vault markdown: $e');
    }

    try {
      // Maintain a canonical backup.json in the vault folder for easy inspection
      final payload = BackupService.createPayload(habits);
      final json = const JsonEncoder.withIndent('  ').convert(payload);
      final backupJsonFile = File('${dir.path}/backup.json');
      await backupJsonFile.writeAsString(json, flush: true);

      // Save S3 configuration into the vault so it travels with the vault folder
      final s3Config = S3Service.loadConfig();
      if (s3Config.isConfigured) {
        final s3File = File('${dir.path}/s3.json');
        final s3Map = {
          'enabled': s3Config.enabled,
          'endpoint': s3Config.endpoint,
          'bucket': s3Config.bucket,
          'region': s3Config.region,
          'accessKey': s3Config.accessKey,
          'secretKey': s3Config.secretKey,
          'prefix': s3Config.prefix,
          'syncIntervalMinutes': s3Config.syncIntervalMinutes,
          'encryptionPassword': s3Config.encryptionPassword,
        };
        await s3File.writeAsString(
          const JsonEncoder.withIndent('  ').convert(s3Map),
          flush: true,
        );
      }

      // Clean up any lingering streak_backup_*, streak_safety_*, or .part archive files
      try {
        final entities = dir.listSync();
        for (final entity in entities) {
          if (entity is File) {
            final name = entity.uri.pathSegments.last;
            if (name.startsWith('soulstate_backup_') ||
                name.startsWith('streak_backup_') ||
                name.startsWith('streak_safety_') ||
                name.endsWith('.part')) {
              try {
                entity.deleteSync();
              } catch (_) {}
            }
          }
        }
        final legacyDir = Directory('${dir.path}/$vaultFolder');
        if (legacyDir.existsSync()) {
          legacyDir.deleteSync(recursive: true);
        }
      } catch (_) {}

      // Track mutation timestamp for intelligent S3 sync resolution
      await LocalStore.writeSetting('lastLocalMutationAt', DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      debugPrint('Could not write vault backup JSON / S3 config: $e');
    }
  }
}
