import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:soulstate/app/theme/app_tokens.dart';
import 'package:soulstate/core/i18n/l10n.dart';
import 'package:soulstate/core/utils/app_snackbar.dart';
import 'package:soulstate/core/utils/responsive.dart';
import 'package:soulstate/core/widgets/app_confirm_dialog.dart';
import 'package:soulstate/core/widgets/app_text_field.dart';
import 'package:soulstate/core/widgets/sheet_type.dart';
import 'package:soulstate/features/money/data/money_category.dart';
import 'package:soulstate/features/money/data/money_transaction.dart';
import 'package:soulstate/features/money/state/money_controller.dart';
import 'package:soulstate/features/money/widgets/money_kit.dart';
import 'package:soulstate/features/money/widgets/money_labels.dart';

/// Opens the add / edit sheet. If the person deletes the transaction, an
/// undo snackbar is shown from [context].
Future<void> openMoneyEditor(
  BuildContext context, {
  MoneyTransaction? tx,
  DateTime? day,
  MoneyKind? kind,
  String? categoryId,
}) async {
  final money = context.read<MoneyController>();
  final deleted = await showModalBottomSheet<MoneyTransaction>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    constraints: BoxConstraints(
      maxWidth: phoneWidth,
      maxHeight: MediaQuery.sizeOf(context).height * 0.94,
    ),
    builder: (_) => MoneyEditorSheet(
      initial: tx,
      day: day,
      kind: kind,
      categoryId: categoryId,
    ),
  );
  if (deleted == null || !context.mounted) return;
  AppSnackbar.action(
    context,
    context.l10n.money_deleted,
    label: context.l10n.undo,
    onPressed: () => money.saveTransaction(deleted),
  );
}

class MoneyEditorSheet extends StatefulWidget {
  const MoneyEditorSheet({
    super.key,
    this.initial,
    this.day,
    this.kind,
    this.categoryId,
  });

  final MoneyTransaction? initial;
  final DateTime? day;
  final MoneyKind? kind;
  final String? categoryId;

  @override
  State<MoneyEditorSheet> createState() => _MoneyEditorSheetState();
}

class _MoneyEditorSheetState extends State<MoneyEditorSheet> {
  static final _amountRule = RegExp(r'^\d{0,9}([.,]\d{0,2})?$');
  static const _chipLimit = 7;

  late MoneyKind _kind =
      widget.initial?.kind ?? widget.kind ?? MoneyKind.expense;
  late String _categoryId =
      widget.initial?.categoryId ?? widget.categoryId ?? '';
  late DateTime _at = widget.initial?.at ?? _startingPoint();
  late final TextEditingController _amount = TextEditingController(
    text: widget.initial == null ? '' : _plain(widget.initial!.amount),
  );
  late final TextEditingController _note = TextEditingController(
    text: widget.initial?.note ?? '',
  );

  DateTime _startingPoint() {
    final now = DateTime.now();
    final day = widget.day;
    if (day == null) return now;
    return DateTime(day.year, day.month, day.day, now.hour, now.minute);
  }

  static String _plain(double value) {
    var text = value.toStringAsFixed(2);
    text = text.replaceFirst(RegExp(r'0+$'), '');
    return text.replaceFirst(RegExp(r'\.$'), '');
  }

  double get _value =>
      double.tryParse(_amount.text.trim().replaceAll(',', '.')) ?? 0;

  bool get _canSave => _value > 0 && _categoryId.isNotEmpty;

