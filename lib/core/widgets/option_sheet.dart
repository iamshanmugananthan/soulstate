import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:soulstate/app/theme/app_tokens.dart';

Future<int?> showOptionSheet(
  BuildContext context, {
  required String title,
  required List<String> options,
  int? index,
  int? selected,
  ValueChanged<int>? onSelected,
  List<IconData>? icons,
  List<String>? subtitles,
}) {
  final current = selected ?? index ?? -1;
  return showModalBottomSheet<int>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) {
      return SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (var i = 0; i < options.length; i++)
                        ListTile(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          leading: icons != null && i < icons.length
                              ? Icon(icons[i])
                              : null,
                          title: Text(
                            options[i],
                            style: TextStyle(
                              fontWeight: i == current
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: i == current
                                  ? context.colors.primary
                                  : null,
                            ),
                          ),
                          subtitle: subtitles != null && i < subtitles.length
                              ? Text(subtitles[i])
                              : null,
                          trailing: i == current
                              ? Icon(
                                  LucideIcons.check,
                                  size: 20,
                                  color: context.colors.primary,
                                )
                              : null,
                          onTap: () {
                            Navigator.of(context).pop(i);
                            onSelected?.call(i);
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
