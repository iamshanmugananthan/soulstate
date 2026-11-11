import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:soulstate/app/theme/app_tokens.dart';
import 'package:soulstate/core/extensions/date_extensions.dart';
import 'package:soulstate/core/extensions/inset_extensions.dart';
import 'package:soulstate/core/i18n/l10n.dart';
import 'package:soulstate/core/utils/responsive.dart';
import 'package:soulstate/features/meals/data/meal_entry.dart';
import 'package:soulstate/features/meals/data/meal_stats.dart';
import 'package:soulstate/features/meals/state/meals_controller.dart';
import 'package:soulstate/features/meals/widgets/meal_analysis.dart';
import 'package:soulstate/features/meals/widgets/meal_calendar.dart';
import 'package:soulstate/features/meals/widgets/meal_editor_sheet.dart';
import 'package:soulstate/features/meals/widgets/meal_tile.dart';
import 'package:soulstate/features/money/data/money_stats.dart';
import 'package:soulstate/features/money/widgets/money_kit.dart';
import 'package:soulstate/features/settings/state/settings_controller.dart';

/// Meal and Nutrition Tracker page.
///
/// Allows users to log daily meals, classify them as healthy vs unhealthy,
/// track total daily calories, period analysis, and calendar like Money page.
class MealTrackerPage extends StatefulWidget {
  const MealTrackerPage({super.key});

  @override
  State<MealTrackerPage> createState() => _MealTrackerPageState();
}

class _MealTrackerPageState extends State<MealTrackerPage> {
  int _view = 0; // 0: Overview, 1: Analysis, 2: Calendar
  DateTime _selectedDate = AppClock.today();

  late DateTime _month = DateTime(AppClock.today().year, AppClock.today().month, 1);
  late DateTime _calendarSelected = AppClock.today();

  MoneyPeriod _period = MoneyPeriod.month;
  late DateTime _anchor = AppClock.today();

  void _shiftMonth(int steps) {
    final next = DateTime(_month.year, _month.month + steps, 1);
    final today = AppClock.today();
    final isCurrent = next.year == today.year && next.month == today.month;
    setState(() {
      _month = next;
      _calendarSelected = isCurrent ? today : next;
    });
  }

  void _jumpToCalendarToday() {
    final today = AppClock.today();
    setState(() {
      _month = DateTime(today.year, today.month, 1);
      _calendarSelected = today;
    });
  }

  void _shiftAnalysis(int steps) =>
      setState(() => _anchor = MoneyRange.shift(_period, _anchor, steps));

  void _previousDay() {
    setState(() {
      _selectedDate = _selectedDate.subtract(const Duration(days: 1));
    });
  }

  void _nextDay() {
    setState(() {
      _selectedDate = _selectedDate.add(const Duration(days: 1));
    });
  }

