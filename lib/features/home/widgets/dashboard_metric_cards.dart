import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:soulstate/app/theme/app_tokens.dart';
import 'package:soulstate/core/extensions/date_extensions.dart';
import 'package:soulstate/core/routing/app_navigator.dart';
import 'package:soulstate/core/utils/money_format.dart';
import 'package:soulstate/core/widgets/sheet_type.dart';
import 'package:soulstate/features/habits/pages/habit_tracker_page.dart';
import 'package:soulstate/features/habits/state/habits_controller.dart';
import 'package:soulstate/features/meals/pages/meal_tracker_page.dart';
import 'package:soulstate/features/meals/state/meals_controller.dart';
import 'package:soulstate/features/money/data/money_stats.dart';
import 'package:soulstate/features/money/pages/money_page.dart';
import 'package:soulstate/features/money/state/money_controller.dart';
import 'package:soulstate/features/money/widgets/money_kit.dart';
import 'package:soulstate/features/settings/state/settings_controller.dart';

/// 6 interactive square metric cards built with the standard [MoneyCard] design
/// matching Habit Tracker, Money Tracker, and Meal Tracker.
///
/// Organized into two sections:
/// 1. "Today" with current day's formatted date, followed by 3 square cards (Habits, Spending, Nutrition).
/// 2. "This Month" with current month name, followed by 3 square cards with month progress bars.
class DashboardMetricCards extends StatelessWidget {
  const DashboardMetricCards({
    super.key,
    this.onTapHabits,
    this.onTapMoney,
    this.onTapMeals,
  });

  final VoidCallback? onTapHabits;
  final VoidCallback? onTapMoney;
  final VoidCallback? onTapMeals;

