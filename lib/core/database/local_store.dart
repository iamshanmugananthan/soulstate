import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:soulstate/core/database/data_location.dart';
import 'package:soulstate/core/utils/app_dirs.dart';
import 'package:soulstate/features/habits/data/category.dart';
import 'package:soulstate/features/habits/data/habit.dart';
import 'package:soulstate/features/habits/data/habit_note.dart';
import 'package:soulstate/features/meals/data/meal_entry.dart';
import 'package:soulstate/features/money/data/money_category.dart';
import 'package:soulstate/features/money/data/money_transaction.dart';
import 'package:soulstate/features/todos/data/todo.dart';
import 'package:soulstate/features/todos/data/todo_tag.dart';

class LocalStore {
  const LocalStore._();

  static const _habitsBox = 'habits';
  static const _settingsBox = 'settings';
  static const _categoriesBox = 'categories';
  static const _notesBox = 'notes';
  static const _todosBox = 'todos';
  static const _todoTagsBox = 'todo_tags';
  static const _moneyTxBox = 'money_tx';
  static const _moneyCatsBox = 'money_cats';
  static const _mealsBox = 'meals';
  static const _changesKey = 'syncChanges';
  static const _deletedKey = 'syncDeleted';
  static const _clearedKey = 'syncCleared';
  static const _deviceKey = 'deviceId';
  static const _quietZone = #streakQuiet;
  static const _forgetAfter = Duration(days: 120);

  static late Box _habits;
  static late Box _settings;
  static late Box _categories;
  static late Box _notes;
  static late Box _todos;
  static late Box _todoTags;
  static late Box _moneyTx;
  static late Box _moneyCats;
  static late Box _meals;

  static int _writing = 0;
  static String _habitsStamp = '';
  static String _todosStamp = '';

  static bool get isWriting => _writing > 0;

  static void Function()? onChanged;
  static Map<String, int>? _changes;
  static Map<String, int>? _deleted;
  static Map<String, int>? _cleared;
  static Completer<void>? _idle;

  static Map<String, int> _stamps(String key) => {
        for (final entry in settingMap(key).entries)
          if (entry.value is int) entry.key: entry.value as int,
      };

  static Map<String, int> get changes => _changes ??= _stamps(_changesKey);

  static Map<String, int> get deleted => _deleted ??= _forgetOld(_stamps(_deletedKey));

  static Map<String, int> get cleared => _cleared ??= _stamps(_clearedKey);

  static Map<String, int> _forgetOld(Map<String, int> marks) {
    final limit = DateTime.now().subtract(_forgetAfter).millisecondsSinceEpoch;
    return marks..removeWhere((_, at) => at < limit);
  }

  static int? changedAt(String id) => changes[id];

  static int? deletedAt(String id) => deleted[id];

  static int? clearedAt(String id) => cleared[id];

  static bool get _tracking => true;

  static bool get _quiet => Zone.current[_quietZone] == true;

  static Future<void> stampChange(String id, int at) async {
    changes[id] = at;
    await _settings.put(_changesKey, Map<String, int>.of(changes));
    if (deleted.remove(id) != null) {
      await _settings.put(_deletedKey, Map<String, int>.of(deleted));
    }
  }

  static Future<void> stampDeleted(String id, int at) async {
    deleted[id] = at;
    changes.remove(id);
    await _settings.put(_deletedKey, Map<String, int>.of(deleted));
    await _settings.put(_changesKey, Map<String, int>.of(changes));
  }

  static Future<void> stampCleared(Iterable<String> ids, int at) async {
    for (final id in ids) {
      cleared[id] = at;
    }
    await _settings.put(_clearedKey, Map<String, int>.of(cleared));
  }

  static Future<void> _touch(Iterable<String> ids) async {
    if (_quiet) return;
    if (_tracking) {
      final now = DateTime.now().millisecondsSinceEpoch;
      var revived = false;
      for (final id in ids) {
        changes[id] = now;
        revived = deleted.remove(id) != null || revived;
      }
      await _settings.put(_changesKey, Map<String, int>.of(changes));
      if (revived) await _settings.put(_deletedKey, Map<String, int>.of(deleted));
    }
    onChanged?.call();
  }

  static Future<void> _removed(Iterable<String> ids) async {
    if (_quiet || ids.isEmpty) return;
    if (_tracking) {
      final now = DateTime.now().millisecondsSinceEpoch;
      for (final id in ids) {
        deleted[id] = now;
        changes.remove(id);
      }
      await _settings.put(_deletedKey, Map<String, int>.of(deleted));
      await _settings.put(_changesKey, Map<String, int>.of(changes));
    }
    onChanged?.call();
  }

