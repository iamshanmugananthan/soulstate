import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:soulstate/app/theme/app_tokens.dart';
import 'package:soulstate/core/extensions/date_extensions.dart';
import 'package:soulstate/core/i18n/date_labels.dart';
import 'package:soulstate/core/i18n/l10n.dart';
import 'package:soulstate/core/widgets/sheet_type.dart';
import 'package:soulstate/features/money/data/money_stats.dart';
import 'package:soulstate/features/money/data/money_transaction.dart';
import 'package:soulstate/features/money/state/money_controller.dart';
import 'package:soulstate/features/money/widgets/money_kit.dart';
import 'package:soulstate/features/money/widgets/money_labels.dart';
import 'package:soulstate/features/money/widgets/money_tile.dart';
import 'package:soulstate/features/settings/state/settings_controller.dart';

class MoneyCalendar extends StatelessWidget {
  const MoneyCalendar({
    super.key,
    required this.month,
    required this.selected,
    required this.padding,
    required this.onSelect,
    required this.onShift,
    required this.onToday,
    required this.onOpen,
    required this.onAdd,
  });

  final DateTime month;
  final DateTime selected;
  final EdgeInsets padding;
  final ValueChanged<DateTime> onSelect;
  final ValueChanged<int> onShift;
  final VoidCallback onToday;
  final ValueChanged<MoneyTransaction> onOpen;
  final VoidCallback onAdd;

  static const _cell = 54.0;

  @override
  Widget build(BuildContext context) {
    final money = context.watch<MoneyController>();
    final weekStart = context.select<SettingsController, int>(
      (s) => s.weekStart,
    );
    final fmt = MoneyFmt.of(context);
    final scheme = context.colors;
    final range = MoneyRange.of(MoneyPeriod.month, month, weekStart);
    final items = money.inRange(range);
    final perDay = MoneyStats.byDay(items);
    final first = DateTime(month.year, month.month, 1);
    final lead = (first.weekday - weekStart + 7) % 7;
    final count = DateTime(month.year, month.month + 1, 0).day;
    final weeks = ((lead + count) / 7).ceil();
    final labels = WeekdayLabels.narrowFrom(moneyLocale(context), weekStart);
    final today = AppClock.today();
    final dayItems = [
      for (final tx in items)
        if (tx.day.isSameDay(selected)) tx,
    ];
    var dayNet = 0.0;
    for (final tx in dayItems) {
      dayNet += tx.signed;
    }

    Widget cell(int week, int column) {
      final number = week * 7 + column - lead + 1;
      if (number < 1 || number > count) return const SizedBox(height: _cell);
      final date = DateTime(month.year, month.month, number);
      final totals = perDay[date];
      final isSelected = date.isSameDay(selected);
      final isToday = date.isSameDay(today);
      final net = totals?.net ?? 0;
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onSelect(date),
        child: SizedBox(
          height: _cell,
          child: Padding(
            padding: const EdgeInsets.all(2),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected
                    ? scheme.primary.withValues(alpha: 0.18)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
                border: isToday
                    ? Border.all(color: scheme.primary, width: 1.4)
                    : null,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$number',
                    style: sheetOptionStyle(
                      context,
                      size: 14,
                      selected: isSelected || isToday,
                    ),
                  ),
                  const SizedBox(height: 2),
                  SizedBox(
                    height: 12,
                    child: totals == null
                        ? null
                        : FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              fmt.compact(net.abs()),
                              maxLines: 1,
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                color: net >= 0
                                    ? context.tokens.success
                                    : context.tokens.danger,
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return ListView(
      padding: padding,
      children: [
        MoneyPeriodBar(
          label: moneyMonthLabel(context, month),
          onPrevious: () => onShift(-1),
          onNext: () => onShift(1),
          onLabel: onToday,
        ),
        const SizedBox(height: 4),
        MoneyCard(
          padding: const EdgeInsets.fromLTRB(8, 14, 8, 8),
          child: MediaQuery.withClampedTextScaling(
            maxScaleFactor: 1.25,
            child: Column(
              children: [
                Row(
                  children: [
                    for (final label in labels)
                      Expanded(
                        child: Text(
                          label,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          style: sheetLabelStyle(context, size: 12),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                for (var week = 0; week < weeks; week++)
                  Row(
                    children: [
                      for (var column = 0; column < 7; column++)
                        Expanded(child: cell(week, column)),
                    ],
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.fromLTRB(6, 0, 6, 10),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  moneyDayLabel(context, selected),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: sheetHeadingStyle(context, size: 16),
                ),
              ),
              if (dayItems.isNotEmpty)
                Text(
                  fmt.signed(dayNet),
                  style: sheetHeadingStyle(
                    context,
                    size: 16,
                    color: dayNet >= 0
                        ? context.tokens.success
                        : context.tokens.danger,
                  ),
                ),
            ],
          ),
        ),
        if (dayItems.isEmpty)
          MoneyCard(
            onTap: onAdd,
            child: Row(
              children: [
                Icon(LucideIcons.circlePlus, color: scheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    context.l10n.money_empty_day,
                    style: sheetOptionStyle(context, size: 14.5),
                  ),
                ),
              ],
            ),
          )
        else
          MoneyCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (final (index, tx) in dayItems.indexed) ...[
                  if (index > 0) const MoneyDivider(),
                  MoneyTile(tx: tx, onTap: () => onOpen(tx)),
                ],
              ],
            ),
          ),
      ],
    );
  }
}
