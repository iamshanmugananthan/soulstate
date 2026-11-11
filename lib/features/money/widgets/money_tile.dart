import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:soulstate/app/theme/app_tokens.dart';
import 'package:soulstate/core/i18n/l10n.dart';
import 'package:soulstate/core/widgets/sheet_type.dart';
import 'package:soulstate/features/money/data/money_category.dart';
import 'package:soulstate/features/money/data/money_transaction.dart';
import 'package:soulstate/features/money/state/money_controller.dart';
import 'package:soulstate/features/money/widgets/money_kit.dart';
import 'package:soulstate/features/money/widgets/money_labels.dart';
import 'package:soulstate/features/settings/state/settings_controller.dart';

/// One transaction row: category badge, name and note, signed amount.
class MoneyTile extends StatelessWidget {
  const MoneyTile({
    super.key,
    required this.tx,
    required this.onTap,
    this.showDate = false,
  });

  final MoneyTransaction tx;
  final VoidCallback onTap;

  /// Show the date instead of the time (for lists that span several days).
  final bool showDate;

  @override
  Widget build(BuildContext context) {
    final money = context.watch<MoneyController>();
    final fmt = MoneyFmt.of(context);
    final category = money.categoryOf(tx);
    final name = money.nameOf(tx, context.l10n.money_uncategorized);
    final locale = moneyLocale(context);
    final when = showDate
        ? DateFormat.MMMd(locale).format(tx.at)
        : DateFormat.jm(locale).format(tx.at);
    final detail = tx.note.isEmpty ? when : '${tx.note} \u00b7 $when';
    final amountColor = tx.isExpense
        ? context.tokens.danger
        : context.tokens.success;
    final compact = context.select<SettingsController, bool>((s) => s.compactMoney);

    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: compact ? 7 : 12,
          ),
          child: Row(
            children: [
              CategoryBadge(
                icon: MoneyIcons.resolve(category?.icon ?? 'tag'),
                color: category?.color ?? MoneyPalette.fallback,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: sheetOptionStyle(
                        context,
                        size: 15.5,
                        selected: true,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      detail,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: sheetBodyStyle(context, size: 12.5),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 140),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Text(
                    fmt.signed(tx.signed),
                    maxLines: 1,
                    style: sheetActionStyle(
                      context,
                      size: 15.5,
                      color: amountColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A card holding the transactions of one day, with the day above it.
class MoneyDaySection extends StatelessWidget {
  const MoneyDaySection({
    super.key,
    required this.day,
    required this.items,
    required this.onOpen,
  });

  final DateTime day;
  final List<MoneyTransaction> items;
  final ValueChanged<MoneyTransaction> onOpen;

  @override
  Widget build(BuildContext context) {
    final fmt = MoneyFmt.of(context);
    var net = 0.0;
    for (final tx in items) {
      net += tx.signed;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(6, 0, 6, 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  moneyDayLabel(context, day),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: sheetLabelStyle(context, size: 13),
                ),
              ),
              Text(fmt.signed(net), style: sheetLabelStyle(context, size: 13)),
            ],
          ),
        ),
        MoneyCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (final (index, tx) in items.indexed) ...[
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
