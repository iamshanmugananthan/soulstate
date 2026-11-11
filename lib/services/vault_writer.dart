import 'dart:io';

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:soulstate/core/extensions/date_extensions.dart';
import 'package:soulstate/core/utils/amount_format.dart';
import 'package:soulstate/features/habits/data/category.dart';
import 'package:soulstate/features/habits/data/habit.dart';
import 'package:soulstate/features/habits/data/habit_note.dart';
import 'package:soulstate/features/meals/data/meal_entry.dart';
import 'package:soulstate/features/money/data/money_category.dart';
import 'package:soulstate/features/money/data/money_transaction.dart';
import 'package:soulstate/features/todos/data/todo.dart';

const vaultFolder = 'SoulState';

class VaultWriter {
  const VaultWriter._();

  static const marker = 'generator: soulstate';

  static const _weekdays = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  static Future<void> write(
    Directory root, {
    required List<Habit> habits,
    required List<Category> categories,
    required List<HabitNote> notes,
    required List<Todo> todos,
    List<MealEntry> meals = const [],
    List<MoneyTransaction> transactions = const [],
    List<MoneyCategory> moneyCategories = const [],
  }) async {
    final names = <String, String>{};
    for (final habit in habits) {
      names[habit.id] = habit.name;
    }
    final labels = <String, String>{};
    for (final category in categories) {
      labels[category.id] = category.name;
    }

    final live = habits.where((h) => !h.isArchived).toList()
      ..sort((a, b) => a.order.compareTo(b.order));
    final archived = habits.where((h) => h.isArchived).toList()
      ..sort((a, b) => a.name.compareTo(b.name));

    await _writeText(
      root,
      'README.md',
      _readme(
        habits,
        todos,
        notes,
        meals: meals,
        transactions: transactions,
      ),
    );
    await _writeHabits(Directory('${root.path}/habits'), live, labels);
    await _writeHabits(
      Directory('${root.path}/habits/archived'),
      archived,
      labels,
    );
    await _writeText(root, 'tasks.md', _tasks(todos));
    await _writeText(root, 'notes.md', _notes(notes, names));
    await _writeText(root, 'meals.md', _meals(meals));
    await _writeText(
      root,
      'finances.md',
      _finances(transactions, moneyCategories),
    );
  }

  static Future<void> _writeHabits(
    Directory dir,
    List<Habit> habits,
    Map<String, String> categories,
  ) async {
    if (!dir.existsSync()) dir.createSync(recursive: true);

    final taken = <String>{};
    final written = <String>{};
    for (final habit in habits) {
      final name = _unique(_slug(habit.name), taken);
      written.add('$name.md');
      await _writeText(dir, '$name.md', _habit(habit, categories));
    }
    _sweep(dir, written);
  }

  static void _sweep(Directory dir, Set<String> keep) {
    try {
      if (!dir.existsSync()) return;
      for (final entity in dir.listSync()) {
        if (entity is! File || !entity.path.endsWith('.md')) continue;
        final name = entity.uri.pathSegments.last;
        if (!keep.contains(name)) {
          try {
            entity.deleteSync();
          } catch (_) {}
        }
      }
    } catch (e) {
      debugPrint('Could not tidy the vault: $e');
    }
  }

  static Future<void> _writeText(
    Directory dir,
    String name,
    String content,
  ) async {
    if (!dir.existsSync()) dir.createSync(recursive: true);
    final file = File('${dir.path}/$name');
    if (file.existsSync() && file.readAsStringSync() == content) return;
    await file.writeAsString(content, flush: true);
  }

  static String _readme(
    List<Habit> habits,
    List<Todo> todos,
    List<HabitNote> notes, {
    List<MealEntry> meals = const [],
    List<MoneyTransaction> transactions = const [],
  }) {
    final live = habits.where((h) => !h.isArchived).length;
    final archived = habits.length - live;
    return '''
# Soul State Vault

Everything Soul State knows about your habits, tasks, meals, and finances, written as plain files you can read
with any editor, or open as a vault in a notes app. Nothing here is encrypted or
packed: it is yours.

Written on ${_stamp(DateTime.now())}.

| What | How many |
| --- | --- |
| Habits | $live |
| Archived habits | $archived |
| Tasks | ${todos.length} |
| Notes | ${notes.length} |
| Meals | ${meals.length} |
| Transactions | ${transactions.length} |

## What is in here

- `habits/` one file per habit, with its settings and its full day by day
  history. Archived ones are in `habits/archived/`.
- `tasks.md` your to-do list and reminders.
- `notes.md` the notes you wrote on habit days.
- `meals.md` your logged meals and healthy/treat ratio.
- `finances.md` your expenses and income records.

Soul State automatically syncs with your Soul State Vault folder simultaneously.

## Restoring

These files are for reading and editing directly. What Soul State restores from is
your Soul State Vault files or backup archives in Settings > Data.
''';
  }

