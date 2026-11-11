import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:soulstate/app/app_lock_pin.dart';
import 'package:soulstate/core/database/local_store.dart';
import 'package:soulstate/core/extensions/date_extensions.dart';
import 'package:soulstate/features/money/data/money_transaction.dart';
import 'package:soulstate/features/todos/data/todo.dart';
import 'package:soulstate/services/backup_crypto.dart';
import 'package:soulstate/services/s3_service.dart';
import 'package:soulstate/services/vault_writer.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('sec_test_');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (MethodCall methodCall) async => tempDir.path,
    );
    Hive.init(tempDir.path);
    await LocalStore.init();
  });

  tearDown(() async {
    await Hive.close();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  group('Security & Resilience Verification', () {
    test('parseDayKey safely parses valid and invalid date keys without unhandled exceptions', () {
      final validYmd = parseDayKey('2026-11-10');
      expect(validYmd.year, 2026);
      expect(validYmd.month, 11);
      expect(validYmd.day, 10);

      final validDmy = parseDayKey('10-11-2026');
      expect(validDmy.year, 2026);
      expect(validDmy.month, 11);
      expect(validDmy.day, 10);

      final validCompact = parseDayKey('20261110');
      expect(validCompact.year, 2026);
      expect(validCompact.month, 11);
      expect(validCompact.day, 10);

      // Malformed inputs that could crash with FormatException
      expect(() => parseDayKey(''), returnsNormally);
      expect(() => parseDayKey('not-a-date'), returnsNormally);
      expect(() => parseDayKey('2026-ab-cd'), returnsNormally);
      expect(() => parseDayKey('----'), returnsNormally);
      expect(() => parseDayKey('999999999999'), returnsNormally);
      expect(() => parseDayKey('day:habit:invalid'), returnsNormally);
    });

    test('BackupCrypto correctly encrypts, decrypts, and rejects tampered data', () {
      final plaintext = utf8.encode('{"app":"soulstate","test":true}');
      const password = 'SuperSecurePassword123!';

      final encrypted = BackupCrypto.encrypt(plaintext, password);
      expect(BackupCrypto.isEncrypted(encrypted), isTrue);

      final decrypted = BackupCrypto.decrypt(encrypted, password);
      expect(utf8.decode(decrypted), utf8.decode(plaintext));

      // Wrong password fails
      expect(
        () => BackupCrypto.decrypt(encrypted, 'WrongPassword'),
        throwsA(isA<FormatException>()),
      );

      // Tampered payload fails HMAC verification
      final tampered = List<int>.from(encrypted);
      tampered[tampered.length - 1] ^= 0xFF;
      expect(
        () => BackupCrypto.decrypt(tampered, password),
        throwsA(isA<FormatException>()),
      );
    });

    test('VaultWriter sanitizes Markdown table cells against Formula Injection and Pipe breaking', () async {
      final vaultDir = Directory('${tempDir.path}/vault');
      await vaultDir.create(recursive: true);

      final maliciousTxs = <MoneyTransaction>[
        MoneyTransaction(
          id: 'tx-1',
          kind: MoneyKind.expense,
          categoryId: 'cat-1',
          label: '=cmd|\'/C calc\'!A0',
          amount: 50.0,
          at: DateTime(2026, 11, 10),
          note: '+123456789|malicious_pipe',
        ),
      ];

      await VaultWriter.write(
        vaultDir,
        habits: [],
        categories: [],
        notes: [],
        todos: [
          Todo(
            id: 't-1',
            text: '=DDE("cmd";"";"calc.exe")',
            createdAt: DateTime.now(),
          ),
        ],
        transactions: maliciousTxs,
      );

      final financesFile = File('${vaultDir.path}/finances.md');
      expect(financesFile.existsSync(), isTrue);
      final financesContent = financesFile.readAsStringSync();

      // Ensure formulas were neutralized with a leading quote and pipe was escaped
      expect(financesContent.contains("'=cmd"), isTrue);
      expect(financesContent.contains(r"'+123456789\|malicious_pipe"), isTrue);

      final tasksFile = File('${vaultDir.path}/tasks.md');
      expect(tasksFile.existsSync(), isTrue);
      final tasksContent = tasksFile.readAsStringSync();
      expect(tasksContent.contains("'-"), isFalse); // Normal bullet point
      expect(tasksContent.contains("'=DDE"), isTrue); // Neutralized task text
    });

    test('S3Service rejects SSRF attempts to AWS metadata endpoints and non-http schemes', () async {
      const metadataConfig = S3Config(
        endpoint: 'http://169.254.169.254',
        bucket: 'test-bucket',
        accessKey: 'AKIA...',
        secretKey: 'secret...',
      );

      final res = await S3Service.testConnection(metadataConfig);
      expect(res.ok, isFalse);
      expect(res.message.contains('cloud metadata endpoints is prohibited'), isTrue);

      const ftpSchemeConfig = S3Config(
        endpoint: 'ftp://ftp.example.com',
        bucket: 'test-bucket',
        accessKey: 'AKIA...',
        secretKey: 'secret...',
      );

      final ftpRes = await S3Service.testConnection(ftpSchemeConfig);
      expect(ftpRes.ok, isFalse);
    });

    test('AppLockPin uses PBKDF2 hashing and handles lockout strikes', () async {
      final recoveryCode = await AppLockPin.save('1234');
      expect(AppLockPin.isSet, isTrue);
      expect(recoveryCode.isNotEmpty, isTrue);

      expect(AppLockPin.matches('1234'), isTrue);
      expect(AppLockPin.matches('0000'), isFalse);

      // Record misses
      await AppLockPin.recordMiss();
      await AppLockPin.recordMiss();
      expect(AppLockPin.waitSeconds, 0);

      await AppLockPin.clear();
      expect(AppLockPin.isSet, isFalse);
    });
  });
}
