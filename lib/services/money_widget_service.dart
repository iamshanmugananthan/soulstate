import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';
import 'package:intl/intl.dart';
import 'package:soulstate/core/database/local_store.dart';
import 'package:soulstate/core/utils/app_dirs.dart';
import 'package:soulstate/core/utils/money_format.dart';
import 'package:soulstate/features/money/data/money_stats.dart';
import 'package:soulstate/features/money/data/money_transaction.dart';
import 'package:soulstate/services/home_widget_service.dart';

class MoneyWidgetService {
  const MoneyWidgetService._();

  static const _provider = 'MoneyWidgetProvider';

  static Future<void> sync([List<MoneyTransaction>? transactions]) async {
    if (!hasHomeWidgets) return;
    try {
      await HomeWidgetService.prepare();
      final all = transactions ?? LocalStore.readMoneyTransactions();
      final currency = LocalStore.setting('currency', defaultCurrencySymbol());
      final now = DateTime.now();
      final monthRange = MoneyRange.of(MoneyPeriod.month, now, 1);
      final monthItems = MoneyStats.within(all, monthRange);
      final monthTotals = MoneyStats.totals(monthItems);
      final allTotals = MoneyStats.totals(all);

      final todayRange = MoneyRange.of(MoneyPeriod.today, now, 1);
      final todayItems = MoneyStats.within(all, todayRange);
      final todayTotals = MoneyStats.totals(todayItems);

      final monthName = DateFormat('MMMM').format(now);

      final data = {
        'currency': currency,
        'balance': formatMoney(allTotals.net, currency, 'en'),
        'income': formatMoney(monthTotals.income, currency, 'en'),
        'expense': formatMoney(monthTotals.expense, currency, 'en'),
        'month': monthName,
        'count': monthTotals.count,
        'todayExpense': formatMoney(todayTotals.expense, currency, 'en'),
      };

      await HomeWidget.saveWidgetData<String>('money_data', json.encode(data));
      await HomeWidget.updateWidget(androidName: _provider, iOSName: _provider);
    } catch (e) {
      debugPrint('Money widget sync failed: $e');
    }
  }
}
