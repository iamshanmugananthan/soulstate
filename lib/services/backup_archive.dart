import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:archive/archive_io.dart';

const backupJsonName = 'backup.json';
const _files = 'files';

const backupSettingKeys = {
  'accentColor',
  'appBackground',
  'appStyle',
  'bgImage',
  'cardActivity',
  'celebration',
  'checkStyle',
  'colorTheme',
  'compactCards',
  'consistencyPeriod',
  'currency',
  'customQuotes',
  'dayCutoff',
  'difficultyOption',
  'heatmapMode',
  'heatmapPath',
  'heatmapRolling',
  'locale',
  'moneyEnabled',
  'notesEnabled',
  'todoPapers',
  'profileName',
  'profilePhoto',
  'quietWhenDone',
  'quoteSource',
  'readableCopy',
  'showTodayProgress',
  'sortCompletedLast',
  'startView',
  'swipeCards',
  'themeMode',
  'todayOnly',
  'hideDone',
  'pastFirst',
  'hideTracking',
  'todoLowFirst',
  'todosEnabled',
  'trackingOption',
  'vacationAll',
  'vacationAllIds',
  'viewSwitcher',
  'weekStart',
  'widgetBgColor',
  'widgetBorder',
  'widgetOpacity',
};

class BackupArchive {
  const BackupArchive._();

  static Future<void> pack(Map<String, Object?> payload, String target) =>
      Isolate.run(() => _pack(payload, target));

  static Future<String?> unpack(String path, String dataDir) =>
      Isolate.run(() => _unpack(path, dataDir));

  static Future<void> _pack(Map<String, Object?> payload, String target) async {
    final zip = ZipFileEncoder()..create(target);
    final packed = <String, String>{};

    Object? swap(Object? value) => switch (value) {
          Map() => {
              for (final entry in value.entries) '${entry.key}': swap(entry.value),
            },
          List() => [for (final item in value) swap(item)],
          String() => _packed(value, packed),
          _ => value,
        };

    final json = const JsonEncoder.withIndent('  ').convert(swap(payload));
    for (final entry in packed.entries) {
      await zip.addFile(File(entry.key), entry.value);
    }
    zip.addArchiveFile(ArchiveFile.string(backupJsonName, json));
    await zip.close();
  }

  static String _packed(String value, Map<String, String> packed) {
    final (path, rest) = _split(value);
    if (!_absolute(path) || !File(path).existsSync()) return value;
    final name = packed[path] ??= _nameFor(path, packed.values.toSet());
    return '$name$rest';
  }

  static String _nameFor(String path, Set<String> used) {
    final parts = path.replaceAll(r'\', '/').split('/');
    final folder = parts.length > 1 ? parts[parts.length - 2] : 'other';
    final file = parts.last;
    var name = '$_files/$folder/$file';
    for (var i = 2; used.contains(name); i++) {
      name = '$_files/$folder/${i}_$file';
    }
    return name;
  }

  static const _maxSingleFileSize = 50 * 1024 * 1024; // 50 MB limit per file
  static const _maxTotalExtraction = 250 * 1024 * 1024; // 250 MB max cumulative extraction
  static const _maxFileCount = 1000;

  static Future<String?> _unpack(String path, String dataDir) async {
    final input = InputFileStream(path);
    final placed = <String, String>{};
    final normDataDir = Directory(dataDir).absolute.path.replaceAll(r'\', '/');
    ArchiveFile? jsonFile;
    var totalExtractedBytes = 0;
    var extractedFileCount = 0;

    try {
      final archive = ZipDecoder().decodeStream(input);
      for (final file in archive.files) {
        final name = file.name.replaceAll(r'\', '/');
        if (name == backupJsonName) {
          jsonFile = file;
          continue;
        }
        if (name.endsWith('/') || !name.startsWith('$_files/')) continue;
        final inside = name.substring(_files.length + 1);
        if (inside.contains('\x00') ||
            inside.contains('%00') ||
            inside.contains(':') ||
            inside.split('/').any((part) =>
                part.isEmpty ||
                part == '..' ||
                part == '.' ||
                part.startsWith(' ') ||
                part.endsWith('.'))) {
          continue;
        }

        // Zip Bomb protection: verify single entry size and cumulative extraction size
        final int size = file.size.toInt();
        if (size > _maxSingleFileSize) {
          continue; // Drop suspiciously oversized file
        }
        totalExtractedBytes += size;
        extractedFileCount++;
        if (totalExtractedBytes > _maxTotalExtraction || extractedFileCount > _maxFileCount) {
          break; // Abort extraction: potential zip bomb / resource exhaustion
        }

        final targetFile = File('$dataDir/$inside');
        final targetPath = targetFile.absolute.path.replaceAll(r'\', '/');
        // Zip Slip protection: ensure canonical path does not escape the application data directory
        if (!targetPath.startsWith('$normDataDir/')) {
          continue;
        }

        final dest = _freeSpot(targetFile, file.size);
        dest.parent.createSync(recursive: true);
        if (!dest.existsSync()) {
          final output = OutputFileStream(dest.path);
          try {
            file.writeContent(output);
          } finally {
            output.closeSync();
          }
        }
        placed[name] = dest.path;
      }
      if (jsonFile == null) return null;
      final raw = utf8.decode(jsonFile.content, allowMalformed: true);
      Object? swap(Object? value) => switch (value) {
            Map() => {
                for (final entry in value.entries)
                  '${entry.key}': swap(entry.value),
              },
            List() => [for (final item in value) swap(item)],
            String() => _unpacked(value, placed),
            _ => value,
          };

      return jsonEncode(swap(jsonDecode(raw)));
    } finally {
      input.closeSync();
    }
  }

  static File _freeSpot(File file, int length) {
    var candidate = file;
    for (var i = 2;
        candidate.existsSync() && candidate.lengthSync() != length;
        i++) {
      final name = file.uri.pathSegments.last;
      candidate = File('${file.parent.path}/${i}_$name');
    }
    return candidate;
  }

  static String _unpacked(String value, Map<String, String> placed) {
    final (path, rest) = _split(value);
    final local = placed[path];
    return local == null ? value : '$local$rest';
  }

  static (String, String) _split(String value) {
    final cut = value.indexOf(RegExp(r'[?|]'));
    return cut < 0
        ? (value, '')
        : (value.substring(0, cut), value.substring(cut));
  }

  static bool _absolute(String path) =>
      path.length > 3 &&
      !path.contains('\n') &&
      (path.startsWith('/') || RegExp(r'^[A-Za-z]:[\\/]').hasMatch(path));
}
