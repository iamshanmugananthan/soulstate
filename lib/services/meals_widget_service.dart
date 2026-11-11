import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';
import 'package:soulstate/core/database/local_store.dart';
import 'package:soulstate/core/extensions/date_extensions.dart';
import 'package:soulstate/core/utils/app_dirs.dart';
import 'package:soulstate/features/meals/data/meal_entry.dart';
import 'package:soulstate/features/meals/data/meal_stats.dart';
import 'package:soulstate/services/home_widget_service.dart';

class MealsWidgetService {
  const MealsWidgetService._();

  static const _provider = 'MealsWidgetProvider';

  static Future<void> sync([List<MealEntry>? meals]) async {
    if (!hasHomeWidgets) return;
    try {
      await HomeWidgetService.prepare();
      final all = meals ?? LocalStore.readMeals();
      final today = AppClock.today();
      final stats = DailyMealStats.compute(today, all);
      final goal = LocalStore.setting('calorieGoal', 2000);
      final water = LocalStore.setting('water_${today.dayKey}', 6);

      final data = {
        'calories': stats.totalCalories,
        'calorieGoal': goal,
        'mealCount': stats.totalMeals,
        'cleanRatio': stats.healthyPercentage,
        'healthyCount': stats.healthyCount,
        'unhealthyCount': stats.unhealthyCount,
        'waterGlasses': water,
        'waterGoal': 8,
      };

      await HomeWidget.saveWidgetData<String>('meals_data', json.encode(data));
      await HomeWidget.updateWidget(androidName: _provider, iOSName: _provider);
    } catch (e) {
      debugPrint('Meals widget sync failed: $e');
    }
  }
}
