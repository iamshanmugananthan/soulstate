import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:soulstate/app/theme/app_tokens.dart';
import 'package:soulstate/core/extensions/color_extensions.dart';
import 'package:soulstate/core/extensions/date_extensions.dart';
import 'package:soulstate/core/extensions/inset_extensions.dart';
import 'package:soulstate/core/i18n/l10n.dart';
import 'package:soulstate/core/routing/app_navigator.dart';
import 'package:soulstate/core/routing/back_handlers.dart';
import 'package:soulstate/core/utils/responsive.dart';
import 'package:soulstate/core/widgets/celebration_overlay.dart';
import 'package:soulstate/core/widgets/stacked_corners.dart';
import 'package:soulstate/features/habits/data/habit.dart';
import 'package:soulstate/features/habits/pages/habit_details_page.dart';
import 'package:soulstate/features/habits/pages/habit_form_page.dart';
import 'package:soulstate/features/habits/state/habits_controller.dart';
import 'package:soulstate/features/habits/widgets/habit_analysis.dart';
import 'package:soulstate/features/habits/widgets/habit_calendar.dart';
import 'package:soulstate/features/habits/widgets/habit_card.dart';
import 'package:soulstate/features/habits/widgets/habit_heatmap.dart';
import 'package:soulstate/features/habits/widgets/swipe_check.dart';
import 'package:soulstate/features/habits/widgets/unscheduled_day_dialog.dart';
import 'package:soulstate/features/money/data/money_stats.dart';
import 'package:soulstate/features/money/widgets/money_kit.dart';
import 'package:soulstate/features/settings/pages/settings_page.dart';
import 'package:soulstate/features/settings/state/settings_controller.dart';

/// Dedicated Habit Tracker page with full streak tracking, heatmaps,
/// analysis, calendar, and responsive widescreen layout for PC.
class HabitTrackerPage extends StatefulWidget {
  const HabitTrackerPage({super.key});

  @override
  State<HabitTrackerPage> createState() => _HabitTrackerPageState();
}

class _HabitTrackerPageState extends State<HabitTrackerPage> {
  int _confetti = 0;
  bool _reordering = false;

  int _view = 0; // 0: Overview, 1: Analysis, 2: Calendar

  late DateTime _month = _firstOf(AppClock.today());
  late DateTime _selected = AppClock.today();

  MoneyPeriod _period = MoneyPeriod.month;
  late DateTime _anchor = AppClock.today();

  static DateTime _firstOf(DateTime day) => DateTime(day.year, day.month, 1);

  void _shiftMonth(int steps) {
    final next = DateTime(_month.year, _month.month + steps, 1);
    final today = AppClock.today();
    final isCurrent = next.year == today.year && next.month == today.month;
    setState(() {
      _month = next;
      _selected = isCurrent ? today : next;
    });
  }

  void _jumpToToday() {
    final today = AppClock.today();
    setState(() {
      _month = _firstOf(today);
      _selected = today;
    });
  }

  void _shiftAnalysis(int steps) =>
      setState(() => _anchor = MoneyRange.shift(_period, _anchor, steps));

  @override
  void initState() {
    super.initState();
    BackHandlers.add(_backOut);
  }

  @override
  void dispose() {
    BackHandlers.remove(_backOut);
    super.dispose();
  }

  bool _backOut() {
    if (!_reordering || !BackHandlers.isVisible(context)) return false;
    setState(() => _reordering = false);
    return true;
  }

  void _celebrate() => setState(() => _confetti++);

  Future<void> _toggleHabit(Habit habit, [DateTime? targetDate]) async {
    final date = targetDate ?? AppClock.today();
    if (!await confirmUnscheduledDay(context, habit: habit, date: date)) {
      return;
    }
    if (!mounted) return;
    final wasDone = habit.isCompletedOn(date);
    final controller = context.read<HabitsController>();
    await controller.toggle(habit.id, date);
    if (!mounted) return;
    final updated = controller.byId(habit.id);
    if (!wasDone && (updated?.isCompletedOn(date) ?? false)) {
      _celebrate();
    }
  }

