import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:soulstate/app/theme/app_tokens.dart';
import 'package:soulstate/core/extensions/color_extensions.dart';
import 'package:soulstate/core/widgets/sheet_type.dart';

/// Vertical bars with a label under each. Tapping a bar selects it.
class MoneyBars extends StatelessWidget {
  const MoneyBars({
    super.key,
    required this.values,
    required this.labels,
    required this.color,
    required this.selected,
    required this.onSelect,
    this.height = 140,
  });

  final List<double> values;
  final List<String> labels;
  final Color color;
  final int? selected;
  final ValueChanged<int> onSelect;
  final double height;

  @override
  Widget build(BuildContext context) {
    final top = values.fold<double>(0, math.max);
    final tone = color.shownIn(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (var i = 0; i < values.length; i++)
          Expanded(
            child: Semantics(
              button: true,
              selected: i == selected,
              label: labels[i],
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onSelect(i),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: height,
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: FractionallySizedBox(
                          widthFactor: 0.6,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 320),
                            curve: Curves.easeOutCubic,
                            height: top <= 0
                                ? 4
                                : math.max(4.0, values[i] / top * height),
                            decoration: BoxDecoration(
                              color: i == selected
                                  ? tone
                                  : tone.withValues(
                                      alpha: values[i] > 0 ? 0.5 : 0.18,
                                    ),
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(6),
                                bottom: Radius.circular(2),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        labels[i],
                        maxLines: 1,
                        style: sheetBodyStyle(
                          context,
                          size: 11,
                          color: i == selected
                              ? context.colors.onSurface
                              : context.tokens.muted,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
