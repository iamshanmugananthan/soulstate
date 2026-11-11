import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:soulstate/app/theme/app_tokens.dart';
import 'package:soulstate/core/extensions/date_extensions.dart';
import 'package:soulstate/core/extensions/inset_extensions.dart';
import 'package:soulstate/core/i18n/l10n.dart';
import 'package:soulstate/core/widgets/cover_image.dart';
import 'package:soulstate/core/icons/habit_glyph.dart';
import 'package:soulstate/core/routing/app_navigator.dart';
import 'package:soulstate/core/widgets/number_keypad_dialog.dart';
import 'package:soulstate/core/widgets/section_label.dart';
import 'package:soulstate/features/habits/data/habit.dart';
import 'package:soulstate/features/habits/pages/habit_form_page.dart';
import 'package:soulstate/features/habits/pages/quant_stats_page.dart';
import 'package:soulstate/features/habits/state/habits_controller.dart';
import 'package:soulstate/features/habits/widgets/activity_calendar.dart';
import 'package:soulstate/features/habits/widgets/day_actions_sheet.dart';
import 'package:soulstate/features/habits/widgets/miss_reasons.dart';
import 'package:soulstate/features/habits/widgets/check_history.dart';
import 'package:soulstate/features/habits/widgets/frequency_chip.dart';
import 'package:soulstate/features/habits/widgets/habit_checklist.dart';
import 'package:soulstate/features/habits/widgets/habit_heatmap.dart';
import 'package:soulstate/core/widgets/glass.dart';
import 'package:soulstate/features/habits/widgets/quant_daily_bars.dart';
import 'package:soulstate/features/habits/widgets/quantitative_progress.dart';
import 'package:soulstate/features/habits/pages/habit_stats_page.dart';
import 'package:soulstate/features/habits/widgets/saved_money.dart';
import 'package:soulstate/features/habits/widgets/share_card.dart';
import 'package:soulstate/features/habits/widgets/soulstate_summary.dart';
import 'package:soulstate/features/habits/widgets/unscheduled_day_dialog.dart';
import 'package:soulstate/features/habits/widgets/vacation_sheet.dart';
import 'package:soulstate/features/settings/state/settings_controller.dart';
import 'package:soulstate/core/extensions/color_extensions.dart';

class HabitDetailsPage extends StatefulWidget {
  const HabitDetailsPage({super.key, required this.habitId});

  final String habitId;

  @override
  State<HabitDetailsPage> createState() => _HabitDetailsPageState();
}

class _HabitDetailsPageState extends State<HabitDetailsPage> {
  late HeatmapMode _mode;

  @override
  void initState() {
    super.initState();
    final saved = context.read<SettingsController>().heatmapMode;
    _mode = HeatmapMode.values[saved.clamp(0, 2)];
  }

  @override
  void dispose() {
    if (AppNavigator.paneItem.value == widget.habitId) {
      AppNavigator.paneItem.value = null;
    }
    super.dispose();
  }

