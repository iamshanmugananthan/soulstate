import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:soulstate/app/theme/app_palette.dart';
import 'package:soulstate/app/theme/app_tokens.dart';
import 'package:soulstate/app/theme/color_themes.dart';
import 'package:soulstate/core/utils/responsive.dart';

class AppTheme {
  const AppTheme._();

  static const classicFont = 'GoogleSansRounded';

  static bool isClassic(BuildContext context) => true;

  static ThemeData light([Color? accent, int style = 0, ColorTheme? colors]) =>
      _build(Brightness.light, accent ?? AppPalette.brand, colors);
  static ThemeData dark([Color? accent, int style = 0, ColorTheme? colors]) =>
      _build(Brightness.dark, accent ?? AppPalette.brand, colors);

  static Color _readableOn(Color fill, Color dark) {
    double contrast(Color a, Color b) {
      final x = a.computeLuminance();
      final y = b.computeLuminance();
      return (math.max(x, y) + 0.05) / (math.min(x, y) + 0.05);
    }

    return contrast(fill, dark) >= contrast(fill, Colors.white)
        ? dark
        : Colors.white;
  }

  static ColorScheme _paint(ColorScheme scheme, ThemeColors c) {
    final ink = scheme.brightness == Brightness.dark ? c.background : c.text;
    return scheme.copyWith(
      primary: c.accent,
      onPrimary: _readableOn(c.accent, ink),
      surface: c.background,
      onSurface: c.text,
      onSurfaceVariant: c.muted,
      surfaceContainerLowest: c.background,
      surfaceContainerLow: c.card,
      surfaceContainer: c.card,
      surfaceContainerHigh: c.high,
      surfaceContainerHighest: c.highest,
      outline: c.muted,
      outlineVariant: c.outline,
      error: c.danger,
      onError: _readableOn(c.danger, ink),
    );
  }

  static AppTokens _tokens(bool isDark, ThemeColors? c) => c == null
      ? (isDark ? AppTokens.dark : AppTokens.light)
      : AppTokens(
          success: c.success,
          warning: c.warning,
          danger: c.danger,
          info: c.info,
          muted: c.muted,
        );

  static BorderSide cardEdge(bool isDark) => BorderSide(
        color: isDark
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.black.withValues(alpha: 0.05),
      );

  static Color adaptAccent(Color accent, bool isDark) {
    final luminance = accent.computeLuminance();
    if (isDark && luminance < 0.06) return const Color(0xFFF2F2F2);
    if (!isDark && luminance > 0.82) return const Color(0xFF1C1C1E);
    return accent;
  }

  static SystemUiOverlayStyle systemBars(Brightness brightness) {
    final icons =
        brightness == Brightness.dark ? Brightness.light : Brightness.dark;

    return SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarBrightness: brightness,
      statusBarIconBrightness: icons,
      systemStatusBarContrastEnforced: false,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarIconBrightness: icons,
      systemNavigationBarContrastEnforced: true,
    );
  }

  static ThemeData _build(
    Brightness brightness,
    Color seed,
    ColorTheme? theme,
  ) {
    final colors = theme?.of(brightness);
    final isDark = brightness == Brightness.dark;
    final accent = colors?.accent ?? adaptAccent(seed, isDark);
    const font = classicFont;

    final base = ColorScheme.fromSeed(
      seedColor: accent,
      brightness: brightness,
    ).copyWith(
      primary: accent,
      onPrimary: accent.computeLuminance() > 0.5 ? Colors.black : Colors.white,
      surface: isDark ? AppPalette.darkSurface : const Color(0xFFFAFAFC),
      surfaceContainer: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF4F4F8),
      surfaceContainerHigh: isDark ? const Color(0xFF1F1F22) : const Color(0xFFEDEDF2),
      surfaceContainerHighest: isDark ? AppPalette.darkElevated : const Color(0xFFE4E4EC),
      outlineVariant: isDark ? AppPalette.darkBorder : const Color(0xFFD9D9E0),
    );
    final scheme = colors == null ? base : _paint(base, colors);

    final cardColor = colors?.card ?? (isDark ? AppPalette.darkCard : Colors.white);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: Colors.transparent,
      fontFamily: font,
      visualDensity: VisualDensity.standard,
      splashFactory: NoSplash.splashFactory,
      extensions: [_tokens(isDark, colors)],
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        systemOverlayStyle: systemBars(brightness),
        foregroundColor: scheme.onSurface,
        titleTextStyle: TextStyle(
          fontFamily: font,
          fontSize: 26,
          fontWeight: FontWeight.w800,
          color: scheme.onSurface,
        ),
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: isDark ? 0 : 1,
        shadowColor: Colors.black.withValues(alpha: 0.35),
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: cardEdge(isDark),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: cardColor,
        surfaceTintColor: Colors.transparent,
        constraints: const BoxConstraints(maxWidth: phoneWidth),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(28),
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        constraints: const BoxConstraints(minWidth: 280, maxWidth: paneWidth),
        backgroundColor: cardColor,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        titleTextStyle: TextStyle(
          fontFamily: classicFont,
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: scheme.onSurface,
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
      timePickerTheme: TimePickerThemeData(
        backgroundColor: cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: cardColor,
        indicatorColor: scheme.primary.withValues(alpha: 0.18),
        elevation: 0,
        height: 68,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
    );
  }
}
