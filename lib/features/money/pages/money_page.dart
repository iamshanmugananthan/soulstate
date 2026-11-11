import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:soulstate/app/theme/app_tokens.dart';
import 'package:soulstate/core/extensions/date_extensions.dart';
import 'package:soulstate/core/extensions/inset_extensions.dart';
import 'package:soulstate/core/i18n/l10n.dart';
import 'package:soulstate/core/routing/app_navigator.dart';
import 'package:soulstate/core/utils/app_snackbar.dart';
import 'package:soulstate/core/utils/responsive.dart';
import 'package:soulstate/core/widgets/app_confirm_dialog.dart';
import 'package:soulstate/core/widgets/glass.dart';
import 'package:soulstate/core/widgets/sheet_action.dart';
import 'package:soulstate/features/habits/widgets/saved_money.dart';
import 'package:soulstate/features/money/data/money_stats.dart';
import 'package:soulstate/features/money/data/money_transaction.dart';
import 'package:soulstate/features/money/pages/money_categories_page.dart';
import 'package:soulstate/features/money/pages/money_category_report_page.dart';
import 'package:soulstate/features/money/state/money_controller.dart';
import 'package:soulstate/features/money/widgets/money_analysis.dart';
import 'package:soulstate/features/money/widgets/money_calendar.dart';
import 'package:soulstate/features/money/widgets/money_editor_sheet.dart';
import 'package:soulstate/features/money/widgets/money_kit.dart';
import 'package:soulstate/features/money/widgets/money_overview.dart';
import 'package:soulstate/features/settings/state/settings_controller.dart';

/// Income and expense tracking: a month overview, period analysis and a
/// calendar, with a single add button.
class MoneyPage extends StatefulWidget {
  const MoneyPage({super.key});

  @override
  State<MoneyPage> createState() => _MoneyPageState();
}

class _MoneyPageState extends State<MoneyPage> {
  int _view = 0;

  late DateTime _month = _firstOf(AppClock.today());
  late DateTime _selected = AppClock.today();

  MoneyPeriod _period = MoneyPeriod.month;
  late DateTime _anchor = AppClock.today();
  MoneyKind _kind = MoneyKind.expense;

  static DateTime _firstOf(DateTime day) => DateTime(day.year, day.month, 1);

  bool get _viewingThisMonth {
    final today = AppClock.today();
    return _month.year == today.year && _month.month == today.month;
  }

  void _shiftMonth(int steps) {
    final next = DateTime(_month.year, _month.month + steps, 1);
    final today = AppClock.today();
    final isCurrent = next.year == today.year && next.month == today.month;
    setState(() {
      _month = next;
      _selected = isCurrent ? today : next;
    });
  }

  void _jumpToToday() {
    final today = AppClock.today();
    setState(() {
      _month = _firstOf(today);
      _selected = today;
    });
  }

  void _shiftAnalysis(int steps) =>
      setState(() => _anchor = MoneyRange.shift(_period, _anchor, steps));

  void _openTransaction(MoneyTransaction tx) =>
      openMoneyEditor(context, tx: tx);

  void _add() {
    DateTime? day;
    if (_view == 2) {
      day = _selected;
    } else if (_view == 0 && !_viewingThisMonth) {
      day = _month;
    }
    openMoneyEditor(context, day: day, kind: _view == 1 ? _kind : null);
  }

  void _openCategory(MoneyBreakdown row) {
    final year = _period == MoneyPeriod.all
        ? AppClock.today().year
        : _anchor.year;
    AppNavigator.push(
      MoneyCategoryReportPage(
        categoryId: row.categoryId,
        kind: _kind,
        fallbackName: row.label,
        year: year,
      ),
    );
  }