  static Future<T> quietly<T>(Future<T> Function() action) =>
      runZoned(action, zoneValues: {_quietZone: true});

  static Future<void> idle() {
    if (_writing == 0) return Future.value();
    return (_idle ??= Completer<void>()).future;
  }

  static String get deviceId {
    final saved = setting(_deviceKey, '');
    if (saved.isNotEmpty) return saved;
    final random = Random.secure();
    final made = List.generate(8, (_) => random.nextInt(16).toRadixString(16)).join();
    _settings.put(_deviceKey, made);
    return made;
  }

  static Future<T> guardWrites<T>(Future<T> Function() action) async {
    _writing++;
    try {
      return await action();
    } finally {
      _writing--;
      if (_writing == 0) {
        _idle?.complete();
        _idle = null;
      }
    }
  }

  static Future<void> init() async {
    if (isMobile) {
      await Hive.initFlutter();
    } else {
      Hive.init((await appDataDir()).path);
    }
    _habits = await Hive.openBox(_habitsBox);
    _habitsStamp = _stampOf(_habits);
    _settings = await Hive.openBox(_settingsBox);
    _changes = null;
    _deleted = null;
    _cleared = null;
    _categories = await Hive.openBox(_categoriesBox);
    _notes = await Hive.openBox(_notesBox);
    _todos = await Hive.openBox(_todosBox);
    _todosStamp = _stampOf(_todos);
    _todoTags = await Hive.openBox(_todoTagsBox);
    _moneyTx = await Hive.openBox(_moneyTxBox);
    _moneyCats = await Hive.openBox(_moneyCatsBox);
    _meals = await Hive.openBox(_mealsBox);
    final movedFrom = DataLocation.rewriteFrom;
    if (movedFrom != null) await _followMove(movedFrom);
  }

  static Future<void> _followMove(String from) async {
    final to = (await appDataDir()).path;
    for (final box in [
      _habits,
      _settings,
      _categories,
      _notes,
      _todos,
      _todoTags,
      _moneyTx,
      _moneyCats,
      _meals,
    ]) {
      for (final key in box.keys.toList()) {
        final value = box.get(key);
        final moved = DataLocation.rewrite(value, from, to);
        if (!identical(moved, value)) await box.put(key, moved);
      }
      await box.flush();
    }
    DataLocation.finish();
  }

  static List<Todo> readTodos() {
    final result = <Todo>[];
    for (final raw in _todos.values) {
      try {
        result.add(Todo.fromMap(Map<String, dynamic>.from(raw as Map)));
      } catch (e) {
        debugPrint('Skipped an unreadable to-do: $e');
      }
    }
    return result;
  }

  static Future<void> writeTodo(Todo todo) async {
    await _todos.put(todo.id, todo.toMap());
    _todosStamp = _stampOf(_todos);
    await _touch([todo.id]);
  }

  static Todo? todo(String id) {
    try {
      final raw = _todos.get(id);
      return raw is Map ? Todo.fromMap(Map<String, dynamic>.from(raw)) : null;
    } catch (_) {
      return null;
    }
  }

  static bool get todosChangedElsewhere {
    final stamp = _stampOf(_todos);
    return stamp.isEmpty || stamp != _todosStamp;
  }

  static Future<void> reloadTodos() async {
    await guardWrites(() async {
      if (_todos.isOpen) await _todos.close();
      _todos = await Hive.openBox(_todosBox);
      _todosStamp = _stampOf(_todos);
    });
  }

  static Future<void> writeTodos(Iterable<Todo> todos) async {
    await _todos.putAll({for (final todo in todos) todo.id: todo.toMap()});
    await _touch(todos.map((todo) => todo.id));
  }

  static Future<void> removeTodo(String id) async {
    await _todos.delete(id);
    _todosStamp = _stampOf(_todos);
    await _removed([id]);
  }

  static Future<void> removeTodos(Iterable<String> ids) async {
    await _todos.deleteAll(ids);
    _todosStamp = _stampOf(_todos);
    await _removed(ids);
  }

  static List<TodoTag> readTodoTags() {
    final result = <TodoTag>[];
    for (final raw in _todoTags.values) {
      try {
        result.add(TodoTag.fromJson(raw as String));
      } catch (e) {
        debugPrint('Skipped an unreadable tag: $e');
      }
    }
    return result;
  }

  static Future<void> writeTodoTag(TodoTag tag) async {
    await _todoTags.put(tag.id, tag.toJson());
    await _touch([tag.id]);
  }

