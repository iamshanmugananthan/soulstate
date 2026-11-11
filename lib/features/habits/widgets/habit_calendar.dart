import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:soulstate/app/theme/app_tokens.dart';
import 'package:soulstate/core/extensions/color_extensions.dart';
import 'package:soulstate/core/extensions/date_extensions.dart';
import 'package:soulstate/core/i18n/date_labels.dart';
import 'package:soulstate/core/routing/app_navigator.dart';
import 'package:soulstate/core/widgets/sheet_type.dart';
import 'package:soulstate/features/habits/data/habit.dart';
import 'package:soulstate/features/habits/pages/habit_details_page.dart';
import 'package:soulstate/features/habits/state/habits_controller.dart';
import 'package:soulstate/features/habits/widgets/soulstate_label.dart';
import 'package:soulstate/features/money/widgets/money_kit.dart';
import 'package:soulstate/features/money/widgets/money_labels.dart';
import 'package:soulstate/features/settings/state/settings_controller.dart';

class HabitCalendar extends StatelessWidget {
  const HabitCalendar({
    super.key,
    required this.month,
    required this.selected,
    required this.padding,
    required this.onSelect,
    required this.onShift,
    required this.onToday,
  });

  final DateTime month;
  final DateTime selected;
  final EdgeInsets padding;
  final ValueChanged<DateTime> onSelect;
  final ValueChanged<int> onShift;
  final VoidCallback onToday;

  static const _cell = 54.0;

  @override
  Widget build(BuildContext context) {
    final habits = context.watch<HabitsController>().habits;
    final weekStart = context.select<SettingsController, int>(
      (s) => s.weekStart,
    );
    final scheme = context.colors;
    final first = DateTime(month.year, month.month, 1);
    final lead = (first.weekday - weekStart + 7) % 7;
    final count = DateTime(month.year, month.month + 1, 0).day;
    final weeks = ((lead + count) / 7).ceil();
    final labels = WeekdayLabels.narrowFrom(moneyLocale(context), weekStart);
    final today = AppClock.today();

    final scheduledToday = habits.where((h) => h.isScheduledOn(selected)).toList();
    final completedCount =
        scheduledToday.where((h) => h.isCompletedOn(selected)).length;

    Widget cell(int week, int column) {
      final number = week * 7 + column - lead + 1;
      if (number < 1 || number > count) return const SizedBox(height: _cell);
      final date = DateTime(month.year, month.month, number);
      final isSelected = date.isSameDay(selected);
      final isToday = date.isSameDay(today);

      final dayScheduled =
          habits.where((h) => h.isScheduledOn(date) && !h.isOffDay(date)).toList();
      final dayDone = dayScheduled.where((h) => h.isCompletedOn(date)).length;
      final allDone = dayScheduled.isNotEmpty && dayDone == dayScheduled.length;

      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onSelect(date),
        child: SizedBox(
          height: _cell,
          child: Padding(
            padding: const EdgeInsets.all(2),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected
                    ? scheme.primary.withValues(alpha: 0.18)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
                border: isToday
                    ? Border.all(color: scheme.primary, width: 1.4)
                    : null,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$number',
                    style: sheetOptionStyle(
                      context,
                      size: 14,
                      selected: isSelected || isToday,
                    ),
                  ),
                  const SizedBox(height: 2),
                  SizedBox(
                    height: 12,
                    child: dayScheduled.isEmpty
                        ? null
                        : allDone
                            ? Icon(
                                LucideIcons.circleCheck,
                                size: 12,
                                color: context.tokens.success,
                              )
                            : FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  '$dayDone/${dayScheduled.length}',
                                  maxLines: 1,
                                  style: TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w700,
                                    color: dayDone > 0
                                        ? scheme.primary
                                        : context.tokens.muted,
                                  ),
                                ),
                              ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final dateTitle = selected.isSameDay(today)
        ? 'Today, ${DateFormat.yMMMMd().format(selected)}'
        : DateFormat.yMMMMEEEEd().format(selected);

    return ListView(
      padding: padding,
      children: [
        MoneyPeriodBar(
          label: moneyMonthLabel(context, month),
          onPrevious: () => onShift(-1),
          onNext: () => onShift(1),
          onLabel: onToday,
        ),
        const SizedBox(height: 4),
        MoneyCard(
          padding: const EdgeInsets.fromLTRB(8, 14, 8, 8),
          child: MediaQuery.withClampedTextScaling(
            maxScaleFactor: 1.25,
            child: Column(
              children: [
                Row(
                  children: [
                    for (final label in labels)
                      Expanded(
                        child: Center(
                          child: Text(
                            label,
                            style: sheetBodyStyle(context, size: 12),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                for (var w = 0; w < weeks; w++)
                  Row(
                    children: [
                      for (var c = 0; c < 7; c++)
                        Expanded(child: cell(w, c)),
                    ],
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        MoneyCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      dateTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: sheetOptionStyle(context, size: 15),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$completedCount of ${scheduledToday.length} done',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: completedCount == scheduledToday.length &&
                              scheduledToday.isNotEmpty
                          ? context.tokens.success
                          : scheme.primary,
                    ),
                  ),
                ],
              ),
              if (scheduledToday.isEmpty) ...[
                const SizedBox(height: 14),
                Text(
                  'No habits scheduled for this day',
                  style: sheetBodyStyle(context, size: 13),
                ),
              ] else ...[
                const SizedBox(height: 12),
                for (final (i, habit) in scheduledToday.indexed) ...[
                  if (i > 0) const MoneyDivider(indent: 48),
                  _CalendarHabitRow(
                    habit: habit,
                    date: selected,
                  ),
                ],
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _CalendarHabitRow extends StatelessWidget {
  const _CalendarHabitRow({
    required this.habit,
    required this.date,
  });

  final Habit habit;
  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final controller = context.read<HabitsController>();
    final color = habit.color.shownIn(context);
    final isDone = habit.isCompletedOn(date);
    final todayProg = habit.dayProgress(date);
    final todayPct = (todayProg * 100).round();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          InkWell(
            onTap: () => AppNavigator.push(HabitDetailsPage(habitId: habit.id)),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                habitMarkIcon(habit),
                size: 18,
                color: color,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: InkWell(
              onTap: () => AppNavigator.push(HabitDetailsPage(habitId: habit.id)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    habit.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: sheetOptionStyle(context, size: 14),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    habit.kind == HabitKind.quantitative
                        ? '${habit.completions[date.dayKey]?.count ?? 0} / ${habit.perDayTarget.toInt()} ($todayPct%)'
                        : isDone
                            ? 'Completed (100%)'
                            : 'Pending (0%)',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDone ? context.tokens.success : context.tokens.muted,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(
              isDone ? LucideIcons.circleCheck : LucideIcons.circle,
              color: isDone ? color : context.tokens.muted,
              size: 24,
            ),
            tooltip: isDone ? 'Mark incomplete' : 'Mark complete',
            onPressed: () async {
              if (habit.kind == HabitKind.quantitative) {
                await controller.addProgress(habit.id, date, habit.incrementAmount);
              } else {
                await controller.toggle(habit.id, date);
              }
            },
          ),
        ],
      ),
    );
  }
}