  Future<void> _showMore() {
    final page = context;
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      constraints: const BoxConstraints(maxWidth: phoneWidth),
      builder: (sheet) {
        void close() => Navigator.of(sheet).pop();
        final symbol = sheet.read<SettingsController>().currency;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SheetAction(
                  icon: LucideIcons.layoutGrid,
                  label: sheet.l10n.money_manage_categories,
                  onTap: () {
                    close();
                    AppNavigator.push(const MoneyCategoriesPage());
                  },
                ),
                SheetAction(
                  icon: LucideIcons.coins,
                  label: sheet.l10n.currency,
                  badge: symbol,
                  onTap: () {
                    close();
                    if (page.mounted) showCurrencySheet(page);
                  },
                ),
                SheetAction(
                  icon: LucideIcons.rotateCcw,
                  label: sheet.l10n.money_reset_categories,
                  onTap: () {
                    close();
                    _confirmReset(page);
                  },
                ),
                SheetAction(
                  icon: LucideIcons.trash2,
                  label: sheet.l10n.money_delete_all,
                  accent: sheet.tokens.danger,
                  onTap: () {
                    close();
                    _confirmDeleteAll(page);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmReset(BuildContext page) async {
    final money = page.read<MoneyController>();
    final confirmed = await showAppConfirmDialog(
      page,
      title: page.l10n.money_reset_categories,
      message: page.l10n.money_reset_categories_body,
      confirmLabel: page.l10n.money_reset_action,
      icon: LucideIcons.rotateCcw,
      danger: false,
    );
    if (confirmed != true || !page.mounted) return;
    await money.resetCategories();
    if (page.mounted) {
      AppSnackbar.success(page, page.l10n.money_reset_done);
    }
  }

  Future<void> _confirmDeleteAll(BuildContext page) async {
    final money = page.read<MoneyController>();
    final confirmed = await showAppConfirmDialog(
      page,
      title: page.l10n.money_delete_all,
      message: page.l10n.money_delete_all_body,
      confirmLabel: page.l10n.delete,
    );
    if (confirmed != true || !page.mounted) return;
    await money.deleteAllTransactions();
    if (page.mounted) {
      AppSnackbar.success(page, page.l10n.money_delete_all_done);
    }
  }

  @override
  Widget build(BuildContext context) {
    const side = 16.0;
    final railed = hasSideRail(context);
    final listPadding = context.pagePadding(
      side,
      8,
      side,
      railed ? 110 : 160,
    );

    final more = Padding(
      padding: const EdgeInsetsDirectional.only(end: 8),
      child: GlassIconButton(
        icon: LucideIcons.ellipsis,
        tooltip: context.l10n.money_more,
        size: 38,
        onTap: _showMore,
      ),
    );

    final Widget body = switch (_view) {
      1 => MoneyAnalysis(
        period: _period,
        anchor: _anchor,
        kind: _kind,
        padding: listPadding,
        onPeriod: (p) => setState(() => _period = p),
        onShift: _shiftAnalysis,
        onToday: () => setState(() => _anchor = AppClock.today()),
        onKind: (k) => setState(() => _kind = k),
        onOpenCategory: _openCategory,
      ),
      2 => MoneyCalendar(
        month: _month,
        selected: _selected,
        padding: listPadding,
        onSelect: (day) => setState(() => _selected = day),
        onShift: _shiftMonth,
        onToday: _jumpToToday,
        onOpen: _openTransaction,
        onAdd: _add,
      ),
      _ => MoneyOverview(
        month: _month,
        padding: listPadding,
        onShift: _shiftMonth,
        onToday: _jumpToToday,
        onOpen: _openTransaction,
        onAdd: _add,
      ),
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.money),
        actions: [
          more,
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _add,
        child: const Icon(LucideIcons.plus),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: maxContentWidth),
          child: Column(
            children: [
              Padding(
                padding: context.pagePadding(side, 4, side, 4),
                child: MoneySegmented(
                  options: [
                    context.l10n.money_overview,
                    context.l10n.money_analysis,
                    context.l10n.money_calendar,
                  ],
                  index: _view,
                  onChanged: (i) => setState(() => _view = i),
                ),
              ),
              Expanded(
                child: KeyedSubtree(key: ValueKey(_view), child: body),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
