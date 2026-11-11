import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:soulstate/core/database/local_store.dart';
import 'package:soulstate/core/extensions/date_extensions.dart';
import 'package:soulstate/features/meals/data/meal_entry.dart';
import 'package:soulstate/features/meals/data/meal_stats.dart';
import 'package:soulstate/features/vault/services/vault_manager.dart';
import 'package:soulstate/services/dashboard_widget_service.dart';
import 'package:soulstate/services/meals_widget_service.dart';

/// Manages meal logging, healthy vs unhealthy classification, and nutritional metrics.
class MealsController extends ChangeNotifier {
  MealsController() {
    _load();
  }

  final List<MealEntry> _meals = [];

  List<MealEntry> get all => List.unmodifiable(_meals);

  void _load() {
    _meals.clear();
    _meals.addAll(LocalStore.readMeals());
    _meals.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    notifyListeners();
    unawaited(MealsWidgetService.sync(_meals));
    unawaited(DashboardWidgetService.sync());
  }

  Future<void> reload() async {
    _load();
  }

  /// All meals logged for the current active day.
  List<MealEntry> get todayMeals => mealsForDate(AppClock.today());

  /// Aggregated metrics for today.
  DailyMealStats get todayStats => statsFor(AppClock.today());

  /// Total calories logged today.
  int get todayCalories => todayStats.totalCalories;

  /// Healthy meal count today.
  int get todayHealthyCount => todayStats.healthyCount;

  /// Unhealthy meal count today.
  int get todayUnhealthyCount => todayStats.unhealthyCount;

  /// Healthy meal ratio today (0.0 to 1.0).
  double get todayHealthyRatio => todayStats.healthyRatio;

  /// Filter meals for any given calendar date.
  List<MealEntry> mealsForDate(DateTime date) {
    return _meals.where((m) =>
        m.dateTime.year == date.year &&
        m.dateTime.month == date.month &&
        m.dateTime.day == date.day).toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
  }

  /// Filter meals for a given date and specific meal type.
  List<MealEntry> mealsForDateAndType(DateTime date, MealType type) {
    return mealsForDate(date).where((m) => m.type == type).toList();
  }

  /// Compute aggregated metrics for a specific date.
  DailyMealStats statsFor(DateTime date) {
    return DailyMealStats.compute(date, _meals);
  }

  /// Returns 7-day stats ending on [endDate] (defaults to today).
  List<DailyMealStats> recentDaysStats({int days = 7, DateTime? endDate}) {
    final end = endDate ?? AppClock.today();
    final result = <DailyMealStats>[];
    for (var i = days - 1; i >= 0; i--) {
      final d = end.subtract(Duration(days: i));
      result.add(statsFor(d));
    }
    return result;
  }

  /// Inserts a new meal record.
  Future<void> addMeal(MealEntry meal) async {
    _meals.insert(0, meal);
    _meals.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    await LocalStore.writeMeal(meal);
    notifyListeners();
    await VaultManager.syncCurrentVault();
    unawaited(MealsWidgetService.sync(_meals));
    unawaited(DashboardWidgetService.sync());
  }

  /// Updates an existing meal record.
  Future<void> updateMeal(MealEntry meal) async {
    final index = _meals.indexWhere((m) => m.id == meal.id);
    if (index >= 0) {
      _meals[index] = meal;
      _meals.sort((a, b) => b.dateTime.compareTo(a.dateTime));
      await LocalStore.writeMeal(meal);
      notifyListeners();
      await VaultManager.syncCurrentVault();
      unawaited(MealsWidgetService.sync(_meals));
      unawaited(DashboardWidgetService.sync());
    }
  }

  /// Deletes a meal record by id.
  Future<void> deleteMeal(String id) async {
    _meals.removeWhere((m) => m.id == id);
    await LocalStore.removeMeals([id]);
    notifyListeners();
    await VaultManager.syncCurrentVault();
    unawaited(MealsWidgetService.sync(_meals));
    unawaited(DashboardWidgetService.sync());
  }

  /// Clears all meals.
  Future<void> clearAll() async {
    _meals.clear();
    await LocalStore.clearMeals();
    notifyListeners();
    await VaultManager.syncCurrentVault();
    unawaited(MealsWidgetService.sync(_meals));
    unawaited(DashboardWidgetService.sync());
  }
}