  @override
  void dispose() {
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_canSave) return;
    final money = context.read<MoneyController>();
    final navigator = Navigator.of(context);
    final initial = widget.initial;
    final kind = _kind;
    final amount = _value;
    final categoryId = _categoryId;
    final at = _at;
    final note = _note.text.trim();
    navigator.pop();
    if (initial == null) {
      await money.addTransaction(
        kind: kind,
        amount: amount,
        categoryId: categoryId,
        at: at,
        note: note,
      );
    } else {
      await money.saveTransaction(
        initial.copyWith(
          kind: kind,
          amount: amount,
          categoryId: categoryId,
          at: at,
          note: note,
        ),
      );
    }
  }

  Future<void> _delete() async {
    final initial = widget.initial;
    if (initial == null) return;
    final money = context.read<MoneyController>();
    final confirmed = await showAppConfirmDialog(
      context,
      title: context.l10n.money_delete_title,
      message: context.l10n.money_delete_body,
      confirmLabel: context.l10n.delete,
    );
    if (confirmed != true || !mounted) return;
    final navigator = Navigator.of(context);
    await money.deleteTransaction(initial.id);
    navigator.pop(initial);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _at,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null || !mounted) return;
    setState(() {
      _at = DateTime(
        picked.year,
        picked.month,
        picked.day,
        _at.hour,
        _at.minute,
      );
    });
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_at),
    );
    if (picked == null || !mounted) return;
    setState(() {
      _at = DateTime(_at.year, _at.month, _at.day, picked.hour, picked.minute);
    });
  }

  Future<void> _browse() async {
    FocusScope.of(context).unfocus();
    final picked = await showMoneyCategoryPicker(
      context,
      kind: _kind,
      selectedId: _categoryId,
    );
    if (picked != null && mounted) setState(() => _categoryId = picked);
  }

  void _setKind(MoneyKind kind) {
    if (kind == _kind) return;
    setState(() {
      _kind = kind;
      final current = context.read<MoneyController>().category(_categoryId);
      if (current == null || current.kind != kind) _categoryId = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final money = context.watch<MoneyController>();
    final fmt = MoneyFmt.of(context);
    final scheme = context.colors;
    final tokens = context.tokens;
    final locale = moneyLocale(context);
    final expense = _kind == MoneyKind.expense;
    final accent = expense ? tokens.danger : tokens.success;

    final chips = money.frequent(_kind, limit: _chipLimit);
    final chosen = money.category(_categoryId);
    if (chosen != null &&
        chosen.kind == _kind &&
        !chips.any((c) => c.id == chosen.id)) {
      if (chips.length >= _chipLimit) chips.removeLast();
      chips.insert(0, chosen);
    }

    final amountStyle = sheetFigureStyle(context, size: 38, color: accent);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          4,
          20,
          20 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.initial == null
                    ? context.l10n.money_add
                    : context.l10n.money_edit,
                style: sheetTitleStyle(context),
              ),
              const SizedBox(height: 16),
              MoneySegmented(
                options: [
                  context.l10n.money_expense,
                  context.l10n.money_income,
                ],
                index: expense ? 0 : 1,
                onChanged: (i) =>
                    _setKind(i == 0 ? MoneyKind.expense : MoneyKind.income),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextField(
                  controller: _amount,
                  autofocus: widget.initial == null,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  textInputAction: TextInputAction.done,
                  inputFormatters: [
                    TextInputFormatter.withFunction(
                      (old, next) =>
                          _amountRule.hasMatch(next.text) ? next : old,
                    ),
                  ],
                  onChanged: (_) => setState(() {}),
                  cursorColor: accent,
                  style: amountStyle,
                  decoration: InputDecoration(
                    isDense: true,
                    filled: false,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    hintText: '0',
                    hintStyle: amountStyle.copyWith(
                      color: tokens.muted.withValues(alpha: 0.5),
                    ),
                    prefixText: '${fmt.symbol} ',
                    prefixStyle: amountStyle,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(context.l10n.category, style: sheetBodyStyle(context)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final category in chips)
                    MoneyChip(
                      label: category.name,
                      icon: MoneyIcons.resolve(category.icon),
                      tint: category.color,
                      selected: category.id == _categoryId,
                      onTap: () => setState(() => _categoryId = category.id),
                    ),
                  MoneyChip(
                    label: context.l10n.money_more,
                    icon: LucideIcons.ellipsis,
                    selected: false,
                    onTap: _browse,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    flex: 6,
                    child: _FieldButton(
                      icon: LucideIcons.calendar,
                      text: DateFormat.yMMMd(locale).format(_at),
                      onTap: _pickDate,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 4,
                    child: _FieldButton(
                      icon: LucideIcons.clock,
                      text: DateFormat.jm(locale).format(_at),
                      onTap: _pickTime,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              AppTextField(controller: _note, hint: context.l10n.money_note),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: FilledButton(
                  onPressed: _canSave ? _save : null,
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    context.l10n.save,
                    style: sheetActionStyle(context, size: 16),
                  ),
                ),
              ),
              if (widget.initial != null) ...[
                const SizedBox(height: 6),
                SizedBox(
                  width: double.infinity,
                  child: TextButton.icon(
                    onPressed: _delete,
                    icon: const Icon(LucideIcons.trash2, size: 18),
                    label: Text(context.l10n.delete),
                    style: TextButton.styleFrom(
                      foregroundColor: tokens.danger,
                      minimumSize: const Size.fromHeight(48),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _FieldButton extends StatelessWidget {
  const _FieldButton({
    required this.icon,
    required this.text,
    required this.onTap,
  });

  final IconData icon;
  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: text,
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: context.colors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: context.tokens.muted),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: sheetOptionStyle(context, size: 14.5),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

/// Every category of [kind], grouped. Returns the chosen id.
Future<String?> showMoneyCategoryPicker(
  BuildContext context, {
  required MoneyKind kind,
  String selectedId = '',
}) => showModalBottomSheet<String>(
  context: context,
  isScrollControlled: true,
  showDragHandle: true,
  constraints: BoxConstraints(
    maxWidth: phoneWidth,
    maxHeight: MediaQuery.sizeOf(context).height * 0.85,
  ),
  builder: (_) => _CategoryPicker(kind: kind, selectedId: selectedId),
);

class _CategoryPicker extends StatelessWidget {
  const _CategoryPicker({required this.kind, required this.selectedId});

  final MoneyKind kind;
  final String selectedId;

  @override
  Widget build(BuildContext context) {
    final money = context.watch<MoneyController>();
    final groups = money.groups(kind);

    Widget chip(BuildContext context, MoneyCategory category) => MoneyChip(
      label: category.name,
      icon: MoneyIcons.resolve(category.icon),
      tint: category.color,
      selected: category.id == selectedId,
      onTap: () => Navigator.of(context).pop(category.id),
    );

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.money_choose_category,
              style: sheetTitleStyle(context),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (kind == MoneyKind.income)
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [for (final c in groups) chip(context, c)],
                      )
                    else
                      for (final group in groups)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              chip(context, group),
                              for (final child in money.childrenOf(group.id))
                                chip(context, child),
                            ],
                          ),
                        ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
