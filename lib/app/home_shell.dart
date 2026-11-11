import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:soulstate/services/backup_service.dart';
import 'package:soulstate/app/theme/app_tokens.dart';
import 'package:soulstate/core/i18n/l10n.dart';
import 'package:soulstate/core/routing/app_navigator.dart';
import 'package:soulstate/core/database/local_store.dart';
import 'package:soulstate/core/extensions/date_extensions.dart';
import 'package:soulstate/core/routing/back_handlers.dart';
import 'package:soulstate/core/utils/responsive.dart';
import 'package:soulstate/core/widgets/page_motion.dart';
import 'package:soulstate/app/static_nav_bar.dart';
import 'package:soulstate/features/habits/pages/habit_tracker_page.dart';
import 'package:soulstate/features/home/pages/home_page.dart';
import 'package:soulstate/features/habits/state/habits_controller.dart';
import 'package:soulstate/features/habits/widgets/today_intro.dart';
import 'package:soulstate/features/meals/pages/meal_tracker_page.dart';
import 'package:soulstate/features/money/pages/money_page.dart';
import 'package:soulstate/features/settings/pages/settings_page.dart';
import 'package:soulstate/features/settings/settings_actions.dart';
import 'package:soulstate/features/settings/state/settings_controller.dart';
import 'package:soulstate/features/vault/services/vault_manager.dart';
import 'package:soulstate/features/todos/pages/todos_page.dart';
import 'package:soulstate/features/todos/state/todos_controller.dart';
import 'package:soulstate/services/auto_sync.dart';
import 'package:soulstate/services/health_steps.dart';
import 'package:soulstate/services/home_widget_service.dart';
import 'package:soulstate/services/s3_service.dart';
import 'package:soulstate/services/s3_sync_service.dart';
import 'package:soulstate/services/widget_action_service.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  static void showSettings() {
    AppNavigator.push(const SettingsPage());
  }

  static void openHabitsTab() {
    _toHabits.value++;
  }

  @override
  State<HomeShell> createState() => _HomeShellState();
}

enum _Tab { today, habits, todos, money, meals }

final _toHabits = ValueNotifier(0);

