import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:soulstate/core/database/local_store.dart';
import 'package:soulstate/features/habits/data/category.dart';
import 'package:soulstate/features/habits/data/completion.dart';
import 'package:soulstate/features/habits/data/habit.dart';
import 'package:soulstate/features/habits/state/habits_controller.dart';
import 'package:soulstate/features/meals/data/meal_entry.dart';
import 'package:soulstate/features/money/data/money_transaction.dart';
import 'package:soulstate/features/todos/data/todo.dart';
import 'package:soulstate/features/vault/services/vault_manager.dart';
import 'package:soulstate/services/backup_service.dart';
import 'package:soulstate/services/s3_service.dart';
import 'package:soulstate/services/s3_sync_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('s3_sync_test');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (MethodCall methodCall) async => tempDir.path,
    );
    Hive.init(tempDir.path);
    await LocalStore.init();
  });

  tearDown(() async {
    await Hive.close();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  test('Pulling backup from S3 on a new device populates habits, todos, money, and meals without duplication', () async {
    final controller = HabitsController();

    // Simulate Device A backup payload
    final habitA = Habit(
      id: 'habit-1',
      name: 'Morning Run',
      color: const Color(0xFF4CAF50),
      order: 0,
      completions: {'2026-10-31': const Completion(date: '2026-10-31', count: 1)},
    );

    final todoA = Todo(
      id: 'todo-1',
      text: 'Buy groceries',
      date: '2026-10-31',
      createdAt: DateTime(2026, 10, 31, 9, 0),
    );

    final txA = MoneyTransaction(
      id: 'tx-1',
      amount: 45.50,
      kind: MoneyKind.expense,
      categoryId: 'food',
      at: DateTime(2026, 10, 31, 10, 0),
      label: 'Supermarket',
    );

    final mealA = MealEntry(
      id: 'meal-1',
      name: 'Oatmeal & Fruit',
      type: MealType.breakfast,
      isHealthy: true,
      dateTime: DateTime(2026, 10, 31, 8, 30),
      calories: 350,
    );

    final backupData = BackupData(
      habits: [habitA],
      notes: [],
      todos: [todoA],
      todoTags: [],
      categories: [Category(id: 'fitness', name: 'Fitness', color: const Color(0xFF4CAF50), order: 0)],
      moneyTransactions: [txA],
      meals: [mealA],
      skipped: 0,
    );

    // Apply backup data onto fresh controller (simulating Device B pull)
    final err = await controller.applyBackupData(backupData, replace: false);
    expect(err, isNull);

    // Verify all items are present
    expect(controller.habits.length, 1);
    expect(controller.habits.first.name, 'Morning Run');
    expect(controller.habits.first.completions.containsKey('2026-10-31'), isTrue);

    expect(LocalStore.readTodos().length, 1);
    expect(LocalStore.readTodos().first.text, 'Buy groceries');

    expect(LocalStore.readMoneyTransactions().length, 1);
    expect(LocalStore.readMoneyTransactions().first.label, 'Supermarket');

    expect(LocalStore.readMeals().length, 1);
    expect(LocalStore.readMeals().first.name, 'Oatmeal & Fruit');

    // Simulate pulling AGAIN (e.g. repeated sync or periodic S3 poll)
    final err2 = await controller.applyBackupData(backupData, replace: false);
    expect(err2, isNull);

    // Verify NO items were duplicated!
    expect(controller.habits.length, 1);
    expect(LocalStore.readTodos().length, 1);
    expect(LocalStore.readMoneyTransactions().length, 1);
    expect(LocalStore.readMeals().length, 1);
  });

  test('S3Config target and backup item sorting prioritizes backup.json', () {
    final items = [
      const S3BackupItem(key: 'vault/streak_backup_20261030.zip', lastModified: null, size: 100),
      const S3BackupItem(key: 'vault/backup.json', lastModified: null, size: 200),
      const S3BackupItem(key: 'vault/tasks.md', lastModified: null, size: 50),
    ];

    final latest = items.where((it) =>
        it.displayName == 'backup.json' ||
        it.displayName == 'backup.enc'
    ).firstOrNull ?? items.where((it) =>
        it.displayName.endsWith('.zip') ||
        it.displayName.startsWith('soulstate_backup_') ||
        it.displayName.startsWith('streak_backup_') ||
        it.displayName.endsWith('.json') ||
        it.displayName.endsWith('.enc')
    ).firstOrNull;

    expect(latest, isNotNull);
    expect(latest!.displayName, 'backup.json');
  });

  test('VaultManager writes markdown and backup.json after S3 restore', () async {
    final vaultDir = Directory('${tempDir.path}/vault');
    await vaultDir.create();

    final controller = HabitsController();
    final habit = Habit(
      id: 'h-1',
      name: 'Read 20 pages',
      color: const Color(0xFF2196F3),
      order: 0,
      completions: {'2026-10-31': const Completion(date: '2026-10-31', count: 1)},
    );

    final backupData = BackupData(
      habits: [habit],
      notes: [],
      todos: [Todo(id: 't-1', text: 'Workout', date: '2026-10-31', createdAt: DateTime(2026, 10, 31))],
      todoTags: [],
      categories: [],
      moneyTransactions: [MoneyTransaction(id: 'm-1', amount: 12.0, kind: MoneyKind.expense, categoryId: 'misc', at: DateTime(2026, 10, 31), label: 'Coffee')],
      meals: [MealEntry(id: 'meal-1', name: 'Salad', type: MealType.lunch, isHealthy: true, dateTime: DateTime(2026, 10, 31))],
      skipped: 0,
    );

    await controller.applyBackupData(backupData);
    await VaultManager.syncVault(vaultDir.path);

    expect(File('${vaultDir.path}/backup.json').existsSync(), isTrue);
    expect(File('${vaultDir.path}/tasks.md').existsSync(), isTrue);
    expect(File('${vaultDir.path}/meals.md').existsSync(), isTrue);
    expect(File('${vaultDir.path}/finances.md').existsSync(), isTrue);
    expect(File('${vaultDir.path}/habits/Read 20 pages.md').existsSync(), isTrue);

    final tasksContent = File('${vaultDir.path}/tasks.md').readAsStringSync();
    expect(tasksContent.contains('Workout'), isTrue);

    final mealsContent = File('${vaultDir.path}/meals.md').readAsStringSync();
    expect(mealsContent.contains('Salad'), isTrue);

    final financesContent = File('${vaultDir.path}/finances.md').readAsStringSync();
    expect(financesContent.contains('Coffee'), isTrue);
  });

  test('Deleting items and reopening vault does NOT resurrect deleted items', () async {
    final vaultDir = Directory('${tempDir.path}/live_vault');
    await vaultDir.create();
    await LocalStore.writeSetting('vaultFolder', vaultDir.path);

    final habits = HabitsController();
    final h1 = Habit(id: 'h-1', name: 'Exercise', color: const Color(0xFF4CAF50), order: 0);
    final h2 = Habit(id: 'h-2', name: 'Smoking (bad)', color: const Color(0xFFFF5722), order: 1);

    await LocalStore.writeHabit(h1);
    await LocalStore.writeHabit(h2);
    await habits.reload();
    expect(habits.habits.length, 2);

    final todo1 = Todo(id: 't-1', text: 'Task 1', date: '2026-10-31', createdAt: DateTime(2026, 10, 31));
    final todo2 = Todo(id: 't-2', text: 'Task 2 to delete', date: '2026-10-31', createdAt: DateTime(2026, 10, 31));
    await LocalStore.writeTodo(todo1);
    await LocalStore.writeTodo(todo2);

    await VaultManager.syncVault(vaultDir.path);

    expect(File('${vaultDir.path}/habits/Exercise.md').existsSync(), isTrue);
    expect(File('${vaultDir.path}/habits/Smoking (bad).md').existsSync(), isTrue);

    // Now delete h2 and todo2
    await habits.remove('h-2');
    await LocalStore.removeTodo('t-2');
    await VaultManager.syncVault(vaultDir.path);

    // Verify h2 markdown file is deleted from disk
    expect(File('${vaultDir.path}/habits/Smoking (bad).md').existsSync(), isFalse);
    expect(File('${vaultDir.path}/habits/Exercise.md').existsSync(), isTrue);

    // Now SIMULATE UNINSTALL: wipe all Hive boxes / LocalStore memory
    await LocalStore.wipeContent();
    expect(LocalStore.readHabits().isEmpty, isTrue);
    expect(LocalStore.readTodos().isEmpty, isTrue);

    // Reopen the existing vault (like a fresh reinstall pointing to the folder)
    final count = await VaultManager.importExistingVault(vaultDir.path);
    expect(count, greaterThan(0));

    final reopenedHabits = LocalStore.readHabits();
    final reopenedTodos = LocalStore.readTodos();

    // Verify deleted habit and deleted todo are GONE, NOT resurrected!
    expect(reopenedHabits.containsKey('h-2'), isFalse);
    expect(reopenedHabits.values.any((h) => h.name.contains('Smoking')), isFalse);
    expect(reopenedHabits.containsKey('h-1'), isTrue);
    expect(reopenedHabits.length, 1);

    expect(reopenedTodos.any((t) => t.id == 't-2'), isFalse);
    expect(reopenedTodos.any((t) => t.text.contains('Task 2')), isFalse);
    expect(reopenedTodos.any((t) => t.id == 't-1'), isTrue);
    expect(reopenedTodos.length, 1);
  });

  test('Older backup pull does NOT resurrect items deleted locally', () async {
    final habits = HabitsController();
    await habits.reload();

    final h1 = Habit(id: 'h-keep', name: 'Reading', color: const Color(0xFF4CAF50), order: 0);
    final h2 = Habit(id: 'h-del', name: 'Junk Food', color: const Color(0xFFFF5722), order: 1);

    await LocalStore.writeHabit(h1);
    await LocalStore.writeHabit(h2);
    await habits.reload();

    // Create an older backup snapshot that contains both h1 and h2
    final oldSnapshotTime = DateTime.now().subtract(const Duration(minutes: 10));
    final oldData = BackupData(
      habits: [h1, h2],
      notes: [],
      todos: [],
      todoTags: [],
      categories: [],
      skipped: 0,
      exportedAt: oldSnapshotTime,
    );

    // Delete h2 locally NOW
    await habits.remove('h-del');
    expect(habits.habits.any((h) => h.id == 'h-del'), isFalse);
    expect(LocalStore.deletedAt('h-del'), isNotNull);

    // Now simulate S3 pulling that older backup into our habits controller
    await habits.applyBackupData(oldData, replace: false);

    // Verify h-del is STILL deleted, NOT resurrected!
    expect(habits.habits.any((h) => h.id == 'h-del'), isFalse);
    expect(LocalStore.habit('h-del'), isNull);
    expect(habits.habits.any((h) => h.id == 'h-keep'), isTrue);
  });

  test('S3Config enabled defaults to false and isSyncActive requires both enabled and configured', () async {
    // Fresh install state
    final freshConfig = S3Service.loadConfig();
    expect(freshConfig.enabled, isFalse);
    expect(freshConfig.isConfigured, isFalse);
    expect(freshConfig.isSyncActive, isFalse);
    expect(S3SyncService.subtitle(), 'Disabled');

    // Enabled but unconfigured
    await S3Service.saveConfig(freshConfig.copyWith(enabled: true));
    final enabledConfig = S3Service.loadConfig();
    expect(enabledConfig.enabled, isTrue);
    expect(enabledConfig.isConfigured, isFalse);
    expect(enabledConfig.isSyncActive, isFalse);
    expect(S3SyncService.subtitle(), 'Not configured');

    // Configured but disabled
    final configuredDisabled = enabledConfig.copyWith(
      enabled: false,
      bucket: 'test-bucket',
      accessKey: 'AKIA123',
      secretKey: 'SECRET123',
      syncIntervalMinutes: 5,
    );
    await S3Service.saveConfig(configuredDisabled);
    final loadedDisabled = S3Service.loadConfig();
    expect(loadedDisabled.enabled, isFalse);
    expect(loadedDisabled.isConfigured, isTrue);
    expect(loadedDisabled.isSyncActive, isFalse);
    expect(S3SyncService.subtitle(), 'Disabled');

    // Both configured and enabled
    await S3Service.saveConfig(loadedDisabled.copyWith(enabled: true));
    final loadedActive = S3Service.loadConfig();
    expect(loadedActive.enabled, isTrue);
    expect(loadedActive.isConfigured, isTrue);
    expect(loadedActive.isSyncActive, isTrue);
    expect(S3SyncService.subtitle(), contains('Every 5 min'));
  });

  test('S3SyncService supports manual only and interval options (1m, 5m, 10m, 30m, 1h, 1d)', () {
    expect(S3SyncService.intervalOptions, [0, 1, 5, 10, 30, 60, 1440]);
    expect(S3SyncService.intervalLabel(0), 'Manual only');
    expect(S3SyncService.intervalLabel(1), 'Every 1 min');
    expect(S3SyncService.intervalLabel(5), 'Every 5 min');
    expect(S3SyncService.intervalLabel(10), 'Every 10 min');
    expect(S3SyncService.intervalLabel(30), 'Every 30 min');
    expect(S3SyncService.intervalLabel(60), 'Every 1 hour');
    expect(S3SyncService.intervalLabel(1440), 'Every 1 day');
  });
}