  static String _habit(Habit habit, Map<String, String> categories) {
    final out = StringBuffer();
    final category = categories[habit.category] ?? '';

    out.writeln('---');
    out.writeln('name: ${_yaml(habit.name)}');
    out.writeln('id: ${_yaml(habit.id)}');
    out.writeln('type: ${_type(habit)}');
    if (habit.kind == HabitKind.quantitative) {
      out.writeln('target: ${formatAmount(habit.perDayTarget)}');
      if (habit.unitLabel.isNotEmpty) {
        out.writeln('unit: ${_yaml(habit.unitLabel)}');
      }
    }
    out.writeln('schedule: ${_yaml(_schedule(habit))}');
    if (category.isNotEmpty) out.writeln('category: ${_yaml(category)}');
    out.writeln('color: ${_yaml(_hex(habit.color.toARGB32()))}');
    out.writeln('created: ${_day(habit.createdAt)}');
    if (habit.isArchived) {
      out.writeln('archived: ${_day(habit.archivedAt!)}');
    }
    out.writeln(marker);
    out.writeln('---');
    out.writeln();
    out.writeln('# ${habit.name}');

    if (habit.description.trim().isNotEmpty) {
      out.writeln();
      out.writeln(habit.description.trim());
    }

    if (habit.substeps.isNotEmpty) {
      out.writeln();
      out.writeln('## Steps');
      out.writeln();
      for (final step in habit.substeps) {
        out.writeln('- ${step.title}');
      }
    }

    if (habit.reminders.isNotEmpty) {
      out.writeln();
      out.writeln('## Reminders');
      out.writeln();
      for (final reminder in habit.reminders) {
        final at = '${_pad(reminder.hour)}:${_pad(reminder.minute)}';
        final days = reminder.days.isEmpty
            ? 'every day'
            : (reminder.days.toList()..sort())
                .map((d) => _weekdays[d - 1])
                .join(', ');
        out.writeln('- $at on $days');
      }
    }

    if (habit.vacations.isNotEmpty) {
      out.writeln();
      out.writeln('## Breaks');
      out.writeln();
      for (final vacation in habit.vacations) {
        final end = vacation.end == null ? 'ongoing' : _day(vacation.end!);
        out.writeln('- ${_day(vacation.start)} to $end');
      }
    }

    out.writeln();
    out.writeln('## History');
    out.writeln();
    out.write(_history(habit));
    return out.toString();
  }

  static String _history(Habit habit) {
    final entries = habit.completions.values.toList()
      ..sort((a, b) => parseDayKey(b.date).compareTo(parseDayKey(a.date)));

    if (entries.isEmpty) return 'Nothing logged yet.\n';

    final negative = habit.kind == HabitKind.negative;
    final column = negative
        ? 'Relapse'
        : habit.kind == HabitKind.quantitative
            ? 'Amount'
            : 'Done';

    final out = StringBuffer()
      ..writeln('| Date | Day | $column |')
      ..writeln('| --- | --- | --- |');

    for (final entry in entries) {
      final date = parseDayKey(entry.date);
      final value = negative
          ? 'yes'
          : habit.kind == HabitKind.quantitative
              ? _amount(habit, entry.count)
              : 'yes';
      out.writeln(
        '| ${_day(date)} | ${_weekdays[date.weekday - 1]} | ${_safeCell(value)} |',
      );
    }
    return out.toString();
  }

  static String _amount(Habit habit, double count) {
    if (habit.isTimeAmount) return formatMinutes(count);
    final value = formatAmount(count);
    return habit.unitLabel.isEmpty ? value : '$value ${habit.unitLabel}';
  }

  static String _tasks(List<Todo> todos) {
    if (todos.isEmpty) return '# Tasks\n\nNothing here yet.\n';

    final open = todos.where((t) => !t.done).toList();
    final done = todos.where((t) => t.done).toList();

    final out = StringBuffer()..writeln('# Tasks');
    out.writeln();
    out.writeln('${open.length} open, ${done.length} done.');

    void section(String title, List<Todo> list, bool checked) {
      if (list.isEmpty) return;
      out.writeln();
      out.writeln('## $title');
      out.writeln();
      for (final todo in list) {
        final box = checked ? '[x]' : '[ ]';
        final when = todo.date.isEmpty
            ? ''
            : ' (${_day(parseDayKey(todo.date))})';
        final reminderStr = todo.minutes != null
            ? ' ⏰ ${(todo.minutes! ~/ 60).toString().padLeft(2, '0')}:${(todo.minutes! % 60).toString().padLeft(2, '0')}'
            : '';
        out.writeln('- $box ${_safeText(todo.text)}$when$reminderStr');
        for (final step in todo.steps) {
          out.writeln('  - ${step.done ? '[x]' : '[ ]'} ${_safeText(step.text)}');
        }
      }
    }

    section('Open', open, false);
    section('Done', done, true);
    return out.toString();
  }

  static String _notes(List<HabitNote> notes, Map<String, String> habits) {
    if (notes.isEmpty) return '# Notes\n\nNothing here yet.\n';

    final sorted = notes.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    final out = StringBuffer()..writeln('# Notes');
    for (final note in sorted) {
      final habit = habits[note.habitId] ?? 'Unknown habit';
      final day = note.date.isEmpty ? '' : ' · ${_day(parseDayKey(note.date))}';
      out.writeln();
      out.writeln('## $habit$day');
      out.writeln();
      out.writeln(note.text.trim().isEmpty ? '(empty)' : note.text.trim());
    }
    return out.toString();
  }