class _HomeShellState extends State<HomeShell>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  _Tab _tab = _Tab.today;

  final _visited = <_Tab>{_Tab.today};

  late final AnimationController _swap;
  final _compact = ValueNotifier(false);
  Timer? _nextDay;
  DateTime? _leftAt;
  bool _replayDue = false;

  static const _awayForReplay = Duration(minutes: 5);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(const AssetImage('assets/profile_default.jpg'), context);
    precacheImage(const AssetImage('assets/icon.png'), context);
  }

  @override
  void initState() {
    super.initState();
    _swap = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      value: 1,
    );
    WidgetsBinding.instance.addObserver(this);
    _toHabits.addListener(_openHabits);
    final habits = context.read<HabitsController>();
    _waitForNextDay();
    unawaited(HealthSteps.sync(habits));
    S3SyncService.init(habits);
    final settings = context.read<SettingsController>();
    AutoSync.start(
      enabled: () => settings.syncsFolder || settings.hasVault,
      reload: () async {
        if (mounted) await SettingsActions.reloadAll(context);
      },
      save: () async {
        if (settings.hasVault) {
          await VaultManager.syncVault(settings.vaultFolder);
          return true;
        }
        return settings.runAutoBackup(force: true, archive: false);
      },
    );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await SettingsActions.reloadAll(context);
      if (!mounted) return;
      final settings = context.read<SettingsController>();

      // Pull from S3 cloud on app startup if enabled and configured
      if (S3Service.loadConfig().isSyncActive) {
        try {
          final habits = context.read<HabitsController>();
          final res = await S3Service.pullLatestBackup(controller: habits);
          if (res.updated && mounted) {
            await SettingsActions.reloadAll(context);
          }
        } catch (e) {
          debugPrint('S3 pull on startup error: $e');
        }
      }

      if (settings.hasVault && Platform.isAndroid) {
        final hasAccess = await Permission.manageExternalStorage.isGranted;
        if (!hasAccess && mounted) {
          final shouldRequest = await showDialog<bool>(
            context: context,
            barrierDismissible: false,
            builder: (ctx) => AlertDialog(
              title: const Text('Storage Permission Required'),
              content: Text(
                'Soul State needs "All files access" to save your habits, tasks, meals, and finances to your vault folder:\n\n${settings.vaultFolder}\n\nPlease enable it in Settings so your data is saved to your vault.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(false),
                  child: const Text('Later'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(ctx).pop(true),
                  child: const Text('Open Settings'),
                ),
              ],
            ),
          );
          if (shouldRequest == true) {
            await BackupService.ensureStorageAccess();
            if (await Permission.manageExternalStorage.isGranted) {
              await VaultManager.syncCurrentVault();
            }
          }
        } else {
          // Immediately ensure existing vault data is synchronized
          await VaultManager.syncCurrentVault();
        }
      }
    });
  }

  void _waitForNextDay() {
    _nextDay?.cancel();
    final end = AppClock.today()
        .addDays(1)
        .add(Duration(hours: AppClock.cutoffHour, seconds: 1));
    _nextDay = Timer(end.difference(DateTime.now()), () {
      if (!mounted) return;
      context.read<HabitsController>().refresh();
      context.read<TodosController>().reload();
      _waitForNextDay();
    });
  }

  @override
  void dispose() {
    _nextDay?.cancel();
    AutoSync.stop();
    _swap.dispose();
    _compact.dispose();
    _toHabits.removeListener(_openHabits);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _select(List<_Tab> tabs, _Tab tab) {
    if (tab == _tab) return;
    if (tab == _Tab.today && _replayDue) {
      _replayDue = false;
      TodayIntro.replay();
    }
    setState(() {
      _visited.add(tab);
      _tab = tab;
    });
    AppNavigator.clearPane();
    _compact.value = false;
    _swap.forward(from: 0);
  }

  void _openHabits() {
    setState(() {
      _visited.add(_Tab.habits);
      _tab = _Tab.habits;
    });
    _compact.value = false;
    _swap.forward(from: 0);
  }

  bool _onScroll(ScrollUpdateNotification note) {
    final delta = note.scrollDelta ?? 0;
    if (note.metrics.axis != Axis.vertical) return false;
    if (note.metrics.pixels <= note.metrics.minScrollExtent + 8) {
      _compact.value = false;
    } else if (note.dragDetails == null) {
      return false;
    } else if (delta > 4) {
      _compact.value = true;
    } else if (delta < -4) {
      _compact.value = false;
    }
    return false;
  }

  Widget _rail(
    BuildContext context,
    List<_Tab> tabs,
    _Tab current,
  ) {
    final compact = isCompactRail(context);
    return _NavRail(
      tabs: tabs,
      current: current,
      compact: compact,
      onSelect: (tab) => _select(tabs, tab),
    );
  }

  void _back(List<_Tab> tabs, _Tab current) {
    if (BackHandlers.handle()) return;
    if (current != _Tab.today) {
      _select(tabs, _Tab.today);
      return;
    }
    SystemNavigator.pop();
  }

  Widget _guard(List<_Tab> tabs, _Tab current, Widget child) => PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) _back(tabs, current);
        },
        child: child,
      );

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.hidden) {
      _leftAt ??= DateTime.now();
      unawaited(AutoSync.pause());
    }
    if (state == AppLifecycleState.resumed) {
      final left = _leftAt;
      _leftAt = null;
      if (left != null && DateTime.now().difference(left) >= _awayForReplay) {
        _replayDue = _tab != _Tab.today;
        if (!_replayDue) TodayIntro.replay();
      }
      final habits = context.read<HabitsController>();
      if (Platform.isIOS) _applyWidgetActions(habits);
      habits.refresh().then((_) {
        HomeWidgetService.sync(habits.asMap);
        return HealthSteps.sync(habits);
      });
      context.read<TodosController>().refresh();
      context.read<SettingsController>().runAutoBackup();
      if (context.read<SettingsController>().hasVault) {
        VaultManager.syncCurrentVault();
      }

      // Every time user resumes the app, pull latest from S3 if enabled
      if (S3Service.loadConfig().isSyncActive) {
        S3Service.pullLatestBackup(controller: habits).then((res) {
          if (res.updated && mounted) {
            SettingsActions.reloadAll(context);
          }
        }).catchError((e) {
          debugPrint('S3 pull on resume error: $e');
        });
      }

      AutoSync.resume();
      _waitForNextDay();
    }
  }

  Future<void> _applyWidgetActions(HabitsController habits) async {
    final todos = context.read<TodosController>();
    final changed = await WidgetActionService.drain(
      LocalStore.readHabits(),
      todos: LocalStore.readTodos(),
    );
    if (!changed) return;
    await habits.reload();
    todos.reload();
    await HomeWidgetService.sync(habits.asMap);
  }

  @override
  Widget build(BuildContext context) =>
      _StableMedia(child: Builder(builder: _layout));

  Widget _layout(BuildContext context) {
    final settings = context.watch<SettingsController>();
    final wide = isWideLayout(context);
    final railed = hasSideRail(context);
    final tabs = [
      _Tab.today,
      _Tab.habits,
      if (settings.todosEnabled) _Tab.todos,
      if (settings.moneyEnabled) _Tab.money,
      if (settings.mealsEnabled) _Tab.meals,
    ];
    final current = tabs.contains(_tab) ? _tab : _Tab.today;

    if (railed) {
      return _guard(
        tabs,
        current,
        _SplitScaffold(
        full: true,
        single: !wide,
        rail: _rail(context, tabs, current),
        page: FadeThrough(
          animation: _swap,
          child: IndexedStack(
            index: tabs.indexOf(current),
            children: [
              for (final tab in tabs)
                TickerMode(
                  enabled: tab == current,
                  child: _visited.contains(tab)
                      ? _pageOf(tab)
                      : const SizedBox.shrink(),
                ),
            ],
          ),
        ),
      ),
      );
    }

    return _guard(
      tabs,
      current,
      Scaffold(
        resizeToAvoidBottomInset: false,
        body: NotificationListener<ScrollUpdateNotification>(
          onNotification: _onScroll,
          child: FadeThrough(
            animation: _swap,
            child: IndexedStack(
              index: tabs.indexOf(current),
              children: [
                for (final tab in tabs)
                  TickerMode(
                    enabled: tab == current,
                    child: _visited.contains(tab)
                        ? _pageOf(tab)
                        : const SizedBox.shrink(),
                  ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: StaticNavBar(
          items: [
            for (final tab in tabs)
              (icon: _iconOf(tab), label: _labelOf(context, tab)),
          ],
          index: tabs.indexOf(current),
          onSelect: (i) => _select(tabs, tabs[i]),
        ),
      ),
    );
  }
}

Widget _pageOf(_Tab tab) => switch (tab) {
      _Tab.today => const HomePage(onOpenHabits: HomeShell.openHabitsTab),
      _Tab.habits => const HabitTrackerPage(),
      _Tab.todos => const TodosPage(),
      _Tab.money => const MoneyPage(),
      _Tab.meals => const MealTrackerPage(),
    };

IconData _iconOf(_Tab tab) => switch (tab) {
      _Tab.today => LucideIcons.layoutDashboard,
      _Tab.habits => LucideIcons.flame,
      _Tab.todos => LucideIcons.listChecks,
      _Tab.money => LucideIcons.wallet,
      _Tab.meals => LucideIcons.utensils,
    };

String _labelOf(BuildContext context, _Tab tab) => switch (tab) {
      _Tab.today => context.l10n.nav_home,
      _Tab.habits => context.l10n.nav_habits,
      _Tab.todos => context.l10n.todos,
      _Tab.money => context.l10n.money,
      _Tab.meals => context.l10n.nav_meals,
    };

class _StableMedia extends StatefulWidget {
  const _StableMedia({required this.child});

  final Widget child;

  @override
  State<_StableMedia> createState() => _StableMediaState();
}

class _StableMediaState extends State<_StableMedia> {
  MediaQueryData? _kept;

  @override
  Widget build(BuildContext context) {
    final live = MediaQuery.of(context);
    final current = ModalRoute.isCurrentOf(context) ?? true;
    final kept = _kept;
    if (current || kept == null || kept.size != live.size) _kept = live;
    return MediaQuery(data: _kept!, child: widget.child);
  }
}

class _SplitScaffold extends StatefulWidget {
  const _SplitScaffold({
    this.rail,
    required this.page,
    this.full = false,
    this.single = false,
  });

  final Widget? rail;
  final Widget page;
  final bool full;
  final bool single;

  @override
  State<_SplitScaffold> createState() => _SplitScaffoldState();
}

class _SplitScaffoldState extends State<_SplitScaffold> {
  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_onKey);
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_onKey);
    super.dispose();
  }

  bool _onKey(KeyEvent event) {
    if (event is! KeyDownEvent) return false;
    if (event.logicalKey != LogicalKeyboardKey.escape) return false;
    final root = AppNavigator.key.currentState;
    if (root == null || root.canPop()) return false;
    final pane = AppNavigator.paneKey.currentState;
    if (pane == null || !pane.canPop()) return false;
    AppNavigator.pop();
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          if (widget.rail != null) ...[
            widget.rail!,
            const _Line(),
          ],
          if (widget.single)
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: maxContentWidth),
                  child: widget.page,
                ),
              ),
            )
          else
            Expanded(child: widget.page),
        ],
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line();

  @override
  Widget build(BuildContext context) {
    return VerticalDivider(
      width: 1,
      thickness: 1,
      color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.32),
    );
  }
}