  Future<void> _showHabitActions(Habit habit) async {
    final l10n = context.l10n;
    final controller = context.read<HabitsController>();
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(LucideIcons.arrowUpDown),
              title: Text(l10n.reorder),
              onTap: () {
                Navigator.pop(sheetContext);
                setState(() => _reordering = true);
              },
            ),
            ListTile(
              leading: const Icon(LucideIcons.copy),
              title: Text(l10n.duplicate_habit),
              onTap: () {
                Navigator.pop(sheetContext);
                AppNavigator.push(
                  HabitFormPage(template: habit),
                  fullscreenDialog: true,
                );
              },
            ),
            ListTile(
              leading: Icon(LucideIcons.trash2, color: context.tokens.danger),
              title: Text(
                l10n.delete,
                style: TextStyle(color: context.tokens.danger),
              ),
              onTap: () async {
                Navigator.pop(sheetContext);
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (dialogCtx) => AlertDialog(
                    title: Text(l10n.delete_habit),
                    content: Text(l10n.delete_habit_body(habit.name)),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(dialogCtx, false),
                        child: Text(l10n.cancel),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(dialogCtx, true),
                        child: Text(
                          l10n.delete,
                          style: TextStyle(color: context.tokens.danger),
                        ),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  await controller.remove(habit.id);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final habits = context.watch<HabitsController>();
    final settings = context.watch<SettingsController>();

    const side = 16.0;
    final railed = hasSideRail(context);
    final listPadding = context.pagePadding(
      side,
      8,
      side,
      railed ? 110 : 160,
    );

    final today = AppClock.today();
    final allHabits = habits.habits;
    final scheduled = settings.todayOnly
        ? allHabits.where((h) => h.isScheduledOn(today)).toList()
        : allHabits;
    final listed = settings.hideTracking
        ? scheduled.where((h) => !h.tracking).toList()
        : scheduled;

    final hidingDone = settings.hideDone && !_reordering;
    final visibleHabits = hidingDone
        ? listed.where((h) => !h.isCompletedOn(today)).toList()
        : listed;

    final scheduledHabits = allHabits.where((h) => h.isScheduledOn(today)).toList();
    final targetList = scheduledHabits.isEmpty ? allHabits : scheduledHabits;
    final completedCount = targetList.where((h) => h.isCompletedOn(today)).length;
    final progress = targetList.isEmpty ? 0.0 : completedCount / targetList.length;

    final Widget body = switch (_view) {
      1 => HabitAnalysis(
          period: _period,
          anchor: _anchor,
          padding: listPadding,
          onPeriod: (p) => setState(() => _period = p),
          onShift: _shiftAnalysis,
          onToday: () => setState(() => _anchor = AppClock.today()),
        ),
      2 => HabitCalendar(
          month: _month,
          selected: _selected,
          padding: listPadding,
          onSelect: (day) => setState(() => _selected = day),
          onShift: _shiftMonth,
          onToday: _jumpToToday,
        ),
      _ => _buildOverview(
          context: context,
          allHabits: allHabits,
          targetList: targetList,
          visibleHabits: visibleHabits,
          completedCount: completedCount,
          progress: progress,
          hidingDone: hidingDone,
          today: today,
          settings: settings,
        ),
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Habit Tracker',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.settings),
            tooltip: 'Settings',
            onPressed: () => AppNavigator.push(
              const SettingsPage(),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => AppNavigator.push(
          const HabitFormPage(),
          fullscreenDialog: true,
        ),
        child: const Icon(LucideIcons.plus),
      ),
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: Center(
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
          ),
          IgnorePointer(
            child: CelebrationOverlay(trigger: _confetti),
          ),
        ],
      ),
    );
  }

