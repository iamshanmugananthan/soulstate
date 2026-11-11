import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:soulstate/core/i18n/app_locale.dart';
import 'package:soulstate/app/app_background.dart';
import 'package:soulstate/app/app_lock.dart';
import 'package:soulstate/app/home_shell.dart';
import 'package:soulstate/app/theme/app_theme.dart';
import 'package:soulstate/core/i18n/l10n.dart';
import 'package:soulstate/core/routing/app_navigator.dart';
import 'package:soulstate/features/habits/state/habits_controller.dart';
import 'package:soulstate/features/settings/state/settings_controller.dart';
import 'package:soulstate/features/vault/pages/vault_setup_page.dart';
import 'package:soulstate/services/home_widget_service.dart';

class SoulStateApp extends StatelessWidget {
  const SoulStateApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsController>();

    return MaterialApp(
      title: 'Soul State',
      debugShowCheckedModeBanner: false,
      navigatorKey: AppNavigator.key,
      theme: AppTheme.light(
        settings.accentColor,
        settings.appStyle,
        settings.colorTheme,
      ),
      darkTheme: AppTheme.dark(
        settings.accentColor,
        settings.appStyle,
        settings.colorTheme,
      ),
      themeMode: settings.themeMode,
      builder: (context, child) {
        HomeWidgetService.localize(
          AppLocalizations.of(context),
          () => context.read<HabitsController>().asMap,
        );
        final media = MediaQuery.of(context);
        return MediaQuery(
          data: settings.animations
              ? media
              : media.copyWith(disableAnimations: true),
          child: AnnotatedRegion<SystemUiOverlayStyle>(
          value: AppTheme.systemBars(Theme.of(context).brightness),
          child: AppLockGate(
            child: AppBackground(
              child: _DesktopFrame(
                shell: settings.hasVault,
                child: child ?? const SizedBox.shrink(),
              ),
            ),
          ),
        ),
        );
      },
      locale: settings.locale,
      supportedLocales: shippedLocales,
      localeListResolutionCallback: (wanted, _) => pickLocale(wanted),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: !settings.hasVault
          ? const VaultSetupPage()
          : const HomeShell(),
    );
  }
}

class _DesktopFrame extends StatelessWidget {
  const _DesktopFrame({required this.shell, required this.child});

  final bool shell;
  final Widget child;

  @override
  Widget build(BuildContext context) => child;
}
