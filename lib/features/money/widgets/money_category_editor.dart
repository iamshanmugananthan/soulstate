import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:soulstate/app/theme/app_tokens.dart';
import 'package:soulstate/core/i18n/l10n.dart';
import 'package:soulstate/core/utils/responsive.dart';
import 'package:soulstate/core/widgets/app_confirm_dialog.dart';
import 'package:soulstate/core/widgets/app_text_field.dart';
import 'package:soulstate/core/widgets/sheet_type.dart';
import 'package:soulstate/features/habits/widgets/color_picker.dart';
import 'package:soulstate/features/money/data/money_category.dart';
import 'package:soulstate/features/money/data/money_transaction.dart';
import 'package:soulstate/features/money/state/money_controller.dart';
import 'package:soulstate/features/money/widgets/money_kit.dart';

Future<void> showMoneyCategoryEditor(
  BuildContext context, {
  required MoneyKind kind,
  MoneyCategory? initial,
  String parentId = '',
}) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  showDragHandle: true,
  constraints: BoxConstraints(
    maxWidth: phoneWidth,
    maxHeight: MediaQuery.sizeOf(context).height * 0.94,
  ),
  builder: (_) =>
      _CategoryEditor(kind: kind, initial: initial, parentId: parentId),
);

class _CategoryEditor extends StatefulWidget {
  const _CategoryEditor({
    required this.kind,
    required this.initial,
    required this.parentId,
  });

  final MoneyKind kind;
  final MoneyCategory? initial;
  final String parentId;

  @override
  State<_CategoryEditor> createState() => _CategoryEditorState();
}

class _CategoryEditorState extends State<_CategoryEditor> {
  static const _previewCount = 16;

  late final TextEditingController _name = TextEditingController(
    text: widget.initial?.name ?? '',
  );
  late String _parentId = widget.initial?.parentId ?? widget.parentId;
  late String _icon = widget.initial?.icon ?? 'tag';
  late Color _color = widget.initial?.color ?? _inheritedColor();
  bool _showAllIcons = false;

  Color _inheritedColor() {
    final parent = context.read<MoneyController>().category(widget.parentId);
    return parent?.color ?? MoneyPalette.colors.first;
  }

  bool get _canSave => _name.text.trim().isNotEmpty;

  List<String> get _visibleIcons {
    final all = MoneyIcons.names;
    if (_showAllIcons || all.length <= _previewCount) return all;
    final preview = all.take(_previewCount).toList();
    if (!preview.contains(_icon) && all.contains(_icon)) {
      preview[preview.length - 1] = _icon;
    }
    return preview;
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final money = context.read<MoneyController>();
    final navigator = Navigator.of(context);
    final initial = widget.initial;
    final name = _name.text.trim();
    final color = _color;
    final icon = _icon;
    final parentId = widget.kind == MoneyKind.expense ? _parentId : '';
    navigator.pop();
    if (initial == null) {
      await money.createCategory(
        name: name,
        kind: widget.kind,
        color: color,
        icon: icon,
        parentId: parentId,
      );
    } else {
      await money.updateCategory(
        initial.copyWith(
          name: name,
          color: color,
          icon: icon,
          parentId: parentId,
        ),
      );
    }
  }

  Future<void> _delete() async {
    final initial = widget.initial;
    if (initial == null) return;
    final money = context.read<MoneyController>();
    final used = money.usageWithChildren(initial.id);
    final confirmed = await showAppConfirmDialog(
      context,
      title: context.l10n.money_delete_category_title,
      message: used == 0
          ? context.l10n.money_delete_category_unused
          : context.l10n.money_delete_category_used(used),
      confirmLabel: context.l10n.delete,
    );
    if (confirmed != true || !mounted) return;
    final navigator = Navigator.of(context);
    navigator.pop();
    await money.deleteCategory(initial.id);
  }

  @override
  Widget build(BuildContext context) {
    final money = context.watch<MoneyController>();
    final initial = widget.initial;
    final expense = widget.kind == MoneyKind.expense;
    final canNest =
        expense &&
        (initial == null ||
            !initial.isGroup ||
            money.childrenOf(initial.id).isEmpty);
    final groups = [
      for (final g in money.groups(widget.kind))
        if (g.id != initial?.id) g,
    ];

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
                initial == null
                    ? context.l10n.new_category
                    : context.l10n.edit_category,
                style: sheetTitleStyle(context),
              ),
              const SizedBox(height: 18),
              AppTextField(
                controller: _name,
                hint: context.l10n.name,
                autofocus: initial == null,
                onChanged: (_) => setState(() {}),
              ),
              if (canNest && groups.isNotEmpty) ...[
                const SizedBox(height: 18),
                Text(context.l10n.money_group, style: sheetBodyStyle(context)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    MoneyChip(
                      label: context.l10n.money_top_level,
                      selected: _parentId.isEmpty,
                      onTap: () => setState(() => _parentId = ''),
                    ),
                    for (final group in groups)
                      MoneyChip(
                        label: group.name,
                        icon: MoneyIcons.resolve(group.icon),
                        tint: group.color,
                        selected: _parentId == group.id,
                        onTap: () => setState(() => _parentId = group.id),
                      ),
                  ],
                ),
              ],
              const SizedBox(height: 18),
              Text(context.l10n.icon, style: sheetBodyStyle(context)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (final name in _visibleIcons)
                    Semantics(
                      button: true,
                      selected: _icon == name,
                      label: name,
                      child: GestureDetector(
                        onTap: () => setState(() => _icon = name),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: _icon == name
                                ? _color.withValues(alpha: 0.16)
                                : context.colors.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(12),
                            border: _icon == name
                                ? Border.all(color: _color, width: 1.6)
                                : null,
                          ),
                          child: Icon(
                            MoneyIcons.resolve(name),
                            size: 20,
                            color: _icon == name
                                ? _color
                                : context.tokens.muted,
                          ),
                        ),
                      ),
                    ),
                  if (!_showAllIcons && MoneyIcons.names.length > _previewCount)
                    Semantics(
                      button: true,
                      child: GestureDetector(
                        onTap: () => setState(() => _showAllIcons = true),
                        child: Container(
                          height: 44,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: context.colors.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            context.l10n.see_more,
                            style: sheetLabelStyle(
                              context,
                              color: context.colors.primary,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 18),
              Text(context.l10n.color, style: sheetBodyStyle(context)),
              const SizedBox(height: 10),
              ColorPicker(
                selected: _color,
                onSelected: (c) => setState(() => _color = c),
              ),
              const SizedBox(height: 24),
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
              if (initial != null) ...[
                const SizedBox(height: 6),
                SizedBox(
                  width: double.infinity,
                  child: TextButton.icon(
                    onPressed: _delete,
                    icon: const Icon(LucideIcons.trash2, size: 18),
                    label: Text(context.l10n.delete),
                    style: TextButton.styleFrom(
                      foregroundColor: context.tokens.danger,
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