  static String _meals(List<MealEntry> meals) {
    if (meals.isEmpty) return '# Meals\n\nNothing logged yet.\n';
    final sorted = meals.toList()
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
    final out = StringBuffer()..writeln('# Meals');
    out.writeln();
    for (final meal in sorted) {
      final date = _day(meal.dateTime);
      final healthy = meal.isHealthy ? '🥗 Healthy' : '🍔 Treat';
      final cal = meal.calories != null ? ' (${meal.calories} kcal)' : '';
      out.writeln(
        '- $date · ${meal.type.iconEmoji} ${meal.type.label}: **${meal.name}**$cal · $healthy',
      );
      if (meal.notes != null && meal.notes!.trim().isNotEmpty) {
        out.writeln('  > ${meal.notes!.trim()}');
      }
    }
    return out.toString();
  }

  static String _safeCell(String value) {
    var s = value.replaceAll('\r', '').replaceAll('\n', ' ').trim();
    // Escape pipe characters to maintain table structure
    s = s.replaceAll('|', r'\|');
    // Prevent spreadsheet formula injection (=, +, -, @, \t)
    if (s.startsWith('=') ||
        s.startsWith('+') ||
        s.startsWith('-') ||
        s.startsWith('@') ||
        s.startsWith('\t')) {
      s = "'$s";
    }
    return s;
  }

  static String _safeText(String value) {
    var s = value.replaceAll('\r', '').trim();
    if (s.startsWith('=') ||
        s.startsWith('+') ||
        s.startsWith('-') ||
        s.startsWith('@')) {
      s = "'$s";
    }
    return s;
  }

  static String _finances(
    List<MoneyTransaction> txs,
    List<MoneyCategory> categories,
  ) {
    if (txs.isEmpty) return '# Finances\n\nNothing logged yet.\n';
    final catNames = {for (final c in categories) c.id: c.name};
    final sorted = txs.toList()..sort((a, b) => b.at.compareTo(a.at));
    final out = StringBuffer()..writeln('# Finances');
    out.writeln();
    out.writeln('| Date | Type | Category | Amount | Note |');
    out.writeln('| --- | --- | --- | --- | --- |');
    for (final tx in sorted) {
      final date = _day(tx.at);
      final type = tx.isExpense ? 'Expense' : 'Income';
      final cat = _safeCell(catNames[tx.categoryId] ?? tx.label);
      final amount = formatAmount(tx.amount);
      final note = _safeCell(tx.note);
      out.writeln('| $date | $type | $cat | $amount | $note |');
    }
    return out.toString();
  }

  static String _type(Habit habit) => switch (habit.kind) {
        HabitKind.positive => habit.substeps.isEmpty ? 'habit' : 'checklist',
        HabitKind.negative => 'avoid',
        HabitKind.quantitative => 'amount',
      };

  static String _schedule(Habit habit) => switch (habit.interval) {
        HabitInterval.daily => 'every day',
        HabitInterval.weekly => '${habit.targetFrequency} times per week',
        HabitInterval.monthly => '${habit.targetFrequency} times per month',
        HabitInterval.weekdays => habit.scheduleWeekdays.isEmpty
            ? 'every day'
            : (habit.scheduleWeekdays.toList()..sort())
                .map((d) => _weekdays[d - 1])
                .join(', '),
        HabitInterval.everyXDays =>
          'every ${habit.scheduleEvery} ${habit.scheduleUnit.name}',
      };

  static String _slug(String name) {
    var clean = name;
    for (final bad in [
      r'\',
      '/',
      ':',
      '*',
      '?',
      '"',
      '<',
      '>',
      '|',
      '\n',
      '\r',
      '\t',
    ]) {
      clean = clean.replaceAll(bad, ' ');
    }
    clean = clean.replaceAll(RegExp(r'\s+'), ' ').trim();
    while (clean.endsWith('.')) {
      clean = clean.substring(0, clean.length - 1).trimRight();
    }
    if (clean.length > 60) clean = clean.substring(0, 60).trim();
    return clean.isEmpty ? 'habit' : clean;
  }

  static String _unique(String name, Set<String> taken) {
    final lower = name.toLowerCase();
    if (taken.add(lower)) return name;
    var index = 2;
    while (!taken.add('$lower ($index)')) {
      index++;
    }
    return '$name ($index)';
  }

  static String _yaml(String value) =>
      '"${value.replaceAll(r'\', r'\\').replaceAll('"', r'\"')}"';

  static String _hex(int argb) =>
      '#${(argb & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';

  static String _day(DateTime date) =>
      '${date.year}-${_pad(date.month)}-${_pad(date.day)}';

  static String _stamp(DateTime date) =>
      '${_day(date)} ${_pad(date.hour)}:${_pad(date.minute)}';

  static String _pad(int value) => value < 10 ? '0$value' : '$value';
}
