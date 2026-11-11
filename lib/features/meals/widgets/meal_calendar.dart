import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:soulstate/app/theme/app_tokens.dart';
import 'package:soulstate/core/extensions/date_extensions.dart';
import 'package:soulstate/core/i18n/date_labels.dart';
import 'package:soulstate/core/widgets/sheet_type.dart';
import 'package:soulstate/features/meals/state/meals_controller.dart';
import 'package:soulstate/features/meals/widgets/meal_editor_sheet.dart';
import 'package:soulstate/features/meals/widgets/meal_tile.dart';
import 'package:soulstate/features/money/widgets/money_kit.dart';
import 'package:soulstate/features/money/widgets/money_labels.dart';
import 'package:soulstate/features/settings/state/settings_controller.dart';

class MealCalendar extends StatelessWidget {
  const MealCalendar({
    super.key,
    required this.month,
    required this.selected,
    required this.padding,
    required this.onSelect,
    required this.onShift,
    required this.onToday,
    required this.onAdd,
  });

  final DateTime month;
  final DateTime selected;
  final EdgeInsets padding;
  final ValueChanged<DateTime> onSelect;
  final ValueChanged<int> onShift;
  final VoidCallback onToday;
  final VoidCallback onAdd;

  static const _cell = 54.0;

  @override
  Widget build(BuildContext context) {
    final mealsController = context.watch<MealsController>();
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

    final dayMeals = mealsController.mealsForDate(selected);
    final dayStats = mealsController.statsFor(selected);

    Widget cell(int week, int column) {
      final number = week * 7 + column - lead + 1;
      if (number < 1 || number > count) return const SizedBox(height: _cell);
      final date = DateTime(month.year, month.month, number);
      final stats = mealsController.statsFor(date);
      final isSelected = date.isSameDay(selected);
      final isToday = date.isSameDay(today);

      final hasMeals = stats.totalMeals > 0;
      final ratio = stats.healthyRatio;
      final healthDotColor = ratio >= 0.7
          ? const Color(0xFF10B981)
          : ratio >= 0.4
              ? const Color(0xFFF59E0B)
              : const Color(0xFFEF4444);

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
                    child: !hasMeals
                        ? null
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 5,
                                height: 5,
                                decoration: BoxDecoration(
                                  color: healthDotColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              if (stats.totalCalories > 0) ...[
                                const SizedBox(width: 3),
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    '${stats.totalCalories}',
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700,
                                      color: context.tokens.muted,
                                    ),
                                  ),
                                ),
                              ],
                            ],
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
                  if (dayStats.totalMeals > 0)
                    Text(
                      '${dayStats.totalCalories} kcal · ${dayStats.healthyPercentage}% clean',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: dayStats.healthyRatio >= 0.7
                            ? const Color(0xFF10B981)
                            : scheme.primary,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              if (dayMeals.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Center(
                    child: Column(
                      children: [
                        Text(
                          'No meals logged for this day',
                          style: sheetBodyStyle(context, size: 13),
                        ),
                        const SizedBox(height: 8),
                        TextButton.icon(
                          onPressed: onAdd,
                          icon: const Icon(LucideIcons.plus, size: 16),
                          label: const Text('Log a meal'),
                        ),
                      ],
                    ),
                  ),
                )
              else ...[
                for (final (i, meal) in dayMeals.indexed) ...[
                  if (i > 0) const SizedBox(height: 8),
                  MealTile(
                    meal: meal,
                    onTap: () => MealEditorSheet.show(context, meal: meal),
                    onDelete: () => mealsController.deleteMeal(meal.id),
                  ),
                ],
                const SizedBox(height: 12),
                Center(
                  child: TextButton.icon(
                    onPressed: onAdd,
                    icon: const Icon(LucideIcons.plus, size: 16),
                    label: const Text('Log another meal'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
