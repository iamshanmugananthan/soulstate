import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:soulstate/app/theme/app_tokens.dart';
import 'package:soulstate/core/extensions/inset_extensions.dart';
import 'package:soulstate/core/i18n/l10n.dart';
import 'package:soulstate/core/routing/app_navigator.dart';
import 'package:soulstate/core/utils/app_dirs.dart';
import 'package:soulstate/core/utils/app_snackbar.dart';
import 'package:soulstate/core/utils/responsive.dart';
import 'package:soulstate/core/widgets/entrance.dart';
import 'package:soulstate/core/widgets/option_sheet.dart';
import 'package:soulstate/core/widgets/section_label.dart';
import 'package:soulstate/features/settings/data_folder_actions.dart';
import 'package:soulstate/features/settings/pages/about_page.dart';
import 'package:soulstate/features/settings/pages/quotes_page.dart';
import 'package:soulstate/features/settings/settings_actions.dart';
import 'package:soulstate/features/settings/state/settings_controller.dart';
import 'package:soulstate/features/settings/widgets/settings_rows.dart';
import 'package:soulstate/features/settings/widgets/color_theme_sheet.dart';
import 'package:soulstate/features/settings/widgets/settings_sheets.dart';
import 'package:soulstate/features/settings/widgets/widget_style_list.dart';
import 'package:soulstate/features/vault/services/vault_manager.dart';
import 'package:soulstate/services/s3_sync_service.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ClassicSettingsPage();
  }
}

