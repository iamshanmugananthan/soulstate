import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';
import 'package:soulstate/core/database/local_store.dart';
import 'package:soulstate/core/extensions/date_extensions.dart';
import 'package:soulstate/core/utils/app_dirs.dart';
import 'package:soulstate/core/utils/money_format.dart';
import 'package:soulstate/features/meals/data/meal_stats.dart';
import 'package:soulstate/features/money/data/money_stats.dart';
import 'package:soulstate/services/home_widget_service.dart';

class DashboardWidgetService {
  const DashboardWidgetService._();

  static const _provider = 'DashboardWidgetProvider';

  static Future<void> sync() async {
    if (!hasHomeWidgets) return;
    try {
      await HomeWidgetService.prepare();
      final today = AppClock.today();
      final habits = LocalStore.readHabits().values.where((h) => !h.isArchived).toList();
      var habitsDone = 0;
      var habitsTotal = 0;
      for (final h in habits) {
        if (h.isScheduledOn(today)) {
          habitsTotal++;
          if (h.isCompletedOn(today)) habitsDone++;
        }
      }

      final todos = LocalStore.readTodos();
      final todosOpen = todos.where((t) => !t.done).length;

      final transactions = LocalStore.readMoneyTransactions();
      final currency = LocalStore.setting('currency', defaultCurrencySymbol());
      final allTotals = MoneyStats.totals(transactions);

      final meals = LocalStore.readMeals();
      final mealStats = DailyMealStats.compute(today, meals);
      final calorieGoal = LocalStore.setting('calorieGoal', 2000);

      final data = {
        'habitsDone': habitsDone,
        'habitsTotal': habitsTotal,
        'habitsPct': habitsTotal > 0 ? ((habitsDone * 100) ~/ habitsTotal) : 0,
        'todosOpen': todosOpen,
        'moneyBalance': formatMoney(allTotals.net, currency, 'en'),
        'mealsLogged': mealStats.totalMeals,
        'calories': mealStats.totalCalories,
        'calorieGoal': calorieGoal,
      };

      await HomeWidget.saveWidgetData<String>('dashboard_data', json.encode(data));
      await HomeWidget.updateWidget(androidName: _provider, iOSName: _provider);
    } catch (e) {
      debugPrint('Dashboard widget sync failed: $e');
    }
  }
}
