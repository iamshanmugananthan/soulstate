import 'dart:io';

import 'package:flutter/services.dart';

class ReminderSound {
  const ReminderSound(this.title, this.uri);

  final String title;
  final String uri;
}

class ReminderSounds {
  const ReminderSounds._();

  static const _channel = MethodChannel('soulstate/sounds');
  static const _legacyChannel = MethodChannel('soulstate/sounds');
  static List<ReminderSound>? _cache;

  static bool get supported => Platform.isAndroid;

  static Future<List<ReminderSound>> list() async {
    final cached = _cache;
    if (cached != null) return cached;
    if (!supported) return const [];
    try {
      List<Map>? raw;
      try {
        raw = await _channel.invokeListMethod<Map>('list');
      } catch (_) {
        raw = await _legacyChannel.invokeListMethod<Map>('list');
      }
      return _cache = [
        for (final item in (raw ?? const []))
          ReminderSound(item['title'] as String, item['uri'] as String),
      ];
    } on PlatformException {
      return const [];
    } on MissingPluginException {
      return const [];
    }
  }

  static Future<String?> resolve(String uri, String title) async {
    if (uri.isEmpty) return null;
    final sounds = await list();
    if (sounds.isEmpty) return uri;
    for (final sound in sounds) {
      if (sound.uri == uri) return uri;
    }
    for (final sound in sounds) {
      if (sound.title == title) return sound.uri;
    }
    return null;
  }

  static Future<void> play(String uri) => _call('play', {'uri': uri});

  static Future<void> stop() => _call('stop');

  static Future<void> _call(String method, [Map<String, String>? args]) async {
    if (!supported) return;
    try {
      await _channel.invokeMethod(method, args);
    } catch (_) {
      try {
        await _legacyChannel.invokeMethod(method, args);
      } catch (_) {}
    }
  }
}