  Widget _buildOverview({
    required BuildContext context,
    required List<Habit> allHabits,
    required List<Habit> targetList,
    required List<Habit> visibleHabits,
    required int completedCount,
    required double progress,
    required bool hidingDone,
    required DateTime today,
    required SettingsController settings,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWidescreen = constraints.maxWidth >= 720;
        return ListView(
          padding: EdgeInsets.fromLTRB(
            20,
            12,
            20,
            MediaQuery.viewPaddingOf(context).bottom + 90,
          ),
          children: [
            // Progress bar card banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.4),
                    Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '$completedCount of ${targetList.length} habits completed today',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${(progress * 100).toInt()}%',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                      valueColor: AlwaysStoppedAnimation(
                        progress >= 1.0
                            ? const Color(0xFF10B981)
                            : Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Habit cards content
            if (visibleHabits.isEmpty)
              _buildEmptyState(context, allHabits.length, visibleHabits.length, hidingDone)
            else if (_reordering)
              _buildReorderList(visibleHabits)
            else if (isWidescreen)
              _buildWidescreenGrid(visibleHabits, today, settings)
            else
              _buildMobileList(visibleHabits, today, settings),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, int allCount, int filteredCount, bool hidingDone) {
    final theme = Theme.of(context);
    if (hidingDone && filteredCount > 0) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(LucideIcons.circleCheckBig, size: 36, color: context.tokens.muted),
            const SizedBox(height: 12),
            Text(
              context.l10n.all_done_today,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      );
    }
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        children: [
          const Text('🎯', style: TextStyle(fontSize: 40)),
          const SizedBox(height: 12),
          Text(
            allCount == 0 ? 'No habits created yet' : 'No habits scheduled for today',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            icon: const Icon(LucideIcons.plus, size: 18),
            label: Text(context.l10n.add_habit),
            onPressed: () => AppNavigator.push(
              const HabitFormPage(),
              fullscreenDialog: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWidescreenGrid(List<Habit> habits, DateTime today, SettingsController settings) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth >= 1000 ? 3 : 2;
        final rows = (habits.length + crossAxisCount - 1) ~/ crossAxisCount;

        return Column(
          children: [
            for (var r = 0; r < rows; r++) ...[
              if (r > 0) const SizedBox(height: 14),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var c = 0; c < crossAxisCount; c++) ...[
                    if (c > 0) const SizedBox(width: 14),
                    Expanded(
                      child: (r * crossAxisCount + c < habits.length)
                          ? _buildSingleHabitCard(
                              habits[r * crossAxisCount + c],
                              today,
                              settings,
                              null,
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ],
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildMobileList(List<Habit> habits, DateTime today, SettingsController settings) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: habits.length,
      separatorBuilder: (_, __) => SizedBox(height: settings.compactCards ? 2 : 12),
      itemBuilder: (context, index) {
        final habit = habits[index];
        final corners = settings.compactCards
            ? stackedCorners(index, habits.length)
            : null;
        return _buildSingleHabitCard(habit, today, settings, corners);
      },
    );
  }

  Widget _buildSingleHabitCard(
    Habit habit,
    DateTime today,
    SettingsController settings,
    BorderRadius? corners,
  ) {
    final mode = HeatmapMode.values[settings.openingMode.clamp(0, 2)];
    final card = HabitCard(
      habit: habit,
      mode: mode,
      corners: corners,
      onOpen: () => AppNavigator.push(
        HabitDetailsPage(habitId: habit.id),
      ),
      onToggleToday: () => _toggleHabit(habit),
      onToggleDay: (date) => _toggleHabit(habit, date),
      onLongPress: () => _showHabitActions(habit),
    );

    return SwipeCheck(
      done: habit.isCompletedOn(today),
      tint: habit.color.shownIn(context),
      corners: corners ?? BorderRadius.circular(24),
      onSwipe: settings.swipeCards ? () => _toggleHabit(habit) : null,
      child: card,
    );
  }

  Widget _buildReorderList(List<Habit> habits) {
    final habitsCtrl = context.read<HabitsController>();
    final mode = HeatmapMode.values[context.read<SettingsController>().openingMode.clamp(0, 2)];
    return ReorderableListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: habits.length,
      buildDefaultDragHandles: false,
      onReorderItem: (oldIndex, newIndex) {
        habitsCtrl.reorder(
          habits,
          oldIndex,
          newIndex > oldIndex ? newIndex + 1 : newIndex,
        );
      },
      itemBuilder: (context, index) {
        final habit = habits[index];
        return ReorderableDelayedDragStartListener(
          key: ValueKey(habit.id),
          index: index,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Expanded(
                  child: HabitCard(
                    habit: habit,
                    mode: mode,
                    onOpen: () {},
                    onToggleToday: () {},
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Icon(
                    LucideIcons.gripVertical,
                    color: context.tokens.muted,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
