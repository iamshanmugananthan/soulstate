import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:soulstate/app/theme/app_tokens.dart';
import 'package:soulstate/core/i18n/l10n.dart';
import 'package:soulstate/core/extensions/date_extensions.dart';
import 'package:soulstate/features/meals/state/meals_controller.dart';
import 'package:soulstate/features/meals/widgets/meal_editor_sheet.dart';

/// Interactive section on the homepage displaying today's logged meals and nutrition balance.
class TodayMealsSection extends StatelessWidget {
  const TodayMealsSection({
    super.key,
    this.onViewAll,
  });

  final VoidCallback? onViewAll;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mealsController = context.watch<MealsController>();
    final today = AppClock.today();
    final todayMeals = mealsController.todayMeals;
    final stats = mealsController.todayStats;

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
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        LucideIcons.utensils,
                        size: 16,
                        color: Color(0xFF10B981),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        context.l10n.today_nutrition,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (onViewAll != null)
                    TextButton(
                      onPressed: onViewAll,
                      child: Text(context.l10n.view_all, style: const TextStyle(fontSize: 12)),
                    ),
                  IconButton(
                    icon: const Icon(LucideIcons.plusCircle, size: 20),
                    tooltip: context.l10n.log_meal,
                    onPressed: () => MealEditorSheet.show(context, date: today),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (todayMeals.isEmpty)
            InkWell(
              onTap: () => MealEditorSheet.show(context, date: today),
              borderRadius: BorderRadius.circular(14),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  children: [
                    const Text('🥗', style: TextStyle(fontSize: 28)),
                    const SizedBox(height: 8),
                    Text(
                      context.l10n.no_meals_today,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      context.l10n.tap_to_log_meals,
                      style: TextStyle(
                        fontSize: 12,
                        color: context.tokens.muted,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else ...[
            // Nutrition summary banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 6,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${stats.healthyPercentage}% Clean',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF10B981),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          '${stats.healthyCount} Healthy • ${stats.unhealthyCount} Cheat',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: context.tokens.muted,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (stats.totalCalories > 0)
                    Text(
                      '${stats.totalCalories} kcal',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFF97316),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Today's meals preview list
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: todayMeals.take(4).length,
              separatorBuilder: (_, __) => const SizedBox(height: 6),
              itemBuilder: (context, index) {
                final meal = todayMeals[index];
                final timeLabel = DateFormat.jm().format(meal.dateTime);

                return InkWell(
                  onTap: () => MealEditorSheet.show(context, meal: meal),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Text(
                          meal.isHealthy ? '🥗' : '🍔',
                          style: const TextStyle(fontSize: 20),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      meal.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 5, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: (meal.isHealthy
                                              ? const Color(0xFF10B981)
                                              : const Color(0xFFF59E0B))
                                          .withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      meal.isHealthy ? 'CLEAN' : 'CHEAT',
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w800,
                                        color: meal.isHealthy
                                            ? const Color(0xFF10B981)
                                            : const Color(0xFFF59E0B),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${meal.type.iconEmoji} ${meal.type.label} • $timeLabel',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: context.tokens.muted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (meal.calories != null && meal.calories! > 0)
                          Text(
                            '${meal.calories} kcal',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFF97316),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}
