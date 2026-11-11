import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:soulstate/core/extensions/inset_extensions.dart';
import 'package:soulstate/core/routing/app_navigator.dart';
import 'package:soulstate/features/habits/data/habit.dart';
import 'package:soulstate/features/habits/state/habits_controller.dart';
import 'package:soulstate/features/habits/widgets/avoid_stats.dart';

bool hasHabitStats(Habit habit) =>
    habit.hasTotalGoal || habit.kind == HabitKind.negative;

class HabitStatsPage extends StatelessWidget {
  const HabitStatsPage({super.key, required this.habitId});

  final String habitId;

  @override
  Widget build(BuildContext context) {
    final habit = context.watch<HabitsController>().byId(habitId);
    if (habit == null) return const SizedBox.shrink();

    final children = <Widget>[
      if (habit.hasCleanGoal) CleanGoalCard(habit: habit),
      if (habit.hasTotalGoal) TotalGoalCard(habit: habit),
      if (habit.kind == HabitKind.negative) AvoidMonthSection(habit: habit),
    ];
    final spaced = [
      for (final (i, child) in children.indexed) ...[
        if (i > 0) const SizedBox(height: 20),
        child,
      ],
    ];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft),
          onPressed: () => AppNavigator.pop(),
        ),
        title: Text(habit.name),
      ),
      body: ListView(
        padding: context.pagePadding(16, 8, 16, 32),
        children: spaced,
      ),
    );
  }
}
