import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:soulstate/app/theme/app_tokens.dart';
import 'package:soulstate/core/extensions/inset_extensions.dart';
import 'package:soulstate/core/i18n/l10n.dart';
import 'package:soulstate/core/widgets/sheet_type.dart';
import 'package:soulstate/features/money/data/money_category.dart';
import 'package:soulstate/features/money/data/money_transaction.dart';
import 'package:soulstate/features/money/state/money_controller.dart';
import 'package:soulstate/features/money/widgets/money_category_editor.dart';
import 'package:soulstate/features/money/widgets/money_kit.dart';

class MoneyCategoriesPage extends StatefulWidget {
  const MoneyCategoriesPage({super.key});

  @override
  State<MoneyCategoriesPage> createState() => _MoneyCategoriesPageState();
}

class _MoneyCategoriesPageState extends State<MoneyCategoriesPage> {
  MoneyKind _kind = MoneyKind.expense;

  @override
  Widget build(BuildContext context) {
    final money = context.watch<MoneyController>();
    final expense = _kind == MoneyKind.expense;
    final groups = money.groups(_kind);
    const side = 16.0;

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.money_categories)),
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: context.pagePadding(side, 8, side, 12),
                child: MoneySegmented(
                  options: [
                    context.l10n.money_expense,
                    context.l10n.money_income,
                  ],
                  index: expense ? 0 : 1,
                  onChanged: (i) => setState(
                    () => _kind = i == 0 ? MoneyKind.expense : MoneyKind.income,
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  padding: context.pagePadding(side, 4, side, 120),
                  children: [
                    if (groups.isEmpty)
                      MoneyCard(
                        child: Text(
                          context.l10n.money_no_categories,
                          style: sheetBodyStyle(context),
                        ),
                      )
                    else if (!expense)
                      MoneyCard(
                        padding: EdgeInsets.zero,
                        child: Column(
                          children: [
                            for (final (index, category) in groups.indexed) ...[
                              if (index > 0) const MoneyDivider(),
                              _CategoryRow(
                                category: category,
                                onTap: () => showMoneyCategoryEditor(
                                  context,
                                  kind: _kind,
                                  initial: category,
                                ),
                              ),
                            ],
                          ],
                        ),
                      )
                    else
                      for (final group in groups)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: _GroupCard(group: group),
                        ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            right: side + context.safeInsets.right,
            bottom: 20 + context.bottomInset,
            child: MoneyAddButton(
              label: context.l10n.new_category,
              onTap: () => showMoneyCategoryEditor(context, kind: _kind),
            ),
          ),
        ],
      ),
    );
  }
}

class _GroupCard extends StatelessWidget {
  const _GroupCard({required this.group});

  final MoneyCategory group;

  @override
  Widget build(BuildContext context) {
    final money = context.watch<MoneyController>();
    final children = money.childrenOf(group.id);
    return MoneyCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          _CategoryRow(
            category: group,
            strong: true,
            onTap: () => showMoneyCategoryEditor(
              context,
              kind: group.kind,
              initial: group,
            ),
          ),
          for (final child in children) ...[
            const MoneyDivider(),
            _CategoryRow(
              category: child,
              indent: true,
              onTap: () => showMoneyCategoryEditor(
                context,
                kind: child.kind,
                initial: child,
              ),
            ),
          ],
          const MoneyDivider(),
          Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: () => showMoneyCategoryEditor(
                context,
                kind: group.kind,
                parentId: group.id,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 13,
                ),
                child: Row(
                  children: [
                    Icon(
                      LucideIcons.plus,
                      size: 18,
                      color: context.colors.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        context.l10n.money_add_sub,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: sheetActionStyle(
                          context,
                          size: 14,
                          color: context.colors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({
    required this.category,
    required this.onTap,
    this.strong = false,
    this.indent = false,
  });

  final MoneyCategory category;
  final VoidCallback onTap;
  final bool strong;
  final bool indent;

  @override
  Widget build(BuildContext context) {
    final used = context.watch<MoneyController>().usageOf(category.id);
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.fromLTRB(indent ? 36 : 16, 11, 16, 11),
          child: Row(
            children: [
              CategoryBadge(
                icon: MoneyIcons.resolve(category.icon),
                color: category.color,
                size: indent ? 34 : 40,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: sheetOptionStyle(
                        context,
                        size: 15.5,
                        selected: strong,
                      ),
                    ),
                    if (used > 0)
                      Text(
                        context.l10n.money_transactions_count(used),
                        style: sheetBodyStyle(context, size: 12),
                      ),
                  ],
                ),
              ),
              Icon(
                LucideIcons.chevronRight,
                size: 18,
                color: context.tokens.muted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
