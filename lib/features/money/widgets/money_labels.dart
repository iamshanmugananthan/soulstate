import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:soulstate/core/extensions/date_extensions.dart';
import 'package:soulstate/core/i18n/l10n.dart';
import 'package:soulstate/features/money/data/money_stats.dart';

String moneyLocale(BuildContext context) =>
    Localizations.localeOf(context).toString();

/// "Today", "Yesterday" or a short weekday and date.
String moneyDayLabel(BuildContext context, DateTime day) {
  final today = AppClock.today();
  if (day.isSameDay(today)) return context.l10n.today;
  if (day.isSameDay(today.addDays(-1))) return context.l10n.yesterday;
  final locale = moneyLocale(context);
  final format = day.year == today.year
      ? DateFormat.MMMEd(locale)
      : DateFormat.yMMMEd(locale);
  return format.format(day);
}

String moneyMonthLabel(BuildContext context, DateTime month) =>
    DateFormat.yMMMM(moneyLocale(context)).format(month);

String moneyPeriodLabel(
  BuildContext context,
  MoneyPeriod period,
  DateTime anchor,
  int weekStart,
) {
  final locale = moneyLocale(context);
  switch (period) {
    case MoneyPeriod.today:
      return moneyDayLabel(context, anchor);
    case MoneyPeriod.week:
      final range = MoneyRange.of(period, anchor, weekStart);
      final last = range.end!.addDays(-1);
      final short = DateFormat.MMMd(locale);
      return '${short.format(range.start!)} \u2013 ${short.format(last)}';
    case MoneyPeriod.month:
      return DateFormat.yMMMM(locale).format(anchor);
    case MoneyPeriod.quarter:
      return 'Q${(anchor.month - 1) ~/ 3 + 1} ${anchor.year}';
    case MoneyPeriod.year:
      return '${anchor.year}';
    case MoneyPeriod.all:
      return context.l10n.all;
  }
}

String moneyPeriodName(BuildContext context, MoneyPeriod period) =>
    switch (period) {
      MoneyPeriod.today => context.l10n.today,
      MoneyPeriod.week => context.l10n.week,
      MoneyPeriod.month => context.l10n.month,
      MoneyPeriod.quarter => context.l10n.money_quarter,
      MoneyPeriod.year => context.l10n.year,
      MoneyPeriod.all => context.l10n.all,
    };
