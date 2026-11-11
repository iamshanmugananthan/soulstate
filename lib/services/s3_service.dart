import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:intl/intl.dart';
import 'package:soulstate/core/database/local_store.dart';
import 'package:soulstate/core/utils/app_dirs.dart';
import 'package:soulstate/features/habits/state/habits_controller.dart';
import 'package:soulstate/features/vault/services/vault_manager.dart';
import 'package:soulstate/services/backup_archive.dart';
import 'package:soulstate/services/backup_crypto.dart';
import 'package:soulstate/services/backup_service.dart';

class S3BackupItem {
  const S3BackupItem({
    required this.key,
    required this.lastModified,
    required this.size,
  });

  final String key;
  final DateTime? lastModified;
  final int size;

  String get displayName {
    final parts = key.split('/').where((s) => s.isNotEmpty);
    return parts.isEmpty ? key : parts.last;
  }

  String get formattedSize {
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
    return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

class S3Config {
  const S3Config({
    this.enabled = false,
    this.endpoint = '',
    this.bucket = '',
    this.region = 'us-east-1',
    this.accessKey = '',
    this.secretKey = '',
    this.prefix = '',
    this.syncIntervalMinutes = 0,
    this.encryptionPassword = '',
    this.lastBackupAt,
    this.lastBackupStatus,
  });

  final bool enabled;
  final String endpoint;
  final String bucket;
  final String region;
  final String accessKey;
  final String secretKey;
  final String prefix;
  final int syncIntervalMinutes;
  final String encryptionPassword;
  final DateTime? lastBackupAt;
  final String? lastBackupStatus;

  bool get isConfigured =>
      bucket.trim().isNotEmpty &&
      accessKey.trim().isNotEmpty &&
      secretKey.trim().isNotEmpty;

  bool get isSyncActive => enabled && isConfigured;

  S3Config copyWith({
    bool? enabled,
    String? endpoint,
    String? bucket,
    String? region,
    String? accessKey,
    String? secretKey,
    String? prefix,
    int? syncIntervalMinutes,
    String? encryptionPassword,
    DateTime? lastBackupAt,
    String? lastBackupStatus,
  }) {
    return S3Config(
      enabled: enabled ?? this.enabled,
      endpoint: endpoint ?? this.endpoint,
      bucket: bucket ?? this.bucket,
      region: region ?? this.region,
      accessKey: accessKey ?? this.accessKey,
      secretKey: secretKey ?? this.secretKey,
      prefix: prefix ?? this.prefix,
      syncIntervalMinutes: syncIntervalMinutes ?? this.syncIntervalMinutes,
      encryptionPassword: encryptionPassword ?? this.encryptionPassword,
      lastBackupAt: lastBackupAt ?? this.lastBackupAt,
      lastBackupStatus: lastBackupStatus ?? this.lastBackupStatus,
    );
  }
}

class S3Service {
  const S3Service._();

  static const _kEnabled = 's3_enabled';
  static const _kEndpoint = 's3_endpoint';
  static const _kBucket = 's3_bucket';
  static const _kRegion = 's3_region';
  static const _kAccessKey = 's3_access_key';
  static const _kSecretKey = 's3_secret_key';
  static const _kPrefix = 's3_prefix';
  static const _kSyncInterval = 's3_sync_interval_mins';
  static const _kEncryptionPassword = 's3_encryption_password';
  static const _kLastBackupAt = 's3_last_backup_at';
  static const _kLastBackupStatus = 's3_last_backup_status';

  static S3Config loadConfig() {
    var enabled = LocalStore.setting(_kEnabled, false);
    var endpoint = LocalStore.setting(_kEndpoint, '');
    var bucket = LocalStore.setting(_kBucket, '');
    var region = LocalStore.setting(_kRegion, 'us-east-1');
    var accessKey = LocalStore.setting(_kAccessKey, '');
    var secretKey = LocalStore.setting(_kSecretKey, '');
    var prefix = LocalStore.setting(_kPrefix, '');
    var syncInterval = LocalStore.setting(_kSyncInterval, 0);
    var encryptionPassword = LocalStore.setting(_kEncryptionPassword, '');
    final lastAtRaw = LocalStore.setting(_kLastBackupAt, '');
    final lastBackupStatus = LocalStore.setting(_kLastBackupStatus, '');

    // If unconfigured locally, check if vault's s3.json exists
    if (bucket.isEmpty || accessKey.isEmpty || secretKey.isEmpty) {
      final vaultFolder = LocalStore.setting('vaultFolder', '');
      if (vaultFolder.isNotEmpty) {
        final s3File = File('$vaultFolder/s3.json');
        if (s3File.existsSync()) {
          try {
            final content = s3File.readAsStringSync();
            final map = jsonDecode(content);
            if (map is Map<String, dynamic>) {
              enabled = map['enabled'] as bool? ?? enabled;
              endpoint = map['endpoint'] as String? ?? endpoint;
              bucket = map['bucket'] as String? ?? bucket;
              region = map['region'] as String? ?? region;
              accessKey = map['accessKey'] as String? ?? accessKey;
              secretKey = map['secretKey'] as String? ?? secretKey;
              prefix = map['prefix'] as String? ?? prefix;
              syncInterval = map['syncIntervalMinutes'] as int? ?? syncInterval;
              encryptionPassword = map['encryptionPassword'] as String? ?? encryptionPassword;

              LocalStore.writeSetting(_kEnabled, enabled);
              LocalStore.writeSetting(_kEndpoint, endpoint);
              LocalStore.writeSetting(_kBucket, bucket);
              LocalStore.writeSetting(_kRegion, region);
              LocalStore.writeSetting(_kAccessKey, accessKey);
              LocalStore.writeSetting(_kSecretKey, secretKey);
              LocalStore.writeSetting(_kPrefix, prefix);
              LocalStore.writeSetting(_kSyncInterval, syncInterval);
              LocalStore.writeSetting(_kEncryptionPassword, encryptionPassword);
            }
          } catch (_) {}
        }
      }
    }

    return S3Config(
      enabled: enabled,
      endpoint: endpoint,
      bucket: bucket,
      region: region,
      accessKey: accessKey,
      secretKey: secretKey,
      prefix: prefix,
      syncIntervalMinutes: syncInterval,
      encryptionPassword: encryptionPassword,
      lastBackupAt: lastAtRaw.isNotEmpty ? DateTime.tryParse(lastAtRaw) : null,
      lastBackupStatus: lastBackupStatus,
    );
  }

  static Future<void> saveConfig(S3Config config) async {
    await LocalStore.writeSetting(_kEnabled, config.enabled);
    await LocalStore.writeSetting(_kEndpoint, config.endpoint.trim());
    await LocalStore.writeSetting(_kBucket, config.bucket.trim());
    await LocalStore.writeSetting(
      _kRegion,
      config.region.trim().isEmpty ? 'us-east-1' : config.region.trim(),
    );
    await LocalStore.writeSetting(_kAccessKey, config.accessKey.trim());
    await LocalStore.writeSetting(_kSecretKey, config.secretKey.trim());
    var p = config.prefix.trim();
    if (p.isNotEmpty && !p.endsWith('/')) p = '$p/';
    await LocalStore.writeSetting(_kPrefix, p);
    await LocalStore.writeSetting(_kSyncInterval, config.syncIntervalMinutes);
    await LocalStore.writeSetting(_kEncryptionPassword, config.encryptionPassword);
    if (config.lastBackupAt != null) {
      await LocalStore.writeSetting(
        _kLastBackupAt,
        config.lastBackupAt!.toIso8601String(),
      );
    }
    if (config.lastBackupStatus != null) {
      await LocalStore.writeSetting(_kLastBackupStatus, config.lastBackupStatus!);
    }

    // Save s3.json inside the vault folder so credentials persist with the vault
    final vaultFolder = LocalStore.setting('vaultFolder', '');
    if (vaultFolder.isNotEmpty) {
      try {
        final s3File = File('$vaultFolder/s3.json');
        final data = {
          'enabled': config.enabled,
          'endpoint': config.endpoint.trim(),
          'bucket': config.bucket.trim(),
          'region': config.region.trim().isEmpty ? 'us-east-1' : config.region.trim(),
          'accessKey': config.accessKey.trim(),
          'prefix': p,
          'syncIntervalMinutes': config.syncIntervalMinutes,
        };
        await s3File.writeAsString(
          const JsonEncoder.withIndent('  ').convert(data),
          flush: true,
        );
      } catch (e) {
        debugPrint('Could not save s3.json in vault: $e');
      }
    }
  }

  static String _cleanPrefix(String p) {
    var s = p.trim();
    while (s.startsWith('/')) {
      s = s.substring(1);
    }
    if (s.isNotEmpty && !s.endsWith('/')) {
      s = '$s/';
    }
    return s;
  }

  static ({String host, String uriPath, Uri uri}) _buildTarget(
    S3Config config,
    String objectKey, {
    Map<String, String>? query,
  }) {
    final endpoint = config.endpoint.trim();
    final bucket = config.bucket.trim();
    final region = config.region.trim().isEmpty ? 'us-east-1' : config.region.trim();
    var key = objectKey;
    while (key.startsWith('/')) {
      key = key.substring(1);
    }

    if (endpoint.isNotEmpty) {
      final parsed = Uri.parse(
        endpoint.startsWith('http://') || endpoint.startsWith('https://')
            ? endpoint
            : 'https://$endpoint',
      );

      // Security: Disallow non-HTTP(S) schemes (prevent file://, javascript:, gopher:, data:, etc.)
      if (parsed.scheme != 'http' && parsed.scheme != 'https') {
        throw const FormatException('Invalid S3 endpoint scheme. Only HTTP and HTTPS are permitted.');
      }

      // Security: SSRF Protection against cloud metadata services and link-local targets
      final h = parsed.host.toLowerCase();
      if (h == '169.254.169.254' ||
          h.startsWith('169.254.') ||
          h == 'instance-data' ||
          h == 'metadata.google.internal' ||
          h == 'metadata' ||
          h == '100.100.100.200' ||
          h == 'fd00:ec2::254' ||
          h == '[fd00:ec2::254]') {
        throw const FormatException('Connecting to cloud metadata endpoints is prohibited for security.');
      }

      // Security: Disallow cleartext HTTP for remote S3 endpoints to prevent credential leakage & MITM.
      // Auto-upgrade to HTTPS unless connecting to local loopback (e.g., local MinIO testing).
      final isLoopback = parsed.host == 'localhost' || parsed.host == '127.0.0.1';
      final base = (parsed.scheme == 'http' && !isLoopback)
          ? parsed.replace(scheme: 'https')
          : parsed;
      final host = base.host + (base.hasPort ? ':${base.port}' : '');
      final fullPath = key.isEmpty ? '/$bucket' : '/$bucket/$key';
      final uri = base.replace(
        path: fullPath,
        queryParameters: query?.isEmpty ?? true ? null : query,
      );
      return (host: host, uriPath: fullPath, uri: uri);
    } else {
      final host = region == 'us-east-1'
          ? '$bucket.s3.amazonaws.com'
          : '$bucket.s3.$region.amazonaws.com';
      final fullPath = key.isEmpty ? '/' : '/$key';
      final uri = Uri(
        scheme: 'https',
        host: host,
        path: fullPath,
        queryParameters: query?.isEmpty ?? true ? null : query,
      );
      return (host: host, uriPath: fullPath, uri: uri);
    }
  }

  static HttpClient _createSecureHttpClient() {
    final client = HttpClient();
    client.connectionTimeout = const Duration(seconds: 15);
    return client;
  }

  static const _maxDownloadBytes = 50 * 1024 * 1024; // 50 MB limit
  static const _networkTimeout = Duration(seconds: 30);

  static String _sanitizeError(Object error, S3Config config) {
    var msg = error.toString().replaceFirst('Exception: ', '');
    if (config.secretKey.isNotEmpty) {
      msg = msg.replaceAll(config.secretKey, '***');
    }
    if (config.encryptionPassword.isNotEmpty) {
      msg = msg.replaceAll(config.encryptionPassword, '***');
    }
    return msg;
  }

  static String _toHex(List<int> bytes) =>
      bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();

  static List<int> _hmacSha256(List<int> key, List<int> data) {
    return Hmac(sha256, key).convert(data).bytes;
  }

  static Map<String, String> _signRequest({
    required String method,
    required String host,
    required String uriPath,
    required Map<String, String> query,
    required List<int> body,
    required S3Config config,
    required DateTime now,
    String? contentType,
  }) {
    final region = config.region.trim().isEmpty ? 'us-east-1' : config.region.trim();
    final dateStamp = DateFormat('yyyyMMdd').format(now);
    final amzDate = '${DateFormat("yyyyMMdd'T'HHmmss").format(now)}Z';
    final payloadHash = _toHex(sha256.convert(body).bytes);

    final sortedQueryKeys = query.keys.toList()..sort();
    final canonicalQueryString = sortedQueryKeys.map((k) {
      final v = query[k] ?? '';
      return '${Uri.encodeQueryComponent(k)}=${Uri.encodeQueryComponent(v)}';
    }).join('&');

    final canonicalUri = uriPath.isEmpty ? '/' : Uri.encodeFull(uriPath);

    final headersToSign = <String, String>{
      'host': host,
      'x-amz-content-sha256': payloadHash,
      'x-amz-date': amzDate,
    };
    if (contentType != null && contentType.isNotEmpty) {
      headersToSign['content-type'] = contentType;
    }

    final sortedHeaderKeys = headersToSign.keys.toList()..sort();
    final canonicalHeaders =
        '${sortedHeaderKeys.map((k) => '$k:${headersToSign[k]!.trim()}').join('\n')}\n';
    final signedHeaders = sortedHeaderKeys.join(';');

    final canonicalRequest = [
      method,
      canonicalUri,
      canonicalQueryString,
      canonicalHeaders,
      signedHeaders,
      payloadHash,
    ].join('\n');

    final credentialScope = '$dateStamp/$region/s3/aws4_request';
    final stringToSign = [
      'AWS4-HMAC-SHA256',
      amzDate,
      credentialScope,
      _toHex(sha256.convert(utf8.encode(canonicalRequest)).bytes),
    ].join('\n');

    final kSecret = utf8.encode('AWS4${config.secretKey.trim()}');
    final kDate = _hmacSha256(kSecret, utf8.encode(dateStamp));
    final kRegion = _hmacSha256(kDate, utf8.encode(region));
    final kService = _hmacSha256(kRegion, utf8.encode('s3'));
    final kSigning = _hmacSha256(kService, utf8.encode('aws4_request'));

    final signature = _toHex(
      _hmacSha256(kSigning, utf8.encode(stringToSign)),
    );

    final authorization =
        'AWS4-HMAC-SHA256 Credential=${config.accessKey.trim()}/$credentialScope, '
        'SignedHeaders=$signedHeaders, Signature=$signature';

    return {
      'host': host,
      'x-amz-date': amzDate,
      'x-amz-content-sha256': payloadHash,
      'Authorization': authorization,
      if (contentType != null && contentType.isNotEmpty)
        'content-type': contentType,
    };
  }

  static Future<({bool ok, String message})> testConnection([S3Config? customConfig]) async {
    final config = customConfig ?? loadConfig();
    if (!config.isConfigured) {
      return (ok: false, message: 'Bucket, Access Key, and Secret Key are required');
    }

    try {
      final target = _buildTarget(config, '', query: {'list-type': '2', 'max-keys': '1'});
      final now = DateTime.now().toUtc();
      final headers = _signRequest(
        method: 'GET',
        host: target.host,
        uriPath: target.uriPath,
        query: {'list-type': '2', 'max-keys': '1'},
        body: const [],
        config: config,
        now: now,
      );

      final client = _createSecureHttpClient();
      try {
        final request = await client.getUrl(target.uri).timeout(_networkTimeout);
        headers.forEach((k, v) => request.headers.set(k, v));
        final response = await request.close().timeout(_networkTimeout);
        final body = await utf8.decoder.bind(response).join();

        if (response.statusCode >= 200 && response.statusCode < 300) {
          return (ok: true, message: 'Connected successfully to bucket "${config.bucket}"');
        } else if (response.statusCode == 403) {
          return (
            ok: false,
            message: 'Access Denied (403): Verify Access Key, Secret Key, and S3 permissions.'
          );
        } else if (response.statusCode == 404) {
          return (
            ok: false,
            message: 'Bucket Not Found (404): Check bucket name and region.'
          );
        } else {
          final errorMsg = _extractErrorMessage(body);
          return (
            ok: false,
            message: 'HTTP ${response.statusCode}: $errorMsg'
          );
        }
      } finally {
        client.close();
      }
    } catch (e) {
      return (ok: false, message: 'Connection failed: ${_sanitizeError(e, config)}');
    }
  }

  static String _extractErrorMessage(String xml) {
    final messageMatch = RegExp(r'<Message>(.*?)</Message>').firstMatch(xml);
    if (messageMatch != null) return messageMatch.group(1) ?? 'Unknown S3 error';
    final codeMatch = RegExp(r'<Code>(.*?)</Code>').firstMatch(xml);
    if (codeMatch != null) return codeMatch.group(1) ?? 'Unknown S3 error';
    return xml.isNotEmpty ? xml.substring(0, xml.length > 100 ? 100 : xml.length) : 'Unknown S3 error';
  }

  static Future<List<S3BackupItem>> listBackups([S3Config? customConfig]) async {
    final config = customConfig ?? loadConfig();
    if (!config.isConfigured) return [];

    final prefix = _cleanPrefix(config.prefix);
    final query = <String, String>{
      'list-type': '2',
      if (prefix.isNotEmpty) 'prefix': prefix,
    };

    final target = _buildTarget(config, '', query: query);
    final now = DateTime.now().toUtc();
    final headers = _signRequest(
      method: 'GET',
      host: target.host,
      uriPath: target.uriPath,
      query: query,
      body: const [],
      config: config,
      now: now,
    );

    final client = _createSecureHttpClient();
    try {
      final request = await client.getUrl(target.uri).timeout(_networkTimeout);
      headers.forEach((k, v) => request.headers.set(k, v));
      final response = await request.close().timeout(_networkTimeout);
      final body = await utf8.decoder.bind(response).join();

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Failed to list S3 objects (${response.statusCode}): ${_extractErrorMessage(body)}');
      }

      final items = <S3BackupItem>[];
      final contentsPattern = RegExp(r'<Contents>(.*?)</Contents>', dotAll: true);
      final keyPattern = RegExp(r'<Key>(.*?)</Key>');
      final lastModifiedPattern = RegExp(r'<LastModified>(.*?)</LastModified>');
      final sizePattern = RegExp(r'<Size>(.*?)</Size>');

      for (final match in contentsPattern.allMatches(body)) {
        final contentXml = match.group(1) ?? '';
        final keyMatch = keyPattern.firstMatch(contentXml);
        if (keyMatch == null) continue;
        final key = keyMatch.group(1) ?? '';
        if (!key.endsWith('.zip') && !key.endsWith('.json') && !key.endsWith('.enc')) continue;

        final lastModMatch = lastModifiedPattern.firstMatch(contentXml);
        final sizeMatch = sizePattern.firstMatch(contentXml);

        final lastModified = lastModMatch != null
            ? DateTime.tryParse(lastModMatch.group(1) ?? '')
            : null;
        final size = sizeMatch != null ? int.tryParse(sizeMatch.group(1) ?? '') ?? 0 : 0;

        items.add(S3BackupItem(
          key: key,
          lastModified: lastModified,
          size: size,
        ));
      }

      items.sort((a, b) {
        if (a.lastModified != null && b.lastModified != null) {
          return b.lastModified!.compareTo(a.lastModified!);
        }
        return b.key.compareTo(a.key);
      });

      return items;
    } finally {
      client.close();
    }
  }

  static Future<({bool ok, String message})> uploadFile({
    required List<int> bytes,
    required String fileName,
    S3Config? customConfig,
  }) async {
    final config = customConfig ?? loadConfig();
    if (!config.isConfigured) {
      return (ok: false, message: 'S3 is not configured');
    }

    final prefix = _cleanPrefix(config.prefix);
    final objectKey = '$prefix$fileName';
    final target = _buildTarget(config, objectKey);
    final now = DateTime.now().toUtc();
    final contentType = fileName.endsWith('.zip')
        ? 'application/zip'
        : (fileName.endsWith('.json')
            ? 'application/json'
            : (fileName.endsWith('.md')
                ? 'text/markdown; charset=utf-8'
                : 'text/plain; charset=utf-8'));

    final headers = _signRequest(
      method: 'PUT',
      host: target.host,
      uriPath: target.uriPath,
      query: const {},
      body: bytes,
      config: config,
      now: now,
      contentType: contentType,
    );

    final client = _createSecureHttpClient();
    try {
      final request = await client.putUrl(target.uri).timeout(_networkTimeout);
      request.contentLength = bytes.length;
      headers.forEach((k, v) => request.headers.set(k, v));
      request.add(bytes);
      final response = await request.close().timeout(_networkTimeout);
      final body = await utf8.decoder.bind(response).join();

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return (ok: true, message: 'Uploaded successfully ($fileName)');
      } else {
        final err = _extractErrorMessage(body);
        return (ok: false, message: 'Upload failed (${response.statusCode}): $err');
      }
    } catch (e) {
      return (ok: false, message: 'Upload failed: $e');
    } finally {
      client.close();
    }
  }

