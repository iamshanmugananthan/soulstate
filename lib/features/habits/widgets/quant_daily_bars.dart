import 'package:flutter/material.dart';
import 'package:soulstate/core/extensions/date_extensions.dart';
import 'package:soulstate/features/habits/data/habit.dart';
import 'package:soulstate/core/widgets/charts/stat_line_charts.dart';
import 'package:soulstate/core/extensions/color_extensions.dart';

class QuantDailyBars extends StatelessWidget {
  const QuantDailyBars({super.key, required this.habit, this.days = 14});

  final Habit habit;
  final int days;

  @override
  Widget build(BuildContext context) {
    final span = days;
    final today = AppClock.today();
    final start = today.addDays(-(span - 1));
    final unit = habit.isTimeAmount || habit.unitLabel.isEmpty
        ? ''
        : ' ${habit.unitLabel}';
    final amounts = [
      for (var i = 0; i < span; i++)
        habit.completions[start.addDays(i).dayKey]?.count ?? 0,
    ];
    String label(double value) => '${habit.amountText(value)}$unit';
    String axis(double value) => habit.amountText(value);

    return TrendChart(
      values: amounts,
      color: habit.color.shownIn(context),
      startDate: start,
      height: 132,
      goal: habit.hasGoal ? habit.perDayTarget : null,
      format: label,
      axisFormat: axis,
    );
  }
}
