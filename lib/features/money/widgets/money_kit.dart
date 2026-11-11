import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:soulstate/app/theme/app_tokens.dart';
import 'package:soulstate/core/extensions/color_extensions.dart';
import 'package:soulstate/core/utils/money_format.dart';
import 'package:soulstate/core/widgets/sheet_type.dart';
import 'package:soulstate/features/settings/state/settings_controller.dart';

int moneyStyle(BuildContext context) => 0;

/// Formats amounts with the app-wide currency and the current language.
class MoneyFmt {
  const MoneyFmt(this.symbol, this.locale, {this.decimals});

  final String symbol;
  final String locale;
  final bool? decimals;

  static MoneyFmt of(BuildContext context) {
    final settings = context.watch<SettingsController>();
    return MoneyFmt(
      settings.currency.isEmpty ? defaultCurrencySymbol() : settings.currency,
      Localizations.localeOf(context).toString(),
      decimals: settings.moneyDecimals,
    );
  }

  String plain(double value) => formatMoney(value, symbol, locale, decimals: decimals);

  /// "+₹40", "−₹40", or "₹0".
  String signed(double value, {bool plus = true}) {
    if (value == 0) return plain(0);
    final sign = value < 0 ? '\u2212' : (plus ? '+' : '');
    return '$sign${plain(value.abs())}';
  }

  String compact(double value) =>
      NumberFormat.compact(locale: locale).format(value);
}

class MoneyCard extends StatelessWidget {
  const MoneyCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
  });

  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final body = Padding(padding: padding, child: child);
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: onTap == null ? body : InkWell(onTap: onTap, child: body),
    );
  }
}

class MoneyDivider extends StatelessWidget {
  const MoneyDivider({super.key, this.indent = 68});

  final double indent;

  @override
  Widget build(BuildContext context) => Divider(
    height: 1,
    thickness: 1,
    indent: indent,
    color: context.colors.outlineVariant.withValues(alpha: 0.35),
  );
}

class CategoryBadge extends StatelessWidget {
  const CategoryBadge({
    super.key,
    required this.icon,
    required this.color,
    this.size = 40,
  });

  final IconData icon;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.16),
      borderRadius: BorderRadius.circular(size * 0.34),
    ),
    child: Icon(icon, size: size * 0.5, color: color.shownIn(context)),
  );
}

/// Full-width switcher between two to four labelled options.
class MoneySegmented extends StatelessWidget {
  const MoneySegmented({
    super.key,
    required this.options,
    required this.index,
    required this.onChanged,
  });

  final List<String> options;
  final int index;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    return Container(
      height: 44,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          for (var i = 0; i < options.length; i++)
            Expanded(
              child: Semantics(
                button: true,
                selected: i == index,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    if (i != index) onChanged(i);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: i == index
                          ? scheme.primary
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Text(
                      options[i],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: sheetActionStyle(
                        context,
                        size: 14,
                        color: i == index
                            ? scheme.onPrimary
                            : context.tokens.muted,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// A rounded pill. With [tint] it highlights in that color (used for
/// categories); without it, a selected chip is filled with the accent.
class MoneyChip extends StatelessWidget {
  const MoneyChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
    this.tint,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;
  final Color? tint;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    final accent = tint ?? scheme.primary;
    final shown = accent.shownIn(context);
    final solid = tint == null;
    final background = selected
        ? (solid ? scheme.primary : accent.withValues(alpha: 0.18))
        : scheme.surfaceContainerHighest;
    final foreground = selected
        ? (solid ? scheme.onPrimary : shown)
        : context.tokens.muted;
    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          height: 38,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(19),
            border: selected && !solid
                ? Border.all(color: shown, width: 1.3)
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: foreground),
                const SizedBox(width: 7),
              ],
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 170),
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: sheetActionStyle(
                    context,
                    size: 13.5,
                    color: foreground,
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

/// Previous / label / next control used for months, weeks and years.
class MoneyPeriodBar extends StatelessWidget {
  const MoneyPeriodBar({
    super.key,
    required this.label,
    required this.onPrevious,
    required this.onNext,
    this.onLabel,
  });

  final String label;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback? onLabel;

  @override
  Widget build(BuildContext context) {
    final muted = context.tokens.muted;
    return Row(
      children: [
        IconButton(
          onPressed: onPrevious,
          icon: Icon(LucideIcons.chevronLeft, color: muted),
          visualDensity: VisualDensity.compact,
        ),
        Expanded(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onLabel,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: sheetHeadingStyle(context, size: 16),
              ),
            ),
          ),
        ),
        IconButton(
          onPressed: onNext,
          icon: Icon(LucideIcons.chevronRight, color: muted),
          visualDensity: VisualDensity.compact,
        ),
      ],
    );
  }
}

class MoneyAddButton extends StatefulWidget {
  const MoneyAddButton({super.key, required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  State<MoneyAddButton> createState() => _MoneyAddButtonState();
}

class _MoneyAddButtonState extends State<MoneyAddButton> {
  bool _down = false;

  void _set(bool down) {
    if (_down != down) setState(() => _down = down);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    final face = scheme.primary;
    final ink = scheme.onPrimary;
    return Semantics(
      button: true,
      label: widget.label,
      child: Listener(
        onPointerDown: (_) => _set(true),
        onPointerUp: (_) => _set(false),
        onPointerCancel: (_) => _set(false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedScale(
            scale: _down ? 0.9 : 1,
            duration: Duration(milliseconds: _down ? 90 : 320),
            curve: _down ? Curves.easeOut : Curves.easeOutBack,
            child: Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(21),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color.lerp(face, Colors.white, 0.16)!, face],
                ),
                border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
                boxShadow: [
                  BoxShadow(
                    color: face.withValues(alpha: _down ? 0.2 : 0.38),
                    blurRadius: _down ? 10 : 22,
                    offset: Offset(0, _down ? 3 : 8),
                  ),
                ],
              ),
              child: Icon(LucideIcons.plus, size: 26, color: ink),
            ),
          ),
        ),
      ),
    );
  }
}