class ClassicSettingsPage extends StatelessWidget {
  const ClassicSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsController>();

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.settings)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: maxContentWidth),
          child: ListView(
            padding: context.pagePadding(16, 16, 16, 104),
        children: [
          Entrance(
            child: _ProfileHeader(
              name: settings.profileName.isEmpty
                  ? context.l10n.default_user
                  : settings.profileName,
              photoPath: settings.profilePhoto,
            ),
          ),
          const SizedBox(height: 24),
          Entrance(
            index: 1,
            child: Card(
              child: Column(
                children: [
                  NavRow(
                    icon: LucideIcons.palette,
                    title: context.l10n.appearance,
                    subtitle: context.l10n.appearance_sub,
                    onTap: () =>
                        AppNavigator.push(const _ClassicAppearancePage()),
                  ),
                  settingsDivider(context),
                  NavRow(
                    icon: LucideIcons.slidersHorizontal,
                    title: context.l10n.preferences,
                    subtitle: context.l10n.preferences_sub,
                    onTap: () =>
                        AppNavigator.push(const _ClassicPreferencesPage()),
                  ),
                  settingsDivider(context),
                  NavRow(
                    icon: LucideIcons.database,
                    title: context.l10n.data,
                    subtitle: context.l10n.data_sub,
                    onTap: () => AppNavigator.push(const _ClassicDataPage()),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Entrance(
            index: 3,
            child: Card(
              child: NavRow(
                icon: LucideIcons.info,
                title: context.l10n.about_app,
                subtitle: context.l10n.about_app_sub,
                onTap: () => AppNavigator.push(const AboutPage()),
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

class _ClassicSection extends StatelessWidget {
  const _ClassicSection({
    required this.title,
    required this.label,
    required this.children,
  });

  final String title;
  final String label;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(
        padding: context.pagePadding(16, 8, 16, 24),
        children: [
          Entrance(child: SectionLabel(label)),
          Entrance(index: 1, child: Card(child: Column(children: children))),
        ],
      ),
    );
  }
}

class _ClassicAppearancePage extends StatelessWidget {
  const _ClassicAppearancePage();

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsController>();

    return _ClassicSection(
      title: context.l10n.appearance,
      label: context.l10n.appearance_sub,
      children: [
        SettingRow(
          icon: LucideIcons.sunMoon,
          title: context.l10n.theme,
          subtitle: context.l10n.theme_sub,
          trailing: Segmented(
            options: [
              context.l10n.system,
              context.l10n.light,
              context.l10n.dark,
            ],
            index: settings.themeMode.index,
            onChanged: (i) => settings.setThemeMode(ThemeMode.values[i]),
          ),
        ),
        settingsDivider(context),
        PickerRow(
          icon: LucideIcons.swatchBook,
          title: context.l10n.color_theme,
          subtitle: context.l10n.color_theme_sub,
          value: colorThemeLabel(context, settings.colorTheme),
          onTap: () => showColorThemeSheet(context),
        ),
        if (settings.colorTheme == null) settingsDivider(context),
        if (settings.colorTheme == null)
        PickerRow(
          icon: LucideIcons.palette,
          title: context.l10n.accent_color,
          subtitle: context.l10n.accent_color_sub,
          value: null,
          trailing: _AccentDot(color: settings.accentColor),
          onTap: () => showAccentSheet(context),
        ),
        settingsDivider(context),
        PickerRow(
          icon: LucideIcons.image,
          title: context.l10n.app_background,
          subtitle: context.l10n.app_background_sub,
          value: SettingsActions.backgroundLabel(
            context,
            settings.appBackground,
          ),
          onTap: () => showBackgroundSheet(context),
        ),
        settingsDivider(context),
        SettingRow(
          icon: LucideIcons.squareCheck,
          title: context.l10n.check_style,
          subtitle: context.l10n.check_style_sub,
          trailing: Segmented(
            options: [context.l10n.square, context.l10n.circle],
            index: settings.checkStyle,
            onChanged: settings.setCheckStyle,
          ),
        ),
        settingsDivider(context),
        NavRow(
          icon: LucideIcons.wallet,
          title: 'Money Tracker Appearance',
          subtitle: 'Currency symbol, transaction rows, and decimal numbers',
          onTap: () => AppNavigator.push(const _ClassicMoneyAppearancePage()),
        ),
        settingsDivider(context),
        NavRow(
          icon: LucideIcons.utensils,
          title: 'Meal Tracker Appearance',
          subtitle: 'Calorie target, macronutrient bars, and water intake',
          onTap: () => AppNavigator.push(const _ClassicMealAppearancePage()),
        ),
        settingsDivider(context),
        NavRow(
          icon: LucideIcons.gauge,
          title: context.l10n.performance,
          subtitle: context.l10n.performance_sub,
          onTap: () => AppNavigator.push(const _ClassicPerformancePage()),
        ),
        if (Platform.isAndroid) ...[
          settingsDivider(context),
          NavRow(
            icon: LucideIcons.layoutDashboard,
            title: context.l10n.widgets,
            subtitle: context.l10n.widgets_sub,
            onTap: () => AppNavigator.push(const _ClassicWidgetsPage()),
          ),
        ],
      ],
    );
  }
}

class _ClassicMoneyAppearancePage extends StatelessWidget {
  const _ClassicMoneyAppearancePage();

  static const _currencies = [
    ('\$', 'USD / Dollar (\$)'),
    ('€', 'EUR / Euro (€)'),
    ('£', 'GBP / Pound (£)'),
    ('₹', 'INR / Rupee (₹)'),
    ('¥', 'JPY/CNY / Yen (¥)'),
    ('₩', 'KRW / Won (₩)'),
    ('₱', 'PHP / Peso (₱)'),
    ('₨', 'PKR / Rupee (₨)'),
    ('৳', 'BDT / Taka (৳)'),
  ];

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsController>();

    return _ClassicSection(
      title: 'Money Tracker Appearance',
      label: 'Customize money display and formatting',
      children: [
        PickerRow(
          icon: LucideIcons.badgePercent,
          title: 'Currency symbol',
          subtitle: 'Select currency symbol used in transactions',
          value: settings.currency,
          onTap: () => showOptionSheet(
            context,
            title: 'Currency Symbol',
            options: [for (final c in _currencies) c.$2],
            index: _currencies
                .indexWhere((c) => c.$1 == settings.currency)
                .clamp(0, _currencies.length - 1),
            onSelected: (i) => settings.setCurrency(_currencies[i].$1),
          ),
        ),
        settingsDivider(context),
        SettingRow(
          icon: LucideIcons.rows3,
          title: 'Compact transaction rows',
          subtitle: 'Show smaller rows to fit more items on screen',
          trailing: Segmented(
            options: [context.l10n.off, context.l10n.on],
            index: settings.compactMoney ? 1 : 0,
            onChanged: (i) => settings.setCompactMoney(i == 1),
          ),
        ),
        settingsDivider(context),
        SettingRow(
          icon: LucideIcons.binary,
          title: 'Decimal places',
          subtitle: 'Show cents and decimals in amounts',
          trailing: Segmented(
            options: ['Whole', '.00'],
            index: settings.moneyDecimals ? 1 : 0,
            onChanged: (i) => settings.setMoneyDecimals(i == 1),
          ),
        ),
      ],
    );
  }
}

class _ClassicMealAppearancePage extends StatelessWidget {
  const _ClassicMealAppearancePage();

  static const _goals = [1500, 1800, 2000, 2200, 2500, 3000];

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsController>();

    return _ClassicSection(
      title: 'Meal Tracker Appearance',
      label: 'Configure meal metrics, macros, and calorie visuals',
      children: [
        PickerRow(
          icon: LucideIcons.flame,
          title: 'Daily calorie goal',
          subtitle: 'Target calories for the progress ring',
          value: '${settings.calorieGoal} kcal',
          onTap: () => showOptionSheet(
            context,
            title: 'Daily Calorie Goal',
            options: [for (final g in _goals) '$g kcal'],
            index: _goals.indexOf(settings.calorieGoal).clamp(0, _goals.length - 1),
            onSelected: (i) => settings.setCalorieGoal(_goals[i]),
          ),
        ),
        settingsDivider(context),
        SettingRow(
          icon: LucideIcons.pieChart,
          title: 'Macronutrient breakdown',
          subtitle: 'Show protein, carbs, and fat ratio bar',
          trailing: Segmented(
            options: [context.l10n.off, context.l10n.on],
            index: settings.showMealMacros ? 1 : 0,
            onChanged: (i) => settings.setShowMealMacros(i == 1),
          ),
        ),
        settingsDivider(context),
        SettingRow(
          icon: LucideIcons.droplets,
          title: 'Water intake tracker',
          subtitle: 'Display quick water intake logging counter',
          trailing: Segmented(
            options: [context.l10n.off, context.l10n.on],
            index: settings.showMealWater ? 1 : 0,
            onChanged: (i) => settings.setShowMealWater(i == 1),
          ),
        ),
      ],
    );
  }
}

class _ClassicPerformancePage extends StatelessWidget {
  const _ClassicPerformancePage();

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsController>();

    return _ClassicSection(
      title: context.l10n.performance,
      label: context.l10n.performance_sub,
      children: [
        SettingRow(
          icon: LucideIcons.blend,
          title: context.l10n.glass_effects,
          subtitle: context.l10n.glass_effects_sub,
          trailing: Segmented(
            options: [context.l10n.off, context.l10n.on],
            index: settings.glassEffects ? 1 : 0,
            onChanged: (i) => settings.setGlassEffects(i == 1),
          ),
        ),
        settingsDivider(context),
        SettingRow(
          icon: LucideIcons.sparkles,
          title: context.l10n.animations,
          subtitle: context.l10n.animations_sub,
          trailing: Segmented(
            options: [context.l10n.off, context.l10n.on],
            index: settings.animations ? 1 : 0,
            onChanged: (i) => settings.setAnimations(i == 1),
          ),
        ),
      ],
    );
  }
}

class _ClassicWidgetsPage extends StatelessWidget {
  const _ClassicWidgetsPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.widgets)),
      body: ListView(
        padding: context.pagePadding(16, 8, 16, 24),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 0, 4, 16),
            child: Text(
              context.l10n.widgets_hint,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: context.tokens.muted,
              ),
            ),
          ),
          const WidgetStyleList(),
        ],
      ),
    );
  }
}

