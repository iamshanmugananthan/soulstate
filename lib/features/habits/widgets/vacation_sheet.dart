import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:soulstate/app/theme/app_tokens.dart';
import 'package:soulstate/core/i18n/date_labels.dart';
import 'package:soulstate/core/i18n/l10n.dart';
import 'package:soulstate/core/widgets/sheet_type.dart';
import 'package:soulstate/features/habits/data/habit.dart';
import 'package:soulstate/features/habits/state/habits_controller.dart';

String vacationSummary(BuildContext context, Habit habit) {
  if (habit.isOnVacation) return context.l10n.paused;
  final days = [...habit.restDays]..sort();
  if (days.isEmpty) return context.l10n.off;
  final labels = WeekdayLabels.shortMonFirst(
    Localizations.localeOf(context).languageCode,
  );
  return days.map((day) => labels[day - 1]).join(', ');
}

Future<void> showVacationSheet(BuildContext context, {required Habit habit}) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (_) => _VacationSheet(habitId: habit.id),
  );
}

class _VacationSheet extends StatelessWidget {
  const _VacationSheet({required this.habitId});

  final String habitId;

  @override
  Widget build(BuildContext context) {
    final habit = context.watch<HabitsController>().byId(habitId);
    if (habit == null) return const SizedBox.shrink();

    final accent = context.tokens.info;
    final on = habit.isOnVacation;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(LucideIcons.palmtree, size: 22, color: accent),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    context.l10n.vacation_mode,
                    style: sheetTitleStyle(context, size: 18),
                  ),
                ),
                const SizedBox(width: 10),
                Switch(
                  value: on,
                  onChanged: (value) => _setVacation(context, habit, value),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              on ? context.l10n.vacation_on_desc : context.l10n.vacation_off_desc,
              style: sheetBodyStyle(context, size: 13),
            ),
            const SizedBox(height: 22),
            Text(
              context.l10n.rest_days,
              style: sheetHeadingStyle(context),
            ),
            const SizedBox(height: 4),
            Text(
              context.l10n.rest_days_desc,
              style: sheetBodyStyle(context, size: 12.5),
            ),
            const SizedBox(height: 14),
            _WeekdaysRow(
              selected: habit.restDays,
              accent: accent,
              onChanged: (days) {
                context.read<HabitsController>().setRestDays(habit.id, days);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _setVacation(BuildContext context, Habit habit, bool value) {
    context.read<HabitsController>().setVacation(habit.id, value);
  }
}

class _WeekdaysRow extends StatelessWidget {
  const _WeekdaysRow({
    required this.selected,
    required this.onChanged,
    this.accent,
  });

  final List<int> selected;
  final ValueChanged<List<int>> onChanged;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final accent = this.accent ?? context.colors.primary;
    final labels = WeekdayLabels.shortMonFirst(
      Localizations.localeOf(context).languageCode,
    );

    return Row(
      children: List.generate(7, (i) {
        final day = i + 1;
        final active = selected.contains(day);
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i == 6 ? 0 : 5),
            child: Semantics(
              button: true,
              selected: active,
              child: GestureDetector(
                onTap: () {
                  final next = [...selected];
                  active ? next.remove(day) : next.add(day);
                  next.sort();
                  onChanged(next);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: active
                        ? accent.withValues(alpha: 0.12)
                        : context.colors.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(9),
                    border: Border.all(
                      color: active
                          ? accent.withValues(alpha: 0.75)
                          : Colors.transparent,
                      width: 1.2,
                    ),
                  ),
                  child: Text(
                    labels[i],
                    maxLines: 1,
                    softWrap: false,
                    textScaler: MediaQuery.textScalerOf(context)
                        .clamp(maxScaleFactor: 1.3),
                    style: TextStyle(
                      color: active ? accent : context.tokens.muted,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
