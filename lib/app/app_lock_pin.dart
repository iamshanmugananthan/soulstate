import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:soulstate/core/database/local_store.dart';

class AppLockPin {
  const AppLockPin._();

  static const minLength = 4;
  static const maxLength = 8;
  static const recoveryLength = 12;
  static const maxTries = 5;
  static const lockout = Duration(seconds: 30);
  static const pbkdf2Iterations = 25000;

  static const _pinKey = 'appLockPin';
  static const _saltKey = 'appLockPinSalt';
  static const _lengthKey = 'appLockPinLength';
  static const _recoveryKey = 'appLockRecovery';
  static const _missesKey = 'appLockMisses';
  static const _strikesKey = 'appLockStrikes';
  static const _blockedKey = 'appLockBlockedUntil';

  static bool get isSet => LocalStore.setting(_pinKey, '').isNotEmpty;

  static int get length => LocalStore.setting(_lengthKey, minLength);

  static DateTime? get blockedUntil =>
      DateTime.tryParse(LocalStore.setting(_blockedKey, ''));

  static int get waitSeconds {
    final until = blockedUntil;
    if (until == null) return 0;
    final left = until.difference(DateTime.now());
    return left.isNegative ? 0 : left.inSeconds + 1;
  }

  /// Verifies PIN with timing-attack resistance and lockout enforcement.
  /// Automatically upgrades legacy single-round SHA-256 hashes to PBKDF2.
  static bool matches(String pin) {
    if (waitSeconds > 0) return false;
    final stored = LocalStore.setting(_pinKey, '');
    if (stored.isEmpty) return false;

    final salt = LocalStore.setting(_saltKey, '');
    final pbkdf2Candidate = _pbkdf2Hash(pin, salt);

    if (_constantTimeEqual(stored, pbkdf2Candidate)) {
      return true;
    }

    // Check legacy single-round SHA-256 for backward compatibility
    final legacyCandidate = _legacyHash(pin, salt);
    if (_constantTimeEqual(stored, legacyCandidate)) {
      // Auto-migrate to PBKDF2 for future protection
      LocalStore.writeSetting(_pinKey, pbkdf2Candidate);
      return true;
    }

    return false;
  }

  /// Verifies recovery code with timing-attack resistance and lockout enforcement.
  static bool matchesRecovery(String code) {
    if (waitSeconds > 0) return false;
    final stored = LocalStore.setting(_recoveryKey, '');
    if (stored.isEmpty) return false;

    final salt = LocalStore.setting(_saltKey, '');
    final pbkdf2Candidate = _pbkdf2Hash(code, salt);

    if (_constantTimeEqual(stored, pbkdf2Candidate)) {
      return true;
    }

    // Check legacy single-round SHA-256
    final legacyCandidate = _legacyHash(code, salt);
    if (_constantTimeEqual(stored, legacyCandidate)) {
      LocalStore.writeSetting(_recoveryKey, pbkdf2Candidate);
      return true;
    }

    return false;
  }

  static Future<void> recordMiss() async {
    final misses = LocalStore.setting(_missesKey, 0) + 1;
    if (misses < maxTries) {
      await LocalStore.writeSetting(_missesKey, misses);
      return;
    }
    final strikes = LocalStore.setting(_strikesKey, 0);
    final wait = lockout * (1 << strikes.clamp(0, 6));
    await LocalStore.writeSetting(_missesKey, 0);
    await LocalStore.writeSetting(_strikesKey, strikes + 1);
    await LocalStore.writeSetting(
      _blockedKey,
      DateTime.now().add(wait).toIso8601String(),
    );
  }

  static Future<void> clearMisses() async {
    await LocalStore.writeSetting(_missesKey, 0);
    await LocalStore.writeSetting(_strikesKey, 0);
    await LocalStore.writeSetting(_blockedKey, '');
  }

  static Future<String> save(String pin) async {
    final random = Random.secure();
    final salt = base64Url.encode(
      List<int>.generate(16, (_) => random.nextInt(256)),
    );
    final code = List.generate(recoveryLength, (_) => random.nextInt(10)).join();
    await LocalStore.writeSetting(_saltKey, salt);
    await LocalStore.writeSetting(_pinKey, _pbkdf2Hash(pin, salt));
    await LocalStore.writeSetting(_lengthKey, pin.length);
    await LocalStore.writeSetting(_recoveryKey, _pbkdf2Hash(code, salt));
    await clearMisses();
    return [
      for (var i = 0; i < code.length; i += 4) code.substring(i, i + 4),
    ].join(' ');
  }

  static Future<void> clear() async {
    await LocalStore.writeSetting(_pinKey, '');
    await LocalStore.writeSetting(_saltKey, '');
    await LocalStore.writeSetting(_recoveryKey, '');
    await clearMisses();
  }

  /// Multi-iteration PBKDF2-HMAC-SHA256 key stretching.
  static String _pbkdf2Hash(String value, String salt) {
    final passwordBytes = utf8.encode(value);
    final saltBytes = utf8.encode(salt);
    final hmac = Hmac(sha256, passwordBytes);
    final saltBlock = Uint8List(saltBytes.length + 4);
    saltBlock.setAll(0, saltBytes);
    saltBlock[saltBytes.length + 3] = 1;

    var u = hmac.convert(saltBlock).bytes;
    final t = Uint8List.fromList(u);

    for (var iter = 1; iter < pbkdf2Iterations; iter++) {
      u = hmac.convert(u).bytes;
      for (var i = 0; i < 32; i++) {
        t[i] ^= u[i];
      }
    }
    return base64Url.encode(t);
  }

  /// Legacy single-round SHA-256 for migration of previously stored PINs.
  static String _legacyHash(String value, String salt) {
    return sha256.convert(utf8.encode('$salt:$value')).toString();
  }

  /// Constant-time string equality to prevent timing attacks.
  static bool _constantTimeEqual(String a, String b) {
    final aBytes = utf8.encode(a);
    final bBytes = utf8.encode(b);
    if (aBytes.length != bBytes.length) return false;
    var diff = 0;
    for (var i = 0; i < aBytes.length; i++) {
      diff |= aBytes[i] ^ bBytes[i];
    }
    return diff == 0;
  }
}