  void _changeMode(HeatmapMode mode) {
    setState(() => _mode = mode);
    context.read<SettingsController>().setHeatmapMode(mode.index);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HabitsController>(
      builder: (context, controller, _) {
        final habit = controller.byId(widget.habitId);
        if (habit == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            AppNavigator.pop();
          });
          return const SizedBox.shrink();
        }

        Future<void> editAmount(DateTime date) async {
          final allowed =
              await confirmUnscheduledDay(context, habit: habit, date: date);
          if (!allowed || !context.mounted) return;

          final current = habit.completions[date.dayKey]?.count ?? 0;
          final value = await showNumberKeypadDialog(
            context,
            title: DateFormat.yMMMMd(
              Localizations.localeOf(context).toString(),
            ).format(date),
            value: current,
            unit: habit.unitLabel,
            target: habit.hasGoal ? habit.perDayTarget : null,
            decimals: true,
            clock: habit.isTimeAmount,
            accent: habit.color.shownIn(context),
          );
          if (value != null && value != current) {
            await controller.setProgress(habit.id, date, value);
          }
        }

        Future<void> toggleDay(DateTime date) async {
          final allowed =
              await confirmUnscheduledDay(context, habit: habit, date: date);
          if (!allowed) return;
          await controller.toggle(habit.id, date);
        }

        void toggle(DateTime date) {
          final prefs = context.read<SettingsController>();
          if (prefs.pastFirst && date.atMidnight.isBefore(AppClock.today())) {
            showDayActionsSheet(
              context,
              habit: habit,
              date: date,
            );
            return;
          }
          switch (habit.kind) {
            case HabitKind.positive:
              unawaited(toggleDay(date));
              break;
            case HabitKind.negative:
              final relapsed = habit.completions.containsKey(date.dayKey);
              relapsed
                  ? controller.clearRelapse(habit.id, date)
                  : controller.logRelapse(habit.id, date);
              break;
            case HabitKind.quantitative:
              unawaited(editAmount(date));
              break;
          }
        }

        void openDay(DateTime date) => showDayActionsSheet(
              context,
              habit: habit,
              date: date,
            );

        return Scaffold(
          appBar: AppBar(
            title: Row(
              children: [
                HabitGlyph(glyph: habit.icon, color: habit.color.shownIn(context), size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(habit.name, overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
            leadingWidth: 64,
            leading: Center(
              child: GlassIconButton(
                icon: LucideIcons.x,
                size: 38,
                tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                onTap: () => AppNavigator.pop(),
              ),
            ),
            actions: [
              GlassIconButton(
                icon: LucideIcons.share2,
                size: 38,
                tooltip: context.l10n.share_progress,
                onTap: () => showShareCard(context, habit),
              ),
              const SizedBox(width: 8),
              GlassIconButton(
                icon: LucideIcons.pencil,
                size: 38,
                tooltip: context.l10n.edit,
                onTap: () => AppNavigator.push(
                  HabitFormPage(habit: habit),
                  fullscreenDialog: true,
                ),
              ),
              const SizedBox(width: 16),
            ],
          ),
          body: _DetailBackground(
            coverPath: habit.coverPath,
            clarity: habit.coverClarity,
            child: ListView(
              padding: context.pagePadding(16, 16, 16, 16),
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: FrequencyChip(habit: habit),
                ),
                const SizedBox(height: 14),
                if (habit.description.isNotEmpty) ...[
                  Text(
                    habit.description,
                    style: TextStyle(
                      fontSize: 15,
                      color: context.tokens.muted,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
                if (habit.kind == HabitKind.quantitative) ...[
                  QuantitativeProgress(habit: habit),
                  const SizedBox(height: 20),
                  SectionLabel(
                    context.l10n.quant_per_day,
                    trailing: QuantStatsLink(habit: habit),
                  ),
                  QuantDailyBars(habit: habit),
                  const SizedBox(height: 20),
                ],
                if (habit.hasSubsteps) ...[
                  SectionLabel(context.l10n.todays_checklist),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: HabitChecklist(habit: habit, header: true),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
                SectionLabel(
                  context.l10n.streaks,
                  trailing: habit.kind != HabitKind.quantitative &&
                          hasHabitStats(habit)
                      ? QuantStatsLink(habit: habit)
                      : null,
                ),
                SoulStateSummary(habit: habit, mode: _mode),
                if (habit.hasCost) ...[
                  const SizedBox(height: 12),
                  SavedMoneyCard(habit: habit),
                ],
                const SizedBox(height: 20),
                SectionLabel(
                  context.l10n.activity,
                  trailing: _ModeToggle(mode: _mode, onChanged: _changeMode),
                ),
                _ActivityView(
                  habit: habit,
                  mode: _mode,
                  onToggle: toggle,
                  onLongPress: openDay,
                ),
                const SizedBox(height: 20),
                CheckHistoryTile(habit: habit),
                const SizedBox(height: 12),
                MissReasonsTile(habit: habit),
                _VacationTile(habit: habit),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DetailBackground extends StatelessWidget {
  const _DetailBackground({
    required this.coverPath,
    required this.clarity,
    required this.child,
  });

  final String coverPath;
  final int clarity;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final hasCover = CoverImage.exists(coverPath);
    if (!hasCover) return child;
    return Stack(
      children: [
        Positioned.fill(
          child: CoverImage(path: coverPath, clarity: clarity),
        ),
        Positioned.fill(
          child: ColoredBox(color: Colors.black.withValues(alpha: 0.78)),
        ),
        child,
      ],
    );
  }
}

class _ActivityView extends StatelessWidget {
  const _ActivityView({
    required this.habit,
    required this.mode,
    required this.onToggle,
    required this.onLongPress,
  });

  final Habit habit;
  final HeatmapMode mode;
  final void Function(DateTime date) onToggle;
  final void Function(DateTime date)? onLongPress;

  @override
  Widget build(BuildContext context) {
    if (mode == HeatmapMode.month) {
      return ActivityCalendar(
        habit: habit,
        onToggle: onToggle,
        onLongPress: onLongPress,
      );
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: HabitHeatmap(
          habit: habit,
          mode: mode,
          onToggle: mode == HeatmapMode.week ? onToggle : null,
          onLongPress: onLongPress,
        ),
      ),
    );
  }
}

class _VacationTile extends StatelessWidget {
  const _VacationTile({required this.habit});

  final Habit habit;

  @override
  Widget build(BuildContext context) {
    final color = context.tokens.info;
    final summary = vacationSummary(context, habit);

    return Card(
      child: ListTile(
        onTap: () => showVacationSheet(context, habit: habit),
        leading: Icon(LucideIcons.palmtree, size: 22, color: color),
        title: Text(
          context.l10n.vacation_mode,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: context.colors.onSurface,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              summary,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: habit.isOnVacation ? color : context.tokens.muted,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              LucideIcons.chevronRight,
              size: 18,
              color: context.tokens.muted,
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeToggle extends StatelessWidget {
  const _ModeToggle({required this.mode, required this.onChanged});

  final HeatmapMode mode;
  final ValueChanged<HeatmapMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    final options = [
      (HeatmapMode.week, context.l10n.week),
      (HeatmapMode.month, context.l10n.month),
      (HeatmapMode.year, context.l10n.year),
    ];
    return MediaQuery.withClampedTextScaling(
      maxScaleFactor: 1.3,
      child: Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final (value, label) in options)
              Flexible(
                child: Semantics(
                  button: true,
                  selected: value == mode,
                  child: GestureDetector(
                    onTap: () => onChanged(value),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: value == mode
                            ? scheme.primary
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: value == mode
                              ? scheme.onPrimary
                              : context.tokens.muted,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
