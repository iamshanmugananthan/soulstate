import 'package:flutter/material.dart';

const todoPapers = [
  Color(0xFFFFF6B8),
  Color(0xFFF7D9C4),
  Color(0xFFF9C9C2),
  Color(0xFFE3F0D3),
  Color(0xFFBEDDD4),
  Color(0xFFD3E4EE),
  Color(0xFFDCC7E3),
  Color(0xFFEDE0D4),
  Color(0xFFE6E3D6),
];

const paperInk = Color(0xFF1F1F22);
const paperInkSoft = Color(0xFF5B5B63);

const darkSheet = Color(0xFF36363C);

Color paperColor(int paper) =>
    paper < 0 ? Colors.white : todoPapers[paper % todoPapers.length];

bool _dark(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark;

Color sheetColor(BuildContext context, int paper) {
  if (!_dark(context)) return paperColor(paper);
  return paper < 0 ? darkSheet : Color.lerp(darkSheet, paperColor(paper), 0.3)!;
}

Color inkOf(BuildContext context) =>
    _dark(context) ? const Color(0xFFEDEDF0) : paperInk;

Color softInkOf(BuildContext context) =>
    _dark(context) ? const Color(0xFFA4A4AD) : paperInkSoft;