  static TodoTag? todoTag(String id) {
    try {
      final raw = _todoTags.get(id);
      return raw is String ? TodoTag.fromJson(raw) : null;
    } catch (_) {
      return null;
    }
  }

  static Future<void> removeTodoTag(String id) async {
    await _todoTags.delete(id);
    await _removed([id]);
  }

  static List<MoneyTransaction> readMoneyTransactions() {
    final result = <MoneyTransaction>[];
    for (final raw in _moneyTx.values) {
      try {
        result.add(
          MoneyTransaction.fromMap(Map<String, dynamic>.from(raw as Map)),
        );
      } catch (e) {
        debugPrint('Skipped an unreadable transaction: $e');
      }
    }
    return result;
  }

  static MoneyTransaction? moneyTransaction(String id) {
    try {
      final raw = _moneyTx.get(id);
      return raw is Map
          ? MoneyTransaction.fromMap(Map<String, dynamic>.from(raw))
          : null;
    } catch (_) {
      return null;
    }
  }

  static Future<void> writeMoneyTransaction(MoneyTransaction tx) async {
    await _moneyTx.put(tx.id, tx.toMap());
    await _touch([tx.id]);
  }

  static Future<void> removeMoneyTransactions(Iterable<String> ids) async {
    final gone = ids.toList();
    await _moneyTx.deleteAll(gone);
    await _removed(gone);
  }

  static Future<void> clearMoneyTransactions() async {
    final gone = _moneyTx.keys.cast<String>().toList();
    await _moneyTx.clear();
    await _removed(gone);
  }

  static List<MoneyCategory> readMoneyCategories() {
    final result = <MoneyCategory>[];
    for (final raw in _moneyCats.values) {
      try {
        result.add(
          MoneyCategory.fromMap(Map<String, dynamic>.from(raw as Map)),
        );
      } catch (e) {
        debugPrint('Skipped an unreadable money category: $e');
      }
    }
    return result;
  }

  static MoneyCategory? moneyCategory(String id) {
    try {
      final raw = _moneyCats.get(id);
      return raw is Map
          ? MoneyCategory.fromMap(Map<String, dynamic>.from(raw))
          : null;
    } catch (_) {
      return null;
    }
  }

  static Future<void> writeMoneyCategory(MoneyCategory category) async {
    await _moneyCats.put(category.id, category.toMap());
    await _touch([category.id]);
  }

  static Future<void> writeMoneyCategories(
    Iterable<MoneyCategory> categories,
  ) async {
    final list = categories.toList();
    await _moneyCats.putAll({for (final c in list) c.id: c.toMap()});
    await _touch(list.map((c) => c.id));
  }

  static Future<void> removeMoneyCategories(Iterable<String> ids) async {
    final gone = ids.toList();
    await _moneyCats.deleteAll(gone);
    await _removed(gone);
  }

  static List<MealEntry> readMeals() {
    final result = <MealEntry>[];
    for (final raw in _meals.values) {
      try {
        result.add(
          MealEntry.fromMap(Map<String, dynamic>.from(raw as Map)),
        );
      } catch (e) {
        debugPrint('Skipped an unreadable meal entry: $e');
      }
    }
    return result;
  }

  static Future<void> writeMeal(MealEntry meal) async {
    await _meals.put(meal.id, meal.toMap());
    await _touch([meal.id]);
  }

  static Future<void> writeMeals(Iterable<MealEntry> meals) async {
    final list = meals.toList();
    await _meals.putAll({for (final m in list) m.id: m.toMap()});
    await _touch(list.map((m) => m.id));
  }

  static Future<void> removeMeals(Iterable<String> ids) async {
    final gone = ids.toList();
    await _meals.deleteAll(gone);
    await _removed(gone);
  }

  static Future<void> clearMeals() async {
    final gone = _meals.keys.cast<String>().toList();
    await _meals.clear();
    await _removed(gone);
  }

  static List<HabitNote> readNotes() {
    final result = <HabitNote>[];
    for (final raw in _notes.values) {
      result.add(HabitNote.fromMap(Map<String, dynamic>.from(raw as Map)));
    }
    return result;
  }

  static Future<void> writeNote(HabitNote note) async {
    await _notes.put(note.id, note.toMap());
    await _touch([note.id]);
  }

  static HabitNote? note(String id) {
    try {
      final raw = _notes.get(id);
      return raw is Map ? HabitNote.fromMap(Map<String, dynamic>.from(raw)) : null;
    } catch (_) {
      return null;
    }
  }

  static Future<void> removeNote(String id) async {
    await _notes.delete(id);
    await _removed([id]);
  }

