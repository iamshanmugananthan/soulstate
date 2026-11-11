import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:soulstate/app/theme/app_tokens.dart';
import 'package:soulstate/features/meals/data/meal_entry.dart';

/// Interactive tile displaying a logged meal with health badge and calories.
class MealTile extends StatelessWidget {
  const MealTile({
    super.key,
    required this.meal,
    required this.onTap,
    required this.onDelete,
  });

  final MealEntry meal;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final healthColor = meal.isHealthy
        ? const Color(0xFF10B981) // Emerald green
        : const Color(0xFFF59E0B); // Amber / orange

    final healthBg = healthColor.withValues(alpha: isDark ? 0.16 : 0.12);
    final timeStr = DateFormat.jm().format(meal.dateTime);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.25),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Health indicator icon container
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: healthBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  meal.isHealthy ? '🥗' : '🍔',
                  style: const TextStyle(fontSize: 22),
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Meal info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: healthBg,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          meal.isHealthy ? 'HEALTHY' : 'UNHEALTHY',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                            color: healthColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${meal.type.iconEmoji} ${meal.type.label}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: context.tokens.muted,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        timeStr,
                        style: TextStyle(
                          fontSize: 12,
                          color: context.tokens.muted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    meal.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  if (meal.notes != null && meal.notes!.trim().isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      meal.notes!.trim(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: context.tokens.muted,
                      ),
                    ),
                  ],
                  if (meal.calories != null && meal.calories! > 0) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          LucideIcons.flame,
                          size: 13,
                          color: const Color(0xFFF97316),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${meal.calories} kcal',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFF97316),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            // Delete action button
            IconButton(
              icon: Icon(
                LucideIcons.trash2,
                size: 18,
                color: context.tokens.muted.withValues(alpha: 0.6),
              ),
              onPressed: onDelete,
              tooltip: 'Delete meal',
            ),
          ],
        ),
      ),
    );
  }
}
