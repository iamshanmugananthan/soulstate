import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:soulstate/app/theme/app_tokens.dart';
import 'package:soulstate/core/i18n/l10n.dart';
import 'package:soulstate/core/extensions/date_extensions.dart';
import 'package:soulstate/core/routing/app_navigator.dart';
import 'package:soulstate/core/utils/app_snackbar.dart';
import 'package:soulstate/core/utils/responsive.dart';
import 'package:soulstate/features/habits/pages/habit_tracker_page.dart';
import 'package:soulstate/features/habits/state/habits_controller.dart';
import 'package:soulstate/features/habits/widgets/daily_quote.dart';
import 'package:soulstate/features/home/widgets/dashboard_metric_cards.dart';
import 'package:soulstate/features/home/widgets/today_meals_section.dart';
import 'package:soulstate/features/home/widgets/today_spending_section.dart';
import 'package:soulstate/features/home/widgets/weekly_momentum_section.dart';
import 'package:soulstate/features/settings/pages/settings_page.dart';
import 'package:soulstate/features/settings/settings_actions.dart';
import 'package:soulstate/features/settings/state/settings_controller.dart';
import 'package:soulstate/features/todos/pages/todos_page.dart';
import 'package:soulstate/features/todos/state/todos_controller.dart';
import 'package:soulstate/features/vault/services/vault_manager.dart';
import 'package:soulstate/services/s3_service.dart';

/// The central Lifestyle Dashboard of Soul State.
///
/// Unifies vital metrics across daily habits, expenses, nutrition, and tasks
/// into a cohesive, responsive dashboard that adapts cleanly across mobile and PC widescreen.
class HomePage extends StatelessWidget {
  const HomePage({super.key, this.onOpenHabits});

  final VoidCallback? onOpenHabits;

  String _greetingText(BuildContext context) {
    final hour = DateTime.now().hour;
    if (hour < 12) return context.l10n.good_morning;
    if (hour < 17) return context.l10n.good_afternoon;
    return context.l10n.good_evening;
  }