  static Future<List<int>> downloadFile(String key, [S3Config? customConfig]) async {
    final config = customConfig ?? loadConfig();
    if (!config.isConfigured) {
      throw Exception('S3 is not configured');
    }

    final target = _buildTarget(config, key);
    final now = DateTime.now().toUtc();
    final headers = _signRequest(
      method: 'GET',
      host: target.host,
      uriPath: target.uriPath,
      query: const {},
      body: const [],
      config: config,
      now: now,
    );

    final client = _createSecureHttpClient();
    try {
      final request = await client.getUrl(target.uri).timeout(_networkTimeout);
      headers.forEach((k, v) => request.headers.set(k, v));
      final response = await request.close().timeout(_networkTimeout);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        final body = await utf8.decoder.bind(response).join();
        throw Exception('Download failed (${response.statusCode}): ${_extractErrorMessage(body)}');
      }

      final bytes = <int>[];
      var total = 0;
      await for (final chunk in response.timeout(_networkTimeout)) {
        total += chunk.length;
        if (total > _maxDownloadBytes) {
          throw const FormatException('Download exceeds maximum allowed backup size (50 MB)');
        }
        bytes.addAll(chunk);
      }
      return bytes;
    } finally {
      client.close();
    }
  }

  static Future<({bool ok, String message})> deleteFile(String key, [S3Config? customConfig]) async {
    final config = customConfig ?? loadConfig();
    if (!config.isConfigured) {
      return (ok: false, message: 'S3 is not configured');
    }

    final target = _buildTarget(config, key);
    final now = DateTime.now().toUtc();
    final headers = _signRequest(
      method: 'DELETE',
      host: target.host,
      uriPath: target.uriPath,
      query: const {},
      body: const [],
      config: config,
      now: now,
    );

    final client = _createSecureHttpClient();
    try {
      final request = await client.deleteUrl(target.uri).timeout(_networkTimeout);
      headers.forEach((k, v) => request.headers.set(k, v));
      final response = await request.close().timeout(_networkTimeout);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return (ok: true, message: 'Deleted successfully');
      } else {
        final body = await utf8.decoder.bind(response).join();
        return (ok: false, message: 'Delete failed (${response.statusCode}): ${_extractErrorMessage(body)}');
      }
    } catch (e) {
      return (ok: false, message: 'Delete failed: $e');
    } finally {
      client.close();
    }
  }

  static Future<({bool ok, String message})> performBackup({
    String? password,
  }) async {
    final config = loadConfig();
    if (!config.isConfigured) {
      return (ok: false, message: 'S3 Cloud Sync is not configured');
    }

    try {
      final habits = LocalStore.readHabits().values.toList();
      final payload = BackupService.createPayload(habits);
      final jsonString = const JsonEncoder.withIndent('  ').convert(payload);
      var bytes = utf8.encode(jsonString);

      final encPassword = (password ?? config.encryptionPassword).trim();
      final String fileName;
      if (encPassword.isNotEmpty) {
        bytes = BackupCrypto.encrypt(bytes, encPassword);
        fileName = 'backup.enc';
      } else {
        fileName = 'backup.json';
      }

      final uploadResult = await uploadFile(
        bytes: bytes,
        fileName: fileName,
        customConfig: config,
      );

      final now = DateTime.now();
      if (uploadResult.ok) {
        // Also mirror all vault markdown files to S3 so S3 holds the actual vault!
        final vaultFolder = LocalStore.setting('vaultFolder', '');
        if (vaultFolder.isNotEmpty) {
          final vaultDir = Directory(vaultFolder);
          if (vaultDir.existsSync()) {
            final filesToUpload = <({String relPath, List<int> bytes})>[];
            void collectFiles(Directory dir, String rel) {
              for (final entity in dir.listSync()) {
                if (entity is File) {
                  final name = entity.uri.pathSegments.last;
                  if (name.startsWith('.') || name.endsWith('.part') || name == 's3.json') continue;
                  final fileRel = rel.isEmpty ? name : '$rel/$name';
                  try {
                    filesToUpload.add((relPath: fileRel, bytes: entity.readAsBytesSync()));
                  } catch (_) {}
                } else if (entity is Directory) {
                  final dirName = entity.uri.pathSegments.where((s) => s.isNotEmpty).lastOrNull ?? '';
                  if (!dirName.startsWith('.')) {
                    collectFiles(entity, rel.isEmpty ? dirName : '$rel/$dirName');
                  }
                }
              }
            }
            collectFiles(vaultDir, '');
            for (final item in filesToUpload) {
              if (item.relPath == 'backup.json' || item.relPath == 'backup.enc') continue;
              try {
                await uploadFile(
                  bytes: item.bytes,
                  fileName: item.relPath,
                  customConfig: config,
                );
              } catch (_) {}
            }
          }
        }

        await saveConfig(config.copyWith(
          lastBackupAt: now,
          lastBackupStatus: 'Synced (${DateFormat('MMM d, HH:mm').format(now)})',
        ));
        await LocalStore.writeSetting('lastLocalMutationAt', now.millisecondsSinceEpoch);
        final encMsg = encPassword.isNotEmpty ? ' (encrypted)' : '';
        return (ok: true, message: 'Vault synced to S3$encMsg');
      } else {
        await saveConfig(config.copyWith(
          lastBackupStatus: 'Failed: ${uploadResult.message}',
        ));
        return uploadResult;
      }
    } catch (e) {
      final errMsg = _sanitizeError(e, config);
      await saveConfig(config.copyWith(
        lastBackupStatus: 'Failed: $errMsg',
      ));
      return (ok: false, message: 'S3 sync failed: $errMsg');
    }
  }

  static Future<({bool ok, String message})> restoreFromS3({
    required String key,
    required bool replace,
    required HabitsController controller,
    String? password,
    S3Config? customConfig,
  }) async {
    try {
      final config = customConfig ?? loadConfig();
      var bytes = await downloadFile(key, config);

      if (BackupCrypto.isEncrypted(bytes)) {
        final pwd = (password ?? config.encryptionPassword).trim();
        if (pwd.isEmpty) {
          return (
            ok: false,
            message: 'Backup is encrypted. Please provide your S3 encryption password.',
          );
        }
        try {
          bytes = BackupCrypto.decrypt(bytes, pwd);
        } catch (e) {
          return (
            ok: false,
            message: 'Decryption failed: Incorrect encryption password.',
          );
        }
      }

      final tempDir = await Directory.systemTemp.createTemp('s3_restore');
      final tempFile = File('${tempDir.path}/downloaded_backup');
      await tempFile.writeAsBytes(bytes);

      try {
        BackupData data;
        final isZip = (bytes.length >= 4 && bytes[0] == 0x50 && bytes[1] == 0x4B) || key.endsWith('.zip');
        if (isZip) {
          final json = await BackupArchive.unpack(
            tempFile.path,
            (await appDataDir()).path,
          );
          if (json == null) {
            return (ok: false, message: 'Failed to unpack backup archive');
          }
          data = BackupService.parse(json);
        } else {
          final text = utf8.decode(bytes);
          data = BackupService.parse(text);
        }

        final err = await controller.applyBackupData(data, replace: replace);
        if (err != null) {
          return (ok: false, message: 'Restore failed: $err');
        }
        return (ok: true, message: 'Backup restored successfully');
      } finally {
        if (tempDir.existsSync()) {
          try {
            tempDir.deleteSync(recursive: true);
          } catch (_) {}
        }
      }
    } catch (e) {
      return (ok: false, message: 'Restore failed: $e');
    }
  }

  /// Pulls the latest backup from S3 and merges it into the local store.
  static Future<({bool ok, String message, bool updated})> pullLatestBackup({
    required HabitsController controller,
    String? password,
    S3Config? customConfig,
  }) async {
    final config = customConfig ?? loadConfig();
    if (!config.isConfigured) {
      return (ok: false, message: 'S3 Cloud Backup is not configured', updated: false);
    }

    try {
      final items = await listBackups(config);
      if (items.isEmpty) {
        return (ok: true, message: 'No backups found on S3', updated: false);
      }

      final latest = items.where((it) =>
          it.displayName == 'backup.json' ||
          it.displayName == 'backup.enc'
      ).firstOrNull ?? items.where((it) =>
          it.displayName.endsWith('.zip') ||
          it.displayName.startsWith('soulstate_backup_') ||
          it.displayName.startsWith('streak_backup_') ||
          it.displayName.endsWith('.json') ||
          it.displayName.endsWith('.enc')
      ).firstOrNull;

      if (latest == null) {
        return (ok: true, message: 'No vault backup found on S3 yet', updated: false);
      }

      final s3ModTime = latest.lastModified?.millisecondsSinceEpoch ?? 0;
      final lastLocalMutation = LocalStore.setting('lastLocalMutationAt', 0);

      // If local data was modified after this S3 backup was created, DO NOT pull old data over new local data!
      if (s3ModTime > 0 && lastLocalMutation > s3ModTime) {
        unawaited(performBackup());
        return (ok: true, message: 'Local vault is newer than S3. Synced to S3.', updated: false);
      }

      final result = await restoreFromS3(
        key: latest.key,
        replace: false,
        controller: controller,
        password: password,
        customConfig: config,
      );

      if (result.ok) {
        final now = DateTime.now();
        await saveConfig(config.copyWith(
          lastBackupAt: latest.lastModified ?? now,
          lastBackupStatus: 'Synced (${DateFormat('MMM d, HH:mm').format(now)})',
        ));
        final vaultFolder = LocalStore.setting('vaultFolder', '');
        if (vaultFolder.isNotEmpty) {
          await VaultManager.syncVault(vaultFolder);
        }
        return (ok: true, message: 'Data synced from S3 (${latest.displayName})', updated: true);
      } else {
        return (ok: false, message: result.message, updated: false);
      }
    } catch (e) {
      final errMsg = e.toString().replaceFirst('Exception: ', '');
      return (ok: false, message: 'S3 pull failed: $errMsg', updated: false);
    }
  }
}
