import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:soulstate/app/theme/app_tokens.dart';
import 'package:soulstate/core/extensions/color_extensions.dart';
import 'package:soulstate/core/extensions/date_extensions.dart';
import 'package:soulstate/core/routing/app_navigator.dart';
import 'package:soulstate/core/widgets/app_empty_state.dart';
import 'package:soulstate/core/widgets/sheet_type.dart';
import 'package:soulstate/features/habits/data/habit.dart';
import 'package:soulstate/features/habits/pages/habit_details_page.dart';
import 'package:soulstate/features/habits/state/habits_controller.dart';
import 'package:soulstate/features/habits/widgets/soulstate_label.dart';
import 'package:soulstate/features/money/data/money_stats.dart';
import 'package:soulstate/features/money/widgets/money_donut.dart';
import 'package:soulstate/features/money/widgets/money_kit.dart';
import 'package:soulstate/features/money/widgets/money_labels.dart';
import 'package:soulstate/features/settings/state/settings_controller.dart';

class HabitAnalysis extends StatelessWidget {
  const HabitAnalysis({
    super.key,
    required this.period,
    required this.anchor,
    required this.padding,
    required this.onPeriod,
    required this.onShift,
    required this.onToday,
  });

  final MoneyPeriod period;
  final DateTime anchor;
  final EdgeInsets padding;
  final ValueChanged<MoneyPeriod> onPeriod;
  final ValueChanged<int> onShift;
  final VoidCallback onToday;

  @override
  Widget build(BuildContext context) {
    final habits = context.watch<HabitsController>().habits;
    final weekStart = context.select<SettingsController, int>(
      (s) => s.weekStart,
    );
    final range = MoneyRange.of(period, anchor, weekStart);

    final from = range.start ?? AppClock.today().addDays(-365);
    final to = range.end != null ? range.end!.addDays(-1) : AppClock.today();

    var totalScheduled = 0;
    var totalDone = 0.0;
    final habitStats = <_HabitStat>[];

    for (final habit in habits) {
      final tally = habit.tally(from, to);
      totalScheduled += tally.days;
      totalDone += tally.done;
      habitStats.add(_HabitStat(
        habit: habit,
        done: tally.done,
        scheduled: tally.days,
        rate: tally.days == 0 ? 0.0 : (tally.done / tally.days).clamp(0.0, 1.0),
      ));
    }

    habitStats.sort((a, b) {
      final cmp = b.rate.compareTo(a.rate);
      return cmp != 0 ? cmp : b.done.compareTo(a.done);
    });

    final overallRate = totalScheduled == 0
        ? 0.0
        : (totalDone / totalScheduled).clamp(0.0, 1.0);
    final activeStreaks = habits.where((h) => h.currentStreak > 0).length;
    var maxStreak = 0;
    for (final h in habits) {
      if (h.longestStreak > maxStreak) maxStreak = h.longestStreak;
    }

    final donutSlices = <DonutSlice>[];
    if (totalDone > 0) {
      for (final stat in habitStats) {
        if (stat.done > 0) {
          donutSlices.add(DonutSlice(
            stat.done / totalDone,
            stat.habit.color.shownIn(context),
          ));
        }
      }
    }

    return ListView(
      padding: padding,
      children: [
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              for (final p in [
                MoneyPeriod.week,
                MoneyPeriod.month,
                MoneyPeriod.year,
                MoneyPeriod.all,
              ])
                Padding(
                  padding: const EdgeInsetsDirectional.only(end: 8),
                  child: MoneyChip(
                    label: moneyPeriodName(context, p),
                    selected: p == period,
                    onTap: () => onPeriod(p),
                  ),
                ),
            ],
          ),
        ),
        if (period != MoneyPeriod.all)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: MoneyPeriodBar(
              label: moneyPeriodLabel(context, period, anchor, weekStart),
              onPrevious: () => onShift(-1),
              onNext: () => onShift(1),
              onLabel: onToday,
            ),
          )
        else
          const SizedBox(height: 12),
        _HabitSummaryGrid(
          rate: overallRate,
          checkIns: totalDone.round(),
          activeStreaks: activeStreaks,
          bestStreak: maxStreak,
        ),
        const SizedBox(height: 18),
        if (habits.isEmpty || totalScheduled == 0)
          MoneyCard(
            child: AppEmptyState(
              compact: true,
              icon: LucideIcons.flame,
              title: 'No habit data in this period',
            ),
          )
        else ...[
          if (donutSlices.isNotEmpty) ...[
            MoneyCard(
              padding: const EdgeInsets.symmetric(vertical: 22),
              child: Center(
                child: MoneyDonut(
                  slices: donutSlices,
                  label: 'Check-ins',
                  value: '${totalDone.round()}',
                ),
              ),
            ),
            const SizedBox(height: 18),
          ],
          MoneyCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (final (index, stat) in habitStats.indexed) ...[
                  if (index > 0) const MoneyDivider(indent: 56),
                  _HabitBreakdownRow(stat: stat),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _HabitStat {
  const _HabitStat({
    required this.habit,
    required this.done,
    required this.scheduled,
    required this.rate,
  });

  final Habit habit;
  final double done;
  final int scheduled;
  final double rate;
}

class _HabitSummaryGrid extends StatelessWidget {
  const _HabitSummaryGrid({
    required this.rate,
    required this.checkIns,
    required this.activeStreaks,
    this.bestStreak = 0,
  });

  final double rate;
  final int checkIns;
  final int activeStreaks;
  final int bestStreak;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _SummaryBox(
              label: 'Completion',
              value: '${(rate * 100).round()}%',
              icon: LucideIcons.circleCheck,
              accent: context.tokens.success,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _SummaryBox(
              label: 'Check-ins',
              value: '$checkIns',
              icon: LucideIcons.flame,
              accent: context.colors.primary,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _SummaryBox(
              label: 'Streaks',
              value: '$activeStreaks',
              icon: LucideIcons.zap,
              accent: const Color(0xFFF59E0B),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryBox extends StatelessWidget {
  const _SummaryBox({
    required this.label,
    required this.value,
    required this.icon,
    required this.accent,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return MoneyCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: accent),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: sheetBodyStyle(context, size: 11.5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: 1,
            style: sheetFigureStyle(context, size: 18),
          ),
        ],
      ),
    );
  }
}

class _HabitBreakdownRow extends StatelessWidget {
  const _HabitBreakdownRow({required this.stat});

  final _HabitStat stat;

  @override
  Widget build(BuildContext context) {
    final habit = stat.habit;
    final color = habit.color.shownIn(context);
    final pct = (stat.rate * 100).round();

    return InkWell(
      onTap: () => AppNavigator.push(HabitDetailsPage(habitId: habit.id)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
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
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          habit.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: sheetOptionStyle(context, size: 14),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$pct%',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: pct >= 80
                              ? context.tokens.success
                              : context.colors.onSurface,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: LinearProgressIndicator(
                            value: stat.rate,
                            minHeight: 5,
                            backgroundColor:
                                context.colors.surfaceContainerHighest,
                            valueColor: AlwaysStoppedAnimation(color),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '${stat.done.round()}/${stat.scheduled}d',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: context.tokens.muted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              LucideIcons.chevronRight,
              size: 16,
              color: context.tokens.muted,
            ),
          ],
        ),
      ),
    );
  }
}
