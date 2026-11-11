import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:soulstate/app/theme/app_tokens.dart';
import 'package:soulstate/core/extensions/color_extensions.dart';
import 'package:soulstate/core/i18n/l10n.dart';
import 'package:soulstate/core/widgets/app_empty_state.dart';
import 'package:soulstate/core/widgets/sheet_type.dart';
import 'package:soulstate/features/money/data/money_category.dart';
import 'package:soulstate/features/money/data/money_stats.dart';
import 'package:soulstate/features/money/data/money_transaction.dart';
import 'package:soulstate/features/money/state/money_controller.dart';
import 'package:soulstate/features/money/widgets/money_donut.dart';
import 'package:soulstate/features/money/widgets/money_kit.dart';
import 'package:soulstate/features/money/widgets/money_labels.dart';
import 'package:soulstate/features/money/widgets/money_summary.dart';
import 'package:soulstate/features/settings/state/settings_controller.dart';

class MoneyAnalysis extends StatelessWidget {
  const MoneyAnalysis({
    super.key,
    required this.period,
    required this.anchor,
    required this.kind,
    required this.padding,
    required this.onPeriod,
    required this.onShift,
    required this.onToday,
    required this.onKind,
    required this.onOpenCategory,
  });

  final MoneyPeriod period;
  final DateTime anchor;
  final MoneyKind kind;
  final EdgeInsets padding;
  final ValueChanged<MoneyPeriod> onPeriod;
  final ValueChanged<int> onShift;
  final VoidCallback onToday;
  final ValueChanged<MoneyKind> onKind;
  final ValueChanged<MoneyBreakdown> onOpenCategory;

  @override
  Widget build(BuildContext context) {
    final money = context.watch<MoneyController>();
    final weekStart = context.select<SettingsController, int>(
      (s) => s.weekStart,
    );
    final fmt = MoneyFmt.of(context);
    final range = MoneyRange.of(period, anchor, weekStart);
    final items = money.inRange(range);
    final totals = MoneyStats.totals(items);
    final rows = MoneyStats.byCategory(items, kind);
    final total = kind == MoneyKind.expense ? totals.expense : totals.income;
    final expense = kind == MoneyKind.expense;

    Color colorOf(MoneyBreakdown row) =>
        money.category(row.categoryId)?.color ?? MoneyPalette.fallback;

    return ListView(
      padding: padding,
      children: [
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              for (final p in MoneyPeriod.values)
                Padding(
                  padding: const EdgeInsetsDirectional.only(end: 8),
                  child: MoneyChip(
                    label: moneyPeriodName(context, p),
                    selected: p == period,
                    onTap: () => onPeriod(p),
                  ),
                ),
            ],
          ),
        ),
        if (period != MoneyPeriod.all)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: MoneyPeriodBar(
              label: moneyPeriodLabel(context, period, anchor, weekStart),
              onPrevious: () => onShift(-1),
              onNext: () => onShift(1),
              onLabel: onToday,
            ),
          )
        else
          const SizedBox(height: 12),
        MoneySummary(totals: totals),
        const SizedBox(height: 18),
        MoneySegmented(
          options: [context.l10n.money_expense, context.l10n.money_income],
          index: expense ? 0 : 1,
          onChanged: (i) =>
              onKind(i == 0 ? MoneyKind.expense : MoneyKind.income),
        ),
        const SizedBox(height: 18),
        if (rows.isEmpty)
          MoneyCard(
            child: AppEmptyState(
              compact: true,
              icon: LucideIcons.chartPie,
              title: context.l10n.money_no_data,
            ),
          )
        else ...[
          MoneyCard(
            padding: const EdgeInsets.symmetric(vertical: 22),
            child: Center(
              child: MoneyDonut(
                slices: [for (final r in rows) DonutSlice(r.share, colorOf(r))],
                label: expense
                    ? context.l10n.money_expense
                    : context.l10n.money_income,
                value: fmt.plain(total),
              ),
            ),
          ),
          const SizedBox(height: 18),
          MoneyCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (final (index, row) in rows.indexed) ...[
                  if (index > 0) const MoneyDivider(),
                  _BreakdownRow(
                    row: row,
                    color: colorOf(row),
                    onTap: () => onOpenCategory(row),
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _BreakdownRow extends StatelessWidget {
  const _BreakdownRow({
    required this.row,
    required this.color,
    required this.onTap,
  });

  final MoneyBreakdown row;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final money = context.watch<MoneyController>();
    final fmt = MoneyFmt.of(context);
    final category = money.category(row.categoryId);
    final name =
        category?.name ??
        (row.label.isNotEmpty ? row.label : context.l10n.money_uncategorized);
    final percent = row.share < 0.005 ? '<1%' : '${(row.share * 100).round()}%';
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              CategoryBadge(
                icon: MoneyIcons.resolve(category?.icon ?? 'tag'),
                color: color,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: sheetOptionStyle(
                              context,
                              size: 15,
                              selected: true,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          percent,
                          style: sheetLabelStyle(context, size: 12.5),
                        ),
                      ],
                    ),
                    const SizedBox(height: 7),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: SizedBox(
                        height: 5,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            ColoredBox(
                              color: context.colors.surfaceContainerHighest,
                            ),
                            Align(
                              alignment: AlignmentDirectional.centerStart,
                              child: FractionallySizedBox(
                                widthFactor: row.share.clamp(0.02, 1.0),
                                heightFactor: 1,
                                child: ColoredBox(
                                  color: color.shownIn(context),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 120),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Text(
                    fmt.plain(row.amount),
                    maxLines: 1,
                    style: sheetActionStyle(
                      context,
                      size: 15,
                      color: context.colors.onSurface,
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
