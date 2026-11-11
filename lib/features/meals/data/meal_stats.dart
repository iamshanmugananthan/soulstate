import 'package:flutter/foundation.dart';
import 'package:soulstate/features/meals/data/meal_entry.dart';

/// Aggregated nutrition metrics for a specific date or time range.
@immutable
class DailyMealStats {
  const DailyMealStats({
    required this.date,
    required this.totalMeals,
    required this.healthyCount,
    required this.unhealthyCount,
    required this.totalCalories,
    required this.meals,
  });

  final DateTime date;
  final int totalMeals;
  final int healthyCount;
  final int unhealthyCount;
  final int totalCalories;
  final List<MealEntry> meals;

  /// Healthy ratio between 0.0 and 1.0 (defaults to 1.0 if no meals recorded).
  double get healthyRatio =>
      totalMeals == 0 ? 1.0 : (healthyCount / totalMeals).clamp(0.0, 1.0);

  /// Healthy percentage rounded to integer (0 - 100).
  int get healthyPercentage => (healthyRatio * 100).round();

  /// Qualitative feedback based on healthy ratio.
  String get feedbackTitle {
    if (totalMeals == 0) return 'No meals logged yet';
    if (healthyRatio >= 0.8) return 'Super Clean Eating!';
    if (healthyRatio >= 0.5) return 'Balanced Fuel!';
    return 'High Indulgence Day';
  }

  String get feedbackSubtitle {
    if (totalMeals == 0) return 'Tap + to log your first breakfast or snack';
    if (healthyRatio >= 0.8) return 'Excellent work nourishing your body with whole foods';
    if (healthyRatio >= 0.5) return 'A balanced mix of nourishment and occasional treats';
    return 'Balance your next meal with fresh veggies, hydration, or protein';
  }

  static DailyMealStats compute(DateTime date, Iterable<MealEntry> allMeals) {
    final dayMeals = allMeals.where((m) =>
        m.dateTime.year == date.year &&
        m.dateTime.month == date.month &&
        m.dateTime.day == date.day).toList();

    var healthy = 0;
    var unhealthy = 0;
    var calories = 0;

    for (final m in dayMeals) {
      if (m.isHealthy) {
        healthy++;
      } else {
        unhealthy++;
      }
      calories += m.calories ?? 0;
    }

    return DailyMealStats(
      date: date,
      totalMeals: dayMeals.length,
      healthyCount: healthy,
      unhealthyCount: unhealthy,
      totalCalories: calories,
      meals: dayMeals,
    );
  }
}