class _ClassicPreferencesPage extends StatelessWidget {
  const _ClassicPreferencesPage();

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsController>();

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.preferences)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: maxContentWidth),
          child: ListView(
            padding: context.pagePadding(16, 8, 16, 24),
        children: [
          Entrance(child: SectionLabel(context.l10n.prefs_general)),
          Entrance(
            index: 1,
            child: Card(
              child: Column(
                children: [
                  SettingRow(
                    icon: LucideIcons.calendarDays,
                    title: context.l10n.week_starts_on,
                    subtitle: context.l10n.week_start_sub,
                    trailing: Segmented(
                      options: [
                        context.l10n.mon,
                        context.l10n.sat,
                        context.l10n.sun,
                      ],
                      index: switch (settings.weekStart) {
                        6 => 1,
                        7 => 2,
                        _ => 0,
                      },
                      onChanged: (i) => SettingsActions.setWeekStart(
                context,
                        switch (i) {
                          1 => 6,
                          2 => 7,
                          _ => 1,
                        },
                      ),
                    ),
                  ),
                  settingsDivider(context),
                  NavRow(
                    icon: LucideIcons.moon,
                    title: context.l10n.day_start,
                    subtitle: context.l10n.day_start_sub,
                    value: SettingsActions.dayStartLabels(
                      context,
                    )[settings.dayCutoff],
                    onTap: () => showOptionSheet(
                      context,
                      title: context.l10n.day_start,
                      options: SettingsActions.dayStartLabels(context),
                      index: settings.dayCutoff,
                      onSelected: settings.setDayCutoff,
                    ),
                  ),
                  settingsDivider(context),
                  NavRow(
                    icon: LucideIcons.sparkles,
                    title: context.l10n.celebration,
                    subtitle: context.l10n.celebration_sub,
                    value: SettingsActions.celebrationLabels(
                      context,
                    )[settings.celebration.index],
                    onTap: () => showOptionSheet(
                      context,
                      title: context.l10n.celebration,
                      options: SettingsActions.celebrationLabels(context),
                      index: settings.celebration.index,
                      onSelected: settings.setCelebration,
                    ),
                  ),
                  settingsDivider(context),
                  NavRow(
                    icon: LucideIcons.quote,
                    title: context.l10n.quotes,
                    subtitle: context.l10n.quotes_sub,
                    onTap: () => AppNavigator.push(const QuotesPage()),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Entrance(index: 2, child: SectionLabel(context.l10n.today)),
          Entrance(
            index: 3,
            child: Card(
              child: Column(
                children: [
                  NavRow(
                    icon: LucideIcons.house,
                    title: context.l10n.start_view,
                    subtitle: context.l10n.start_view_sub,
                    value: SettingsActions.startViewLabels(
                      context,
                    )[settings.startView],
                    onTap: () => showOptionSheet(
                      context,
                      title: context.l10n.start_view,
                      options: SettingsActions.startViewLabels(context),
                      index: settings.startView,
                      onSelected: settings.setStartView,
                    ),
                  ),
                  settingsDivider(context),
                  SettingRow(
                    icon: LucideIcons.arrowDownWideNarrow,
                    title: context.l10n.sort_completed_last,
                    subtitle: context.l10n.sort_completed_last_sub,
                    trailing: Segmented(
                      options: [context.l10n.off, context.l10n.on],
                      index: settings.sortCompletedLast ? 1 : 0,
                      onChanged: (i) => settings.setSortCompletedLast(i == 1),
                    ),
                  ),
                  settingsDivider(context),
                  SettingRow(
                    icon: LucideIcons.calendarCheck,
                    title: context.l10n.today_only,
                    subtitle: context.l10n.today_only_sub,
                    trailing: Segmented(
                      options: [context.l10n.off, context.l10n.on],
                      index: settings.todayOnly ? 1 : 0,
                      onChanged: (i) => settings.setTodayOnly(i == 1),
                    ),
                  ),
                  settingsDivider(context),
                  SettingRow(
                    icon: LucideIcons.listChecks,
                    title: context.l10n.hide_done,
                    subtitle: context.l10n.hide_done_sub,
                    trailing: Segmented(
                      options: [context.l10n.off, context.l10n.on],
                      index: settings.hideDone ? 1 : 0,
                      onChanged: (i) => settings.setHideDone(i == 1),
                    ),
                  ),
                  settingsDivider(context),
                  SettingRow(
                    icon: LucideIcons.history,
                    title: context.l10n.past_first,
                    subtitle: context.l10n.past_first_sub,
                    trailing: Segmented(
                      options: [context.l10n.off, context.l10n.on],
                      index: settings.pastFirst ? 1 : 0,
                      onChanged: (i) => settings.setPastFirst(i == 1),
                    ),
                  ),
                  settingsDivider(context),
                  SettingRow(
                    icon: LucideIcons.chartPie,
                    title: context.l10n.today_progress_option,
                    subtitle: context.l10n.today_progress_option_sub,
                    trailing: Segmented(
                      options: [context.l10n.off, context.l10n.on],
                      index: settings.showTodayProgress ? 1 : 0,
                      onChanged: (i) => settings.setShowTodayProgress(i == 1),
                    ),
                  ),
                  settingsDivider(context),
                  SettingRow(
                    icon: LucideIcons.moveHorizontal,
                    title: context.l10n.swipe_cards,
                    subtitle: context.l10n.swipe_cards_sub,
                    trailing: Segmented(
                      options: [context.l10n.off, context.l10n.on],
                      index: settings.swipeCards ? 1 : 0,
                      onChanged: (i) => settings.setSwipeCards(i == 1),
                    ),
                  ),
                  settingsDivider(context),
                  SettingRow(
                    icon: LucideIcons.palmtree,
                    title: context.l10n.vacation_all,
                    subtitle: context.l10n.vacation_all_sub,
                    trailing: Segmented(
                      options: [context.l10n.off, context.l10n.on],
                      index: settings.vacationAll ? 1 : 0,
                      onChanged: (i) => SettingsActions.setVacationAll(context, i == 1),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Entrance(index: 6, child: SectionLabel(context.l10n.prefs_habits)),
          Entrance(
            index: 7,
            child: Card(
              child: Column(
                children: [
                  SettingRow(
                    icon: LucideIcons.activity,
                    title: context.l10n.just_tracking_option,
                    subtitle: context.l10n.just_tracking_option_sub,
                    trailing: Segmented(
                      options: [context.l10n.off, context.l10n.on],
                      index: settings.trackingOption ? 1 : 0,
                      onChanged: (i) => settings.setTrackingOption(i == 1),
                    ),
                  ),
                  settingsDivider(context),
                  SettingRow(
                    icon: LucideIcons.mountain,
                    title: context.l10n.difficulty_option,
                    subtitle: context.l10n.difficulty_option_sub,
                    trailing: Segmented(
                      options: [context.l10n.off, context.l10n.on],
                      index: settings.difficultyOption ? 1 : 0,
                      onChanged: (i) => settings.setDifficultyOption(i == 1),
                    ),
                  ),
                  settingsDivider(context),
                  SettingRow(
                    icon: LucideIcons.bellOff,
                    title: context.l10n.quiet_when_done,
                    subtitle: context.l10n.quiet_when_done_sub,
                    trailing: Segmented(
                      options: [context.l10n.off, context.l10n.on],
                      index: settings.quietWhenDone ? 1 : 0,
                      onChanged: (i) =>
                          SettingsActions.toggleQuietWhenDone(context, i == 1),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Entrance(index: 8, child: SectionLabel(context.l10n.prefs_features)),
          Entrance(
            index: 9,
            child: Card(
              child: Column(
                children: [
                  SettingRow(
                    icon: LucideIcons.wallet,
                    title: context.l10n.money,
                    subtitle: context.l10n.money_enable_sub,
                    trailing: Segmented(
                      options: [context.l10n.off, context.l10n.on],
                      index: settings.moneyEnabled ? 1 : 0,
                      onChanged: (i) => settings.setMoneyEnabled(i == 1),
                    ),
                  ),
                  settingsDivider(context),
                  SettingRow(
                    icon: LucideIcons.utensils,
                    title: 'Meal Tracker',
                    subtitle: 'Track meals, calories, and daily nutrition',
                    trailing: Segmented(
                      options: [context.l10n.off, context.l10n.on],
                      index: settings.mealsEnabled ? 1 : 0,
                      onChanged: (i) => settings.setMealsEnabled(i == 1),
                    ),
                  ),
                  settingsDivider(context),
                  SettingRow(
                    icon: LucideIcons.listChecks,
                    title: context.l10n.todos,
                    subtitle: context.l10n.todos_enable_sub,
                    trailing: Segmented(
                      options: [context.l10n.off, context.l10n.on],
                      index: settings.todosEnabled ? 1 : 0,
                      onChanged: (i) => settings.setTodosEnabled(i == 1),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Entrance(index: 10, child: SectionLabel(context.l10n.prefs_privacy)),
          Entrance(
            index: 11,
            child: Card(
              child: Column(
                children: [
                  SettingRow(
                    icon: LucideIcons.fingerprint,
                    title: context.l10n.app_lock,
                    subtitle: context.l10n.app_lock_sub,
                    trailing: Segmented(
                      options: [context.l10n.off, context.l10n.on],
                      index: settings.appLock ? 1 : 0,
                      onChanged: (i) =>
                          SettingsActions.toggleAppLock(context, i == 1),
                    ),
                  ),
                  if (settings.appLock) ...[
                    settingsDivider(context),
                    NavRow(
                      icon: LucideIcons.timer,
                      title: context.l10n.app_lock_delay,
                      subtitle: context.l10n.app_lock_delay_sub,
                      value: SettingsActions.appLockDelayLabels(context)[
                          SettingsActions.appLockDelayIndex(
                              settings.appLockDelay)],
                      onTap: () => showOptionSheet(
                        context,
                        title: context.l10n.app_lock_delay,
                        options: SettingsActions.appLockDelayLabels(context),
                        index: SettingsActions.appLockDelayIndex(
                          settings.appLockDelay,
                        ),
                        onSelected: (i) => settings.setAppLockDelay(
                          SettingsActions.appLockDelays[i],
                        ),
                      ),
                    ),
                    if (hasBiometricLock) settingsDivider(context),
                    if (hasBiometricLock)
                    NavRow(
                      icon: LucideIcons.keyRound,
                      title: context.l10n.app_lock_method,
                      value: settings.appLockMode == 1
                          ? context.l10n.pin_lock
                          : context.l10n.app_lock_biometric,
                      onTap: () => SettingsActions.chooseLockMethod(context),
                    ),
                    if (settings.appLockMode == 1) ...[
                      settingsDivider(context),
                      NavRow(
                        icon: LucideIcons.pencil,
                        title: context.l10n.pin_change,
                        subtitle: context.l10n.pin_lock_sub,
                        onTap: SettingsActions.changePin,
                      ),
                    ],
                  ],
                ],
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

class _ClassicDataPage extends StatelessWidget {
  const _ClassicDataPage();

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsController>();
    return _ClassicSection(
      title: context.l10n.data,
      label: context.l10n.data_sub,
      children: [
        NavRow(
          icon: LucideIcons.vault,
          title: 'Soul State Vault',
          subtitle: settings.vaultFolder.isEmpty
              ? 'Tap to select vault folder'
              : settings.vaultFolder,
          onTap: () async {
            final picked = await FilePicker.getDirectoryPath();
            if (picked != null && context.mounted) {
              await VaultManager.setupVault(
                settings: settings,
                path: picked,
                isNew: false,
              );
              if (context.mounted) {
                await SettingsActions.reloadAll(context);
              }
              if (context.mounted) {
                AppSnackbar.success(context, 'Soul State Vault switched to $picked');
              }
            }
          },
        ),
        settingsDivider(context),
        NavRow(
          icon: LucideIcons.upload,
          title: 'Import tracker data',
          subtitle: 'Restore tracker data from a backup file',
          onTap: () => SettingsActions.importBackup(context),
        ),
        settingsDivider(context),
        NavRow(
          icon: LucideIcons.download,
          title: 'Export tracker data',
          subtitle: 'Save all tracker data to a file',
          onTap: () => SettingsActions.exportBackup(context),
        ),
        settingsDivider(context),
        SettingRow(
          icon: LucideIcons.cloud,
          title: 'AWS S3 Cloud Sync',
          subtitle: settings.isS3Enabled
              ? (settings.isS3Configured ? 'Sync enabled' : 'Needs configuration')
              : 'Disabled (local only)',
          trailing: Segmented(
            options: [context.l10n.off, context.l10n.on],
            index: settings.isS3Enabled ? 1 : 0,
            onChanged: (i) async {
              final enable = i == 1;
              if (enable && !settings.isS3Configured) {
                await settings.setS3Enabled(true);
                if (context.mounted) {
                  SettingsActions.pickS3Backup(context);
                }
              } else {
                await settings.setS3Enabled(enable);
                if (enable && context.mounted) {
                  unawaited(S3SyncService.onAppResume());
                }
              }
            },
          ),
        ),
        settingsDivider(context),
        NavRow(
          icon: LucideIcons.slidersHorizontal,
          title: 'S3 Configuration & Backups',
          subtitle: SettingsActions.s3BackupSubtitle(context),
          onTap: () => SettingsActions.pickS3Backup(context),
        ),
        if (SettingsActions.canRefresh(context)) ...[
          settingsDivider(context),
          NavRow(
            icon: LucideIcons.refreshCw,
            title: context.l10n.refresh_now,
            subtitle: context.l10n.refresh_now_sub,
            onTap: () => SettingsActions.refreshFolder(context),
          ),
        ],
        if (DataFolderActions.available) ...[
          settingsDivider(context),
          NavRow(
            icon: LucideIcons.folderInput,
            title: context.l10n.data_folder,
            subtitle: dataPath,
            onTap: () => DataFolderActions.pick(context),
          ),
        ],
        settingsDivider(context),
        NavRow(
          icon: LucideIcons.eraser,
          title: context.l10n.clear_progress,
          subtitle: context.l10n.clear_progress_sub,
          onTap: () => SettingsActions.clearProgress(context),
        ),
        settingsDivider(context),
        NavRow(
          icon: LucideIcons.triangleAlert,
          tint: context.tokens.danger,
          title: context.l10n.wipe_data,
          subtitle: context.l10n.wipe_data_sub,
          onTap: () => SettingsActions.wipeEverything(context),
        ),
      ],
    );
  }
}

class _AccentDot extends StatelessWidget {
  const _AccentDot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: context.colors.surface, width: 2),
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.45), blurRadius: 8),
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.name, required this.photoPath});

  final String name;
  final String photoPath;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    final filePath = photoPath.split('?').first;
    final hasPhoto = filePath.isNotEmpty && File(filePath).existsSync();

    return Column(
      children: [
        Semantics(
          button: true,
          label: context.l10n.change_photo,
          child: GestureDetector(
            onTap: () => SettingsActions.pickProfilePhoto(context),
            child: Stack(
              children: [
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: scheme.surfaceContainerHighest,
                    image: DecorationImage(
                      image: hasPhoto
                          ? FileImage(File(filePath)) as ImageProvider
                          : const AssetImage('assets/profile_default.jpg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: scheme.primary,
                      border: Border.all(color: scheme.surface, width: 2),
                    ),
                    child: Icon(
                      LucideIcons.pencil,
                      size: 12,
                      color: scheme.onPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Semantics(
          button: true,
          label: context.l10n.edit_name,
          child: GestureDetector(
            onTap: () => SettingsActions.editName(context),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(width: 6),
                Icon(LucideIcons.pencil, size: 15, color: context.tokens.muted),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