class _NavRail extends StatelessWidget {
  const _NavRail({
    required this.tabs,
    required this.current,
    required this.compact,
    required this.onSelect,
  });

  static const _width = 212.0;

  final List<_Tab> tabs;
  final _Tab current;
  final bool compact;
  final void Function(_Tab tab) onSelect;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: compact ? 76 : _width,
      child: SafeArea(
        right: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(compact ? 12 : 14, 22, compact ? 12 : 14, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _RailBrand(compact: compact),
              const SizedBox(height: 26),
              for (final tab in tabs)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: _RailItem(
                    icon: _iconOf(tab),
                    label: _labelOf(context, tab),
                    selected: tab == current,
                    compact: compact,
                    onTap: () => onSelect(tab),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RailBrand extends StatelessWidget {
  const _RailBrand({this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.only(left: compact ? 0 : 6),
      child: Row(
        mainAxisAlignment:
            compact ? MainAxisAlignment.center : MainAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(9),
            child: Image.asset(
              'assets/icon.png',
              width: 30,
              height: 30,
              filterQuality: FilterQuality.medium,
            ),
          ),
          if (!compact) ...[
          const SizedBox(width: 10),
          Text(
            'Soul State',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: scheme.onSurface,
            ),
          ),
          ],
        ],
      ),
    );
  }
}

class _RailItem extends StatelessWidget {
  const _RailItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.compact,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final bool compact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tint = selected ? scheme.primary : context.tokens.muted;

    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      onTap: onTap,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            decoration: BoxDecoration(
              color: scheme.primary.withValues(alpha: selected ? 0.14 : 0),
              borderRadius: BorderRadius.circular(14),
            ),
            child: compact
                ? Tooltip(
                    message: label,
                    child: Icon(icon, size: 19, color: tint),
                  )
                : Row(
              children: [
                Icon(icon, size: 19, color: tint),
                const SizedBox(width: 11),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                      color: tint,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
