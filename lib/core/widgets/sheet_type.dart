import 'package:flutter/material.dart';
import 'package:soulstate/app/theme/app_tokens.dart';

export 'package:soulstate/core/widgets/option_sheet.dart';

int sheetStyle(BuildContext context) => 0;

TextStyle sheetTitleStyle(BuildContext context, {double size = 20, Color? color}) {
  final tone = color ?? context.colors.onSurface;
  return TextStyle(
    fontSize: size,
    fontWeight: FontWeight.w800,
    color: tone,
  );
}

TextStyle sheetHeadingStyle(BuildContext context, {double size = 15, Color? color}) {
  final tone = color ?? context.colors.onSurface;
  return TextStyle(
    fontSize: size,
    fontWeight: FontWeight.w700,
    color: tone,
  );
}

TextStyle sheetOptionStyle(
  BuildContext context, {
  double size = 16,
  bool selected = false,
  Color? color,
}) {
  final tone = color ?? context.colors.onSurface;
  return TextStyle(
    fontSize: size,
    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
    color: tone,
  );
}

TextStyle sheetLabelStyle(BuildContext context, {double size = 13, Color? color}) {
  final tone = color ?? context.tokens.muted;
  return TextStyle(
    fontSize: size,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.3,
    color: tone,
  );
}

TextStyle sheetFigureStyle(BuildContext context, {double size = 40, Color? color}) {
  return TextStyle(
    fontSize: size,
    fontWeight: FontWeight.w800,
    color: color,
  );
}

TextStyle sheetActionStyle(BuildContext context, {double size = 15, Color? color}) {
  return TextStyle(
    fontSize: size,
    fontWeight: FontWeight.w800,
    color: color,
  );
}

TextStyle sheetBodyStyle(BuildContext context, {double size = 13.5, Color? color}) {
  final tone = color ?? context.tokens.muted;
  return TextStyle(fontSize: size, height: 1.35, color: tone);
}

class SheetTitle extends StatelessWidget {
  const SheetTitle(this.text, {super.key, this.subtitle, this.trailing});

  final String text;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final title = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(text, style: sheetTitleStyle(context)),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(subtitle!, style: sheetBodyStyle(context)),
        ],
      ],
    );

    if (trailing == null) return title;
    return Row(
      crossAxisAlignment:
          subtitle == null ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Expanded(child: title),
        const SizedBox(width: 12),
        trailing!,
      ],
    );
  }
}
