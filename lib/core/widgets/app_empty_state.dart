import 'package:flutter/material.dart';
import 'package:soulstate/app/theme/app_tokens.dart';
import 'package:soulstate/core/widgets/sheet_type.dart';

class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.action,
    this.compact = false,
  });

  final IconData icon;
  final String title;
  final String? message;
  final Widget? action;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    final muted = context.tokens.muted;
    final haloSize = compact ? 72.0 : 108.0;
    final glyph = Icon(icon, size: compact ? 32 : 46, color: scheme.primary);

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 8 : 40,
          vertical: compact ? 28 : 40,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: haloSize,
              height: haloSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    scheme.primary.withValues(alpha: 0.16),
                    scheme.primary.withValues(alpha: 0.03),
                  ],
                ),
              ),
              child: glyph,
            ),
            SizedBox(height: compact ? 18 : 28),
            Text(
              title,
              textAlign: TextAlign.center,
              style: sheetTitleStyle(context, size: compact ? 14 : 21),
            ),
            if (message != null) ...[
              const SizedBox(height: 10),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: sheetBodyStyle(
                  context,
                  size: compact ? 13.5 : 14.5,
                  color: muted,
                ),
              ),
            ],
            if (action != null) ...[
              SizedBox(height: compact ? 22 : 30),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
