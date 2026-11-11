import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:soulstate/features/habits/state/habits_controller.dart';
import 'package:soulstate/services/s3_service.dart';

class S3SyncService {
  const S3SyncService._();

  static const checkInterval = Duration(minutes: 1);

  static Timer? _timer;
  static bool _running = false;
  static AppLifecycleListener? _lifecycle;
  static HabitsController? _habitsController;

  static const intervalOptions = <int>[
    0,
    1,
    5,
    10,
    30,
    60,
    1440,
  ];

  static String intervalLabel(int minutes) => switch (minutes) {
        0 => 'Manual only',
        1 => 'Every 1 min',
        5 => 'Every 5 min',
        10 => 'Every 10 min',
        15 => 'Every 15 min',
        30 => 'Every 30 min',
        60 => 'Every 1 hour',
        360 => 'Every 6 hours',
        720 => 'Every 12 hours',
        1440 => 'Every 1 day',
        _ => '$minutes min',
      };

  static void init([HabitsController? controller]) {
    if (controller != null) _habitsController = controller;
    _lifecycle ??= AppLifecycleListener(
      onResume: () => unawaited(onAppResume()),
    );
    _timer?.cancel();
    _timer = Timer.periodic(checkInterval, (_) => checkAndRun());
    unawaited(onAppResume());
  }

  static Future<void> onAppResume() async {
    final controller = _habitsController;
    if (controller != null) {
      await pullFromS3(controller);
    }
    await checkAndRun();
  }

  static Future<void> pullFromS3(HabitsController controller) async {
    final config = S3Service.loadConfig();
    if (!config.isSyncActive) return;
    try {
      final res = await S3Service.pullLatestBackup(controller: controller);
      if (res.updated) {
        debugPrint('S3 pull on open: ${res.message}');
      }
    } catch (e) {
      debugPrint('S3 pull on open error: $e');
    }
  }

  static void stop() {
    _timer?.cancel();
    _timer = null;
  }

  static Future<void> checkAndRun() async {
    if (_running) return;
    final config = S3Service.loadConfig();
    if (!config.isSyncActive || config.syncIntervalMinutes <= 0) return;

    final lastAt = config.lastBackupAt;
    final now = DateTime.now();
    if (lastAt != null) {
      final elapsed = now.difference(lastAt);
      if (elapsed.inMinutes < config.syncIntervalMinutes) {
        return;
      }
    }

    _running = true;
    try {
      await S3Service.performBackup();
    } catch (e) {
      debugPrint('S3 automated sync error: $e');
    } finally {
      _running = false;
    }
  }

  static String subtitle() {
    final config = S3Service.loadConfig();
    if (!config.enabled) return 'Disabled';
    if (!config.isConfigured) return 'Not configured';
    final interval = intervalLabel(config.syncIntervalMinutes);
    final last = config.lastBackupAt;
    if (last == null) return '$interval  ·  No backup yet';
    final stamp = DateFormat('MMM d, HH:mm').format(last);
    return '$interval  ·  $stamp';
  }
}
