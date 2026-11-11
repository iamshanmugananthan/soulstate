import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:soulstate/app/theme/app_tokens.dart';
import 'package:soulstate/core/widgets/app_empty_state.dart';
import 'package:soulstate/core/widgets/sheet_type.dart';
import 'package:soulstate/features/meals/data/meal_entry.dart';
import 'package:soulstate/features/meals/state/meals_controller.dart';
import 'package:soulstate/features/money/data/money_stats.dart';
import 'package:soulstate/features/money/widgets/money_donut.dart';
import 'package:soulstate/features/money/widgets/money_kit.dart';
import 'package:soulstate/features/money/widgets/money_labels.dart';
import 'package:soulstate/features/settings/state/settings_controller.dart';

class MealAnalysis extends StatelessWidget {
  const MealAnalysis({
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
    final allMeals = context.watch<MealsController>().all;
    final weekStart = context.select<SettingsController, int>(
      (s) => s.weekStart,
    );
    final range = MoneyRange.of(period, anchor, weekStart);

    final meals = allMeals.where((m) => range.contains(m.dateTime)).toList();
    final totalMeals = meals.length;
    final healthyMeals = meals.where((m) => m.isHealthy).length;
    final unhealthyMeals = totalMeals - healthyMeals;
    final healthyRatio =
        totalMeals == 0 ? 0.0 : (healthyMeals / totalMeals).clamp(0.0, 1.0);
    final healthyPct = (healthyRatio * 100).round();

    final totalCalories = meals.fold<int>(0, (sum, m) => sum + (m.calories ?? 0));

    final loggedDays = meals
        .map((m) => DateTime(m.dateTime.year, m.dateTime.month, m.dateTime.day))
        .toSet();
    final avgCalories = loggedDays.isEmpty
        ? 0
        : (totalCalories / loggedDays.length).round();

    final donutSlices = <DonutSlice>[];
    if (totalMeals > 0) {
      if (healthyMeals > 0) {
        donutSlices.add(DonutSlice(
          healthyMeals / totalMeals,
          const Color(0xFF10B981),
        ));
      }
      if (unhealthyMeals > 0) {
        donutSlices.add(DonutSlice(
          unhealthyMeals / totalMeals,
          const Color(0xFFEF4444),
        ));
      }
    }

    final byType = <MealType, List<MealEntry>>{};
    for (final type in MealType.values) {
      byType[type] = meals.where((m) => m.type == type).toList();
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
        Row(
          children: [
            Expanded(
              child: _MealSummaryBox(
                label: 'Healthy Ratio',
                value: '$healthyPct%',
                sub: '$healthyMeals healthy / $totalMeals',
                icon: LucideIcons.salad,
                accent: healthyPct >= 70
                    ? const Color(0xFF10B981)
                    : healthyPct >= 40
                        ? const Color(0xFFF59E0B)
                        : const Color(0xFFEF4444),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _MealSummaryBox(
                label: 'Calories',
                value: '$totalCalories',
                sub: '$avgCalories / day',
                icon: LucideIcons.flame,
                accent: context.colors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        if (totalMeals == 0)
          MoneyCard(
            child: AppEmptyState(
              compact: true,
              icon: LucideIcons.utensils,
              title: 'No meals logged in this period',
            ),
          )
        else ...[
          if (donutSlices.isNotEmpty) ...[
            MoneyCard(
              padding: const EdgeInsets.symmetric(vertical: 22),
              child: Center(
                child: MoneyDonut(
                  slices: donutSlices,
                  label: 'Clean Eating',
                  value: '$healthyPct%',
                ),
              ),
            ),
            const SizedBox(height: 18),
          ],
          MoneyCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (final (index, type) in MealType.values.indexed) ...[
                  if (index > 0) const MoneyDivider(indent: 56),
                  _MealTypeRow(
                    type: type,
                    meals: byType[type] ?? const [],
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _MealSummaryBox extends StatelessWidget {
  const _MealSummaryBox({
    required this.label,
    required this.value,
    required this.icon,
    required this.accent,
    this.sub,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color accent;
  final String? sub;

  @override
  Widget build(BuildContext context) {
    return MoneyCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: accent),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: sheetBodyStyle(context, size: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            maxLines: 1,
            style: sheetFigureStyle(context, size: 20),
          ),
          if (sub != null) ...[
            const SizedBox(height: 2),
            Text(
              sub!,
              maxLines: 1,
              style: TextStyle(
                fontSize: 11,
                color: context.tokens.muted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MealTypeRow extends StatelessWidget {
  const _MealTypeRow({
    required this.type,
    required this.meals,
  });

  final MealType type;
  final List<MealEntry> meals;

  @override
  Widget build(BuildContext context) {
    final healthy = meals.where((m) => m.isHealthy).length;
    final cals = meals.fold<int>(0, (acc, m) => acc + (m.calories ?? 0));
    final ratio = meals.isEmpty ? 0.0 : healthy / meals.length;
    final pct = (ratio * 100).round();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: context.colors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              type.iconEmoji,
              style: const TextStyle(fontSize: 18),
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
                        type.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: sheetOptionStyle(context, size: 14),
                      ),
                    ),
                    Text(
                      '${meals.length} meals · $cals kcal',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: context.tokens.muted,
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
                          value: meals.isEmpty ? 0.0 : ratio,
                          minHeight: 5,
                          backgroundColor:
                              context.colors.surfaceContainerHighest,
                          valueColor: AlwaysStoppedAnimation(
                            pct >= 70
                                ? const Color(0xFF10B981)
                                : pct >= 40
                                    ? const Color(0xFFF59E0B)
                                    : const Color(0xFFEF4444),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '$pct% clean',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: pct >= 70
                            ? const Color(0xFF10B981)
                            : context.tokens.muted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
