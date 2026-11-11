import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:soulstate/app/theme/app_tokens.dart';
import 'package:soulstate/core/extensions/inset_extensions.dart';
import 'package:soulstate/core/i18n/l10n.dart';
import 'package:soulstate/core/widgets/sheet_type.dart';
import 'package:soulstate/features/money/data/money_category.dart';
import 'package:soulstate/features/money/data/money_stats.dart';
import 'package:soulstate/features/money/data/money_transaction.dart';
import 'package:soulstate/features/money/state/money_controller.dart';
import 'package:soulstate/features/money/widgets/money_bars.dart';
import 'package:soulstate/features/money/widgets/money_editor_sheet.dart';
import 'package:soulstate/features/money/widgets/money_kit.dart';
import 'package:soulstate/features/money/widgets/money_labels.dart';
import 'package:soulstate/features/money/widgets/money_tile.dart';

/// One category through a year: monthly totals and every transaction in it.
class MoneyCategoryReportPage extends StatefulWidget {
  const MoneyCategoryReportPage({
    super.key,
    required this.categoryId,
    required this.kind,
    this.fallbackName = '',
    this.year,
  });

  final String categoryId;
  final MoneyKind kind;
  final String fallbackName;
  final int? year;

  @override
  State<MoneyCategoryReportPage> createState() =>
      _MoneyCategoryReportPageState();
}

class _MoneyCategoryReportPageState extends State<MoneyCategoryReportPage> {
  late int _year = widget.year ?? DateTime.now().year;
  int? _month;

  void _shift(int steps) => setState(() {
    _year += steps;
    _month = null;
  });

  @override
  Widget build(BuildContext context) {
    final money = context.watch<MoneyController>();
    final fmt = MoneyFmt.of(context);
    final locale = moneyLocale(context);
    final tokens = context.tokens;
    final category = money.category(widget.categoryId);
    final name =
        category?.name ??
        (widget.fallbackName.isNotEmpty
            ? widget.fallbackName
            : context.l10n.money_uncategorized);
    final color = category?.color ?? MoneyPalette.fallback;
    final all = money.forCategory(widget.categoryId);
    final months = MoneyStats.byMonth(
      all,
      _year,
      widget.kind,
      categoryId: widget.categoryId,
    );
    final yearItems = [
      for (final tx in all)
        if (tx.at.year == _year) tx,
    ];
    final total = months.fold<double>(0, (sum, v) => sum + v);
    final accent = widget.kind == MoneyKind.expense
        ? tokens.danger
        : tokens.success;
    final labels = [
      for (var m = 1; m <= 12; m++)
        DateFormat.MMM(locale).format(DateTime(2000, m, 1)),
    ];
    const side = 16.0;
    final selected = _month;
    final hint = selected == null
        ? ''
        : '${DateFormat.MMMM(locale).format(DateTime(2000, selected + 1, 1))} \u00b7 ${fmt.plain(months[selected])}';

    return Scaffold(
      appBar: AppBar(
        title: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            tooltip: context.l10n.money_add,
            icon: const Icon(LucideIcons.plus),
            onPressed: () => openMoneyEditor(
              context,
              kind: widget.kind,
              categoryId: widget.categoryId,
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: ListView(
        padding: context.pagePadding(side, 4, side, 40),
        children: [
          MoneyPeriodBar(
            label: '$_year',
            onPrevious: () => _shift(-1),
            onNext: () => _shift(1),
            onLabel: () => setState(() {
              _year = DateTime.now().year;
              _month = null;
            }),
          ),
          const SizedBox(height: 4),
          MoneyCard(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                CategoryBadge(
                  icon: MoneyIcons.resolve(category?.icon ?? 'tag'),
                  color: color,
                  size: 48,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(context.l10n.total, style: sheetLabelStyle(context)),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: AlignmentDirectional.centerStart,
                        child: Text(
                          fmt.plain(total),
                          maxLines: 1,
                          style: sheetFigureStyle(
                            context,
                            size: 30,
                            color: accent,
                          ),
                        ),
                      ),
                      Text(
                        context.l10n.money_transactions_count(yearItems.length),
                        style: sheetBodyStyle(context, size: 12.5),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          MoneyCard(
            padding: const EdgeInsets.fromLTRB(12, 16, 12, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 22,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: Text(
                      hint,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: sheetActionStyle(context, size: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                MoneyBars(
                  values: months,
                  labels: labels,
                  color: category?.color ?? accent,
                  selected: selected,
                  onSelect: (i) =>
                      setState(() => _month = _month == i ? null : i),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          if (yearItems.isNotEmpty)
            MoneyCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  for (final (index, tx) in yearItems.indexed) ...[
                    if (index > 0) const MoneyDivider(),
                    MoneyTile(
                      tx: tx,
                      showDate: true,
                      onTap: () => openMoneyEditor(context, tx: tx),
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}
