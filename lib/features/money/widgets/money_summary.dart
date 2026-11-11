import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:soulstate/app/theme/app_tokens.dart';
import 'package:soulstate/core/i18n/l10n.dart';
import 'package:soulstate/core/widgets/sheet_type.dart';
import 'package:soulstate/features/money/data/money_stats.dart';
import 'package:soulstate/features/money/widgets/money_kit.dart';

/// Net balance with income and expense side by side.
class MoneySummary extends StatelessWidget {
  const MoneySummary({super.key, required this.totals});

  final MoneyTotals totals;

  @override
  Widget build(BuildContext context) {
    final fmt = MoneyFmt.of(context);
    final scheme = context.colors;
    return MoneyCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.l10n.money_balance, style: sheetLabelStyle(context)),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              fmt.signed(totals.net, plus: false),
              maxLines: 1,
              style: sheetFigureStyle(
                context,
                size: 34,
                color: scheme.onSurface,
              ),
            ),
          ),
          if (!totals.isEmpty) ...[
            const SizedBox(height: 14),
            _Ratio(totals: totals),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _Stat(
                  icon: LucideIcons.plus,
                  color: context.tokens.success,
                  label: context.l10n.money_income,
                  value: fmt.plain(totals.income),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _Stat(
                  icon: LucideIcons.minus,
                  color: context.tokens.danger,
                  label: context.l10n.money_expense,
                  value: fmt.plain(totals.expense),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Ratio extends StatelessWidget {
  const _Ratio({required this.totals});

  final MoneyTotals totals;

  @override
  Widget build(BuildContext context) {
    final spent = totals.income > 0
        ? (totals.expense / totals.income).clamp(0.0, 1.0)
        : (totals.expense > 0 ? 1.0 : 0.0);
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: SizedBox(
        height: 6,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ColoredBox(color: context.tokens.success.withValues(alpha: 0.28)),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: FractionallySizedBox(
                widthFactor: spent,
                heightFactor: 1,
                child: ColoredBox(color: context.tokens.danger),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color color;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.16),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 16, color: color),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: sheetBodyStyle(context, size: 12),
            ),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                value,
                maxLines: 1,
                style: sheetActionStyle(
                  context,
                  size: 15,
                  color: context.colors.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}
