import 'package:flutter/services.dart';
import 'package:soulstate/core/utils/app_dirs.dart';

class AppIconService {
  const AppIconService._();

  static const _channel = MethodChannel('soulstate/app_icon');
  static const _legacyChannel = MethodChannel('soulstate/app_icon');

  static const _names = ['default', 'neutral', 'accent'];

  static Future<void> apply(int index) async {
    if (!hasAppIcons) return;
    final name = _names[index.clamp(0, _names.length - 1)];
    try {
      await _channel.invokeMethod('setIcon', {'icon': name});
    } catch (_) {
      try {
        await _legacyChannel.invokeMethod('setIcon', {'icon': name});
      } catch (_) {}
    }
  }
}