  static Future<void> removeNotesFor(String habitId) async {
    final ids = readNotes()
        .where((n) => n.habitId == habitId)
        .map((n) => n.id)
        .toList();
    for (final id in ids) {
      await _notes.delete(id);
    }
    await _removed(ids);
  }

  static Map<String, Habit> readHabits() {
    final result = <String, Habit>{};
    for (final raw in _habits.values) {
      try {
        final habit = Habit.fromJson(raw as String);
        result[habit.id] = habit;
      } catch (e) {
        debugPrint('Skipped an unreadable habit: $e');
      }
    }
    return result;
  }

  static Habit? habit(String id) {
    try {
      final raw = _habits.get(id);
      return raw is String ? Habit.fromJson(raw) : null;
    } catch (_) {
      return null;
    }
  }

  static String? habitName(String id) => habit(id)?.name;

  static Future<void> writeHabit(Habit habit) async {
    await _habits.put(habit.id, habit.toJson());
    _habitsStamp = _stampOf(_habits);
    await _touch([habit.id]);
  }

  static String _stampOf(Box box) {
    final path = box.path;
    if (path == null) return '';
    try {
      final stat = File(path).statSync();
      return '${stat.size}:${stat.modified.microsecondsSinceEpoch}';
    } catch (_) {
      return '';
    }
  }

  static bool get habitsChangedElsewhere {
    final stamp = _stampOf(_habits);
    return stamp.isEmpty || stamp != _habitsStamp;
  }

  static Future<void> removeHabit(String id) async {
    await _habits.delete(id);
    _habitsStamp = _stampOf(_habits);
    await _removed([id]);
  }

  static Future<void> reloadHabits() async {
    await guardWrites(() async {
      if (_habits.isOpen) await _habits.close();
      _habits = await Hive.openBox(_habitsBox);
      _habitsStamp = _stampOf(_habits);
    });
  }

  static List<Category> readCategories() {
    final result = <Category>[];
    for (final raw in _categories.values) {
      try {
        result.add(Category.fromJson(raw as String));
      } catch (e) {
        debugPrint('Skipped an unreadable category: $e');
      }
    }
    return result;
  }

  static Future<void> writeCategory(Category category) =>
      _categories.put(category.id, category.toJson());

  static Future<void> removeCategory(String id) => _categories.delete(id);

  static String categoryKey(String name) => name.trim().toLowerCase();

  static Future<void> mergeCategory(Category category) async {
    final key = categoryKey(category.name);
    final taken = readCategories()
        .any((c) => c.id != category.id && categoryKey(c.name) == key);
    if (!taken) await writeCategory(category);
  }

  static Future<List<Category>> readCategoriesOnce() async {
    final kept = <String, Category>{};
    final all = readCategories()
      ..sort((a, b) {
        final byOrder = a.order.compareTo(b.order);
        return byOrder != 0 ? byOrder : a.id.compareTo(b.id);
      });
    for (final category in all) {
      final key = categoryKey(category.name);
      if (kept.containsKey(key)) {
        await removeCategory(category.id);
      } else {
        kept[key] = category;
      }
    }
    return kept.values.toList();
  }

  static bool get hasCategories => _categories.isNotEmpty;

  static T setting<T>(String key, T fallback) {
    final value = _settings.get(key, defaultValue: fallback);
    return value is T ? value : fallback;
  }

  static Map<String, dynamic> settingMap(String key) {
    final value = _settings.get(key);
    return value is Map ? Map<String, dynamic>.from(value) : <String, dynamic>{};
  }

  static Future<void> writeSetting(String key, Object value) =>
      _settings.put(key, value);

  static Future<void> clearProgress() async {
    final habits = readHabits().values.toList();
    for (final habit in habits) {
      await writeHabit(habit.copyWith(completions: const {}));
    }
    if (_tracking) {
      await stampCleared(
        habits.map((h) => h.id),
        DateTime.now().millisecondsSinceEpoch,
      );
    }
    final gone = _notes.keys.cast<String>().toList();
    await _notes.clear();
    await _removed(gone);
  }

  static Future<void> wipeContent() async {
    await _habits.clear();
    await _notes.clear();
    await _todos.clear();
    await _todoTags.clear();
    await _categories.clear();
    await _moneyTx.clear();
    await _moneyCats.clear();
    await _meals.clear();
  }

  static Future<void> wipeEverything() async {
    await _habits.clear();
    await _notes.clear();
    await _todos.clear();
    await _todoTags.clear();
    await _categories.clear();
    await _moneyTx.clear();
    await _moneyCats.clear();
    await _meals.clear();
    await _settings.clear();
    _changes = null;
    _deleted = null;
    _cleared = null;
  }
}
