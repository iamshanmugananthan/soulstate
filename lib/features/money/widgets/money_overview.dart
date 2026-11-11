import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:soulstate/core/i18n/l10n.dart';
import 'package:soulstate/core/widgets/app_empty_state.dart';
import 'package:soulstate/features/money/data/money_stats.dart';
import 'package:soulstate/features/money/data/money_transaction.dart';
import 'package:soulstate/features/money/state/money_controller.dart';
import 'package:soulstate/features/money/widgets/money_kit.dart';
import 'package:soulstate/features/money/widgets/money_labels.dart';
import 'package:soulstate/features/money/widgets/money_summary.dart';
import 'package:soulstate/features/money/widgets/money_tile.dart';
import 'package:soulstate/features/settings/state/settings_controller.dart';

class MoneyOverview extends StatelessWidget {
  const MoneyOverview({
    super.key,
    required this.month,
    required this.padding,
    required this.onShift,
    required this.onToday,
    required this.onOpen,
    required this.onAdd,
  });

  final DateTime month;
  final EdgeInsets padding;
  final ValueChanged<int> onShift;
  final VoidCallback onToday;
  final ValueChanged<MoneyTransaction> onOpen;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final money = context.watch<MoneyController>();
    final weekStart = context.select<SettingsController, int>(
      (s) => s.weekStart,
    );
    final range = MoneyRange.of(MoneyPeriod.month, month, weekStart);
    final items = money.inRange(range);
    final totals = MoneyStats.totals(items);

    final days = <(DateTime, List<MoneyTransaction>)>[];
    for (final tx in items) {
      if (days.isNotEmpty && days.last.$1 == tx.day) {
        days.last.$2.add(tx);
      } else {
        days.add((tx.day, [tx]));
      }
    }

    final header = <Widget>[
      MoneyPeriodBar(
        label: moneyMonthLabel(context, month),
        onPrevious: () => onShift(-1),
        onNext: () => onShift(1),
        onLabel: onToday,
      ),
      const SizedBox(height: 4),
      MoneySummary(totals: totals),
      const SizedBox(height: 22),
    ];

    return ListView.builder(
      padding: padding,
      itemCount: header.length + (days.isEmpty ? 1 : days.length),
      itemBuilder: (context, index) {
        if (index < header.length) return header[index];
        if (days.isEmpty) {
          return AppEmptyState(
            compact: true,
            icon: LucideIcons.wallet,
            title: money.isEmpty
                ? context.l10n.money_empty_title
                : context.l10n.money_empty_month,
            message: context.l10n.money_empty_body,
            action: FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(LucideIcons.plus, size: 18),
              label: Text(context.l10n.money_add),
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          );
        }
        final (day, list) = days[index - header.length];
        return Padding(
          padding: const EdgeInsets.only(bottom: 18),
          child: MoneyDaySection(day: day, items: list, onOpen: onOpen),
        );
      },
    );
  }
}
