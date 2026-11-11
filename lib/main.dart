import 'dart:async';
import 'dart:io';
import 'dart:ui' show AppExitResponse;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:soulstate/app/startup_failure.dart';
import 'package:soulstate/app/soulstate_app.dart';
import 'package:soulstate/core/database/local_store.dart';
import 'package:soulstate/core/utils/app_dirs.dart';
import 'package:soulstate/core/extensions/date_extensions.dart';
import 'package:soulstate/core/routing/app_navigator.dart';
import 'package:soulstate/features/habits/pages/habit_details_page.dart';
import 'package:soulstate/features/habits/pages/health_info_page.dart';
import 'package:soulstate/features/habits/state/categories_controller.dart';
import 'package:soulstate/features/habits/state/habits_controller.dart';
import 'package:soulstate/features/habits/widgets/day_actions_sheet.dart';
import 'package:soulstate/features/money/pages/money_page.dart';
import 'package:soulstate/features/money/state/money_controller.dart';
import 'package:soulstate/features/settings/state/settings_controller.dart';
import 'package:soulstate/features/meals/pages/meal_tracker_page.dart';
import 'package:soulstate/features/meals/state/meals_controller.dart';
import 'package:soulstate/features/todos/pages/todos_page.dart';
import 'package:soulstate/features/todos/state/todo_tags_controller.dart';
import 'package:soulstate/features/todos/state/todos_controller.dart';
import 'package:soulstate/services/dashboard_widget_service.dart';
import 'package:soulstate/services/folder_sync.dart';
import 'package:soulstate/services/home_widget_service.dart';
import 'package:soulstate/services/image_cleanup_service.dart';
import 'package:soulstate/services/meals_widget_service.dart';
import 'package:soulstate/services/money_widget_service.dart';
import 'package:soulstate/services/notification_service.dart';
import 'package:soulstate/services/portable_traces.dart';
import 'package:soulstate/services/s3_sync_service.dart';
import 'package:soulstate/services/todos_widget_service.dart';
import 'package:soulstate/services/widget_action_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await _startup();
  } catch (e, s) {
    debugPrint('Soul State could not start: $e');
    debugPrintStack(stackTrace: s);
    runApp(
      StartupFailure(
        error: '$e',
        logPath: _writeStartupLog(e, s),
        blocked: _blockedByWindows(e),
      ),
    );
    return;
  }
  _run();
}

Future<AppExitResponse> _leaveNoTrace() async {
  try {
    await NotificationService().cancelAll();
    await PortableTraces.clear(NotificationService.windowsAppId);
  } catch (e) {
    debugPrint('Could not clear what the portable app left: $e');
  }
  return AppExitResponse.exit;
}

bool _blockedByWindows(Object error) =>
    Platform.isWindows &&
    error is FileSystemException &&
    error.osError?.errorCode == 5;

String? _writeStartupLog(Object error, StackTrace stack) {
  if (isMobile) return null;
  try {
    final tempDir = Directory.systemTemp.createTempSync('soulstate_crash_');
    final file = File('${tempDir.path}/startup_error.log');
    file.writeAsStringSync('${DateTime.now().toUtc()}\n$error\n\n$stack');
    return file.path;
  } catch (_) {
    return null;
  }
}

