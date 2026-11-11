import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:soulstate/app/theme/app_tokens.dart';
import 'package:soulstate/core/widgets/sheet_type.dart';

class DonutSlice {
  const DonutSlice(this.share, this.color);

  final double share;
  final Color color;
}

/// A ring chart with a label in the middle. Slices sweep in once, then stay.
class MoneyDonut extends StatelessWidget {
  const MoneyDonut({
    super.key,
    required this.slices,
    required this.label,
    required this.value,
    this.size = 200,
  });

  final List<DonutSlice> slices;
  final String label;
  final String value;
  final double size;

  @override
  Widget build(BuildContext context) {
    final animate = !MediaQuery.of(context).disableAnimations;
    final signature = slices
        .map((s) => '${s.share.toStringAsFixed(3)}:${s.color.toARGB32()}')
        .join('|');
    final stroke = size * 0.15;
    final track = context.colors.surfaceContainerHighest;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          TweenAnimationBuilder<double>(
            key: ValueKey(signature),
            tween: Tween<double>(begin: animate ? 0 : 1, end: 1),
            duration: animate
                ? const Duration(milliseconds: 700)
                : Duration.zero,
            curve: Curves.easeOutCubic,
            builder: (context, progress, _) => CustomPaint(
              size: Size.square(size),
              painter: _DonutPainter(
                slices: slices,
                progress: progress,
                stroke: stroke,
                track: track,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(stroke + 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: sheetBodyStyle(context, size: 12),
                ),
                const SizedBox(height: 2),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    value,
                    maxLines: 1,
                    style: sheetFigureStyle(
                      context,
                      size: 22,
                      color: context.colors.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  const _DonutPainter({
    required this.slices,
    required this.progress,
    required this.stroke,
    required this.track,
  });

  final List<DonutSlice> slices;
  final double progress;
  final double stroke;
  final Color track;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = (math.min(size.width, size.height) - stroke) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..color = track,
    );

    final full = math.pi * 2;
    final limit = full * progress;
    final gap = slices.length > 1 ? 0.035 : 0.0;
    var start = -math.pi / 2;
    var used = 0.0;
    for (final slice in slices) {
      final sweep = slice.share * full;
      if (used >= limit) break;
      final visible = math.min(sweep, limit - used);
      final drawn = visible - gap;
      if (drawn > 0.002) {
        canvas.drawArc(
          rect,
          start + gap / 2,
          drawn,
          false,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = stroke
            ..strokeCap = StrokeCap.butt
            ..color = slice.color,
        );
      }
      start += sweep;
      used += sweep;
    }
  }

  @override
  bool shouldRepaint(_DonutPainter old) =>
      old.progress != progress ||
      old.stroke != stroke ||
      old.track != track ||
      old.slices != slices;
}