  void _jumpToToday() {
    setState(() {
      _selectedDate = AppClock.today();
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final mealsController = context.watch<MealsController>();
    final stats = mealsController.statsFor(_selectedDate);
    final isToday = _selectedDate.isSameDay(AppClock.today());
    final isWide = isTabletOrDesktop(context);

    const side = 16.0;
    final railed = hasSideRail(context);
    final listPadding = context.pagePadding(
      side,
      8,
      side,
      railed ? 110 : 160,
    );

    final dateLabel = isToday
        ? 'Today, ${DateFormat.MMMd().format(_selectedDate)}'
        : DateFormat('EEEE, MMM d').format(_selectedDate);

    final Widget body = switch (_view) {
      1 => MealAnalysis(
          period: _period,
          anchor: _anchor,
          padding: listPadding,
          onPeriod: (p) => setState(() => _period = p),
          onShift: _shiftAnalysis,
          onToday: () => setState(() => _anchor = AppClock.today()),
        ),
      2 => MealCalendar(
          month: _month,
          selected: _calendarSelected,
          padding: listPadding,
          onSelect: (day) => setState(() => _calendarSelected = day),
          onShift: _shiftMonth,
          onToday: _jumpToCalendarToday,
          onAdd: () => MealEditorSheet.show(context, date: _calendarSelected),
        ),
      _ => _buildOverview(
          context: context,
          mealsController: mealsController,
          stats: stats,
          isWide: isWide,
          dateLabel: dateLabel,
        ),
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Meal & Nutrition',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          if (_view == 0 && !isToday)
            TextButton.icon(
              onPressed: _jumpToToday,
              icon: const Icon(LucideIcons.calendarCheck, size: 16),
              label: const Text('Today'),
            ),
          if (_view == 0)
            IconButton(
              icon: const Icon(LucideIcons.calendar),
              tooltip: 'Pick date',
              onPressed: _pickDate,
            ),
          IconButton(
            icon: const Icon(LucideIcons.plus),
            tooltip: 'Log meal',
            onPressed: () => MealEditorSheet.show(
              context,
              date: _view == 2 ? _calendarSelected : _selectedDate,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => MealEditorSheet.show(
          context,
          date: _view == 2 ? _calendarSelected : _selectedDate,
        ),
        child: const Icon(LucideIcons.plus),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: maxContentWidth),
          child: Column(
            children: [
              Padding(
                padding: context.pagePadding(side, 4, side, 4),
                child: MoneySegmented(
                  options: [
                    context.l10n.money_overview,
                    context.l10n.money_analysis,
                    context.l10n.money_calendar,
                  ],
                  index: _view,
                  onChanged: (i) => setState(() => _view = i),
                ),
              ),
              Expanded(
                child: KeyedSubtree(
                  key: ValueKey(_view),
                  child: body,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverview({
    required BuildContext context,
    required MealsController mealsController,
    required DailyMealStats stats,
    required bool isWide,
    required String dateLabel,
  }) {
    return ListView(
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        MediaQuery.viewPaddingOf(context).bottom + 90,
      ),
      children: [
        // Date Switcher Header
        _DateSelectorBar(
          dateLabel: dateLabel,
          onPrevious: _previousDay,
          onNext: _nextDay,
          onTapDate: _pickDate,
          onAdd: () => MealEditorSheet.show(context, date: _selectedDate),
        ),
        const SizedBox(height: 16),

        if (isWide)
          // Tablet / PC widescreen: 2-column layout
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 4,
                child: Column(
                  children: [
                    _NutritionHeroCard(stats: stats),
                    const SizedBox(height: 16),
                    _WeeklyTrendCard(
                      statsList: mealsController.recentDaysStats(
                        endDate: _selectedDate,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                flex: 6,
                child: Column(
                  children: [
                    for (final type in MealType.values)
                      _MealSection(
                        date: _selectedDate,
                        type: type,
                        meals: mealsController.mealsForDateAndType(
                          _selectedDate,
                          type,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          )
        else
          // Mobile layout: Single column
          Column(
            children: [
              _NutritionHeroCard(stats: stats),
              const SizedBox(height: 16),
              _WeeklyTrendCard(
                statsList: mealsController.recentDaysStats(
                  endDate: _selectedDate,
                ),
              ),
              const SizedBox(height: 20),
              for (final type in MealType.values)
                _MealSection(
                  date: _selectedDate,
                  type: type,
                  meals: mealsController.mealsForDateAndType(
                    _selectedDate,
                    type,
                  ),
                ),
            ],
          ),
      ],
    );
  }
}

class _DateSelectorBar extends StatelessWidget {
  const _DateSelectorBar({
    required this.dateLabel,
    required this.onPrevious,
    required this.onNext,
    required this.onTapDate,
    required this.onAdd,
  });

  final String dateLabel;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onTapDate;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(LucideIcons.chevronLeft),
            onPressed: onPrevious,
            tooltip: 'Previous Day',
          ),
          Flexible(
            child: InkWell(
              onTap: onTapDate,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(LucideIcons.calendarDays, size: 16),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        dateLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(LucideIcons.chevronRight),
            onPressed: onNext,
            tooltip: 'Next Day',
          ),
          IconButton(
            icon: const Icon(LucideIcons.plus, size: 20),
            onPressed: onAdd,
            tooltip: 'Log Meal',
          ),
        ],
      ),
    );
  }
}

class _NutritionHeroCard extends StatelessWidget {
  const _NutritionHeroCard({required this.stats});

  final DailyMealStats stats;

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsController>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final ratio = stats.healthyRatio;
    final pct = stats.healthyPercentage;

    final ringColor = stats.totalMeals == 0
        ? context.tokens.muted
        : ratio >= 0.7
            ? const Color(0xFF10B981)
            : ratio >= 0.4
                ? const Color(0xFFF59E0B)
                : const Color(0xFFEF4444);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.7),
                  theme.colorScheme.surfaceContainerLow.withValues(alpha: 0.9),
                ]
              : [
                  theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.8),
                  theme.colorScheme.surface,
                ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Circular score gauge
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 76,
                    height: 76,
                    child: CircularProgressIndicator(
                      value: stats.totalMeals == 0 ? 0 : ratio,
                      strokeWidth: 8,
                      backgroundColor: context.tokens.muted.withValues(alpha: 0.15),
                      valueColor: AlwaysStoppedAnimation(ringColor),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        stats.totalMeals == 0 ? '--' : '$pct%',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: ringColor,
                        ),
                      ),
                      Text(
                        'CLEAN',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                          color: context.tokens.muted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(width: 20),

              // Title and guidance
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stats.feedbackTitle,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      stats.feedbackSubtitle,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.35,
                        color: context.tokens.muted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(height: 1),
          const SizedBox(height: 16),

          // Metric highlights
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                child: _MetricPill(
                  emoji: '🥗',
                  value: '${stats.healthyCount}',
                  label: 'Healthy',
                  color: const Color(0xFF10B981),
                ),
              ),
              Expanded(
                child: _MetricPill(
                  emoji: '🍔',
                  value: '${stats.unhealthyCount}',
                  label: 'Unhealthy',
                  color: const Color(0xFFF59E0B),
                ),
              ),
              Expanded(
                child: _MetricPill(
                  emoji: '🔥',
                  value: stats.totalCalories > 0
                      ? '${stats.totalCalories}'
                      : 'Goal: ${settings.calorieGoal}',
                  label: stats.totalCalories > 0
                      ? '/ ${settings.calorieGoal} kcal'
                      : 'Calories',
                  color: const Color(0xFFF97316),
                ),
              ),
            ],
          ),
          if (settings.showMealMacros) ...[
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: const Row(
                children: [
                  Expanded(flex: 30, child: ColoredBox(color: Color(0xFF3B82F6), child: SizedBox(height: 6))),
                  Expanded(flex: 45, child: ColoredBox(color: Color(0xFFF59E0B), child: SizedBox(height: 6))),
                  Expanded(flex: 25, child: ColoredBox(color: Color(0xFFEF4444), child: SizedBox(height: 6))),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Protein: 30%', style: TextStyle(fontSize: 11, color: context.tokens.muted)),
                Text('Carbs: 45%', style: TextStyle(fontSize: 11, color: context.tokens.muted)),
                Text('Fat: 25%', style: TextStyle(fontSize: 11, color: context.tokens.muted)),
              ],
            ),
          ],
          if (settings.showMealWater) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(LucideIcons.droplets, size: 16, color: Color(0xFF0EA5E9)),
                  const SizedBox(width: 8),
                  Text(
                    'Water Tracker',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '6 / 8 glasses',
                    style: TextStyle(fontSize: 12, color: context.tokens.muted),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MetricPill extends StatelessWidget {
  const _MetricPill({
    required this.emoji,
    required this.value,
    required this.label,
    required this.color,
  });

  final String emoji;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: context.tokens.muted,
            ),
          ),
        ],
      ),
    );
  }
}

class _WeeklyTrendCard extends StatelessWidget {
  const _WeeklyTrendCard({required this.statsList});

  final List<DailyMealStats> statsList;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Text(
                  '7-Day Clean Eating Trend',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _LegendDot(color: const Color(0xFF10B981), label: 'Clean'),
                  const SizedBox(width: 10),
                  _LegendDot(color: const Color(0xFFF59E0B), label: 'Cheat'),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: statsList.map((dayStats) {
              final dayName = DateFormat('E').format(dayStats.date)[0];
              final total = dayStats.totalMeals;
              final healthy = dayStats.healthyCount;
              final unhealthy = dayStats.unhealthyCount;

              final totalHeight = 64.0;
              final healthyHeight = total == 0 ? 0.0 : (healthy / total) * totalHeight;
              final unhealthyHeight = total == 0 ? 0.0 : (unhealthy / total) * totalHeight;

              return Expanded(
                child: Column(
                  children: [
                    Container(
                      width: 22,
                      height: totalHeight,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: total == 0
                          ? Center(
                              child: Container(
                                width: 4,
                                height: 4,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: context.tokens.muted.withValues(alpha: 0.4),
                                ),
                              ),
                            )
                          : Column(
                              verticalDirection: VerticalDirection.up,
                              children: [
                                Container(
                                  height: healthyHeight,
                                  color: const Color(0xFF10B981),
                                ),
                                Container(
                                  height: unhealthyHeight,
                                  color: const Color(0xFFF59E0B),
                                ),
                              ],
                            ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      dayName,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: context.tokens.muted,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: context.tokens.muted,
          ),
        ),
      ],
    );
  }
}

class _MealSection extends StatelessWidget {
  const _MealSection({
    required this.date,
    required this.type,
    required this.meals,
  });

  final DateTime date;
  final MealType type;
  final List<MealEntry> meals;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Text(
                      type.iconEmoji,
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        type.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (meals.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${meals.length}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(LucideIcons.plusCircle, size: 20),
                tooltip: 'Add ${type.label}',
                onPressed: () => MealEditorSheet.show(
                  context,
                  date: date,
                  type: type,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (meals.isEmpty)
            InkWell(
              onTap: () => MealEditorSheet.show(
                context,
                date: date,
                type: type,
              ),
              borderRadius: BorderRadius.circular(14),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Theme.of(context)
                        .colorScheme
                        .outlineVariant
                        .withValues(alpha: 0.3),
                    style: BorderStyle.solid,
                  ),
                ),
                child: Center(
                  child: Text(
                    'No ${type.label.toLowerCase()} logged • Tap to add',
                    style: TextStyle(
                      fontSize: 13,
                      color: context.tokens.muted.withValues(alpha: 0.8),
                    ),
                  ),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: meals.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final meal = meals[index];
                return MealTile(
                  meal: meal,
                  onTap: () => MealEditorSheet.show(
                    context,
                    meal: meal,
                  ),
                  onDelete: () =>
                      context.read<MealsController>().deleteMeal(meal.id),
                );
              },
            ),
        ],
      ),
    );
  }
}