  void _navigateToHabits(BuildContext context) {
    if (onOpenHabits != null) {
      onOpenHabits!();
    } else {
      AppNavigator.push(const HabitTrackerPage());
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsController>();
    final showTodos = settings.todosEnabled;
    final showMoney = settings.moneyEnabled;
    final showMeals = settings.mealsEnabled;
    final today = AppClock.today();
    final locale = Localizations.localeOf(context).toString();
    final dateFormatted = DateFormat('EEEE, MMMM d', locale).format(today);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: maxContentWidth),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWideDashboard = constraints.maxWidth >= 720;
                return ListView(
                  padding: EdgeInsets.fromLTRB(
                    20,
                    16,
                    20,
                    MediaQuery.viewPaddingOf(context).bottom + 90,
                  ),
                  children: [
                    // Top App Bar / Greeting Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      _greetingText(context),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: context.tokens.muted,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Text('✨', style: TextStyle(fontSize: 14)),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                dateFormatted,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.6,
                                ),
                              ),
                              const SizedBox(height: 6),
                              const DailyQuote(),
                            ],
                          ),
                        ),
                        if (settings.isS3SyncActive) ...[
                          const _S3SyncButton(),
                        ],
                        IconButton(
                          icon: const Icon(LucideIcons.settings),
                          tooltip: context.l10n.settings,
                          onPressed: () => AppNavigator.push(
                            const SettingsPage(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Daily & Monthly Vital Metrics Cards (Habits, Spending, Nutrition)
                    DashboardMetricCards(
                      onTapHabits: () => _navigateToHabits(context),
                    ),
                    const SizedBox(height: 20),

                    // Main Responsive Dashboard Content
                    if (isWideDashboard)
                      // PC widescreen / Tablet 2-column layout
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Left Column: Habits Snapshot + Meals Section
                          Expanded(
                            flex: 6,
                            child: Column(
                              children: [
                                _HabitsDashboardCard(
                                  onViewAll: () => _navigateToHabits(context),
                                ),
                                if (showMeals) ...[
                                  const SizedBox(height: 20),
                                  const TodayMealsSection(),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(width: 20),

                          // Right Column: Spending + Tasks + Weekly Momentum
                          Expanded(
                            flex: 5,
                            child: Column(
                              children: [
                                if (showMoney) ...[
                                  const TodaySpendingSection(),
                                  const SizedBox(height: 20),
                                ],
                                if (showTodos) ...[
                                  const _TodosDashboardCard(),
                                  const SizedBox(height: 20),
                                ],
                                const WeeklyMomentumSection(),
                              ],
                            ),
                          ),
                        ],
                      )
                    else
                      // Phone single column stream
                      Column(
                        children: [
                          _HabitsDashboardCard(
                            onViewAll: () => _navigateToHabits(context),
                          ),
                          if (showMoney) ...[
                            const SizedBox(height: 20),
                            const TodaySpendingSection(),
                          ],
                          if (showMeals) ...[
                            const SizedBox(height: 20),
                            const TodayMealsSection(),
                          ],
                          if (showTodos) ...[
                            const SizedBox(height: 20),
                            const _TodosDashboardCard(),
                          ],
                          const SizedBox(height: 20),
                          const WeeklyMomentumSection(),
                        ],
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// A clean, high-level Habit Overview Card on the Dashboard.
class _HabitsDashboardCard extends StatelessWidget {
  const _HabitsDashboardCard({required this.onViewAll});

  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    final habits = context.watch<HabitsController>().habits;
    final today = AppClock.today();
    final theme = Theme.of(context);

    final totalCount = habits.length;
    final completedCount = habits.where((h) => h.isCompletedOn(today)).length;
    final progress = totalCount == 0 ? 0.0 : completedCount / totalCount;

    // Top active streaks
    final activeStreaks = habits.where((h) => h.currentStreak > 0).toList()
      ..sort((a, b) => b.currentStreak.compareTo(a.currentStreak));
    final topHabit = activeStreaks.isNotEmpty ? activeStreaks.first : null;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF97316).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  LucideIcons.flame,
                  size: 16,
                  color: Color(0xFFF97316),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  context.l10n.habits_overview,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: onViewAll,
                icon: const Icon(LucideIcons.arrowRight, size: 14),
                label: Text(
                  context.l10n.tracker,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.habits_completed_today(completedCount, totalCount),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 8,
                        backgroundColor: theme.colorScheme.surfaceContainerHighest,
                        valueColor: AlwaysStoppedAnimation(
                          progress >= 1.0
                              ? const Color(0xFF10B981)
                              : const Color(0xFFF97316),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF97316).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${(progress * 100).toInt()}%',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFFF97316),
                  ),
                ),
              ),
            ],
          ),
          if (topHabit != null) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Text('🔥', style: TextStyle(fontSize: 14)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Top streak: ${topHabit.name} (${topHabit.currentStreak} days)',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (habits.isNotEmpty) ...[
            const SizedBox(height: 14),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: habits.take(5).length,
              separatorBuilder: (_, __) => const SizedBox(height: 6),
              itemBuilder: (context, index) {
                final habit = habits[index];
                final isDone = habit.isCompletedOn(today);
                return InkWell(
                  onTap: () => context.read<HabitsController>().toggle(habit.id, today),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface.withValues(alpha: isDone ? 0.35 : 0.65),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDone
                            ? theme.colorScheme.outlineVariant.withValues(alpha: 0.15)
                            : habit.color.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isDone ? habit.color : Colors.transparent,
                            border: Border.all(
                              color: isDone ? habit.color : habit.color.withValues(alpha: 0.7),
                              width: 2,
                            ),
                          ),
                          child: isDone
                              ? const Icon(LucideIcons.check, size: 14, color: Colors.white)
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            habit.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              decoration: isDone ? TextDecoration.lineThrough : null,
                              color: isDone
                                  ? theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6)
                                  : theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                        if (habit.currentStreak > 0) ...[
                          const SizedBox(width: 8),
                          Text(
                            '🔥 ${habit.currentStreak}d',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFF97316),
                            ),
                          ),
                        ],
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

/// A compact Todos snapshot card on the Dashboard.
class _TodosDashboardCard extends StatelessWidget {
  const _TodosDashboardCard();

  @override
  Widget build(BuildContext context) {
    final todosController = context.watch<TodosController>();
    final pendingCount = todosController.pendingCount;
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  LucideIcons.listChecks,
                  size: 16,
                  color: Color(0xFF3B82F6),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  context.l10n.todo_tasks,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: () => AppNavigator.push(const TodosPage()),
                icon: const Icon(LucideIcons.arrowRight, size: 14),
                label: Text(
                  context.l10n.view_all,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  pendingCount == 0
                      ? context.l10n.all_tasks_completed
                      : context.l10n.tasks_remaining(pendingCount),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  context.l10n.tasks_pending(pendingCount),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF3B82F6),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _S3SyncButton extends StatefulWidget {
  const _S3SyncButton();

  @override
  State<_S3SyncButton> createState() => _S3SyncButtonState();
}

class _S3SyncButtonState extends State<_S3SyncButton> {
  bool _syncing = false;

  Future<void> _sync() async {
    if (_syncing) return;
    setState(() => _syncing = true);
    final habits = context.read<HabitsController>();

    try {
      final pullRes = await S3Service.pullLatestBackup(controller: habits);
      if (mounted && pullRes.updated) {
        await SettingsActions.reloadAll(context);
      }
      final pushRes = await S3Service.performBackup();
      await VaultManager.syncCurrentVault();

      if (mounted) {
        if (pushRes.ok) {
          AppSnackbar.success(
            context,
            pullRes.updated
                ? 'Synced latest changes with S3 Cloud'
                : 'Vault synced with S3 Cloud',
          );
        } else {
          AppSnackbar.error(context, pushRes.message);
        }
      }
    } catch (e) {
      if (mounted) {
        AppSnackbar.error(context, 'S3 sync error: $e');
      }
    } finally {
      if (mounted) setState(() => _syncing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: _syncing
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(
              LucideIcons.cloudUpload,
              color: Color(0xFF3B82F6),
            ),
      tooltip: 'Sync with S3 Cloud',
      onPressed: _syncing ? null : _sync,
    );
  }
}
