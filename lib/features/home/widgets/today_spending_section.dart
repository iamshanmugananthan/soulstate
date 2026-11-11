import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:soulstate/app/theme/app_tokens.dart';
import 'package:soulstate/core/i18n/l10n.dart';
import 'package:soulstate/core/extensions/date_extensions.dart';
import 'package:soulstate/core/utils/money_format.dart';
import 'package:soulstate/features/money/data/money_stats.dart';
import 'package:soulstate/features/money/state/money_controller.dart';
import 'package:soulstate/features/money/widgets/money_editor_sheet.dart';
import 'package:soulstate/features/settings/state/settings_controller.dart';

/// Interactive section on the homepage displaying today's financial spending.
class TodaySpendingSection extends StatelessWidget {
  const TodaySpendingSection({
    super.key,
    this.onViewAll,
  });

  final VoidCallback? onViewAll;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final money = context.watch<MoneyController>();
    final settings = context.watch<SettingsController>();

    final today = AppClock.today();
    final todayTxs = MoneyStats.within(
      money.transactions,
      MoneyRange.of(MoneyPeriod.today, today, settings.weekStart),
    );

    final totals = MoneyStats.totals(todayTxs);
    final currency = settings.currency.isEmpty
        ? defaultCurrencySymbol()
        : settings.currency;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0EA5E9).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        LucideIcons.wallet,
                        size: 16,
                        color: Color(0xFF0EA5E9),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        context.l10n.today_spending,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (onViewAll != null)
                    TextButton(
                      onPressed: onViewAll,
                      child: Text(context.l10n.view_all, style: const TextStyle(fontSize: 12)),
                    ),
                  IconButton(
                    icon: const Icon(LucideIcons.plusCircle, size: 20),
                    tooltip: context.l10n.add_expense,
                    onPressed: () => openMoneyEditor(context, day: today),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (todayTxs.isEmpty)
            InkWell(
              onTap: () => openMoneyEditor(context, day: today),
              borderRadius: BorderRadius.circular(14),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      LucideIcons.circleCheck,
                      size: 28,
                      color: const Color(0xFF10B981).withValues(alpha: 0.7),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      context.l10n.no_spending_today,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      context.l10n.tap_to_log_spending,
                      style: TextStyle(
                        fontSize: 12,
                        color: context.tokens.muted,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else ...[
            // Expense summary bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${todayTxs.length} transaction${todayTxs.length == 1 ? '' : 's'}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: context.tokens.muted,
                    ),
                  ),
                  Text(
                    formatMoney(totals.expense, currency, 'en'),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFEF4444), // Expense red
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Recent today transactions list
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: todayTxs.take(4).length,
              separatorBuilder: (_, __) => const SizedBox(height: 6),
              itemBuilder: (context, index) {
                final tx = todayTxs[index];
                final categoryName = money.nameOf(tx, 'Expense');
                final timeLabel = DateFormat.jm().format(tx.at);

                return InkWell(
                  onTap: () => openMoneyEditor(context, tx: tx),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: tx.isExpense
                                ? const Color(0xFFEF4444).withValues(alpha: 0.12)
                                : const Color(0xFF10B981).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            tx.isExpense
                                ? LucideIcons.arrowUpRight
                                : LucideIcons.arrowDownLeft,
                            size: 16,
                            color: tx.isExpense
                                ? const Color(0xFFEF4444)
                                : const Color(0xFF10B981),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                categoryName,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              if (tx.note.trim().isNotEmpty)
                                Text(
                                  tx.note.trim(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: context.tokens.muted,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${tx.isExpense ? '-' : '+'}${formatMoney(tx.amount, currency, 'en')}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: tx.isExpense
                                    ? const Color(0xFFEF4444)
                                    : const Color(0xFF10B981),
                              ),
                            ),
                            Text(
                              timeLabel,
                              style: TextStyle(
                                fontSize: 11,
                                color: context.tokens.muted,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}