  @override
  Widget build(BuildContext context) {
    final habits = context.watch<HabitsController>();
    final money = context.watch<MoneyController>();
    final meals = context.watch<MealsController>();
    final settings = context.watch<SettingsController>();

    final today = AppClock.today();
    final weekStart = settings.weekStart;
    final currency = settings.currency.isEmpty
        ? defaultCurrencySymbol()
        : settings.currency;
    final locale = Localizations.localeOf(context).toString();

    // Dynamic section labels that automatically change every day and every month
    String todayDateText;
    String monthDateText;
    try {
      todayDateText = DateFormat('EEE, MMM d', locale).format(today);
      monthDateText = DateFormat('MMMM yyyy', locale).format(today);
    } catch (_) {
      todayDateText = DateFormat('EEE, MMM d').format(today);
      monthDateText = DateFormat('MMMM yyyy').format(today);
    }

    // ----------------------------------------------------
    // 1. HABITS METRICS (TODAY & MONTH)
    // ----------------------------------------------------
    final scheduledHabits =
        habits.habits.where((h) => h.isScheduledOn(today)).toList();
    final completedCount =
        scheduledHabits.where((h) => h.isCompletedOn(today)).length;
    final totalHabits = scheduledHabits.length;
    final habitsRatio =
        totalHabits == 0 ? 1.0 : completedCount / totalHabits;
    final habitsPct = (habitsRatio * 100).round();
    final habitsSubtext = totalHabits == 0
        ? 'No habits'
        : completedCount == totalHabits
            ? 'All done! ✨'
            : '$habitsPct% done';

    // Month Habits
    final monthRange = MoneyRange.of(MoneyPeriod.month, today, weekStart);
    final fromDate = monthRange.start ?? DateTime(today.year, today.month, 1);
    final toDate =
        monthRange.end != null ? monthRange.end!.addDays(-1) : today;
    var monthScheduled = 0;
    var monthDone = 0.0;
    for (final habit in habits.habits) {
      final tally = habit.tally(fromDate, toDate);
      monthScheduled += tally.days;
      monthDone += tally.done;
    }
    final monthHabitRate = monthScheduled == 0
        ? 0.0
        : (monthDone / monthScheduled).clamp(0.0, 1.0);
    final monthHabitPct = (monthHabitRate * 100).round();
    final monthHabitsSubtext = monthScheduled == 0
        ? 'No habits'
        : '${monthDone.round()} / $monthScheduled done';

    // ----------------------------------------------------
    // 2. MONEY METRICS (TODAY & MONTH)
    // ----------------------------------------------------
    final todayTxs = MoneyStats.within(
      money.transactions,
      MoneyRange.of(MoneyPeriod.today, today, weekStart),
    );
    final todayTotals = MoneyStats.totals(todayTxs);
    final spentAmount = todayTotals.expense;
    final formattedSpent = formatMoney(spentAmount, currency, locale);
    final spentSubtext =
        todayTxs.isEmpty ? 'No spend' : '${todayTxs.length} txns';

    // Month Money
    final monthTxs = MoneyStats.within(money.transactions, monthRange);
    final monthTotals = MoneyStats.totals(monthTxs);
    final monthSpent = monthTotals.expense;
    final formattedMonthSpent = formatMoney(monthSpent, currency, locale);
    final daysInMonth = DateTime(today.year, today.month + 1, 0).day;
    final monthDayProgress = (today.day / daysInMonth).clamp(0.0, 1.0);
    final monthSpendingRatio = monthTotals.income > 0
        ? (monthTotals.expense / monthTotals.income).clamp(0.0, 1.0)
        : monthTotals.expense > 0
            ? monthDayProgress
            : 0.0;
    final monthSpentSubtext = monthTxs.isEmpty
        ? '${today.day}/$daysInMonth days'
        : '${monthTxs.length} txns this mo';

    // ----------------------------------------------------
    // 3. MEALS METRICS (TODAY & MONTH)
    // ----------------------------------------------------
    final mealStats = meals.todayStats;
    final totalMeals = mealStats.totalMeals;
    final cleanPct = mealStats.healthyPercentage;
    final mealsSubtext = totalMeals == 0
        ? 'Tap to log'
        : '${mealStats.healthyCount} 🥗 • ${mealStats.unhealthyCount} 🍔';

    // Month Meals
    final monthMeals = meals.all
        .where((m) =>
            m.dateTime.year == today.year && m.dateTime.month == today.month)
        .toList();
    final monthHealthy = monthMeals.where((m) => m.isHealthy).length;
    final monthTotalMeals = monthMeals.length;
    final monthCleanPct = monthTotalMeals == 0
        ? 0
        : ((monthHealthy / monthTotalMeals) * 100).round();
    final monthCleanRatio = monthTotalMeals == 0
        ? 0.0
        : (monthHealthy / monthTotalMeals).clamp(0.0, 1.0);
    final monthMealsSubtext = monthTotalMeals == 0
        ? 'No meals yet'
        : '$monthHealthy / $monthTotalMeals healthy';

    // ----------------------------------------------------
    // TODAY CARDS (SQUARE MONEYCARDS)
    // ----------------------------------------------------
    final todayHabitsCard = _SquareMetricCard(
      title: 'Habits',
      headline: '$completedCount / $totalHabits',
      subtext: habitsSubtext,
      icon: LucideIcons.flame,
      accentColor: const Color(0xFFF97316),
      progressValue: totalHabits == 0 ? 0.0 : habitsRatio,
      onTap: onTapHabits ?? () => AppNavigator.push(const HabitTrackerPage()),
    );

    final todayMoneyCard = _SquareMetricCard(
      title: 'Spending',
      headline: formattedSpent,
      subtext: spentSubtext,
      icon: LucideIcons.wallet,
      accentColor: const Color(0xFF0EA5E9),
      progressValue: todayTxs.isEmpty ? 0.0 : 1.0,
      onTap: onTapMoney ?? () => AppNavigator.push(const MoneyPage()),
    );

    final todayMealsCard = _SquareMetricCard(
      title: 'Nutrition',
      headline: totalMeals == 0 ? '0 Meals' : '$cleanPct%',
      subtext: mealsSubtext,
      icon: LucideIcons.utensils,
      accentColor: const Color(0xFF10B981),
      progressValue: totalMeals == 0 ? 0.0 : mealStats.healthyRatio,
      onTap: onTapMeals ?? () => AppNavigator.push(const MealTrackerPage()),
    );

    // ----------------------------------------------------
    // MONTH CARDS (SQUARE MONEYCARDS WITH MONTH BARS)
    // ----------------------------------------------------
    final monthHabitsCard = _SquareMetricCard(
      title: 'Habits',
      headline: '$monthHabitPct%',
      subtext: monthHabitsSubtext,
      icon: LucideIcons.flame,
      accentColor: const Color(0xFFF97316),
      progressValue: monthHabitRate,
      onTap: onTapHabits ?? () => AppNavigator.push(const HabitTrackerPage()),
    );

    final monthMoneyCard = _SquareMetricCard(
      title: 'Spending',
      headline: formattedMonthSpent,
      subtext: monthSpentSubtext,
      icon: LucideIcons.wallet,
      accentColor: const Color(0xFF0EA5E9),
      progressValue: monthSpendingRatio,
      onTap: onTapMoney ?? () => AppNavigator.push(const MoneyPage()),
    );

    final monthMealsCard = _SquareMetricCard(
      title: 'Nutrition',
      headline: monthTotalMeals == 0 ? '0 Meals' : '$monthCleanPct%',
      subtext: monthMealsSubtext,
      icon: LucideIcons.utensils,
      accentColor: const Color(0xFF10B981),
      progressValue: monthCleanRatio,
      onTap: onTapMeals ?? () => AppNavigator.push(const MealTrackerPage()),
    );

    final todayCards = <Widget>[
      todayHabitsCard,
      if (settings.moneyEnabled) todayMoneyCard,
      if (settings.mealsEnabled) todayMealsCard,
    ];

    final monthCards = <Widget>[
      monthHabitsCard,
      if (settings.moneyEnabled) monthMoneyCard,
      if (settings.mealsEnabled) monthMealsCard,
    ];

    if (todayCards.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 720;

        // Widescreen PC / Tablet layout: side-by-side columns
        if (isWide && todayCards.length == 3) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionHeader(
                      title: 'Today',
                      subtitle: todayDateText,
                      icon: LucideIcons.sunMedium,
                      accentColor: const Color(0xFFF97316),
                    ),
                    Row(
                      children: [
                        for (var i = 0; i < todayCards.length; i++) ...[
                          if (i > 0) const SizedBox(width: 10),
                          Expanded(
                            child: AspectRatio(
                              aspectRatio: 1.0,
                              child: todayCards[i],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionHeader(
                      title: 'This Month',
                      subtitle: monthDateText,
                      icon: LucideIcons.calendarDays,
                      accentColor: const Color(0xFF0EA5E9),
                    ),
                    Row(
                      children: [
                        for (var i = 0; i < monthCards.length; i++) ...[
                          if (i > 0) const SizedBox(width: 10),
                          Expanded(
                            child: AspectRatio(
                              aspectRatio: 1.0,
                              child: monthCards[i],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        }

        // Mobile layout: Stacked sections (Today -> 3 cards -> This Month -> 3 cards)
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _SectionHeader(
              title: 'Today',
              subtitle: todayDateText,
              icon: LucideIcons.sunMedium,
              accentColor: const Color(0xFFF97316),
            ),
            Row(
              children: [
                for (var i = 0; i < todayCards.length; i++) ...[
                  if (i > 0) const SizedBox(width: 10),
                  Expanded(
                    child: AspectRatio(
                      aspectRatio: 1.0,
                      child: todayCards[i],
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 20),
            _SectionHeader(
              title: 'This Month',
              subtitle: monthDateText,
              icon: LucideIcons.calendarDays,
              accentColor: const Color(0xFF0EA5E9),
            ),
            Row(
              children: [
                for (var i = 0; i < monthCards.length; i++) ...[
                  if (i > 0) const SizedBox(width: 10),
                  Expanded(
                    child: AspectRatio(
                      aspectRatio: 1.0,
                      child: monthCards[i],
                    ),
                  ),
                ],
              ],
            ),
          ],
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: accentColor),
              const SizedBox(width: 7),
              Text(
                title,
                style: sheetHeadingStyle(context, size: 16),
              ),
            ],
          ),
          Text(
            subtitle,
            style: sheetBodyStyle(context, size: 12.5),
          ),
        ],
      ),
    );
  }
}

class _SquareMetricCard extends StatelessWidget {
  const _SquareMetricCard({
    required this.title,
    required this.headline,
    required this.subtext,
    required this.icon,
    required this.accentColor,
    required this.progressValue,
    this.onTap,
  });

  final String title;
  final String headline;
  final String subtext;
  final IconData icon;
  final Color accentColor;
  final double progressValue;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return MoneyCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Top: Icon + Label (consistent with Habit & Meal Tracker summary boxes)
          Row(
            children: [
              Icon(icon, size: 15, color: accentColor),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: sheetBodyStyle(context, size: 12),
                ),
              ),
            ],
          ),

          // Middle: Headline Figure
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              headline,
              maxLines: 1,
              style: sheetFigureStyle(context, size: 19),
            ),
          ),

          // Bottom: Progress bar + Subtext
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: SizedBox(
                  height: 5,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ColoredBox(
                        color: accentColor.withValues(alpha: 0.16),
                      ),
                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: FractionallySizedBox(
                          widthFactor: progressValue.clamp(0.0, 1.0),
                          child: ColoredBox(color: accentColor),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 5),
              Text(
                subtext,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  color: context.tokens.muted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