Future<void> _startup() async {
  if (isMobile) {
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  await initializeDateFormatting();
  await LocalStore.init();
  AppClock.cutoffHour = LocalStore.setting('dayCutoff', 0);
  await WidgetActionService.drain(
    LocalStore.readHabits(),
    todos: LocalStore.readTodos(),
  );
  if (LocalStore.setting('vaultFolder', '').isEmpty) {
    await FolderSync.pull();
  }
  unawaited(ImageCleanupService.run());
  S3SyncService.init();

  NotificationService.onOpenHabit = _openHabit;
  NotificationService.onOpenTodos = _openTodos;
  NotificationService.onHabitsChanged = _reloadHabits;
  NotificationService.onTodosChanged = _reloadTodos;
  try {
    await NotificationService().initialize();
  } catch (e, s) {
    debugPrint('Startup init (notifications/widget) failed: $e\n$s');
  }
  if (isPortable) AppLifecycleListener(onExitRequested: _leaveNoTrace);

  Future<dynamic> appCallHandler(MethodCall call) async {
    if (call.method == 'openHabit') {
      final id = call.arguments as String?;
      if (id != null) _openHabit(id);
    }
    if (call.method == 'openPage') {
      final page = call.arguments as String?;
      if (page != null) _openPage(page);
    }
    return null;
  }
  _appChannel.setMethodCallHandler(appCallHandler);
  _legacyAppChannel.setMethodCallHandler(appCallHandler);

  WidgetsBinding.instance.addPostFrameCallback((_) async {
    final pending = NotificationService().pendingHabitId;
    if (pending != null) {
      NotificationService().pendingHabitId = null;
      _openHabit(pending);
    }
    if (isMobile) {
      String? launched;
      try {
        launched = await _appChannel.invokeMethod<String>('consumeLaunchHabit');
      } catch (_) {
        launched = await _legacyAppChannel.invokeMethod<String>('consumeLaunchHabit');
      }
      if (launched != null) _openHabit(launched);
      String? page;
      try {
        page = await _appChannel.invokeMethod<String>('consumeLaunchPage');
      } catch (_) {
        page = await _legacyAppChannel.invokeMethod<String>('consumeLaunchPage');
      }
      if (page != null) _openPage(page);
    }
  });
}

void _run() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsController()),
        ChangeNotifierProvider(create: (_) => CategoriesController()),
        ChangeNotifierProvider(create: (_) => TodoTagsController()),
        ChangeNotifierProvider(
          create: (_) {
            final controller = MoneyController();
            MoneyWidgetService.sync(controller.transactions);
            return controller;
          },
        ),
        ChangeNotifierProvider(
          create: (_) {
            final controller = MealsController();
            MealsWidgetService.sync(controller.all);
            return controller;
          },
        ),
        ChangeNotifierProvider(
          create: (_) {
            final controller = TodosController();
            TodosWidgetService.sync(controller.all);
            return controller;
          },
        ),
        ChangeNotifierProvider(
          create: (_) {
            final controller = HabitsController();
            HomeWidgetService.sync(controller.asMap);
            DashboardWidgetService.sync();
            WidgetsBinding.instance.addPostFrameCallback(
              (_) => controller.rescheduleReminders(),
            );
            return controller;
          },
        ),
      ],
      child: const SoulStateApp(),
    ),
  );
}

const _appChannel = MethodChannel('soulstate/app_icon');
const _legacyAppChannel = MethodChannel('soulstate/app_icon');

void _openHabit(String habitId) {
  AppNavigator.push(HabitDetailsPage(habitId: habitId), fade: true);
}

void _reloadHabits() {
  AppNavigator.key.currentContext?.read<HabitsController>().reload();
}

void _reloadTodos() {
  AppNavigator.key.currentContext?.read<TodosController>().reload();
}

void _openTodos() {
  AppNavigator.push(const TodosPage(), fade: true);
}

void _openPage(String page) {
  try {
    if (page == 'todos') _openTodos();
    if (page == 'money') AppNavigator.push(const MoneyPage(), fade: true);
    if (page == 'meals' || page == 'stats') {
      AppNavigator.push(const MealTrackerPage(), fade: true);
    }
    if (page == 'health') AppNavigator.push(const HealthInfoPage(), fade: true);
    if (page.startsWith('day:')) _openDay(page.substring(4));
  } catch (e) {
    debugPrint('Could not navigate to $page: $e');
  }
}

void _openDay(String target) {
  try {
    final split = target.lastIndexOf(':');
    final context = AppNavigator.key.currentContext;
    if (split <= 0 || context == null) return;
    final habitId = target.substring(0, split).trim();
    if (habitId.isEmpty) return;
    final habit = context.read<HabitsController>().byId(habitId);
    if (habit == null) return;
    showDayActionsSheet(
      context,
      habit: habit,
      date: parseDayKey(target.substring(split + 1)),
    );
  } catch (e) {
    debugPrint('Could not open day action for $target: $e');
  }
}

@pragma('vm:entry-point')
Future<void> widgetActionEntrypoint() async {
  WidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('soulstate/widget_action');
  const legacyChannel = MethodChannel('soulstate/widget_action');
  try {
    await initializeDateFormatting();
    await LocalStore.init();
    AppClock.cutoffHour = LocalStore.setting('dayCutoff', 0);
    await LocalStore.reloadHabits();
    final habits = LocalStore.readHabits();
    final todos = LocalStore.readTodos();
    await WidgetActionService.drain(habits, todos: todos);
    await HomeWidgetService.sync(habits, renderIcons: false);
    await TodosWidgetService.sync(todos);
    await NotificationService().rescheduleTodos(todos);
  } catch (e) {
    debugPrint('Widget action entrypoint failed: $e');
  }
  try {
    await channel.invokeMethod('done');
  } catch (_) {
    await legacyChannel.invokeMethod('done');
  }
}
