import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:soulstate/app/theme/app_tokens.dart';
import 'package:soulstate/core/extensions/inset_extensions.dart';
import 'package:soulstate/core/i18n/l10n.dart';
import 'package:soulstate/core/routing/app_navigator.dart';
import 'package:soulstate/core/widgets/app_empty_state.dart';
import 'package:soulstate/core/widgets/option_sheet.dart';
import 'package:soulstate/core/widgets/section_label.dart';
import 'package:soulstate/features/settings/state/settings_controller.dart';
import 'package:soulstate/features/settings/widgets/settings_rows.dart';

class QuotesPage extends StatelessWidget {
  const QuotesPage({super.key});

  List<String> _sourceLabels(BuildContext context) => [
        context.l10n.quotes_app,
        context.l10n.quotes_mine,
        context.l10n.quotes_both,
        context.l10n.quotes_off,
      ];

  Future<void> _add(BuildContext context) async {
    final text = await _askQuote(context, title: context.l10n.quotes_add);
    if (text == null || !context.mounted) return;
    await context.read<SettingsController>().addCustomQuote(text);
  }

  Future<void> _edit(BuildContext context, int index, String current) async {
    final text = await _askQuote(
      context,
      title: context.l10n.quotes_edit,
      initial: current,
    );
    if (text == null || !context.mounted) return;
    await context.read<SettingsController>().editCustomQuote(index, text);
  }

  Future<String?> _askQuote(
    BuildContext context, {
    required String title,
    String initial = '',
  }) =>
      showDialog<String>(
        context: context,
        builder: (_) => _QuoteDialog(title: title, initial: initial),
      );

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsController>();
    final quotes = settings.customQuotes;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft),
          onPressed: () => AppNavigator.pop(),
        ),
        title: Text(context.l10n.quotes),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _add(context),
        icon: const Icon(LucideIcons.plus, size: 20),
        label: Text(context.l10n.quotes_add),
      ),
      body: ListView(
        padding: context.pagePadding(16, 12, 16, 96),
        children: [
          Card(
            child: NavRow(
              icon: LucideIcons.sparkles,
              title: context.l10n.quotes_which,
              subtitle: _sourceLabels(context)[settings.quoteSource],
              onTap: () => showOptionSheet(
                context,
                title: context.l10n.quotes_which,
                options: _sourceLabels(context),
                selected: settings.quoteSource,
                onSelected: (i) =>
                    context.read<SettingsController>().setQuoteSource(i),
              ),
            ),
          ),
          const SizedBox(height: 20),
          SectionLabel(context.l10n.quotes_mine),
          if (quotes.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 36),
                child: AppEmptyState(
                  icon: LucideIcons.quote,
                  title: context.l10n.quotes_empty,
                  message: context.l10n.quotes_empty_sub,
                ),
              ),
            )
          else
            Card(
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(8),
                itemCount: quotes.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) => _QuoteTile(
                  text: quotes[index],
                  onEdit: () => _edit(context, index, quotes[index]),
                  onDelete: () => context
                      .read<SettingsController>()
                      .removeCustomQuote(index),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _QuoteTile extends StatelessWidget {
  const _QuoteTile({
    required this.text,
    required this.onEdit,
    required this.onDelete,
  });

  final String text;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onEdit,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
        decoration: BoxDecoration(
          color: context.colors.surfaceContainerHighest.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: context.colors.onSurface,
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              tooltip: context.l10n.delete,
              icon: Icon(
                LucideIcons.trash2,
                size: 19,
                color: context.tokens.danger,
              ),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}

class _QuoteDialog extends StatefulWidget {
  const _QuoteDialog({required this.title, required this.initial});

  final String title;
  final String initial;

  @override
  State<_QuoteDialog> createState() => _QuoteDialogState();
}

class _QuoteDialogState extends State<_QuoteDialog> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() => Navigator.of(context).pop(_controller.text);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        autofocus: true,
        maxLines: 3,
        minLines: 1,
        maxLength: 140,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(hintText: context.l10n.quotes_hint),
        onSubmitted: (_) => _save(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(context.l10n.cancel),
        ),
        TextButton(onPressed: _save, child: Text(context.l10n.save)),
      ],
    );
  }
}
