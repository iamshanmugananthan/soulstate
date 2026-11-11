class AppClock {
  const AppClock._();

  static int _cutoffHour = 0;
  static DateTime? _today;
  static int _todayUntil = 0;

  static int get cutoffHour => _cutoffHour;

  static set cutoffHour(int value) {
    if (_cutoffHour == value) return;
    _cutoffHour = value;
    _today = null;
  }

  static DateTime now() => _cutoffHour == 0
      ? DateTime.now()
      : DateTime.now().subtract(Duration(hours: _cutoffHour));

  static DateTime wallNow() => DateTime.now();

  static DateTime today() {
    final cached = _today;
    if (cached != null &&
        DateTime.now().millisecondsSinceEpoch < _todayUntil) {
      return cached;
    }
    final midnight = now().atMidnight;
    _today = midnight;
    _todayUntil = midnight.addDays(1).millisecondsSinceEpoch +
        _cutoffHour * Duration.millisecondsPerHour;
    return midnight;
  }

  static bool isLogicalToday(DateTime date) => date.isSameDay(now());
}

extension DateOnly on DateTime {
  String get dayKey => '${_pad(day)}-${_pad(month)}-$year';

  DateTime get atMidnight => DateTime(year, month, day);

  int get epochDay =>
      DateTime.utc(year, month, day).millisecondsSinceEpoch ~/
      Duration.millisecondsPerDay;

  bool isSameDay(DateTime other) =>
      year == other.year && month == other.month && day == other.day;

  DateTime addDays(int count) => DateTime(year, month, day + count);

  DateTime startOfWeek(int weekStart) {
    final diff = (weekday - weekStart + 7) % 7;
    return addDays(-diff);
  }
}

DateTime parseDayKey(String value) {
  try {
    if (value.contains('-')) {
      final parts = value.split('-');
      if (parts.length == 3) {
        final p0 = int.tryParse(parts[0]);
        final p1 = int.tryParse(parts[1]);
        final p2 = int.tryParse(parts[2]);
        if (p0 != null && p1 != null && p2 != null) {
          if (parts[0].length == 4) {
            // YYYY-MM-DD
            return DateTime(p0, p1.clamp(1, 12), p2.clamp(1, 31));
          } else {
            // DD-MM-YYYY
            return DateTime(p2, p1.clamp(1, 12), p0.clamp(1, 31));
          }
        }
      }
    } else if (value.length == 8) {
      // YYYYMMDD
      final y = int.tryParse(value.substring(0, 4));
      final m = int.tryParse(value.substring(4, 6));
      final d = int.tryParse(value.substring(6, 8));
      if (y != null && m != null && d != null) {
        return DateTime(y, m.clamp(1, 12), d.clamp(1, 31));
      }
    }
  } catch (_) {}
  return DateTime.tryParse(value) ?? AppClock.today();
}

int dayKeyEpoch(String value) {
  if (value.contains('-') && value.indexOf('-') == 2) {
    final day = _digits(value, 0, 2);
    final month = _digits(value, 3, 5);
    final year = _digits(value, 6, value.length);
    final y = month <= 2 ? year - 1 : year;
    final era = (y >= 0 ? y : y - 399) ~/ 400;
    final yearOfEra = y - era * 400;
    final dayOfYear = (153 * (month + (month > 2 ? -3 : 9)) + 2) ~/ 5 + day - 1;
    final dayOfEra =
        yearOfEra * 365 + yearOfEra ~/ 4 - yearOfEra ~/ 100 + dayOfYear;
    return era * 146097 + dayOfEra - 719468;
  }
  final dt = parseDayKey(value);
  return DateTime.utc(dt.year, dt.month, dt.day)
      .difference(DateTime.utc(1970, 1, 1))
      .inDays;
}

DateTime epochDayDate(int epochDay) {
  final utc = DateTime.utc(1970, 1, 1 + epochDay);
  return DateTime(utc.year, utc.month, utc.day);
}

int _digits(String value, int from, int to) {
  var out = 0;
  for (var i = from; i < to; i++) {
    out = out * 10 + value.codeUnitAt(i) - 48;
  }
  return out;
}

String _pad(int value) => value < 10 ? '0$value' : '$value';
