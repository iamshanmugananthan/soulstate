import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:soulstate/app/theme/app_tokens.dart';
import 'package:soulstate/core/i18n/l10n.dart';
import 'package:soulstate/features/habits/data/habit.dart';
import 'package:soulstate/features/habits/widgets/check_history.dart';
import 'package:soulstate/features/habits/widgets/habit_heatmap.dart';
import 'package:soulstate/core/extensions/color_extensions.dart';

class SoulStateSummary extends StatelessWidget {
  const SoulStateSummary({super.key, required this.habit, required this.mode});

  final Habit habit;
  final HeatmapMode mode;

  String _format(BuildContext context, int value) => switch (habit.interval) {
        HabitInterval.weekly => context.l10n.count_weeks(value),
        HabitInterval.monthly => context.l10n.count_months(value),
        _ => context.l10n.count_days(value),
      };

  @override
  Widget build(BuildContext context) {
    final negative = habit.kind == HabitKind.negative;
    final (period, count) = periodTotal(context, habit, mode);
    return Row(
      children: [
        if (habit.tracking)
          Expanded(
            child: _StatBox(
              icon: LucideIcons.history,
              iconColor: habit.color.shownIn(context),
              label: context.l10n.last_check,
              value: lastCheckLabel(context, habit, withTime: false),
            ),
          )
        else ...[
          Expanded(
            child: _StatBox(
              icon: LucideIcons.flame,
              iconColor: habit.color.shownIn(context),
              label: context.l10n.current,
              value: _format(context, habit.currentStreak),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _StatBox(
              icon: LucideIcons.trophy,
              iconColor: context.tokens.warning,
              label: context.l10n.best,
              value: _format(context, habit.longestStreak),
            ),
          ),
        ],
        const SizedBox(width: 8),
        Expanded(
          child: _StatBox(
            icon: negative ? LucideIcons.triangleAlert : LucideIcons.circleCheck,
            iconColor: negative ? context.tokens.danger : context.tokens.success,
            label: period,
            value: '$count',
          ),
        ),
      ],
    );
  }
}

class _StatBox extends StatelessWidget {
  const _StatBox({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
        child: Column(
          children: [
            Icon(icon, color: iconColor, size: 22),
            const SizedBox(height: 10),
            Text(
              value,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: scheme.onSurface,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: context.tokens.muted),
            ),
          ],
        ),
      ),
    );
  }
}

typedef StreakSummary = SoulStateSummary;
