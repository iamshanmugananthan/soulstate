import 'package:soulstate/features/money/data/money_transaction.dart';

enum MoneyPeriod { today, week, month, quarter, year, all }

DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);

/// A half-open range [start, end). `all` has no bounds.
class MoneyRange {
  const MoneyRange(this.start, this.end);

  final DateTime? start;
  final DateTime? end;

  bool contains(DateTime at) =>
      (start == null || !at.isBefore(start!)) &&
      (end == null || at.isBefore(end!));

  static MoneyRange of(MoneyPeriod period, DateTime anchor, int weekStart) {
    final day = _day(anchor);
    switch (period) {
      case MoneyPeriod.today:
        return MoneyRange(day, DateTime(day.year, day.month, day.day + 1));
      case MoneyPeriod.week:
        final back = (day.weekday - weekStart + 7) % 7;
        final from = DateTime(day.year, day.month, day.day - back);
        return MoneyRange(from, DateTime(from.year, from.month, from.day + 7));
      case MoneyPeriod.month:
        return MoneyRange(
          DateTime(day.year, day.month, 1),
          DateTime(day.year, day.month + 1, 1),
        );
      case MoneyPeriod.quarter:
        final first = ((day.month - 1) ~/ 3) * 3 + 1;
        return MoneyRange(
          DateTime(day.year, first, 1),
          DateTime(day.year, first + 3, 1),
        );
      case MoneyPeriod.year:
        return MoneyRange(
          DateTime(day.year, 1, 1),
          DateTime(day.year + 1, 1, 1),
        );
      case MoneyPeriod.all:
        return const MoneyRange(null, null);
    }
  }

  /// Moves [anchor] by [steps] whole periods (negative = back).
  static DateTime shift(MoneyPeriod period, DateTime anchor, int steps) {
    final day = _day(anchor);
    switch (period) {
      case MoneyPeriod.today:
        return DateTime(day.year, day.month, day.day + steps);
      case MoneyPeriod.week:
        return DateTime(day.year, day.month, day.day + 7 * steps);
      case MoneyPeriod.month:
        return DateTime(day.year, day.month + steps, 1);
      case MoneyPeriod.quarter:
        return DateTime(day.year, day.month + 3 * steps, 1);
      case MoneyPeriod.year:
        return DateTime(day.year + steps, 1, 1);
      case MoneyPeriod.all:
        return day;
    }
  }
}

class MoneyTotals {
  const MoneyTotals({this.income = 0, this.expense = 0, this.count = 0});

  final double income;
  final double expense;
  final int count;

  double get net => income - expense;

  bool get isEmpty => count == 0;
}

class MoneyBreakdown {
  const MoneyBreakdown({
    required this.categoryId,
    required this.label,
    required this.amount,
    required this.count,
    required this.share,
  });

  final String categoryId;
  final String label;
  final double amount;
  final int count;
  final double share;
}

class MoneyStats {
  const MoneyStats._();

  static List<MoneyTransaction> within(
    Iterable<MoneyTransaction> all,
    MoneyRange range,
  ) => [
    for (final tx in all)
      if (range.contains(tx.at)) tx,
  ];

  static MoneyTotals totals(Iterable<MoneyTransaction> items) {
    var income = 0.0;
    var expense = 0.0;
    var count = 0;
    for (final tx in items) {
      count++;
      tx.isExpense ? expense += tx.amount : income += tx.amount;
    }
    return MoneyTotals(income: income, expense: expense, count: count);
  }

  /// Totals of one kind grouped by category, largest first.
  static List<MoneyBreakdown> byCategory(
    Iterable<MoneyTransaction> items,
    MoneyKind kind,
  ) {
    final sums = <String, double>{};
    final counts = <String, int>{};
    final labels = <String, String>{};
    var total = 0.0;
    for (final tx in items) {
      if (tx.kind != kind) continue;
      sums[tx.categoryId] = (sums[tx.categoryId] ?? 0) + tx.amount;
      counts[tx.categoryId] = (counts[tx.categoryId] ?? 0) + 1;
      if (tx.label.isNotEmpty) labels[tx.categoryId] = tx.label;
      total += tx.amount;
    }
    final result =
        [
          for (final entry in sums.entries)
            MoneyBreakdown(
              categoryId: entry.key,
              label: labels[entry.key] ?? '',
              amount: entry.value,
              count: counts[entry.key] ?? 0,
              share: total <= 0 ? 0 : entry.value / total,
            ),
        ]..sort((a, b) {
          final byAmount = b.amount.compareTo(a.amount);
          return byAmount != 0
              ? byAmount
              : a.categoryId.compareTo(b.categoryId);
        });
    return result;
  }

  static Map<DateTime, MoneyTotals> byDay(Iterable<MoneyTransaction> items) {
    final income = <DateTime, double>{};
    final expense = <DateTime, double>{};
    final count = <DateTime, int>{};
    for (final tx in items) {
      final day = tx.day;
      count[day] = (count[day] ?? 0) + 1;
      if (tx.isExpense) {
        expense[day] = (expense[day] ?? 0) + tx.amount;
      } else {
        income[day] = (income[day] ?? 0) + tx.amount;
      }
    }
    return {
      for (final day in count.keys)
        day: MoneyTotals(
          income: income[day] ?? 0,
          expense: expense[day] ?? 0,
          count: count[day]!,
        ),
    };
  }

  /// Twelve monthly sums (index 0 = January) for [kind] in [year],
  /// optionally limited to one category.
  static List<double> byMonth(
    Iterable<MoneyTransaction> items,
    int year,
    MoneyKind kind, {
    String? categoryId,
  }) {
    final out = List<double>.filled(12, 0);
    for (final tx in items) {
      if (tx.kind != kind || tx.at.year != year) continue;
      if (categoryId != null && tx.categoryId != categoryId) continue;
      out[tx.at.month - 1] += tx.amount;
    }
    return out;
  }
}
