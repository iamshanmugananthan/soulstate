import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:soulstate/app/theme/app_tokens.dart';
import 'package:soulstate/core/extensions/date_extensions.dart';
import 'package:soulstate/features/habits/state/habits_controller.dart';
import 'package:soulstate/features/settings/state/settings_controller.dart';

/// Section showing weekly momentum, 7-day completion dots, and streak momentum.
class WeeklyMomentumSection extends StatelessWidget {
  const WeeklyMomentumSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final habits = context.watch<HabitsController>();
    final settings = context.watch<SettingsController>();

    final today = AppClock.today();
    final weekStartDay = settings.weekStart;

    // Calculate current week days (7 days)
    final back = (today.weekday - weekStartDay + 7) % 7;
    final startOfWeek = today.subtract(Duration(days: back));
    final weekDays = List.generate(7, (i) => startOfWeek.add(Duration(days: i)));

    // Active habit list
    final activeHabits = habits.habits;

    // Calculate best streak
    var maxStreak = 0;
    for (final h in activeHabits) {
      if (h.currentStreak > maxStreak) {
        maxStreak = h.currentStreak;
      }
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF97316).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        LucideIcons.flame,
                        size: 16,
                        color: Color(0xFFF97316),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Weekly Momentum',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF97316).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$maxStreak day streak',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFF97316),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 7-day pill row
          Row(
            children: weekDays.map((date) {
              final isToday = date.isSameDay(today);
              final isFuture = date.isAfter(today);
              final due = activeHabits.where((h) => h.isScheduledOn(date)).toList();
              final isCompleted =
                  due.isNotEmpty && due.every((h) => h.isCompletedOn(date));
              final partiallyDone =
                  due.any((h) => h.isCompletedOn(date)) && !isCompleted;

              final dotColor = isFuture
                  ? context.tokens.muted.withValues(alpha: 0.15)
                  : isCompleted
                      ? const Color(0xFF10B981)
                      : partiallyDone
                          ? const Color(0xFFF59E0B)
                          : context.tokens.muted.withValues(alpha: 0.25);

              return Expanded(
                child: Column(
                  children: [
                    Text(
                      DateFormat('E').format(date)[0],
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isToday ? FontWeight.w800 : FontWeight.w600,
                        color: isToday
                            ? theme.colorScheme.primary
                            : context.tokens.muted,
                      ),
                    ),
                    const SizedBox(height: 6),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: dotColor,
                          shape: BoxShape.circle,
                          border: isToday
                              ? Border.all(
                                  color: theme.colorScheme.primary,
                                  width: 2,
                                )
                              : null,
                        ),
                        child: Center(
                          child: isCompleted
                              ? const Icon(LucideIcons.check, size: 16, color: Colors.white)
                              : partiallyDone
                                  ? const Icon(LucideIcons.flame, size: 14, color: Colors.white)
                                  : Text(
                                      '${date.day}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: isFuture
                                            ? context.tokens.muted.withValues(alpha: 0.4)
                                            : context.tokens.muted,
                                      ),
                                    ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
