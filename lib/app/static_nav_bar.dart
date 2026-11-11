import 'package:flutter/material.dart';
import 'package:soulstate/app/theme/app_tokens.dart';

typedef StaticNavItem = ({IconData icon, String label});

class StaticNavBar extends StatelessWidget {
  const StaticNavBar({
    super.key,
    required this.items,
    required this.index,
    required this.onSelect,
  });

  final List<StaticNavItem> items;
  final int index;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final tokens = context.tokens;
    final activeColor = scheme.primary;
    final inactiveColor = tokens.muted;

    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border(
          top: BorderSide(
            color: scheme.outlineVariant.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 58,
          child: Row(
            children: [
              for (var i = 0; i < items.length; i++) ...[
                Expanded(
                  child: Semantics(
                    button: true,
                    selected: i == index,
                    label: items[i].label,
                    excludeSemantics: true,
                    onTap: () => onSelect(i),
                    child: InkWell(
                      onTap: () => onSelect(i),
                      splashFactory: NoSplash.splashFactory,
                      highlightColor: Colors.transparent,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            items[i].icon,
                            size: 22,
                            color: i == index ? activeColor : inactiveColor,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            items[i].label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: i == index ? FontWeight.w600 : FontWeight.w500,
                              color: i == index ? activeColor : inactiveColor,
                            ),
                          ),
                        ],
                      ),
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
