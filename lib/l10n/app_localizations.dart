import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// No description provided for @app_tagline.
  ///
  /// In en, this message translates to:
  /// **'Habit tracker'**
  String get app_tagline;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @stats.
  ///
  /// In en, this message translates to:
  /// **'Stats'**
  String get stats;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @new_label.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get new_label;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @discard_changes.
  ///
  /// In en, this message translates to:
  /// **'Discard changes?'**
  String get discard_changes;

  /// No description provided for @discard_changes_body.
  ///
  /// In en, this message translates to:
  /// **'The changes you made to this habit will be lost.'**
  String get discard_changes_body;

  /// No description provided for @discard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discard;

  /// No description provided for @todo_discard_body.
  ///
  /// In en, this message translates to:
  /// **'The changes you made to this to-do will be lost.'**
  String get todo_discard_body;

  /// No description provided for @keep_editing.
  ///
  /// In en, this message translates to:
  /// **'Keep editing'**
  String get keep_editing;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @good_morning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get good_morning;

  /// No description provided for @good_afternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get good_afternoon;

  /// No description provided for @good_evening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get good_evening;

  /// No description provided for @no_habits_yet.
  ///
  /// In en, this message translates to:
  /// **'No habits yet'**
  String get no_habits_yet;

  /// No description provided for @all_done_today.
  ///
  /// In en, this message translates to:
  /// **'All done today!'**
  String get all_done_today;

  /// No description provided for @x_of_y_completed.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} completed'**
  String x_of_y_completed(String done, String total);

  /// No description provided for @empty_title.
  ///
  /// In en, this message translates to:
  /// **'Start your first streak'**
  String get empty_title;

  /// No description provided for @empty_body.
  ///
  /// In en, this message translates to:
  /// **'Create a habit and tap a day to log it. Small steps, every day.'**
  String get empty_body;

  /// No description provided for @add_habit.
  ///
  /// In en, this message translates to:
  /// **'Add habit'**
  String get add_habit;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @onb1_title.
  ///
  /// In en, this message translates to:
  /// **'Build real streaks'**
  String get onb1_title;

  /// No description provided for @onb1_body.
  ///
  /// In en, this message translates to:
  /// **'Log a habit in a single tap and watch your momentum grow day after day.'**
  String get onb1_body;

  /// No description provided for @onb2_title.
  ///
  /// In en, this message translates to:
  /// **'Stay on track'**
  String get onb2_title;

  /// No description provided for @onb2_body.
  ///
  /// In en, this message translates to:
  /// **'Daily, weekly or monthly goals with smart reminders so nothing slips.'**
  String get onb2_body;

  /// No description provided for @onb3_title.
  ///
  /// In en, this message translates to:
  /// **'See your progress'**
  String get onb3_title;

  /// No description provided for @onb3_body.
  ///
  /// In en, this message translates to:
  /// **'Rich statistics and a yearly grid reveal exactly how far you have come.'**
  String get onb3_body;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @get_started.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get get_started;

  /// No description provided for @onb_kicker.
  ///
  /// In en, this message translates to:
  /// **'Welcome to'**
  String get onb_kicker;

  /// No description provided for @onb_blurb.
  ///
  /// In en, this message translates to:
  /// **'Small daily check-ins that turn into habits you keep.'**
  String get onb_blurb;

  /// No description provided for @onb_free_title.
  ///
  /// In en, this message translates to:
  /// **'Free, forever'**
  String get onb_free_title;

  /// No description provided for @onb_free_body.
  ///
  /// In en, this message translates to:
  /// **'No ads, no subscriptions, no locked features.'**
  String get onb_free_body;

  /// No description provided for @onb_private_title.
  ///
  /// In en, this message translates to:
  /// **'Private and offline'**
  String get onb_private_title;

  /// No description provided for @onb_private_body.
  ///
  /// In en, this message translates to:
  /// **'Everything stays on your device. No account needed.'**
  String get onb_private_body;

  /// No description provided for @onb_yours_title.
  ///
  /// In en, this message translates to:
  /// **'Your data is yours'**
  String get onb_yours_title;

  /// No description provided for @onb_yours_body.
  ///
  /// In en, this message translates to:
  /// **'Back it up or take it with you whenever you want.'**
  String get onb_yours_body;

  /// No description provided for @onb_step.
  ///
  /// In en, this message translates to:
  /// **'Step {step} of {total}'**
  String onb_step(int step, int total);

  /// No description provided for @statistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// No description provided for @done_today.
  ///
  /// In en, this message translates to:
  /// **'Done today'**
  String get done_today;

  /// No description provided for @best_streak.
  ///
  /// In en, this message translates to:
  /// **'Best streak'**
  String get best_streak;

  /// No description provided for @active_habits.
  ///
  /// In en, this message translates to:
  /// **'Active habits'**
  String get active_habits;

  /// No description provided for @total_logs.
  ///
  /// In en, this message translates to:
  /// **'Total logs'**
  String get total_logs;

  /// No description provided for @last_7_days.
  ///
  /// In en, this message translates to:
  /// **'Last 7 days'**
  String get last_7_days;

  /// No description provided for @last_30_days.
  ///
  /// In en, this message translates to:
  /// **'Last 30 days'**
  String get last_30_days;

  /// No description provided for @your_habits.
  ///
  /// In en, this message translates to:
  /// **'Your habits'**
  String get your_habits;

  /// No description provided for @stats_empty.
  ///
  /// In en, this message translates to:
  /// **'Add habits to see your statistics'**
  String get stats_empty;

  /// No description provided for @completion_rate_short.
  ///
  /// In en, this message translates to:
  /// **'Consistency'**
  String get completion_rate_short;

  /// No description provided for @completion_rate.
  ///
  /// In en, this message translates to:
  /// **'Completion rate'**
  String get completion_rate;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @system.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get system;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @week_starts_on.
  ///
  /// In en, this message translates to:
  /// **'Week starts'**
  String get week_starts_on;

  /// No description provided for @mon.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get mon;

  /// No description provided for @sat.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get sat;

  /// No description provided for @sun.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get sun;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @data.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get data;

  /// No description provided for @export_backup.
  ///
  /// In en, this message translates to:
  /// **'Export backup'**
  String get export_backup;

  /// No description provided for @export_backup_sub.
  ///
  /// In en, this message translates to:
  /// **'Save all habits to a file'**
  String get export_backup_sub;

  /// No description provided for @auto_backup.
  ///
  /// In en, this message translates to:
  /// **'Automatic backup'**
  String get auto_backup;

  /// No description provided for @auto_backup_sub.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get auto_backup_sub;

  /// No description provided for @auto_backup_off.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get auto_backup_off;

  /// No description provided for @auto_backup_daily.
  ///
  /// In en, this message translates to:
  /// **'Every day'**
  String get auto_backup_daily;

  /// No description provided for @auto_backup_weekly.
  ///
  /// In en, this message translates to:
  /// **'Every week'**
  String get auto_backup_weekly;

  /// No description provided for @auto_backup_where.
  ///
  /// In en, this message translates to:
  /// **'When you open the app, Soul State saves a full backup: a .zip with everything, photos and music included, and a .json. It also writes a readable copy you can open in any editor. The last few backups are kept.'**
  String get auto_backup_where;

  /// No description provided for @auto_backup_folder.
  ///
  /// In en, this message translates to:
  /// **'Folder'**
  String get auto_backup_folder;

  /// No description provided for @auto_backup_folder_default.
  ///
  /// In en, this message translates to:
  /// **'Inside the app (erased if you uninstall it)'**
  String get auto_backup_folder_default;

  /// No description provided for @auto_backup_folder_set.
  ///
  /// In en, this message translates to:
  /// **'Folder saved'**
  String get auto_backup_folder_set;

  /// No description provided for @auto_backup_folder_failed.
  ///
  /// In en, this message translates to:
  /// **'That folder can\'t be written to'**
  String get auto_backup_folder_failed;

  /// No description provided for @auto_backup_no_permission.
  ///
  /// In en, this message translates to:
  /// **'Storage permission denied'**
  String get auto_backup_no_permission;

  /// No description provided for @auto_backup_run_now.
  ///
  /// In en, this message translates to:
  /// **'Back up now'**
  String get auto_backup_run_now;

  /// No description provided for @refresh_now.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh_now;

  /// No description provided for @refresh_now_sub.
  ///
  /// In en, this message translates to:
  /// **'Bring in what your other devices left in the folder'**
  String get refresh_now_sub;

  /// No description provided for @data_folder.
  ///
  /// In en, this message translates to:
  /// **'Data folder'**
  String get data_folder;

  /// No description provided for @data_folder_documents.
  ///
  /// In en, this message translates to:
  /// **'Documents'**
  String get data_folder_documents;

  /// No description provided for @data_folder_app.
  ///
  /// In en, this message translates to:
  /// **'Next to the app'**
  String get data_folder_app;

  /// No description provided for @data_folder_pick.
  ///
  /// In en, this message translates to:
  /// **'Choose a folder'**
  String get data_folder_pick;

  /// No description provided for @data_folder_inside.
  ///
  /// In en, this message translates to:
  /// **'Pick a folder outside the current one.'**
  String get data_folder_inside;

  /// No description provided for @data_folder_taken.
  ///
  /// In en, this message translates to:
  /// **'That folder already has Soul State data in it.'**
  String get data_folder_taken;

  /// No description provided for @data_folder_denied.
  ///
  /// In en, this message translates to:
  /// **'Soul State can\'t write to that folder.'**
  String get data_folder_denied;

  /// No description provided for @data_folder_move_title.
  ///
  /// In en, this message translates to:
  /// **'Move your data'**
  String get data_folder_move_title;

  /// No description provided for @data_folder_move_body.
  ///
  /// In en, this message translates to:
  /// **'Soul State will close and move your data to {path}. Open it again when it closes. If anything goes wrong, your data stays where it is.'**
  String data_folder_move_body(String path);

  /// No description provided for @data_folder_move_confirm.
  ///
  /// In en, this message translates to:
  /// **'Move and close'**
  String get data_folder_move_confirm;

  /// No description provided for @refresh_brought.
  ///
  /// In en, this message translates to:
  /// **'Your habits are up to date'**
  String get refresh_brought;

  /// No description provided for @refresh_nothing.
  ///
  /// In en, this message translates to:
  /// **'Nothing new in the folder'**
  String get refresh_nothing;

  /// No description provided for @import_backup.
  ///
  /// In en, this message translates to:
  /// **'Import backup'**
  String get import_backup;

  /// No description provided for @import_backup_sub.
  ///
  /// In en, this message translates to:
  /// **'Restore habits from a file'**
  String get import_backup_sub;

  /// No description provided for @import_from_app.
  ///
  /// In en, this message translates to:
  /// **'Import from another app'**
  String get import_from_app;

  /// No description provided for @import_from_app_sub.
  ///
  /// In en, this message translates to:
  /// **'Loop Habit Tracker, HabitKit…'**
  String get import_from_app_sub;

  /// No description provided for @import_from_app_done.
  ///
  /// In en, this message translates to:
  /// **'Imported {habits} habits ({days} days) from {source}'**
  String import_from_app_done(int habits, int days, String source);

  /// No description provided for @import_failed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t import that file'**
  String get import_failed;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @backup_saved.
  ///
  /// In en, this message translates to:
  /// **'Backup saved'**
  String get backup_saved;

  /// No description provided for @export_cancelled.
  ///
  /// In en, this message translates to:
  /// **'Export cancelled'**
  String get export_cancelled;

  /// No description provided for @habits_imported.
  ///
  /// In en, this message translates to:
  /// **'Habits imported'**
  String get habits_imported;

  /// No description provided for @new_habit.
  ///
  /// In en, this message translates to:
  /// **'New habit'**
  String get new_habit;

  /// No description provided for @edit_habit.
  ///
  /// In en, this message translates to:
  /// **'Edit habit'**
  String get edit_habit;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @name_hint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Morning run'**
  String get name_hint;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @description_hint.
  ///
  /// In en, this message translates to:
  /// **'Optional note'**
  String get description_hint;

  /// No description provided for @icon.
  ///
  /// In en, this message translates to:
  /// **'Icon'**
  String get icon;

  /// No description provided for @color.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get color;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @category_health.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get category_health;

  /// No description provided for @category_fitness.
  ///
  /// In en, this message translates to:
  /// **'Fitness'**
  String get category_fitness;

  /// No description provided for @category_mindfulness.
  ///
  /// In en, this message translates to:
  /// **'Mindfulness'**
  String get category_mindfulness;

  /// No description provided for @category_productivity.
  ///
  /// In en, this message translates to:
  /// **'Productivity'**
  String get category_productivity;

  /// No description provided for @category_learning.
  ///
  /// In en, this message translates to:
  /// **'Learning'**
  String get category_learning;

  /// No description provided for @category_finance.
  ///
  /// In en, this message translates to:
  /// **'Finance'**
  String get category_finance;

  /// No description provided for @count_days.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day} other{{count} days}}'**
  String count_days(int count);

  /// No description provided for @count_weeks.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 week} other{{count} weeks}}'**
  String count_weeks(int count);

  /// No description provided for @count_months.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 month} other{{count} months}}'**
  String count_months(int count);

  /// No description provided for @streak_unit_week.
  ///
  /// In en, this message translates to:
  /// **'{count}w'**
  String streak_unit_week(String count);

  /// No description provided for @streak_unit_month.
  ///
  /// In en, this message translates to:
  /// **'{count}mo'**
  String streak_unit_month(String count);

  /// No description provided for @habit_kind.
  ///
  /// In en, this message translates to:
  /// **'Habit type'**
  String get habit_kind;

  /// No description provided for @kind_positive.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get kind_positive;

  /// No description provided for @kind_negative.
  ///
  /// In en, this message translates to:
  /// **'Avoid'**
  String get kind_negative;

  /// No description provided for @kind_quantitative.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get kind_quantitative;

  /// No description provided for @kind_locked_hint.
  ///
  /// In en, this message translates to:
  /// **'Type can\'t be changed after creating the habit.'**
  String get kind_locked_hint;

  /// No description provided for @kind_negative_hint.
  ///
  /// In en, this message translates to:
  /// **'Every day counts as clean by default — your streak grows on its own. Tap the check only if you slip; that day turns red and you can undo it.'**
  String get kind_negative_hint;

  /// No description provided for @cost_per_day.
  ///
  /// In en, this message translates to:
  /// **'Cost per day'**
  String get cost_per_day;

  /// No description provided for @cost_note.
  ///
  /// In en, this message translates to:
  /// **'Optional. Leave it empty if this habit does not cost money.'**
  String get cost_note;

  /// No description provided for @currency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currency;

  /// No description provided for @currency_custom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get currency_custom;

  /// No description provided for @currency_hint.
  ///
  /// In en, this message translates to:
  /// **'Symbol or code'**
  String get currency_hint;

  /// No description provided for @money_saved.
  ///
  /// In en, this message translates to:
  /// **'Money saved'**
  String get money_saved;

  /// No description provided for @clean_days.
  ///
  /// In en, this message translates to:
  /// **'Clean days'**
  String get clean_days;

  /// No description provided for @quant_preset_water.
  ///
  /// In en, this message translates to:
  /// **'Water'**
  String get quant_preset_water;

  /// No description provided for @quant_preset_reading.
  ///
  /// In en, this message translates to:
  /// **'Reading'**
  String get quant_preset_reading;

  /// No description provided for @quant_preset_generic.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get quant_preset_generic;

  /// No description provided for @quant_unit_hint.
  ///
  /// In en, this message translates to:
  /// **'Unit (e.g. ml, pages, reps)'**
  String get quant_unit_hint;

  /// No description provided for @quant_unit_ml.
  ///
  /// In en, this message translates to:
  /// **'ml'**
  String get quant_unit_ml;

  /// No description provided for @quant_unit_pages.
  ///
  /// In en, this message translates to:
  /// **'pages'**
  String get quant_unit_pages;

  /// No description provided for @quant_edit_title.
  ///
  /// In en, this message translates to:
  /// **'Today\'s amount'**
  String get quant_edit_title;

  /// No description provided for @quant_daily_goal.
  ///
  /// In en, this message translates to:
  /// **'Daily goal'**
  String get quant_daily_goal;

  /// No description provided for @quant_tap_amount.
  ///
  /// In en, this message translates to:
  /// **'Amount per tap'**
  String get quant_tap_amount;

  /// No description provided for @quant_per_day.
  ///
  /// In en, this message translates to:
  /// **'Amount per day'**
  String get quant_per_day;

  /// No description provided for @quant_average.
  ///
  /// In en, this message translates to:
  /// **'Average per day'**
  String get quant_average;

  /// No description provided for @quant_logged_days.
  ///
  /// In en, this message translates to:
  /// **'Days logged'**
  String get quant_logged_days;

  /// No description provided for @quant_best_day.
  ///
  /// In en, this message translates to:
  /// **'Best day'**
  String get quant_best_day;

  /// No description provided for @quant_goal_days.
  ///
  /// In en, this message translates to:
  /// **'Goal reached'**
  String get quant_goal_days;

  /// No description provided for @quant_stats_empty.
  ///
  /// In en, this message translates to:
  /// **'Log an amount and it adds up here, even on the days you fall short of the goal.'**
  String get quant_stats_empty;

  /// No description provided for @frequency.
  ///
  /// In en, this message translates to:
  /// **'Frequency'**
  String get frequency;

  /// No description provided for @pick_one_day.
  ///
  /// In en, this message translates to:
  /// **'Pick at least one day'**
  String get pick_one_day;

  /// No description provided for @reminder_habit_days.
  ///
  /// In en, this message translates to:
  /// **'On the habit\'s days'**
  String get reminder_habit_days;

  /// No description provided for @reminder_habit_days_hint.
  ///
  /// In en, this message translates to:
  /// **'It rings on the days the habit is due.'**
  String get reminder_habit_days_hint;

  /// No description provided for @by_label.
  ///
  /// In en, this message translates to:
  /// **'By label'**
  String get by_label;

  /// No description provided for @tracking_hide.
  ///
  /// In en, this message translates to:
  /// **'Hide just tracking'**
  String get tracking_hide;

  /// No description provided for @tracking_hide_sub.
  ///
  /// In en, this message translates to:
  /// **'Habits you only track stay out of this list'**
  String get tracking_hide_sub;

  /// No description provided for @tracking_show.
  ///
  /// In en, this message translates to:
  /// **'Show just tracking ({count})'**
  String tracking_show(int count);

  /// No description provided for @daily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get daily;

  /// No description provided for @weekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get weekly;

  /// No description provided for @monthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthly;

  /// No description provided for @sched_days.
  ///
  /// In en, this message translates to:
  /// **'Days'**
  String get sched_days;

  /// No description provided for @sched_interval.
  ///
  /// In en, this message translates to:
  /// **'Interval'**
  String get sched_interval;

  /// No description provided for @times_per_week.
  ///
  /// In en, this message translates to:
  /// **'{n} times per week'**
  String times_per_week(String n);

  /// No description provided for @times_per_month.
  ///
  /// In en, this message translates to:
  /// **'{n} times per month'**
  String times_per_month(String n);

  /// No description provided for @freq_per_week_short.
  ///
  /// In en, this message translates to:
  /// **'{n}×/week'**
  String freq_per_week_short(String n);

  /// No description provided for @freq_per_month_short.
  ///
  /// In en, this message translates to:
  /// **'{n}×/month'**
  String freq_per_month_short(String n);

  /// No description provided for @reminders.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get reminders;

  /// No description provided for @reminders_ready_title.
  ///
  /// In en, this message translates to:
  /// **'Reminders are on'**
  String get reminders_ready_title;

  /// No description provided for @reminders_ready_body.
  ///
  /// In en, this message translates to:
  /// **'Soul State will remind you here.'**
  String get reminders_ready_body;

  /// No description provided for @add_reminder.
  ///
  /// In en, this message translates to:
  /// **'Add reminder'**
  String get add_reminder;

  /// No description provided for @reminder_sound.
  ///
  /// In en, this message translates to:
  /// **'Sound'**
  String get reminder_sound;

  /// No description provided for @reminder_sound_default.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get reminder_sound_default;

  /// No description provided for @reminder_sound_hint.
  ///
  /// In en, this message translates to:
  /// **'Tap a sound to hear it. The reminders of this habit will use it.'**
  String get reminder_sound_hint;

  /// No description provided for @delete_habit.
  ///
  /// In en, this message translates to:
  /// **'Delete habit'**
  String get delete_habit;

  /// No description provided for @archive_habit.
  ///
  /// In en, this message translates to:
  /// **'Archive habit'**
  String get archive_habit;

  /// No description provided for @archive.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get archive;

  /// No description provided for @share_friends.
  ///
  /// In en, this message translates to:
  /// **'Share with a friend'**
  String get share_friends;

  /// No description provided for @share_friends_sub.
  ///
  /// In en, this message translates to:
  /// **'Send them the app'**
  String get share_friends_sub;

  /// No description provided for @share_friends_message.
  ///
  /// In en, this message translates to:
  /// **'I\'m keeping my streaks alive with Soul State — a private, offline life tracker with habits, finances, and meals. Explore here: https://shanmugananthan.com'**
  String get share_friends_message;

  /// No description provided for @copy_message.
  ///
  /// In en, this message translates to:
  /// **'Copy message'**
  String get copy_message;

  /// No description provided for @message_copied.
  ///
  /// In en, this message translates to:
  /// **'Message copied'**
  String get message_copied;

  /// No description provided for @app_lock.
  ///
  /// In en, this message translates to:
  /// **'App lock'**
  String get app_lock;

  /// No description provided for @app_lock_sub.
  ///
  /// In en, this message translates to:
  /// **'Ask for your fingerprint or face to open Soul State'**
  String get app_lock_sub;

  /// No description provided for @app_lock_unavailable.
  ///
  /// In en, this message translates to:
  /// **'This phone has no biometrics set up'**
  String get app_lock_unavailable;

  /// No description provided for @app_lock_failed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t verify it was you'**
  String get app_lock_failed;

  /// No description provided for @app_lock_title.
  ///
  /// In en, this message translates to:
  /// **'Soul State is locked'**
  String get app_lock_title;

  /// No description provided for @app_lock_unlock.
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get app_lock_unlock;

  /// No description provided for @app_lock_delay.
  ///
  /// In en, this message translates to:
  /// **'Lock after'**
  String get app_lock_delay;

  /// No description provided for @app_lock_delay_instant.
  ///
  /// In en, this message translates to:
  /// **'Immediately'**
  String get app_lock_delay_instant;

  /// No description provided for @app_lock_delay_seconds.
  ///
  /// In en, this message translates to:
  /// **'{value} seconds'**
  String app_lock_delay_seconds(String value);

  /// No description provided for @note_photos.
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get note_photos;

  /// No description provided for @note_take_photo.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get note_take_photo;

  /// No description provided for @note_pick_photo.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get note_pick_photo;

  /// No description provided for @journey.
  ///
  /// In en, this message translates to:
  /// **'Journey'**
  String get journey;

  /// No description provided for @journey_sub.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 photo} other{{count} photos}}'**
  String journey_sub(int count);

  /// No description provided for @journey_empty.
  ///
  /// In en, this message translates to:
  /// **'No photos yet'**
  String get journey_empty;

  /// No description provided for @journey_empty_sub.
  ///
  /// In en, this message translates to:
  /// **'Add a photo to a note and it shows up here.'**
  String get journey_empty_sub;

  /// No description provided for @archive_habit_body.
  ///
  /// In en, this message translates to:
  /// **'Move \"{name}\" to the archive? Its history is kept and you can restore it from Settings.'**
  String archive_habit_body(String name);

  /// No description provided for @archived_habits.
  ///
  /// In en, this message translates to:
  /// **'Archived habits'**
  String get archived_habits;

  /// No description provided for @archived_habits_sub.
  ///
  /// In en, this message translates to:
  /// **'Restore them or delete them for good'**
  String get archived_habits_sub;

  /// No description provided for @archived_empty.
  ///
  /// In en, this message translates to:
  /// **'Nothing archived'**
  String get archived_empty;

  /// No description provided for @archived_empty_sub.
  ///
  /// In en, this message translates to:
  /// **'Habits you delete land here, with all their history.'**
  String get archived_empty_sub;

  /// No description provided for @restore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get restore;

  /// No description provided for @restored.
  ///
  /// In en, this message translates to:
  /// **'Habit restored'**
  String get restored;

  /// No description provided for @delete_forever.
  ///
  /// In en, this message translates to:
  /// **'Delete for good'**
  String get delete_forever;

  /// No description provided for @delete_forever_body.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{name}\" and all of its history? This cannot be undone.'**
  String delete_forever_body(String name);

  /// No description provided for @deleted_forever.
  ///
  /// In en, this message translates to:
  /// **'Habit deleted'**
  String get deleted_forever;

  /// No description provided for @clear_progress.
  ///
  /// In en, this message translates to:
  /// **'Clear progress'**
  String get clear_progress;

  /// No description provided for @clear_progress_sub.
  ///
  /// In en, this message translates to:
  /// **'History and notes'**
  String get clear_progress_sub;

  /// No description provided for @clear_progress_warning.
  ///
  /// In en, this message translates to:
  /// **'This erases every logged day and note, but keeps your habits, their schedules and your settings. It cannot be undone unless you have a backup file to import afterwards.'**
  String get clear_progress_warning;

  /// No description provided for @clear_progress_confirm.
  ///
  /// In en, this message translates to:
  /// **'Clear progress'**
  String get clear_progress_confirm;

  /// No description provided for @clear_progress_done.
  ///
  /// In en, this message translates to:
  /// **'Progress cleared'**
  String get clear_progress_done;

  /// No description provided for @wipe_data.
  ///
  /// In en, this message translates to:
  /// **'Erase all data'**
  String get wipe_data;

  /// No description provided for @wipe_data_sub.
  ///
  /// In en, this message translates to:
  /// **'Habits, tasks, meals, finances, notes and settings'**
  String get wipe_data_sub;

  /// No description provided for @wipe_data_warning.
  ///
  /// In en, this message translates to:
  /// **'This erases all habits, tasks, meals, finances, notes and settings on this phone. It cannot be undone unless you have a backup file to import afterwards.'**
  String get wipe_data_warning;

  /// No description provided for @wipe_data_sure.
  ///
  /// In en, this message translates to:
  /// **'Really erase everything?'**
  String get wipe_data_sure;

  /// No description provided for @wipe_data_sure_body.
  ///
  /// In en, this message translates to:
  /// **'Last chance. Without a backup, this data is gone for good.'**
  String get wipe_data_sure_body;

  /// No description provided for @wipe_data_confirm.
  ///
  /// In en, this message translates to:
  /// **'Erase everything'**
  String get wipe_data_confirm;

  /// No description provided for @wipe_data_done.
  ///
  /// In en, this message translates to:
  /// **'All data erased'**
  String get wipe_data_done;

  /// No description provided for @day_start.
  ///
  /// In en, this message translates to:
  /// **'Day starts'**
  String get day_start;

  /// No description provided for @day_start_sub.
  ///
  /// In en, this message translates to:
  /// **'Late nights still count for the day before'**
  String get day_start_sub;

  /// No description provided for @day_start_midnight.
  ///
  /// In en, this message translates to:
  /// **'Midnight'**
  String get day_start_midnight;

  /// No description provided for @day_start_hour.
  ///
  /// In en, this message translates to:
  /// **'{hour}:00 AM'**
  String day_start_hour(String hour);

  /// No description provided for @share_photo.
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get share_photo;

  /// No description provided for @share_stats_short.
  ///
  /// In en, this message translates to:
  /// **'Stats'**
  String get share_stats_short;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @habit_archived.
  ///
  /// In en, this message translates to:
  /// **'Habit archived'**
  String get habit_archived;

  /// No description provided for @duplicate_habit.
  ///
  /// In en, this message translates to:
  /// **'Duplicate habit'**
  String get duplicate_habit;

  /// No description provided for @habit_duplicated.
  ///
  /// In en, this message translates to:
  /// **'{name} added'**
  String habit_duplicated(String name);

  /// No description provided for @share_blur.
  ///
  /// In en, this message translates to:
  /// **'Blur'**
  String get share_blur;

  /// No description provided for @delete_habit_body.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{name}\"? This cannot be undone.'**
  String delete_habit_body(String name);

  /// No description provided for @log_relapse_title.
  ///
  /// In en, this message translates to:
  /// **'Log a relapse?'**
  String get log_relapse_title;

  /// No description provided for @log_relapse_body.
  ///
  /// In en, this message translates to:
  /// **'This breaks today\'s clean streak for \"{name}\". You can undo it by tapping again.'**
  String log_relapse_body(String name);

  /// No description provided for @log_relapse_confirm.
  ///
  /// In en, this message translates to:
  /// **'Yes, log it'**
  String get log_relapse_confirm;

  /// No description provided for @permission_required.
  ///
  /// In en, this message translates to:
  /// **'Notification permission is required'**
  String get permission_required;

  /// No description provided for @streaks.
  ///
  /// In en, this message translates to:
  /// **'Streaks'**
  String get streaks;

  /// No description provided for @activity.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get activity;

  /// No description provided for @current.
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get current;

  /// No description provided for @best.
  ///
  /// In en, this message translates to:
  /// **'Best'**
  String get best;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @relapses.
  ///
  /// In en, this message translates to:
  /// **'Relapses'**
  String get relapses;

  /// No description provided for @strength.
  ///
  /// In en, this message translates to:
  /// **'Strength'**
  String get strength;

  /// No description provided for @week.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get week;

  /// No description provided for @month.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get month;

  /// No description provided for @year.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get year;

  /// No description provided for @new_reminder.
  ///
  /// In en, this message translates to:
  /// **'New reminder'**
  String get new_reminder;

  /// No description provided for @edit_reminder.
  ///
  /// In en, this message translates to:
  /// **'Edit reminder'**
  String get edit_reminder;

  /// No description provided for @days.
  ///
  /// In en, this message translates to:
  /// **'Days'**
  String get days;

  /// No description provided for @time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// No description provided for @save_reminder.
  ///
  /// In en, this message translates to:
  /// **'Save reminder'**
  String get save_reminder;

  /// No description provided for @select_one_day.
  ///
  /// In en, this message translates to:
  /// **'Select at least one day'**
  String get select_one_day;

  /// No description provided for @every_day.
  ///
  /// In en, this message translates to:
  /// **'Every day'**
  String get every_day;

  /// No description provided for @no_days.
  ///
  /// In en, this message translates to:
  /// **'No days'**
  String get no_days;

  /// No description provided for @repeat_hours.
  ///
  /// In en, this message translates to:
  /// **'Repeat during the day'**
  String get repeat_hours;

  /// No description provided for @repeat_until.
  ///
  /// In en, this message translates to:
  /// **'Until'**
  String get repeat_until;

  /// No description provided for @end_of_day.
  ///
  /// In en, this message translates to:
  /// **'End of the day'**
  String get end_of_day;

  /// No description provided for @every_n_hours.
  ///
  /// In en, this message translates to:
  /// **'Every {n} h'**
  String every_n_hours(String n);

  /// No description provided for @repeat_weekly.
  ///
  /// In en, this message translates to:
  /// **'Specific days'**
  String get repeat_weekly;

  /// No description provided for @repeat_interval.
  ///
  /// In en, this message translates to:
  /// **'Every N days'**
  String get repeat_interval;

  /// No description provided for @every_n_days.
  ///
  /// In en, this message translates to:
  /// **'Every {n} days'**
  String every_n_days(int n);

  /// No description provided for @every_n_weeks.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =1{Every week} other{Every {n} weeks}}'**
  String every_n_weeks(int n);

  /// No description provided for @every_n_months.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =1{Every month} other{Every {n} months}}'**
  String every_n_months(int n);

  /// No description provided for @sched_unit_days.
  ///
  /// In en, this message translates to:
  /// **'Days'**
  String get sched_unit_days;

  /// No description provided for @sched_unit_weeks.
  ///
  /// In en, this message translates to:
  /// **'Weeks'**
  String get sched_unit_weeks;

  /// No description provided for @sched_unit_months.
  ///
  /// In en, this message translates to:
  /// **'Months'**
  String get sched_unit_months;

  /// No description provided for @todo_tags.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get todo_tags;

  /// No description provided for @todo_projects.
  ///
  /// In en, this message translates to:
  /// **'Projects'**
  String get todo_projects;

  /// No description provided for @todo_project.
  ///
  /// In en, this message translates to:
  /// **'Project'**
  String get todo_project;

  /// No description provided for @todo_project_new.
  ///
  /// In en, this message translates to:
  /// **'New project'**
  String get todo_project_new;

  /// No description provided for @todo_project_name.
  ///
  /// In en, this message translates to:
  /// **'Project name'**
  String get todo_project_name;

  /// No description provided for @todo_project_edit.
  ///
  /// In en, this message translates to:
  /// **'Edit project'**
  String get todo_project_edit;

  /// No description provided for @todo_project_arrange.
  ///
  /// In en, this message translates to:
  /// **'Rearrange'**
  String get todo_project_arrange;

  /// No description provided for @todo_project_arrange_hint.
  ///
  /// In en, this message translates to:
  /// **'Drag the folders where you want them.'**
  String get todo_project_arrange_hint;

  /// No description provided for @todo_project_pick.
  ///
  /// In en, this message translates to:
  /// **'Pick a project'**
  String get todo_project_pick;

  /// No description provided for @todo_project_none.
  ///
  /// In en, this message translates to:
  /// **'No project'**
  String get todo_project_none;

  /// No description provided for @todo_project_delete_body.
  ///
  /// In en, this message translates to:
  /// **'The project goes away. The tasks stay.'**
  String get todo_project_delete_body;

  /// No description provided for @todo_tag.
  ///
  /// In en, this message translates to:
  /// **'Tag'**
  String get todo_tag;

  /// No description provided for @todo_tag_new.
  ///
  /// In en, this message translates to:
  /// **'New tag'**
  String get todo_tag_new;

  /// No description provided for @todo_tag_name.
  ///
  /// In en, this message translates to:
  /// **'Tag name'**
  String get todo_tag_name;

  /// No description provided for @todo_tag_edit.
  ///
  /// In en, this message translates to:
  /// **'Edit tag'**
  String get todo_tag_edit;

  /// No description provided for @todo_tag_delete_body.
  ///
  /// In en, this message translates to:
  /// **'The tag goes away. The tasks stay.'**
  String get todo_tag_delete_body;

  /// No description provided for @todo_tag_none.
  ///
  /// In en, this message translates to:
  /// **'No tag'**
  String get todo_tag_none;

  /// No description provided for @todo_tag_all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get todo_tag_all;

  /// No description provided for @todo_tag_manage.
  ///
  /// In en, this message translates to:
  /// **'Manage tags'**
  String get todo_tag_manage;

  /// No description provided for @todo_tag_empty_title.
  ///
  /// In en, this message translates to:
  /// **'No tags yet'**
  String get todo_tag_empty_title;

  /// No description provided for @todo_tag_empty_body.
  ///
  /// In en, this message translates to:
  /// **'Group tasks by project, place or whatever you like.'**
  String get todo_tag_empty_body;

  /// No description provided for @todo_tag_folders.
  ///
  /// In en, this message translates to:
  /// **'Folders'**
  String get todo_tag_folders;

  /// No description provided for @todo_tag_list.
  ///
  /// In en, this message translates to:
  /// **'List'**
  String get todo_tag_list;

  /// No description provided for @todo_tag_count.
  ///
  /// In en, this message translates to:
  /// **'{n} open'**
  String todo_tag_count(int n);

  /// No description provided for @todo_tag_icon.
  ///
  /// In en, this message translates to:
  /// **'Icon'**
  String get todo_tag_icon;

  /// No description provided for @todo_tag_pick.
  ///
  /// In en, this message translates to:
  /// **'Pick tags'**
  String get todo_tag_pick;

  /// No description provided for @todo_tag_filtered.
  ///
  /// In en, this message translates to:
  /// **'Filtered by {name}'**
  String todo_tag_filtered(String name);

  /// No description provided for @uncategorized.
  ///
  /// In en, this message translates to:
  /// **'Uncategorized'**
  String get uncategorized;

  /// No description provided for @more_icons.
  ///
  /// In en, this message translates to:
  /// **'More icons'**
  String get more_icons;

  /// No description provided for @less_icons.
  ///
  /// In en, this message translates to:
  /// **'Fewer icons'**
  String get less_icons;

  /// No description provided for @completions.
  ///
  /// In en, this message translates to:
  /// **'Completions'**
  String get completions;

  /// No description provided for @completion_time.
  ///
  /// In en, this message translates to:
  /// **'Completion time'**
  String get completion_time;

  /// No description provided for @current_streak.
  ///
  /// In en, this message translates to:
  /// **'Current streak'**
  String get current_streak;

  /// No description provided for @days_active.
  ///
  /// In en, this message translates to:
  /// **'Days active'**
  String get days_active;

  /// No description provided for @completions_per_month.
  ///
  /// In en, this message translates to:
  /// **'Completions / Month'**
  String get completions_per_month;

  /// No description provided for @overview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get overview;

  /// No description provided for @preferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferences;

  /// No description provided for @support.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get support;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @about_app.
  ///
  /// In en, this message translates to:
  /// **'Soul State'**
  String get about_app;

  /// No description provided for @about_app_sub.
  ///
  /// In en, this message translates to:
  /// **'Version, credits and source code'**
  String get about_app_sub;

  /// No description provided for @my_heatmap.
  ///
  /// In en, this message translates to:
  /// **'My heatmap'**
  String get my_heatmap;

  /// No description provided for @my_heatmap_sub.
  ///
  /// In en, this message translates to:
  /// **'Open the yearly activity grid'**
  String get my_heatmap_sub;

  /// No description provided for @rate_github.
  ///
  /// In en, this message translates to:
  /// **'Star on GitHub'**
  String get rate_github;

  /// No description provided for @rate_github_sub.
  ///
  /// In en, this message translates to:
  /// **'Support the project with a star'**
  String get rate_github_sub;

  /// No description provided for @buy_coffee.
  ///
  /// In en, this message translates to:
  /// **'Buy me a coffee'**
  String get buy_coffee;

  /// No description provided for @buy_coffee_sub.
  ///
  /// In en, this message translates to:
  /// **'Help keep the app free'**
  String get buy_coffee_sub;

  /// No description provided for @view_source.
  ///
  /// In en, this message translates to:
  /// **'View source on GitHub'**
  String get view_source;

  /// No description provided for @about_title.
  ///
  /// In en, this message translates to:
  /// **'Built for you. Free, forever.'**
  String get about_title;

  /// No description provided for @about_footer.
  ///
  /// In en, this message translates to:
  /// **'Made with ☕ and a lot of free time.'**
  String get about_footer;

  /// No description provided for @about_body.
  ///
  /// In en, this message translates to:
  /// **'Soul State was born from a simple idea: a private, mindful life operating system that respects you.\n\nThis app is completely open source. Anyone can see exactly how it works, suggest improvements, or even build their own version. No black boxes. No surprises.\n\nYour privacy is total — everything stays on your phone. No accounts, no servers, no ads. Not a single byte leaves your device.\n\nNo limits. Create as many habits as you want. No subscriptions, no \"pro version\", no pop-ups asking you to pay. Ever.\n\nIf the app brings you something, you can support it with a star on GitHub or by buying me a coffee. But it is completely optional — the app is yours either way.'**
  String get about_body;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @no_data_yet.
  ///
  /// In en, this message translates to:
  /// **'No data yet'**
  String get no_data_yet;

  /// No description provided for @import_question_body.
  ///
  /// In en, this message translates to:
  /// **'Replace all your current habits with the backup, or merge them together?'**
  String get import_question_body;

  /// No description provided for @import_replace.
  ///
  /// In en, this message translates to:
  /// **'Replace all'**
  String get import_replace;

  /// No description provided for @import_merge.
  ///
  /// In en, this message translates to:
  /// **'Merge'**
  String get import_merge;

  /// No description provided for @go.
  ///
  /// In en, this message translates to:
  /// **'Go'**
  String get go;

  /// No description provided for @quote_1.
  ///
  /// In en, this message translates to:
  /// **'Small steps, every day.'**
  String get quote_1;

  /// No description provided for @quote_2.
  ///
  /// In en, this message translates to:
  /// **'Consistency beats intensity.'**
  String get quote_2;

  /// No description provided for @quote_3.
  ///
  /// In en, this message translates to:
  /// **'Show up for yourself.'**
  String get quote_3;

  /// No description provided for @quote_4.
  ///
  /// In en, this message translates to:
  /// **'One day at a time.'**
  String get quote_4;

  /// No description provided for @quote_5.
  ///
  /// In en, this message translates to:
  /// **'Progress, not perfection.'**
  String get quote_5;

  /// No description provided for @quote_6.
  ///
  /// In en, this message translates to:
  /// **'Done is better than perfect.'**
  String get quote_6;

  /// No description provided for @quote_7.
  ///
  /// In en, this message translates to:
  /// **'Keep the streak alive.'**
  String get quote_7;

  /// No description provided for @quote_8.
  ///
  /// In en, this message translates to:
  /// **'Tiny habits, big change.'**
  String get quote_8;

  /// No description provided for @quote_9.
  ///
  /// In en, this message translates to:
  /// **'Trust the process.'**
  String get quote_9;

  /// No description provided for @quote_10.
  ///
  /// In en, this message translates to:
  /// **'Win the morning.'**
  String get quote_10;

  /// No description provided for @quote_11.
  ///
  /// In en, this message translates to:
  /// **'Discipline equals freedom.'**
  String get quote_11;

  /// No description provided for @quote_12.
  ///
  /// In en, this message translates to:
  /// **'Today counts.'**
  String get quote_12;

  /// No description provided for @just_tracking_option.
  ///
  /// In en, this message translates to:
  /// **'Offer just tracking'**
  String get just_tracking_option;

  /// No description provided for @just_tracking_option_sub.
  ///
  /// In en, this message translates to:
  /// **'Adds the switch when you create a habit'**
  String get just_tracking_option_sub;

  /// No description provided for @just_tracking.
  ///
  /// In en, this message translates to:
  /// **'Just tracking'**
  String get just_tracking;

  /// No description provided for @just_tracking_sub.
  ///
  /// In en, this message translates to:
  /// **'Keep its own grid and numbers, but leave it out of Progress and the day\'s count'**
  String get just_tracking_sub;

  /// No description provided for @no_goal.
  ///
  /// In en, this message translates to:
  /// **'No daily goal'**
  String get no_goal;

  /// No description provided for @no_goal_sub.
  ///
  /// In en, this message translates to:
  /// **'Just log the value, like your weight. Any amount marks the day.'**
  String get no_goal_sub;

  /// No description provided for @any_amount.
  ///
  /// In en, this message translates to:
  /// **'Any amount counts'**
  String get any_amount;

  /// No description provided for @any_amount_sub.
  ///
  /// In en, this message translates to:
  /// **'Logging any amount marks the day as done, even below the goal.'**
  String get any_amount_sub;

  /// No description provided for @any_step.
  ///
  /// In en, this message translates to:
  /// **'Done with some steps'**
  String get any_step;

  /// No description provided for @any_step_sub.
  ///
  /// In en, this message translates to:
  /// **'Checking one step marks the day as done, without doing them all.'**
  String get any_step_sub;

  /// No description provided for @steps_needed_sub.
  ///
  /// In en, this message translates to:
  /// **'The day counts as done with {needed} of {total} steps.'**
  String steps_needed_sub(int needed, int total);

  /// No description provided for @sched_start.
  ///
  /// In en, this message translates to:
  /// **'Starts on'**
  String get sched_start;

  /// No description provided for @from_last_done.
  ///
  /// In en, this message translates to:
  /// **'Count from the last time'**
  String get from_last_done;

  /// No description provided for @month_weekday.
  ///
  /// In en, this message translates to:
  /// **'Same weekday every month'**
  String get month_weekday;

  /// No description provided for @month_weekday_sub.
  ///
  /// In en, this message translates to:
  /// **'Falls on the {when} of the month, not on a fixed date.'**
  String month_weekday_sub(String when);

  /// No description provided for @nth_weekday.
  ///
  /// In en, this message translates to:
  /// **'{n, select, first{first} second{second} third{third} fourth{fourth} other{last}} {day}'**
  String nth_weekday(String n, String day);

  /// No description provided for @from_last_done_sub.
  ///
  /// In en, this message translates to:
  /// **'Each time you do it, the wait starts again. A missed day still breaks the streak.'**
  String get from_last_done_sub;

  /// No description provided for @quotes.
  ///
  /// In en, this message translates to:
  /// **'Quotes'**
  String get quotes;

  /// No description provided for @quotes_which.
  ///
  /// In en, this message translates to:
  /// **'Which quotes'**
  String get quotes_which;

  /// No description provided for @quotes_app.
  ///
  /// In en, this message translates to:
  /// **'From the app'**
  String get quotes_app;

  /// No description provided for @quotes_mine.
  ///
  /// In en, this message translates to:
  /// **'Mine'**
  String get quotes_mine;

  /// No description provided for @quotes_both.
  ///
  /// In en, this message translates to:
  /// **'Both'**
  String get quotes_both;

  /// No description provided for @quotes_off.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get quotes_off;

  /// No description provided for @quotes_my_list.
  ///
  /// In en, this message translates to:
  /// **'My quotes'**
  String get quotes_my_list;

  /// No description provided for @quotes_add.
  ///
  /// In en, this message translates to:
  /// **'Add quote'**
  String get quotes_add;

  /// No description provided for @quotes_edit.
  ///
  /// In en, this message translates to:
  /// **'Edit quote'**
  String get quotes_edit;

  /// No description provided for @quotes_hint.
  ///
  /// In en, this message translates to:
  /// **'Write your quote'**
  String get quotes_hint;

  /// No description provided for @quotes_empty.
  ///
  /// In en, this message translates to:
  /// **'No quotes of your own'**
  String get quotes_empty;

  /// No description provided for @quotes_empty_sub.
  ///
  /// In en, this message translates to:
  /// **'Write your own and they show up on Today.'**
  String get quotes_empty_sub;

  /// No description provided for @motiv_start.
  ///
  /// In en, this message translates to:
  /// **'Start the day strong 💪'**
  String get motiv_start;

  /// No description provided for @motiv_progress.
  ///
  /// In en, this message translates to:
  /// **'You\'re on track, keep going'**
  String get motiv_progress;

  /// No description provided for @motiv_almost.
  ///
  /// In en, this message translates to:
  /// **'Almost there! Just a bit more'**
  String get motiv_almost;

  /// No description provided for @motiv_perfect.
  ///
  /// In en, this message translates to:
  /// **'Perfect day! 🔥'**
  String get motiv_perfect;

  /// No description provided for @app_background.
  ///
  /// In en, this message translates to:
  /// **'Background'**
  String get app_background;

  /// No description provided for @widgets.
  ///
  /// In en, this message translates to:
  /// **'Widgets'**
  String get widgets;

  /// No description provided for @customize_widgets.
  ///
  /// In en, this message translates to:
  /// **'Customize widgets'**
  String get customize_widgets;

  /// No description provided for @customize_widgets_sub.
  ///
  /// In en, this message translates to:
  /// **'Background, opacity, border'**
  String get customize_widgets_sub;

  /// No description provided for @widget_background.
  ///
  /// In en, this message translates to:
  /// **'Background color'**
  String get widget_background;

  /// No description provided for @widget_opacity.
  ///
  /// In en, this message translates to:
  /// **'Opacity'**
  String get widget_opacity;

  /// No description provided for @widget_border.
  ///
  /// In en, this message translates to:
  /// **'Border'**
  String get widget_border;

  /// No description provided for @widget_preview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get widget_preview;

  /// No description provided for @bg_solid.
  ///
  /// In en, this message translates to:
  /// **'Solid'**
  String get bg_solid;

  /// No description provided for @bg_gradient.
  ///
  /// In en, this message translates to:
  /// **'Gradient'**
  String get bg_gradient;

  /// No description provided for @bg_dots.
  ///
  /// In en, this message translates to:
  /// **'Dots'**
  String get bg_dots;

  /// No description provided for @bg_oled.
  ///
  /// In en, this message translates to:
  /// **'OLED'**
  String get bg_oled;

  /// No description provided for @weekdays.
  ///
  /// In en, this message translates to:
  /// **'Weekdays'**
  String get weekdays;

  /// No description provided for @weekends.
  ///
  /// In en, this message translates to:
  /// **'Weekends'**
  String get weekends;

  /// No description provided for @reminder_message.
  ///
  /// In en, this message translates to:
  /// **'Message (optional)'**
  String get reminder_message;

  /// No description provided for @reminder_message_hint.
  ///
  /// In en, this message translates to:
  /// **'Leave empty for a motivational quote'**
  String get reminder_message_hint;

  /// No description provided for @new_category.
  ///
  /// In en, this message translates to:
  /// **'New category'**
  String get new_category;

  /// No description provided for @edit_category.
  ///
  /// In en, this message translates to:
  /// **'Edit category'**
  String get edit_category;

  /// No description provided for @add_category.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get add_category;

  /// No description provided for @delete_category.
  ///
  /// In en, this message translates to:
  /// **'Delete category'**
  String get delete_category;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @cover_image.
  ///
  /// In en, this message translates to:
  /// **'Cover image'**
  String get cover_image;

  /// No description provided for @book_cover.
  ///
  /// In en, this message translates to:
  /// **'Book cover'**
  String get book_cover;

  /// No description provided for @add_image.
  ///
  /// In en, this message translates to:
  /// **'Add image'**
  String get add_image;

  /// No description provided for @when_best.
  ///
  /// In en, this message translates to:
  /// **'When are you most consistent?'**
  String get when_best;

  /// No description provided for @streak_evolution.
  ///
  /// In en, this message translates to:
  /// **'Streak evolution'**
  String get streak_evolution;

  /// No description provided for @consistency.
  ///
  /// In en, this message translates to:
  /// **'Consistency'**
  String get consistency;

  /// No description provided for @consistency_trend.
  ///
  /// In en, this message translates to:
  /// **'Consistency trend'**
  String get consistency_trend;

  /// No description provided for @by_habit.
  ///
  /// In en, this message translates to:
  /// **'By habit'**
  String get by_habit;

  /// No description provided for @ranking.
  ///
  /// In en, this message translates to:
  /// **'Ranking'**
  String get ranking;

  /// No description provided for @active_days.
  ///
  /// In en, this message translates to:
  /// **'Active days'**
  String get active_days;

  /// No description provided for @perfect_days.
  ///
  /// In en, this message translates to:
  /// **'Perfect days'**
  String get perfect_days;

  /// No description provided for @per_week.
  ///
  /// In en, this message translates to:
  /// **'Per week'**
  String get per_week;

  /// No description provided for @best_month.
  ///
  /// In en, this message translates to:
  /// **'Best month'**
  String get best_month;

  /// No description provided for @streak_on.
  ///
  /// In en, this message translates to:
  /// **'🔥 {n} days in a row. Don\'t break it!'**
  String streak_on(String n);

  /// No description provided for @streak_off.
  ///
  /// In en, this message translates to:
  /// **'💪 Today you can start a new streak'**
  String get streak_off;

  /// No description provided for @not_enough_data.
  ///
  /// In en, this message translates to:
  /// **'Not enough data yet'**
  String get not_enough_data;

  /// No description provided for @about_inline.
  ///
  /// In en, this message translates to:
  /// **'Soul State is an open-source app for tracking your habits, finances, and nourishment. No accounts, no limits, no payments. Everything stays on your phone.\n\nAnyone can see the code, improve it, or use it freely.'**
  String get about_inline;

  /// No description provided for @about_subtitle.
  ///
  /// In en, this message translates to:
  /// **'For the days you choose to show up.'**
  String get about_subtitle;

  /// No description provided for @made_by.
  ///
  /// In en, this message translates to:
  /// **'Made with ❤️ by Shanmugananthan'**
  String get made_by;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @share_progress.
  ///
  /// In en, this message translates to:
  /// **'Share progress'**
  String get share_progress;

  /// No description provided for @share_failed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t create the image'**
  String get share_failed;

  /// No description provided for @share_swipe_hint.
  ///
  /// In en, this message translates to:
  /// **'Swipe the card to move through time'**
  String get share_swipe_hint;

  /// No description provided for @share_background.
  ///
  /// In en, this message translates to:
  /// **'Background'**
  String get share_background;

  /// No description provided for @share_size.
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get share_size;

  /// No description provided for @share_size_large.
  ///
  /// In en, this message translates to:
  /// **'Tall'**
  String get share_size_large;

  /// No description provided for @share_size_small.
  ///
  /// In en, this message translates to:
  /// **'Square'**
  String get share_size_small;

  /// No description provided for @share_show_stats.
  ///
  /// In en, this message translates to:
  /// **'Show stats'**
  String get share_show_stats;

  /// No description provided for @share_save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get share_save;

  /// No description provided for @share_saved.
  ///
  /// In en, this message translates to:
  /// **'Saved to your gallery'**
  String get share_saved;

  /// No description provided for @share_save_failed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save the image'**
  String get share_save_failed;

  /// No description provided for @about_developer.
  ///
  /// In en, this message translates to:
  /// **'The developer'**
  String get about_developer;

  /// No description provided for @about_legal.
  ///
  /// In en, this message translates to:
  /// **'Soul State is free software under the GNU GPLv3, and comes with no warranty. Tap to read the license.'**
  String get about_legal;

  /// No description provided for @about_credits.
  ///
  /// In en, this message translates to:
  /// **'Credits'**
  String get about_credits;

  /// No description provided for @about_credits_body.
  ///
  /// In en, this message translates to:
  /// **'Built with Flutter. Icons by Lucide. Charts by fl_chart. Set in Figtree & Playfair Display.'**
  String get about_credits_body;

  /// No description provided for @dev_handle.
  ///
  /// In en, this message translates to:
  /// **'@iamshanmugananthan'**
  String get dev_handle;

  /// No description provided for @dev_role.
  ///
  /// In en, this message translates to:
  /// **'Shanmugananthan · Soul State'**
  String get dev_role;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @notes_enable_sub.
  ///
  /// In en, this message translates to:
  /// **'Attach notes to any day of a habit'**
  String get notes_enable_sub;

  /// No description provided for @add_note.
  ///
  /// In en, this message translates to:
  /// **'Add note'**
  String get add_note;

  /// No description provided for @edit_note.
  ///
  /// In en, this message translates to:
  /// **'Edit note'**
  String get edit_note;

  /// No description provided for @view_notes.
  ///
  /// In en, this message translates to:
  /// **'View notes'**
  String get view_notes;

  /// No description provided for @edit_entry.
  ///
  /// In en, this message translates to:
  /// **'Edit entry'**
  String get edit_entry;

  /// No description provided for @note_type.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get note_type;

  /// No description provided for @note_kind_note.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get note_kind_note;

  /// No description provided for @note_kind_planned.
  ///
  /// In en, this message translates to:
  /// **'Planned'**
  String get note_kind_planned;

  /// No description provided for @note_kind_completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get note_kind_completed;

  /// No description provided for @note_hint.
  ///
  /// In en, this message translates to:
  /// **'Write your note...'**
  String get note_hint;

  /// No description provided for @note_time_optional.
  ///
  /// In en, this message translates to:
  /// **'Time (optional)'**
  String get note_time_optional;

  /// No description provided for @save_note.
  ///
  /// In en, this message translates to:
  /// **'Save note'**
  String get save_note;

  /// No description provided for @notes_empty.
  ///
  /// In en, this message translates to:
  /// **'No notes for this day yet'**
  String get notes_empty;

  /// No description provided for @delete_note.
  ///
  /// In en, this message translates to:
  /// **'Delete note'**
  String get delete_note;

  /// No description provided for @legend_note_added.
  ///
  /// In en, this message translates to:
  /// **'Note added'**
  String get legend_note_added;

  /// No description provided for @tomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get tomorrow;

  /// No description provided for @notes_count.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 note} other{{count} notes}}'**
  String notes_count(int count);

  /// No description provided for @todos.
  ///
  /// In en, this message translates to:
  /// **'To-Do'**
  String get todos;

  /// No description provided for @todo_view_list.
  ///
  /// In en, this message translates to:
  /// **'Simple'**
  String get todo_view_list;

  /// No description provided for @todo_view_papers.
  ///
  /// In en, this message translates to:
  /// **'Folders'**
  String get todo_view_papers;

  /// No description provided for @todo_style.
  ///
  /// In en, this message translates to:
  /// **'To-do style'**
  String get todo_style;

  /// No description provided for @todo_style_sub.
  ///
  /// In en, this message translates to:
  /// **'A simple list, or folders of sheets like Google Keep.'**
  String get todo_style_sub;

  /// No description provided for @todos_enable_sub.
  ///
  /// In en, this message translates to:
  /// **'A quick list beside your habits'**
  String get todos_enable_sub;

  /// No description provided for @todo_new.
  ///
  /// In en, this message translates to:
  /// **'New to-do'**
  String get todo_new;

  /// No description provided for @todo_hint.
  ///
  /// In en, this message translates to:
  /// **'What needs doing?'**
  String get todo_hint;

  /// No description provided for @todo_subtasks.
  ///
  /// In en, this message translates to:
  /// **'Subtasks'**
  String get todo_subtasks;

  /// No description provided for @todo_subtask_hint.
  ///
  /// In en, this message translates to:
  /// **'Subtask'**
  String get todo_subtask_hint;

  /// No description provided for @todo_empty_title.
  ///
  /// In en, this message translates to:
  /// **'Nothing on the list'**
  String get todo_empty_title;

  /// No description provided for @todo_empty_body.
  ///
  /// In en, this message translates to:
  /// **'Jot down what you want to get done over the next few days.'**
  String get todo_empty_body;

  /// No description provided for @todo_date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get todo_date;

  /// No description provided for @todo_no_date.
  ///
  /// In en, this message translates to:
  /// **'No date'**
  String get todo_no_date;

  /// No description provided for @todo_time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get todo_time;

  /// No description provided for @todo_repeat.
  ///
  /// In en, this message translates to:
  /// **'Repeat'**
  String get todo_repeat;

  /// No description provided for @todo_repeat_never.
  ///
  /// In en, this message translates to:
  /// **'Don\'t repeat'**
  String get todo_repeat_never;

  /// No description provided for @todo_repeat_workdays.
  ///
  /// In en, this message translates to:
  /// **'Monday to Friday'**
  String get todo_repeat_workdays;

  /// No description provided for @todo_repeat_days.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Every day} other{Every {count} days}}'**
  String todo_repeat_days(int count);

  /// No description provided for @todo_repeat_weeks.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Every week} other{Every {count} weeks}}'**
  String todo_repeat_weeks(int count);

  /// No description provided for @todo_repeat_months.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Every month} other{Every {count} months}}'**
  String todo_repeat_months(int count);

  /// No description provided for @todo_repeat_years.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Every year} other{Every {count} years}}'**
  String todo_repeat_years(int count);

  /// No description provided for @todo_repeat_custom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get todo_repeat_custom;

  /// No description provided for @todo_repeat_unit_days.
  ///
  /// In en, this message translates to:
  /// **'Days'**
  String get todo_repeat_unit_days;

  /// No description provided for @todo_repeat_unit_weeks.
  ///
  /// In en, this message translates to:
  /// **'Weeks'**
  String get todo_repeat_unit_weeks;

  /// No description provided for @todo_repeat_unit_months.
  ///
  /// In en, this message translates to:
  /// **'Months'**
  String get todo_repeat_unit_months;

  /// No description provided for @todo_repeat_unit_years.
  ///
  /// In en, this message translates to:
  /// **'Years'**
  String get todo_repeat_unit_years;

  /// No description provided for @todo_repeat_on_day.
  ///
  /// In en, this message translates to:
  /// **'On day {day}'**
  String todo_repeat_on_day(int day);

  /// No description provided for @todo_repeat_on_weekday.
  ///
  /// In en, this message translates to:
  /// **'On the {nth, select, 1{first} 2{second} 3{third} 4{fourth} other{last}} {weekday}'**
  String todo_repeat_on_weekday(String nth, String weekday);

  /// No description provided for @todo_repeat_from_done.
  ///
  /// In en, this message translates to:
  /// **'Count from when I finish it'**
  String get todo_repeat_from_done;

  /// No description provided for @todo_repeat_skip.
  ///
  /// In en, this message translates to:
  /// **'Skip this one'**
  String get todo_repeat_skip;

  /// No description provided for @todo_estimate.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get todo_estimate;

  /// No description provided for @todo_estimate_none.
  ///
  /// In en, this message translates to:
  /// **'No duration'**
  String get todo_estimate_none;

  /// No description provided for @todo_priority.
  ///
  /// In en, this message translates to:
  /// **'Priority'**
  String get todo_priority;

  /// No description provided for @todo_paper.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get todo_paper;

  /// No description provided for @todo_add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get todo_add;

  /// No description provided for @todo_list_item.
  ///
  /// In en, this message translates to:
  /// **'List item'**
  String get todo_list_item;

  /// No description provided for @todo_title_hint.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get todo_title_hint;

  /// No description provided for @todo_body_hint.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get todo_body_hint;

  /// No description provided for @todo_sort.
  ///
  /// In en, this message translates to:
  /// **'Priority order'**
  String get todo_sort;

  /// No description provided for @todo_sort_high_first.
  ///
  /// In en, this message translates to:
  /// **'High priority first'**
  String get todo_sort_high_first;

  /// No description provided for @todo_sort_low_first.
  ///
  /// In en, this message translates to:
  /// **'Low priority first'**
  String get todo_sort_low_first;

  /// No description provided for @todo_project_empty.
  ///
  /// In en, this message translates to:
  /// **'Nothing in this folder yet'**
  String get todo_project_empty;

  /// No description provided for @todo_background.
  ///
  /// In en, this message translates to:
  /// **'Background'**
  String get todo_background;

  /// No description provided for @todo_background_pick.
  ///
  /// In en, this message translates to:
  /// **'Choose a photo'**
  String get todo_background_pick;

  /// No description provided for @todo_deleted.
  ///
  /// In en, this message translates to:
  /// **'Note deleted'**
  String get todo_deleted;

  /// No description provided for @todo_mark_done.
  ///
  /// In en, this message translates to:
  /// **'Mark as done'**
  String get todo_mark_done;

  /// No description provided for @todo_mark_open.
  ///
  /// In en, this message translates to:
  /// **'Mark as not done'**
  String get todo_mark_open;

  /// No description provided for @todo_pin.
  ///
  /// In en, this message translates to:
  /// **'Pin'**
  String get todo_pin;

  /// No description provided for @todo_unpin.
  ///
  /// In en, this message translates to:
  /// **'Unpin'**
  String get todo_unpin;

  /// No description provided for @todo_select.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get todo_select;

  /// No description provided for @todo_selected.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 selected} other{{count} selected}}'**
  String todo_selected(int count);

  /// No description provided for @todo_deleted_many.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Note deleted} other{{count} notes deleted}}'**
  String todo_deleted_many(int count);

  /// No description provided for @priority_none.
  ///
  /// In en, this message translates to:
  /// **'No priority'**
  String get priority_none;

  /// No description provided for @priority_low.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get priority_low;

  /// No description provided for @priority_medium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get priority_medium;

  /// No description provided for @priority_high.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get priority_high;

  /// No description provided for @todo_overdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get todo_overdue;

  /// No description provided for @todo_upcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get todo_upcoming;

  /// No description provided for @todo_someday.
  ///
  /// In en, this message translates to:
  /// **'Someday'**
  String get todo_someday;

  /// No description provided for @pick_a_date.
  ///
  /// In en, this message translates to:
  /// **'Pick a date'**
  String get pick_a_date;

  /// No description provided for @todo_left.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{All done} =1{1 to do} other{{count} to do}}'**
  String todo_left(int count);

  /// No description provided for @todo_completed_count.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Completed (1)} other{Completed ({count})}}'**
  String todo_completed_count(int count);

  /// No description provided for @todo_search.
  ///
  /// In en, this message translates to:
  /// **'Search to-dos'**
  String get todo_search;

  /// No description provided for @todo_search_empty.
  ///
  /// In en, this message translates to:
  /// **'Nothing matches that'**
  String get todo_search_empty;

  /// No description provided for @todo_clear_completed.
  ///
  /// In en, this message translates to:
  /// **'Clear completed'**
  String get todo_clear_completed;

  /// No description provided for @todo_clear_completed_body.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{This deletes the completed to-do.} other{This deletes the {count} completed to-dos.}}'**
  String todo_clear_completed_body(int count);

  /// No description provided for @prefs_general.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get prefs_general;

  /// No description provided for @prefs_cards.
  ///
  /// In en, this message translates to:
  /// **'Cards and calendar'**
  String get prefs_cards;

  /// No description provided for @prefs_habits.
  ///
  /// In en, this message translates to:
  /// **'Habits'**
  String get prefs_habits;

  /// No description provided for @prefs_features.
  ///
  /// In en, this message translates to:
  /// **'Features'**
  String get prefs_features;

  /// No description provided for @prefs_privacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get prefs_privacy;

  /// No description provided for @collapse_cards.
  ///
  /// In en, this message translates to:
  /// **'Collapse cards'**
  String get collapse_cards;

  /// No description provided for @expand_cards.
  ///
  /// In en, this message translates to:
  /// **'Expand cards'**
  String get expand_cards;

  /// No description provided for @view_switcher.
  ///
  /// In en, this message translates to:
  /// **'View switcher'**
  String get view_switcher;

  /// No description provided for @view_switcher_sub.
  ///
  /// In en, this message translates to:
  /// **'Show the Week / Month / Year buttons on Today. Off, they move to the filter menu'**
  String get view_switcher_sub;

  /// No description provided for @view_switcher_needs.
  ///
  /// In en, this message translates to:
  /// **'Turn on activity on cards to use it'**
  String get view_switcher_needs;

  /// No description provided for @unit_hours.
  ///
  /// In en, this message translates to:
  /// **'hours'**
  String get unit_hours;

  /// No description provided for @unit_minutes.
  ///
  /// In en, this message translates to:
  /// **'minutes'**
  String get unit_minutes;

  /// No description provided for @unit_seconds.
  ///
  /// In en, this message translates to:
  /// **'seconds'**
  String get unit_seconds;

  /// No description provided for @unit_hour_short.
  ///
  /// In en, this message translates to:
  /// **'h'**
  String get unit_hour_short;

  /// No description provided for @unit_min_short.
  ///
  /// In en, this message translates to:
  /// **'min'**
  String get unit_min_short;

  /// No description provided for @celebration.
  ///
  /// In en, this message translates to:
  /// **'Completion effect'**
  String get celebration;

  /// No description provided for @celebration_confetti.
  ///
  /// In en, this message translates to:
  /// **'Confetti'**
  String get celebration_confetti;

  /// No description provided for @celebration_fireworks.
  ///
  /// In en, this message translates to:
  /// **'Fireworks'**
  String get celebration_fireworks;

  /// No description provided for @celebration_surprise.
  ///
  /// In en, this message translates to:
  /// **'Surprise me'**
  String get celebration_surprise;

  /// No description provided for @select_all.
  ///
  /// In en, this message translates to:
  /// **'Select all'**
  String get select_all;

  /// No description provided for @selected_count.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 selected} other{{count} selected}}'**
  String selected_count(int count);

  /// No description provided for @unscheduled_title.
  ///
  /// In en, this message translates to:
  /// **'Day not scheduled'**
  String get unscheduled_title;

  /// No description provided for @unscheduled_body.
  ///
  /// In en, this message translates to:
  /// **'This habit is not scheduled on {day}. Log it anyway as an extra?'**
  String unscheduled_body(String day);

  /// No description provided for @unscheduled_confirm.
  ///
  /// In en, this message translates to:
  /// **'Log anyway'**
  String get unscheduled_confirm;

  /// No description provided for @paused_day_title.
  ///
  /// In en, this message translates to:
  /// **'Day paused'**
  String get paused_day_title;

  /// No description provided for @paused_day_body.
  ///
  /// In en, this message translates to:
  /// **'This habit is paused on {day}. Log it anyway?'**
  String paused_day_body(String day);

  /// No description provided for @rest_days_none.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get rest_days_none;

  /// No description provided for @last_90_days.
  ///
  /// In en, this message translates to:
  /// **'Last 90 days'**
  String get last_90_days;

  /// No description provided for @last_12_months.
  ///
  /// In en, this message translates to:
  /// **'Last 12 months'**
  String get last_12_months;

  /// No description provided for @consistency_vs_previous.
  ///
  /// In en, this message translates to:
  /// **'{change} vs previous'**
  String consistency_vs_previous(String change);

  /// No description provided for @plan_day.
  ///
  /// In en, this message translates to:
  /// **'Plan the day'**
  String get plan_day;

  /// No description provided for @plan_day_sub.
  ///
  /// In en, this message translates to:
  /// **'Give habits a time of day and see them on a timeline.'**
  String get plan_day_sub;

  /// No description provided for @plan_todos.
  ///
  /// In en, this message translates to:
  /// **'Tasks in Plan'**
  String get plan_todos;

  /// No description provided for @plan_todos_sub.
  ///
  /// In en, this message translates to:
  /// **'Show the to-dos dated that day below the habits.'**
  String get plan_todos_sub;

  /// No description provided for @plan_show_habits.
  ///
  /// In en, this message translates to:
  /// **'Habits'**
  String get plan_show_habits;

  /// No description provided for @plan_show_both.
  ///
  /// In en, this message translates to:
  /// **'Both'**
  String get plan_show_both;

  /// No description provided for @plan_show_todos.
  ///
  /// In en, this message translates to:
  /// **'To-dos'**
  String get plan_show_todos;

  /// No description provided for @swipe_cards.
  ///
  /// In en, this message translates to:
  /// **'Swipe habit cards'**
  String get swipe_cards;

  /// No description provided for @swipe_cards_sub.
  ///
  /// In en, this message translates to:
  /// **'Swipe left to complete a habit and right to undo it.'**
  String get swipe_cards_sub;

  /// No description provided for @habit_time.
  ///
  /// In en, this message translates to:
  /// **'Time of day'**
  String get habit_time;

  /// No description provided for @habit_time_none.
  ///
  /// In en, this message translates to:
  /// **'Anytime'**
  String get habit_time_none;

  /// No description provided for @habit_time_sub.
  ///
  /// In en, this message translates to:
  /// **'Places the habit in Plan at this time. It still shows in Today all day.'**
  String get habit_time_sub;

  /// No description provided for @habit_duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get habit_duration;

  /// No description provided for @habit_duration_none.
  ///
  /// In en, this message translates to:
  /// **'No duration'**
  String get habit_duration_none;

  /// No description provided for @day_timeline.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get day_timeline;

  /// No description provided for @day_timeline_free.
  ///
  /// In en, this message translates to:
  /// **'{span} free'**
  String day_timeline_free(String span);

  /// No description provided for @day_timeline_anytime.
  ///
  /// In en, this message translates to:
  /// **'Anytime'**
  String get day_timeline_anytime;

  /// No description provided for @day_timeline_empty.
  ///
  /// In en, this message translates to:
  /// **'Nothing planned for this day'**
  String get day_timeline_empty;

  /// No description provided for @day_timeline_empty_sub.
  ///
  /// In en, this message translates to:
  /// **'Give a habit a time of day and it will show up here.'**
  String get day_timeline_empty_sub;

  /// No description provided for @day_timeline_empty_todos.
  ///
  /// In en, this message translates to:
  /// **'Give a to-do this date and it will show up here.'**
  String get day_timeline_empty_todos;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @start_view.
  ///
  /// In en, this message translates to:
  /// **'Today opens on'**
  String get start_view;

  /// No description provided for @start_view_last.
  ///
  /// In en, this message translates to:
  /// **'Last used'**
  String get start_view_last;

  /// No description provided for @perfect_streak.
  ///
  /// In en, this message translates to:
  /// **'Perfect day streak'**
  String get perfect_streak;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @notes_hint.
  ///
  /// In en, this message translates to:
  /// **'Open a habit and long-press a day on its calendar to see or add notes'**
  String get notes_hint;

  /// No description provided for @app_style.
  ///
  /// In en, this message translates to:
  /// **'App style'**
  String get app_style;

  /// No description provided for @app_style_sub.
  ///
  /// In en, this message translates to:
  /// **'Choose how the whole app looks and feels.'**
  String get app_style_sub;

  /// No description provided for @style_classic.
  ///
  /// In en, this message translates to:
  /// **'Classic'**
  String get style_classic;

  /// No description provided for @style_minimal.
  ///
  /// In en, this message translates to:
  /// **'Minimal'**
  String get style_minimal;

  /// No description provided for @style_classic_desc.
  ///
  /// In en, this message translates to:
  /// **'Habit list, bottom bar and every setting on one screen.'**
  String get style_classic_desc;

  /// No description provided for @style_minimal_desc.
  ///
  /// In en, this message translates to:
  /// **'Habit grid and settings grouped into four sections.'**
  String get style_minimal_desc;

  /// No description provided for @appearance_sub.
  ///
  /// In en, this message translates to:
  /// **'Theme, accent and background'**
  String get appearance_sub;

  /// No description provided for @preferences_sub.
  ///
  /// In en, this message translates to:
  /// **'Language, week and sorting'**
  String get preferences_sub;

  /// No description provided for @data_sub.
  ///
  /// In en, this message translates to:
  /// **'Backups, archive and import'**
  String get data_sub;

  /// No description provided for @about_sub.
  ///
  /// In en, this message translates to:
  /// **'Version, source code and support'**
  String get about_sub;

  /// No description provided for @support_sub.
  ///
  /// In en, this message translates to:
  /// **'Report a bug or ask for a feature'**
  String get support_sub;

  /// No description provided for @check_style.
  ///
  /// In en, this message translates to:
  /// **'Check style'**
  String get check_style;

  /// No description provided for @square.
  ///
  /// In en, this message translates to:
  /// **'Square'**
  String get square;

  /// No description provided for @circle.
  ///
  /// In en, this message translates to:
  /// **'Circle'**
  String get circle;

  /// No description provided for @github_star_row.
  ///
  /// In en, this message translates to:
  /// **'View source & give a star'**
  String get github_star_row;

  /// No description provided for @github_star_sub.
  ///
  /// In en, this message translates to:
  /// **'Give the project a star so more people find it'**
  String get github_star_sub;

  /// No description provided for @icons_tab.
  ///
  /// In en, this message translates to:
  /// **'Icons'**
  String get icons_tab;

  /// No description provided for @emojis_tab.
  ///
  /// In en, this message translates to:
  /// **'Emojis'**
  String get emojis_tab;

  /// No description provided for @emoji_own.
  ///
  /// In en, this message translates to:
  /// **'Type or paste any emoji'**
  String get emoji_own;

  /// No description provided for @report_issue.
  ///
  /// In en, this message translates to:
  /// **'Report an issue'**
  String get report_issue;

  /// No description provided for @report_issue_sub.
  ///
  /// In en, this message translates to:
  /// **'Tell me about a bug or ask for a feature'**
  String get report_issue_sub;

  /// No description provided for @advanced_options.
  ///
  /// In en, this message translates to:
  /// **'Advanced options'**
  String get advanced_options;

  /// No description provided for @default_user.
  ///
  /// In en, this message translates to:
  /// **'Rabbit'**
  String get default_user;

  /// No description provided for @your_name.
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get your_name;

  /// No description provided for @edit_name.
  ///
  /// In en, this message translates to:
  /// **'Edit name'**
  String get edit_name;

  /// No description provided for @change_photo.
  ///
  /// In en, this message translates to:
  /// **'Change photo'**
  String get change_photo;

  /// No description provided for @remove_photo.
  ///
  /// In en, this message translates to:
  /// **'Remove photo'**
  String get remove_photo;

  /// No description provided for @notif_greeting.
  ///
  /// In en, this message translates to:
  /// **'Hi {name}, '**
  String notif_greeting(String name);

  /// No description provided for @app_icon.
  ///
  /// In en, this message translates to:
  /// **'App icon'**
  String get app_icon;

  /// No description provided for @icon_default.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get icon_default;

  /// No description provided for @icon_neutral.
  ///
  /// In en, this message translates to:
  /// **'Green'**
  String get icon_neutral;

  /// No description provided for @icon_accent.
  ///
  /// In en, this message translates to:
  /// **'Tricolor'**
  String get icon_accent;

  /// No description provided for @custom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get custom;

  /// No description provided for @see_more.
  ///
  /// In en, this message translates to:
  /// **'See more'**
  String get see_more;

  /// No description provided for @see_less.
  ///
  /// In en, this message translates to:
  /// **'See less'**
  String get see_less;

  /// No description provided for @colors_tab.
  ///
  /// In en, this message translates to:
  /// **'Colors'**
  String get colors_tab;

  /// No description provided for @reorder.
  ///
  /// In en, this message translates to:
  /// **'Reorder'**
  String get reorder;

  /// No description provided for @reorder_hint.
  ///
  /// In en, this message translates to:
  /// **'Drag the habits to reorder them'**
  String get reorder_hint;

  /// No description provided for @category_order_empty.
  ///
  /// In en, this message translates to:
  /// **'Give a habit a category and it will show up here'**
  String get category_order_empty;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @accent_color.
  ///
  /// In en, this message translates to:
  /// **'Accent color'**
  String get accent_color;

  /// No description provided for @heatmap_path.
  ///
  /// In en, this message translates to:
  /// **'Connect the days'**
  String get heatmap_path;

  /// No description provided for @heatmap_path_sub.
  ///
  /// In en, this message translates to:
  /// **'Draws the grid as one long walk'**
  String get heatmap_path_sub;

  /// No description provided for @sort_completed_last.
  ///
  /// In en, this message translates to:
  /// **'Completed last'**
  String get sort_completed_last;

  /// No description provided for @sort_completed_last_sub.
  ///
  /// In en, this message translates to:
  /// **'Sends what you finish to the bottom of the list'**
  String get sort_completed_last_sub;

  /// No description provided for @today_only.
  ///
  /// In en, this message translates to:
  /// **'Only today\'s'**
  String get today_only;

  /// No description provided for @today_only_sub.
  ///
  /// In en, this message translates to:
  /// **'Hides the habits that are not scheduled for today'**
  String get today_only_sub;

  /// No description provided for @hide_done.
  ///
  /// In en, this message translates to:
  /// **'Hide completed'**
  String get hide_done;

  /// No description provided for @hide_done_sub.
  ///
  /// In en, this message translates to:
  /// **'What you finish today leaves the list'**
  String get hide_done_sub;

  /// No description provided for @past_first.
  ///
  /// In en, this message translates to:
  /// **'Open past days first'**
  String get past_first;

  /// No description provided for @past_first_sub.
  ///
  /// In en, this message translates to:
  /// **'Tapping a past day shows it first, so nothing changes by mistake'**
  String get past_first_sub;

  /// No description provided for @miss_reason_title.
  ///
  /// In en, this message translates to:
  /// **'Why did you miss it?'**
  String get miss_reason_title;

  /// No description provided for @miss_reasons.
  ///
  /// In en, this message translates to:
  /// **'Why you missed'**
  String get miss_reasons;

  /// No description provided for @miss_other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get miss_other;

  /// No description provided for @miss_other_hint.
  ///
  /// In en, this message translates to:
  /// **'Write a reason'**
  String get miss_other_hint;

  /// No description provided for @miss_overslept.
  ///
  /// In en, this message translates to:
  /// **'Overslept'**
  String get miss_overslept;

  /// No description provided for @miss_busy.
  ///
  /// In en, this message translates to:
  /// **'Busy'**
  String get miss_busy;

  /// No description provided for @miss_traveling.
  ///
  /// In en, this message translates to:
  /// **'Traveling'**
  String get miss_traveling;

  /// No description provided for @miss_sick.
  ///
  /// In en, this message translates to:
  /// **'Sick'**
  String get miss_sick;

  /// No description provided for @miss_tired.
  ///
  /// In en, this message translates to:
  /// **'Tired'**
  String get miss_tired;

  /// No description provided for @miss_forgot.
  ///
  /// In en, this message translates to:
  /// **'Forgot'**
  String get miss_forgot;

  /// No description provided for @day_not_done.
  ///
  /// In en, this message translates to:
  /// **'Not done'**
  String get day_not_done;

  /// No description provided for @day_clean.
  ///
  /// In en, this message translates to:
  /// **'Clean'**
  String get day_clean;

  /// No description provided for @day_relapses.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 relapse} other{{count} relapses}}'**
  String day_relapses(int count);

  /// No description provided for @day_log_relapse.
  ///
  /// In en, this message translates to:
  /// **'Log relapse'**
  String get day_log_relapse;

  /// No description provided for @day_amount.
  ///
  /// In en, this message translates to:
  /// **'{value} of {goal}'**
  String day_amount(String value, String goal);

  /// No description provided for @today_filter.
  ///
  /// In en, this message translates to:
  /// **'Show'**
  String get today_filter;

  /// No description provided for @today_fold_done.
  ///
  /// In en, this message translates to:
  /// **'Done ({count})'**
  String today_fold_done(int count);

  /// No description provided for @today_fold_other.
  ///
  /// In en, this message translates to:
  /// **'Other days ({count})'**
  String today_fold_other(int count);

  /// No description provided for @today_fold_hidden.
  ///
  /// In en, this message translates to:
  /// **'Hidden ({count})'**
  String today_fold_hidden(int count);

  /// No description provided for @card_activity.
  ///
  /// In en, this message translates to:
  /// **'Activity on cards'**
  String get card_activity;

  /// No description provided for @card_activity_sub.
  ///
  /// In en, this message translates to:
  /// **'Shows the last days on the card, ready to tick'**
  String get card_activity_sub;

  /// No description provided for @readable_copy.
  ///
  /// In en, this message translates to:
  /// **'Readable copy'**
  String get readable_copy;

  /// No description provided for @readable_copy_sub.
  ///
  /// In en, this message translates to:
  /// **'Also writes your habits as markdown files'**
  String get readable_copy_sub;

  /// No description provided for @auto_sync.
  ///
  /// In en, this message translates to:
  /// **'Keep devices in sync'**
  String get auto_sync;

  /// No description provided for @auto_sync_sub.
  ///
  /// In en, this message translates to:
  /// **'Saves after each change and checks the folder every few minutes'**
  String get auto_sync_sub;

  /// No description provided for @sync_guide.
  ///
  /// In en, this message translates to:
  /// **'How to sync two devices'**
  String get sync_guide;

  /// No description provided for @theme_sub.
  ///
  /// In en, this message translates to:
  /// **'Light, dark or the system one'**
  String get theme_sub;

  /// No description provided for @accent_color_sub.
  ///
  /// In en, this message translates to:
  /// **'Used on buttons and highlights'**
  String get accent_color_sub;

  /// No description provided for @color_theme.
  ///
  /// In en, this message translates to:
  /// **'Color theme'**
  String get color_theme;

  /// No description provided for @color_theme_sub.
  ///
  /// In en, this message translates to:
  /// **'Full palettes like Catppuccin or Nord'**
  String get color_theme_sub;

  /// No description provided for @color_theme_default.
  ///
  /// In en, this message translates to:
  /// **'Soul State'**
  String get color_theme_default;

  /// No description provided for @color_theme_hint.
  ///
  /// In en, this message translates to:
  /// **'Each theme brings its own background, text and accent color. It follows light and dark mode.'**
  String get color_theme_hint;

  /// No description provided for @app_background_sub.
  ///
  /// In en, this message translates to:
  /// **'What you see behind the cards'**
  String get app_background_sub;

  /// No description provided for @check_style_sub.
  ///
  /// In en, this message translates to:
  /// **'Square or round marks'**
  String get check_style_sub;

  /// No description provided for @app_icon_sub.
  ///
  /// In en, this message translates to:
  /// **'The icon on your home screen'**
  String get app_icon_sub;

  /// No description provided for @language_sub.
  ///
  /// In en, this message translates to:
  /// **'The language of the whole app'**
  String get language_sub;

  /// No description provided for @week_start_sub.
  ///
  /// In en, this message translates to:
  /// **'The first column of every grid'**
  String get week_start_sub;

  /// No description provided for @celebration_sub.
  ///
  /// In en, this message translates to:
  /// **'What you see when you tick a habit'**
  String get celebration_sub;

  /// No description provided for @start_view_sub.
  ///
  /// In en, this message translates to:
  /// **'The view Today opens in'**
  String get start_view_sub;

  /// No description provided for @quotes_sub.
  ///
  /// In en, this message translates to:
  /// **'Which quotes show up on Today'**
  String get quotes_sub;

  /// No description provided for @app_lock_delay_sub.
  ///
  /// In en, this message translates to:
  /// **'How soon it asks again after you leave'**
  String get app_lock_delay_sub;

  /// No description provided for @on.
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get on;

  /// No description provided for @off.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get off;

  /// No description provided for @checklist.
  ///
  /// In en, this message translates to:
  /// **'Checklist'**
  String get checklist;

  /// No description provided for @checklist_hint.
  ///
  /// In en, this message translates to:
  /// **'Break the habit into steps. It\'s done only when every step is checked.'**
  String get checklist_hint;

  /// No description provided for @add_step.
  ///
  /// In en, this message translates to:
  /// **'Add step'**
  String get add_step;

  /// No description provided for @step_hint.
  ///
  /// In en, this message translates to:
  /// **'Step name'**
  String get step_hint;

  /// No description provided for @todays_checklist.
  ///
  /// In en, this message translates to:
  /// **'Today\'s checklist'**
  String get todays_checklist;

  /// No description provided for @steps_done.
  ///
  /// In en, this message translates to:
  /// **'{done}/{total} steps'**
  String steps_done(String done, String total);

  /// No description provided for @vacation_all.
  ///
  /// In en, this message translates to:
  /// **'Pause every habit'**
  String get vacation_all;

  /// No description provided for @vacation_all_sub.
  ///
  /// In en, this message translates to:
  /// **'Nothing counts as missed while it is on'**
  String get vacation_all_sub;

  /// No description provided for @vacation_mode.
  ///
  /// In en, this message translates to:
  /// **'Vacation mode'**
  String get vacation_mode;

  /// No description provided for @vacation_on_desc.
  ///
  /// In en, this message translates to:
  /// **'Paused — these days won\'t count as missed or completed.'**
  String get vacation_on_desc;

  /// No description provided for @vacation_off_desc.
  ///
  /// In en, this message translates to:
  /// **'Pause this habit. Skipped days won\'t break your streak.'**
  String get vacation_off_desc;

  /// No description provided for @paused.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get paused;

  /// No description provided for @start_vacation.
  ///
  /// In en, this message translates to:
  /// **'Start vacation'**
  String get start_vacation;

  /// No description provided for @end_vacation.
  ///
  /// In en, this message translates to:
  /// **'End vacation'**
  String get end_vacation;

  /// No description provided for @vacation_day_on.
  ///
  /// In en, this message translates to:
  /// **'Mark as vacation day'**
  String get vacation_day_on;

  /// No description provided for @vacation_day_off.
  ///
  /// In en, this message translates to:
  /// **'Remove vacation day'**
  String get vacation_day_off;

  /// No description provided for @rest_days.
  ///
  /// In en, this message translates to:
  /// **'Rest days'**
  String get rest_days;

  /// No description provided for @rest_days_desc.
  ///
  /// In en, this message translates to:
  /// **'Pause it every week on these days. You can still log them, and they\'ll count.'**
  String get rest_days_desc;

  /// No description provided for @widget_no_habits.
  ///
  /// In en, this message translates to:
  /// **'No habits yet\nTap to open Soul State'**
  String get widget_no_habits;

  /// No description provided for @widget_no_data.
  ///
  /// In en, this message translates to:
  /// **'No data yet\nOpen Soul State to sync'**
  String get widget_no_data;

  /// No description provided for @widget_open_to_sync.
  ///
  /// In en, this message translates to:
  /// **'Open Soul State to sync'**
  String get widget_open_to_sync;

  /// No description provided for @widget_activity.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get widget_activity;

  /// No description provided for @widget_today_progress.
  ///
  /// In en, this message translates to:
  /// **'Today  {done}/{total}'**
  String widget_today_progress(String done, String total);

  /// No description provided for @widget_today_done.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} done'**
  String widget_today_done(String done, String total);

  /// No description provided for @widget_todos_open.
  ///
  /// In en, this message translates to:
  /// **'To-do  {count}'**
  String widget_todos_open(String count);

  /// No description provided for @widget_todos_empty.
  ///
  /// In en, this message translates to:
  /// **'Nothing left for today'**
  String get widget_todos_empty;

  /// No description provided for @widget_done_today.
  ///
  /// In en, this message translates to:
  /// **'done today'**
  String get widget_done_today;

  /// No description provided for @widget_streak_days.
  ///
  /// In en, this message translates to:
  /// **'Streak days'**
  String get widget_streak_days;

  /// No description provided for @widget_this_week.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get widget_this_week;

  /// No description provided for @widget_last_days.
  ///
  /// In en, this message translates to:
  /// **'Last {count} days'**
  String widget_last_days(String count);

  /// No description provided for @widget_cfg_days.
  ///
  /// In en, this message translates to:
  /// **'Days shown'**
  String get widget_cfg_days;

  /// No description provided for @widget_week_done.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total}'**
  String widget_week_done(String done, String total);

  /// No description provided for @widget_best_streak.
  ///
  /// In en, this message translates to:
  /// **'🔥 {streak} best streak'**
  String widget_best_streak(String streak);

  /// No description provided for @widget_cfg_title.
  ///
  /// In en, this message translates to:
  /// **'Customize widget'**
  String get widget_cfg_title;

  /// No description provided for @widget_cfg_content.
  ///
  /// In en, this message translates to:
  /// **'Content'**
  String get widget_cfg_content;

  /// No description provided for @widget_cfg_background.
  ///
  /// In en, this message translates to:
  /// **'Background'**
  String get widget_cfg_background;

  /// No description provided for @widget_cfg_color.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get widget_cfg_color;

  /// No description provided for @widget_cfg_image.
  ///
  /// In en, this message translates to:
  /// **'Image'**
  String get widget_cfg_image;

  /// No description provided for @widget_cfg_choose_image.
  ///
  /// In en, this message translates to:
  /// **'Choose image'**
  String get widget_cfg_choose_image;

  /// No description provided for @widget_cfg_change_image.
  ///
  /// In en, this message translates to:
  /// **'Change image'**
  String get widget_cfg_change_image;

  /// No description provided for @widget_cfg_custom_color.
  ///
  /// In en, this message translates to:
  /// **'Custom color'**
  String get widget_cfg_custom_color;

  /// No description provided for @widget_cfg_follow_system.
  ///
  /// In en, this message translates to:
  /// **'Follow system theme'**
  String get widget_cfg_follow_system;

  /// No description provided for @widget_cfg_dark_color.
  ///
  /// In en, this message translates to:
  /// **'Dark theme'**
  String get widget_cfg_dark_color;

  /// No description provided for @widget_cfg_light_color.
  ///
  /// In en, this message translates to:
  /// **'Light theme'**
  String get widget_cfg_light_color;

  /// No description provided for @widget_cfg_opacity.
  ///
  /// In en, this message translates to:
  /// **'Opacity  {value}%'**
  String widget_cfg_opacity(String value);

  /// No description provided for @widget_cfg_border.
  ///
  /// In en, this message translates to:
  /// **'Border'**
  String get widget_cfg_border;

  /// No description provided for @widget_cfg_thickness.
  ///
  /// In en, this message translates to:
  /// **'Thickness  {value}dp'**
  String widget_cfg_thickness(String value);

  /// No description provided for @widget_cfg_todos_all.
  ///
  /// In en, this message translates to:
  /// **'Show every task'**
  String get widget_cfg_todos_all;

  /// No description provided for @widget_cfg_todos_hint.
  ///
  /// In en, this message translates to:
  /// **'Off: only today, late and undated tasks'**
  String get widget_cfg_todos_hint;

  /// No description provided for @widget_cfg_show_art.
  ///
  /// In en, this message translates to:
  /// **'Show illustration'**
  String get widget_cfg_show_art;

  /// No description provided for @widget_cfg_show_header.
  ///
  /// In en, this message translates to:
  /// **'Header'**
  String get widget_cfg_show_header;

  /// No description provided for @widget_cfg_show_icons.
  ///
  /// In en, this message translates to:
  /// **'Habit icons'**
  String get widget_cfg_show_icons;

  /// No description provided for @widget_cfg_show_cards.
  ///
  /// In en, this message translates to:
  /// **'Background behind each habit'**
  String get widget_cfg_show_cards;

  /// No description provided for @widget_cfg_show_details.
  ///
  /// In en, this message translates to:
  /// **'Streak under the name'**
  String get widget_cfg_show_details;

  /// No description provided for @widget_cfg_buttons.
  ///
  /// In en, this message translates to:
  /// **'Buttons'**
  String get widget_cfg_buttons;

  /// No description provided for @widget_cfg_buttons_round.
  ///
  /// In en, this message translates to:
  /// **'Round'**
  String get widget_cfg_buttons_round;

  /// No description provided for @widget_cfg_buttons_square.
  ///
  /// In en, this message translates to:
  /// **'Square'**
  String get widget_cfg_buttons_square;

  /// No description provided for @widget_cfg_buttons_flower.
  ///
  /// In en, this message translates to:
  /// **'Flower'**
  String get widget_cfg_buttons_flower;

  /// No description provided for @widget_cfg_tick.
  ///
  /// In en, this message translates to:
  /// **'Checkmark'**
  String get widget_cfg_tick;

  /// No description provided for @widget_cfg_tick_hint.
  ///
  /// In en, this message translates to:
  /// **'Off: done buttons are only filled with color'**
  String get widget_cfg_tick_hint;

  /// No description provided for @widget_cfg_hide_done.
  ///
  /// In en, this message translates to:
  /// **'Hide completed'**
  String get widget_cfg_hide_done;

  /// No description provided for @widget_cfg_compact.
  ///
  /// In en, this message translates to:
  /// **'Compact'**
  String get widget_cfg_compact;

  /// No description provided for @widget_cfg_compact_hint.
  ///
  /// In en, this message translates to:
  /// **'Smaller rows, streak next to the name'**
  String get widget_cfg_compact_hint;

  /// No description provided for @widget_cfg_compact_todos_hint.
  ///
  /// In en, this message translates to:
  /// **'Smaller rows, time next to the task'**
  String get widget_cfg_compact_todos_hint;

  /// No description provided for @widget_cfg_today_band.
  ///
  /// In en, this message translates to:
  /// **'Highlight today'**
  String get widget_cfg_today_band;

  /// No description provided for @widget_cfg_show_activity.
  ///
  /// In en, this message translates to:
  /// **'Show activity of'**
  String get widget_cfg_show_activity;

  /// No description provided for @widget_cfg_dot_color.
  ///
  /// In en, this message translates to:
  /// **'Dot color'**
  String get widget_cfg_dot_color;

  /// No description provided for @widget_cfg_style.
  ///
  /// In en, this message translates to:
  /// **'Style'**
  String get widget_cfg_style;

  /// No description provided for @widget_cfg_style_classic.
  ///
  /// In en, this message translates to:
  /// **'Classic'**
  String get widget_cfg_style_classic;

  /// No description provided for @widget_cfg_style_card.
  ///
  /// In en, this message translates to:
  /// **'Card'**
  String get widget_cfg_style_card;

  /// No description provided for @widget_cfg_all_habits.
  ///
  /// In en, this message translates to:
  /// **'All habits'**
  String get widget_cfg_all_habits;

  /// No description provided for @widget_cfg_show_habits.
  ///
  /// In en, this message translates to:
  /// **'Habits to show'**
  String get widget_cfg_show_habits;

  /// No description provided for @widget_cfg_show_habits_hint.
  ///
  /// In en, this message translates to:
  /// **'Pick one or more. With one habit, the summary shows its streak.'**
  String get widget_cfg_show_habits_hint;

  /// No description provided for @widget_cfg_save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get widget_cfg_save;

  /// No description provided for @widget_cfg_add.
  ///
  /// In en, this message translates to:
  /// **'Add widget'**
  String get widget_cfg_add;

  /// No description provided for @widget_cfg_reset.
  ///
  /// In en, this message translates to:
  /// **'Reset to default'**
  String get widget_cfg_reset;

  /// No description provided for @widget_cfg_hue.
  ///
  /// In en, this message translates to:
  /// **'Hue'**
  String get widget_cfg_hue;

  /// No description provided for @widget_cfg_saturation.
  ///
  /// In en, this message translates to:
  /// **'Saturation'**
  String get widget_cfg_saturation;

  /// No description provided for @widget_cfg_brightness.
  ///
  /// In en, this message translates to:
  /// **'Brightness'**
  String get widget_cfg_brightness;

  /// No description provided for @widget_demo_read.
  ///
  /// In en, this message translates to:
  /// **'Read'**
  String get widget_demo_read;

  /// No description provided for @widget_demo_run.
  ///
  /// In en, this message translates to:
  /// **'Run'**
  String get widget_demo_run;

  /// No description provided for @widget_demo_water.
  ///
  /// In en, this message translates to:
  /// **'Water'**
  String get widget_demo_water;

  /// No description provided for @notif_streak.
  ///
  /// In en, this message translates to:
  /// **'🔥 {streak} day streak'**
  String notif_streak(String streak);

  /// No description provided for @notif_streak_week.
  ///
  /// In en, this message translates to:
  /// **'🔥 {streak} week streak'**
  String notif_streak_week(String streak);

  /// No description provided for @notif_streak_month.
  ///
  /// In en, this message translates to:
  /// **'🔥 {streak} month streak'**
  String notif_streak_month(String streak);

  /// No description provided for @notif_action_done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get notif_action_done;

  /// No description provided for @notif_action_snooze.
  ///
  /// In en, this message translates to:
  /// **'Snooze'**
  String get notif_action_snooze;

  /// No description provided for @notif_action_add.
  ///
  /// In en, this message translates to:
  /// **'Add amount'**
  String get notif_action_add;

  /// No description provided for @notif_action_add_hint.
  ///
  /// In en, this message translates to:
  /// **'How much?'**
  String get notif_action_add_hint;

  /// No description provided for @snooze_duration.
  ///
  /// In en, this message translates to:
  /// **'Snooze for'**
  String get snooze_duration;

  /// No description provided for @snooze_custom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get snooze_custom;

  /// No description provided for @snooze_custom_hint.
  ///
  /// In en, this message translates to:
  /// **'Minutes'**
  String get snooze_custom_hint;

  /// No description provided for @minutes_short.
  ///
  /// In en, this message translates to:
  /// **'{value} min'**
  String minutes_short(String value);

  /// Screen reader label for the button that logs a habit
  ///
  /// In en, this message translates to:
  /// **'Mark {name} as done'**
  String a11y_mark_done(String name);

  /// Screen reader label for the button that undoes a habit
  ///
  /// In en, this message translates to:
  /// **'Mark {name} as not done'**
  String a11y_mark_not_done(String name);

  /// Screen reader label for the button that adds progress to a quantitative habit
  ///
  /// In en, this message translates to:
  /// **'Add to {name}'**
  String a11y_add_amount(String name);

  /// Screen reader label for the button that logs a relapse on a habit to avoid
  ///
  /// In en, this message translates to:
  /// **'Log a relapse for {name}'**
  String a11y_log_relapse(String name);

  /// Screen reader label for the button that removes today's relapse
  ///
  /// In en, this message translates to:
  /// **'Clear today\'s relapse for {name}'**
  String a11y_clear_relapse(String name);

  /// Screen reader state of a day that has not been logged
  ///
  /// In en, this message translates to:
  /// **'not done'**
  String get a11y_not_done;

  /// No description provided for @a11y_previous_week.
  ///
  /// In en, this message translates to:
  /// **'Previous week'**
  String get a11y_previous_week;

  /// No description provided for @a11y_next_week.
  ///
  /// In en, this message translates to:
  /// **'Next week'**
  String get a11y_next_week;

  /// No description provided for @a11y_previous_month.
  ///
  /// In en, this message translates to:
  /// **'Previous month'**
  String get a11y_previous_month;

  /// No description provided for @a11y_next_month.
  ///
  /// In en, this message translates to:
  /// **'Next month'**
  String get a11y_next_month;

  /// No description provided for @plan_show_month.
  ///
  /// In en, this message translates to:
  /// **'Show the whole month'**
  String get plan_show_month;

  /// No description provided for @plan_show_week.
  ///
  /// In en, this message translates to:
  /// **'Show one week'**
  String get plan_show_week;

  /// Screen reader label for the plus button of a number stepper
  ///
  /// In en, this message translates to:
  /// **'Increase'**
  String get a11y_increase;

  /// Screen reader label for the minus button of a number stepper
  ///
  /// In en, this message translates to:
  /// **'Decrease'**
  String get a11y_decrease;

  /// Screen reader label for a colour swatch in the picker
  ///
  /// In en, this message translates to:
  /// **'Pick a colour'**
  String get a11y_pick_color;

  /// No description provided for @period_this_week.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get period_this_week;

  /// No description provided for @tracked_week.
  ///
  /// In en, this message translates to:
  /// **'{n} this week'**
  String tracked_week(int n);

  /// No description provided for @tracked_month.
  ///
  /// In en, this message translates to:
  /// **'{n} this month'**
  String tracked_month(int n);

  /// No description provided for @tracked_year.
  ///
  /// In en, this message translates to:
  /// **'{n} this year'**
  String tracked_year(int n);

  /// No description provided for @period_last_week.
  ///
  /// In en, this message translates to:
  /// **'Last week'**
  String get period_last_week;

  /// No description provided for @period_this_month.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get period_this_month;

  /// No description provided for @period_last_month.
  ///
  /// In en, this message translates to:
  /// **'Last month'**
  String get period_last_month;

  /// No description provided for @period_this_year.
  ///
  /// In en, this message translates to:
  /// **'This year'**
  String get period_this_year;

  /// No description provided for @period_all_time.
  ///
  /// In en, this message translates to:
  /// **'All time'**
  String get period_all_time;

  /// No description provided for @times_completed.
  ///
  /// In en, this message translates to:
  /// **'Times completed'**
  String get times_completed;

  /// No description provided for @period_last_year.
  ///
  /// In en, this message translates to:
  /// **'Last year'**
  String get period_last_year;

  /// No description provided for @period_week_of.
  ///
  /// In en, this message translates to:
  /// **'Week of {date}'**
  String period_week_of(String date);

  /// No description provided for @notes_all.
  ///
  /// In en, this message translates to:
  /// **'All notes'**
  String get notes_all;

  /// No description provided for @notes_empty_all.
  ///
  /// In en, this message translates to:
  /// **'No notes yet'**
  String get notes_empty_all;

  /// No description provided for @quant_preset_time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get quant_preset_time;

  /// No description provided for @style_express.
  ///
  /// In en, this message translates to:
  /// **'Express'**
  String get style_express;

  /// No description provided for @style_express_desc.
  ///
  /// In en, this message translates to:
  /// **'Rounded shapes, springy motion and a wider typeface.'**
  String get style_express_desc;

  /// No description provided for @celebration_none.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get celebration_none;

  /// No description provided for @quant_mode_add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get quant_mode_add;

  /// No description provided for @quant_mode_replace.
  ///
  /// In en, this message translates to:
  /// **'Replace'**
  String get quant_mode_replace;

  /// No description provided for @quant_add_title.
  ///
  /// In en, this message translates to:
  /// **'Add amount'**
  String get quant_add_title;

  /// No description provided for @pane_hint.
  ///
  /// In en, this message translates to:
  /// **'Open something from the list to see it here'**
  String get pane_hint;

  /// No description provided for @average_short.
  ///
  /// In en, this message translates to:
  /// **'Avg'**
  String get average_short;

  /// No description provided for @gamification.
  ///
  /// In en, this message translates to:
  /// **'Gamification'**
  String get gamification;

  /// No description provided for @gamification_beta.
  ///
  /// In en, this message translates to:
  /// **'Gamification (beta)'**
  String get gamification_beta;

  /// No description provided for @last_check.
  ///
  /// In en, this message translates to:
  /// **'Last logged'**
  String get last_check;

  /// No description provided for @check_history.
  ///
  /// In en, this message translates to:
  /// **'Check history'**
  String get check_history;

  /// No description provided for @check_history_sub.
  ///
  /// In en, this message translates to:
  /// **'{count} days checked off'**
  String check_history_sub(String count);

  /// No description provided for @check_never.
  ///
  /// In en, this message translates to:
  /// **'Never'**
  String get check_never;

  /// No description provided for @check_no_time.
  ///
  /// In en, this message translates to:
  /// **'no time saved'**
  String get check_no_time;

  /// No description provided for @heatmap_rolling.
  ///
  /// In en, this message translates to:
  /// **'Last 12 months'**
  String get heatmap_rolling;

  /// No description provided for @heatmap_rolling_sub.
  ///
  /// In en, this message translates to:
  /// **'The yearly grid ends today instead of on 31 December'**
  String get heatmap_rolling_sub;

  /// No description provided for @check_marks.
  ///
  /// In en, this message translates to:
  /// **'{count} marks'**
  String check_marks(String count);

  /// No description provided for @today_progress_option.
  ///
  /// In en, this message translates to:
  /// **'Progress on Today'**
  String get today_progress_option;

  /// No description provided for @today_progress_option_sub.
  ///
  /// In en, this message translates to:
  /// **'The day\'s ring and the strength bar on each habit'**
  String get today_progress_option_sub;

  /// No description provided for @quiet_when_done.
  ///
  /// In en, this message translates to:
  /// **'Quiet once done'**
  String get quiet_when_done;

  /// No description provided for @quiet_when_done_sub.
  ///
  /// In en, this message translates to:
  /// **'No more reminders today for a habit you already completed'**
  String get quiet_when_done_sub;

  /// No description provided for @plan_tab.
  ///
  /// In en, this message translates to:
  /// **'Plan'**
  String get plan_tab;

  /// No description provided for @difficulty.
  ///
  /// In en, this message translates to:
  /// **'Difficulty'**
  String get difficulty;

  /// No description provided for @difficulty_hint.
  ///
  /// In en, this message translates to:
  /// **'Harder habits count for more in the day\'s progress'**
  String get difficulty_hint;

  /// No description provided for @difficulty_easy.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get difficulty_easy;

  /// No description provided for @difficulty_medium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get difficulty_medium;

  /// No description provided for @difficulty_hard.
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get difficulty_hard;

  /// No description provided for @pin_lock.
  ///
  /// In en, this message translates to:
  /// **'PIN code'**
  String get pin_lock;

  /// No description provided for @pin_lock_sub.
  ///
  /// In en, this message translates to:
  /// **'Your own code, separate from the phone\'s lock'**
  String get pin_lock_sub;

  /// No description provided for @pin_choose.
  ///
  /// In en, this message translates to:
  /// **'Choose a PIN'**
  String get pin_choose;

  /// No description provided for @pin_choose_sub.
  ///
  /// In en, this message translates to:
  /// **'4 to 8 digits'**
  String get pin_choose_sub;

  /// No description provided for @pin_repeat.
  ///
  /// In en, this message translates to:
  /// **'Enter it again'**
  String get pin_repeat;

  /// No description provided for @pin_mismatch.
  ///
  /// In en, this message translates to:
  /// **'They don\'t match. Start again.'**
  String get pin_mismatch;

  /// No description provided for @pin_enter.
  ///
  /// In en, this message translates to:
  /// **'Enter your PIN'**
  String get pin_enter;

  /// No description provided for @pin_wrong.
  ///
  /// In en, this message translates to:
  /// **'Wrong PIN'**
  String get pin_wrong;

  /// No description provided for @pin_wait.
  ///
  /// In en, this message translates to:
  /// **'Too many tries. Wait {seconds} s'**
  String pin_wait(String seconds);

  /// No description provided for @pin_recovery_title.
  ///
  /// In en, this message translates to:
  /// **'Your recovery code'**
  String get pin_recovery_title;

  /// No description provided for @pin_recovery_body.
  ///
  /// In en, this message translates to:
  /// **'If you forget the PIN, this code opens Soul State and turns the lock off. Keep it somewhere safe: it won\'t be shown again.'**
  String get pin_recovery_body;

  /// No description provided for @pin_copy.
  ///
  /// In en, this message translates to:
  /// **'Copy code'**
  String get pin_copy;

  /// No description provided for @pin_copied.
  ///
  /// In en, this message translates to:
  /// **'Code copied'**
  String get pin_copied;

  /// No description provided for @pin_forgot.
  ///
  /// In en, this message translates to:
  /// **'Forgot your PIN?'**
  String get pin_forgot;

  /// No description provided for @pin_recovery_hint.
  ///
  /// In en, this message translates to:
  /// **'Recovery code'**
  String get pin_recovery_hint;

  /// No description provided for @pin_recovery_wrong.
  ///
  /// In en, this message translates to:
  /// **'That code isn\'t right'**
  String get pin_recovery_wrong;

  /// No description provided for @pin_recovered.
  ///
  /// In en, this message translates to:
  /// **'Lock turned off. You can set a new PIN in Settings.'**
  String get pin_recovered;

  /// No description provided for @pin_change.
  ///
  /// In en, this message translates to:
  /// **'Change PIN'**
  String get pin_change;

  /// No description provided for @pin_remove.
  ///
  /// In en, this message translates to:
  /// **'Remove PIN'**
  String get pin_remove;

  /// No description provided for @pin_fingerprint.
  ///
  /// In en, this message translates to:
  /// **'Use fingerprint'**
  String get pin_fingerprint;

  /// No description provided for @app_lock_method.
  ///
  /// In en, this message translates to:
  /// **'Unlock with'**
  String get app_lock_method;

  /// No description provided for @app_lock_biometric.
  ///
  /// In en, this message translates to:
  /// **'Fingerprint or face'**
  String get app_lock_biometric;

  /// No description provided for @difficulty_option.
  ///
  /// In en, this message translates to:
  /// **'Habit difficulty'**
  String get difficulty_option;

  /// No description provided for @difficulty_option_sub.
  ///
  /// In en, this message translates to:
  /// **'Let harder habits count for more in the day\'s progress'**
  String get difficulty_option_sub;

  /// No description provided for @todo_save_another.
  ///
  /// In en, this message translates to:
  /// **'Save and add another'**
  String get todo_save_another;

  /// No description provided for @todo_add_subtask.
  ///
  /// In en, this message translates to:
  /// **'Add subtask'**
  String get todo_add_subtask;

  /// No description provided for @pin_paste.
  ///
  /// In en, this message translates to:
  /// **'Paste code'**
  String get pin_paste;

  /// No description provided for @quant_preset_steps.
  ///
  /// In en, this message translates to:
  /// **'Steps'**
  String get quant_preset_steps;

  /// No description provided for @health_steps_denied.
  ///
  /// In en, this message translates to:
  /// **'Soul State can\'t read your steps without permission'**
  String get health_steps_denied;

  /// No description provided for @health_permission.
  ///
  /// In en, this message translates to:
  /// **'Permission'**
  String get health_permission;

  /// No description provided for @health_unit_steps.
  ///
  /// In en, this message translates to:
  /// **'steps'**
  String get health_unit_steps;

  /// No description provided for @health_intro.
  ///
  /// In en, this message translates to:
  /// **'Soul State only reads your step count, so your step habits fill in by themselves.'**
  String get health_intro;

  /// No description provided for @health_point_read.
  ///
  /// In en, this message translates to:
  /// **'It only reads steps. It never reads anything else and never writes to Health Connect.'**
  String get health_point_read;

  /// No description provided for @health_point_local.
  ///
  /// In en, this message translates to:
  /// **'Your steps stay on your phone. Soul State never connects to the internet.'**
  String get health_point_local;

  /// No description provided for @health_point_off.
  ///
  /// In en, this message translates to:
  /// **'You can turn it off at any time, in the habit or in Health Connect.'**
  String get health_point_off;

  /// No description provided for @health_manage.
  ///
  /// In en, this message translates to:
  /// **'Manage permission'**
  String get health_manage;

  /// No description provided for @performance.
  ///
  /// In en, this message translates to:
  /// **'Performance'**
  String get performance;

  /// No description provided for @performance_sub.
  ///
  /// In en, this message translates to:
  /// **'Lighter app for older or low-end phones'**
  String get performance_sub;

  /// No description provided for @glass_effects.
  ///
  /// In en, this message translates to:
  /// **'Glass effects'**
  String get glass_effects;

  /// No description provided for @glass_effects_sub.
  ///
  /// In en, this message translates to:
  /// **'Blur behind the bar and at the screen edges. It\'s what weighs the most'**
  String get glass_effects_sub;

  /// No description provided for @animations.
  ///
  /// In en, this message translates to:
  /// **'Animations'**
  String get animations;

  /// No description provided for @animations_sub.
  ///
  /// In en, this message translates to:
  /// **'Entrances, page changes and moving text'**
  String get animations_sub;

  /// No description provided for @widgets_sub.
  ///
  /// In en, this message translates to:
  /// **'Widget style, for phones without the widget editor'**
  String get widgets_sub;

  /// No description provided for @widgets_hint.
  ///
  /// In en, this message translates to:
  /// **'If your home screen doesn\'t open the editor when you add or hold a widget, change its style here. It applies to every widget of that type that wasn\'t customized on its own.'**
  String get widgets_hint;

  /// No description provided for @widget_kind_habit.
  ///
  /// In en, this message translates to:
  /// **'Habits'**
  String get widget_kind_habit;

  /// No description provided for @widget_kind_today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get widget_kind_today;

  /// No description provided for @widget_kind_stats.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get widget_kind_stats;

  /// No description provided for @widget_kind_heatmap.
  ///
  /// In en, this message translates to:
  /// **'Heatmap'**
  String get widget_kind_heatmap;

  /// No description provided for @widget_kind_todos.
  ///
  /// In en, this message translates to:
  /// **'To-do'**
  String get widget_kind_todos;

  /// No description provided for @today_view.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get today_view;

  /// No description provided for @avoid_track_spent.
  ///
  /// In en, this message translates to:
  /// **'Log what you spend'**
  String get avoid_track_spent;

  /// No description provided for @avoid_track_spent_sub.
  ///
  /// In en, this message translates to:
  /// **'When you relapse, note how much it cost you. The cost per day is filled in for you'**
  String get avoid_track_spent_sub;

  /// No description provided for @clean_goal.
  ///
  /// In en, this message translates to:
  /// **'Clean days goal'**
  String get clean_goal;

  /// No description provided for @clean_goal_sub.
  ///
  /// In en, this message translates to:
  /// **'Pick how many days in a row you want to hold out'**
  String get clean_goal_sub;

  /// No description provided for @clean_goal_left.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day to go} other{{count} days to go}}'**
  String clean_goal_left(int count);

  /// No description provided for @clean_goal_reached.
  ///
  /// In en, this message translates to:
  /// **'Goal reached'**
  String get clean_goal_reached;

  /// No description provided for @clean_goal_again.
  ///
  /// In en, this message translates to:
  /// **'Your streak keeps going. Keep it up'**
  String get clean_goal_again;

  /// No description provided for @clean_goal_of.
  ///
  /// In en, this message translates to:
  /// **'of {goal}'**
  String clean_goal_of(int goal);

  /// No description provided for @relapse_spent.
  ///
  /// In en, this message translates to:
  /// **'Spent on this relapse'**
  String get relapse_spent;

  /// No description provided for @money_spent.
  ///
  /// In en, this message translates to:
  /// **'Money spent'**
  String get money_spent;

  /// No description provided for @avoid_month.
  ///
  /// In en, this message translates to:
  /// **'Month summary'**
  String get avoid_month;

  /// No description provided for @avoid_by_month.
  ///
  /// In en, this message translates to:
  /// **'Relapses by month'**
  String get avoid_by_month;

  /// No description provided for @avoid_balance.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get avoid_balance;

  /// No description provided for @total_goal.
  ///
  /// In en, this message translates to:
  /// **'Total goal'**
  String get total_goal;

  /// No description provided for @total_goal_sub.
  ///
  /// In en, this message translates to:
  /// **'A target for the whole habit, like 1000 pages or 50 times'**
  String get total_goal_sub;

  /// No description provided for @total_goal_left.
  ///
  /// In en, this message translates to:
  /// **'{amount} to go'**
  String total_goal_left(String amount);

  /// No description provided for @total_goal_of.
  ///
  /// In en, this message translates to:
  /// **'of {amount}'**
  String total_goal_of(String amount);

  /// No description provided for @book.
  ///
  /// In en, this message translates to:
  /// **'Book'**
  String get book;

  /// No description provided for @book_pages.
  ///
  /// In en, this message translates to:
  /// **'Pages in the book'**
  String get book_pages;

  /// No description provided for @book_pages_sub.
  ///
  /// In en, this message translates to:
  /// **'Counts from today. On the last page it adds a read and starts over'**
  String get book_pages_sub;

  /// No description provided for @book_new.
  ///
  /// In en, this message translates to:
  /// **'New book'**
  String get book_new;

  /// No description provided for @book_reads.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{First read} =1{Read once} other{Read {count} times}}'**
  String book_reads(int count);

  /// No description provided for @book_read_number.
  ///
  /// In en, this message translates to:
  /// **'Read {number}'**
  String book_read_number(int number);

  /// No description provided for @book_since.
  ///
  /// In en, this message translates to:
  /// **'Since {day}'**
  String book_since(String day);

  /// No description provided for @book_reading_now.
  ///
  /// In en, this message translates to:
  /// **'Reading'**
  String get book_reading_now;

  /// No description provided for @book_page.
  ///
  /// In en, this message translates to:
  /// **'Page {page} of {pages}'**
  String book_page(String page, String pages);

  /// No description provided for @count_times.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 time} other{{count} times}}'**
  String count_times(int count);

  /// No description provided for @money.
  ///
  /// In en, this message translates to:
  /// **'Money'**
  String get money;

  /// No description provided for @money_enable_sub.
  ///
  /// In en, this message translates to:
  /// **'Track income and expenses next to your habits'**
  String get money_enable_sub;

  /// No description provided for @money_overview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get money_overview;

  /// No description provided for @money_analysis.
  ///
  /// In en, this message translates to:
  /// **'Analysis'**
  String get money_analysis;

  /// No description provided for @money_calendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get money_calendar;

  /// No description provided for @money_more.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get money_more;

  /// No description provided for @money_add.
  ///
  /// In en, this message translates to:
  /// **'Add transaction'**
  String get money_add;

  /// No description provided for @money_edit.
  ///
  /// In en, this message translates to:
  /// **'Edit transaction'**
  String get money_edit;

  /// No description provided for @money_expense.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get money_expense;

  /// No description provided for @money_income.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get money_income;

  /// No description provided for @money_balance.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get money_balance;

  /// No description provided for @money_quarter.
  ///
  /// In en, this message translates to:
  /// **'Quarter'**
  String get money_quarter;

  /// No description provided for @money_note.
  ///
  /// In en, this message translates to:
  /// **'Add a note (optional)'**
  String get money_note;

  /// No description provided for @money_choose_category.
  ///
  /// In en, this message translates to:
  /// **'Choose a category'**
  String get money_choose_category;

  /// No description provided for @money_uncategorized.
  ///
  /// In en, this message translates to:
  /// **'Uncategorized'**
  String get money_uncategorized;

  /// No description provided for @money_empty_title.
  ///
  /// In en, this message translates to:
  /// **'No transactions yet'**
  String get money_empty_title;

  /// No description provided for @money_empty_month.
  ///
  /// In en, this message translates to:
  /// **'Nothing recorded this month'**
  String get money_empty_month;

  /// No description provided for @money_empty_body.
  ///
  /// In en, this message translates to:
  /// **'Log what you earn and spend to see where your money goes.'**
  String get money_empty_body;

  /// No description provided for @money_empty_day.
  ///
  /// In en, this message translates to:
  /// **'No transactions this day. Tap to add one.'**
  String get money_empty_day;

  /// No description provided for @money_no_data.
  ///
  /// In en, this message translates to:
  /// **'Nothing to show for this period'**
  String get money_no_data;

  /// No description provided for @money_deleted.
  ///
  /// In en, this message translates to:
  /// **'Transaction deleted'**
  String get money_deleted;

  /// No description provided for @money_delete_title.
  ///
  /// In en, this message translates to:
  /// **'Delete transaction?'**
  String get money_delete_title;

  /// No description provided for @money_delete_body.
  ///
  /// In en, this message translates to:
  /// **'This transaction will be removed.'**
  String get money_delete_body;

  /// No description provided for @money_categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get money_categories;

  /// No description provided for @money_manage_categories.
  ///
  /// In en, this message translates to:
  /// **'Manage categories'**
  String get money_manage_categories;

  /// No description provided for @money_no_categories.
  ///
  /// In en, this message translates to:
  /// **'No categories yet. Tap + to create one.'**
  String get money_no_categories;

  /// No description provided for @money_add_sub.
  ///
  /// In en, this message translates to:
  /// **'Add sub-category'**
  String get money_add_sub;

  /// No description provided for @money_group.
  ///
  /// In en, this message translates to:
  /// **'Group'**
  String get money_group;

  /// No description provided for @money_top_level.
  ///
  /// In en, this message translates to:
  /// **'No group'**
  String get money_top_level;

  /// No description provided for @money_delete_category_title.
  ///
  /// In en, this message translates to:
  /// **'Delete category?'**
  String get money_delete_category_title;

  /// No description provided for @money_delete_category_unused.
  ///
  /// In en, this message translates to:
  /// **'No transaction uses this category.'**
  String get money_delete_category_unused;

  /// No description provided for @money_reset_categories.
  ///
  /// In en, this message translates to:
  /// **'Reset categories'**
  String get money_reset_categories;

  /// No description provided for @money_reset_categories_body.
  ///
  /// In en, this message translates to:
  /// **'Replace all categories with the defaults. Your transactions are kept.'**
  String get money_reset_categories_body;

  /// No description provided for @money_reset_action.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get money_reset_action;

  /// No description provided for @money_reset_done.
  ///
  /// In en, this message translates to:
  /// **'Categories reset'**
  String get money_reset_done;

  /// No description provided for @money_delete_all.
  ///
  /// In en, this message translates to:
  /// **'Delete all transactions'**
  String get money_delete_all;

  /// No description provided for @money_delete_all_body.
  ///
  /// In en, this message translates to:
  /// **'Every income and expense you logged will be permanently removed. Your habits, to-dos and categories are not affected.'**
  String get money_delete_all_body;

  /// No description provided for @money_delete_all_done.
  ///
  /// In en, this message translates to:
  /// **'All transactions deleted'**
  String get money_delete_all_done;

  /// No description provided for @money_transactions_count.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 transaction} other{{count} transactions}}'**
  String money_transactions_count(int count);

  /// No description provided for @money_delete_category_used.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 transaction uses it and will keep its name.} other{{count} transactions use it and will keep its name.}}'**
  String money_delete_category_used(int count);

  /// No description provided for @nav_home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get nav_home;

  /// No description provided for @nav_habits.
  ///
  /// In en, this message translates to:
  /// **'Habits'**
  String get nav_habits;

  /// No description provided for @nav_meals.
  ///
  /// In en, this message translates to:
  /// **'Meals'**
  String get nav_meals;

  /// No description provided for @vault_title.
  ///
  /// In en, this message translates to:
  /// **'Soul State Vault'**
  String get vault_title;

  /// No description provided for @vault_desc.
  ///
  /// In en, this message translates to:
  /// **'Choose where your habits, tracking data, and tasks are stored on your device in your Soul State Vault.'**
  String get vault_desc;

  /// No description provided for @vault_open_title.
  ///
  /// In en, this message translates to:
  /// **'Open Existing Vault'**
  String get vault_open_title;

  /// No description provided for @vault_open_desc.
  ///
  /// In en, this message translates to:
  /// **'Open an existing folder where your Soul State Vault data is located to view all habits and entries.'**
  String get vault_open_desc;

  /// No description provided for @vault_open_button.
  ///
  /// In en, this message translates to:
  /// **'Open Folder'**
  String get vault_open_button;

  /// No description provided for @vault_create_title.
  ///
  /// In en, this message translates to:
  /// **'Create New Vault'**
  String get vault_create_title;

  /// No description provided for @vault_create_desc.
  ///
  /// In en, this message translates to:
  /// **'Select a folder on your storage to create a fresh vault. All tracker data will store there as markdown & JSON.'**
  String get vault_create_desc;

  /// No description provided for @vault_create_button.
  ///
  /// In en, this message translates to:
  /// **'Create Vault'**
  String get vault_create_button;

  /// No description provided for @vault_created_success.
  ///
  /// In en, this message translates to:
  /// **'Vault created successfully'**
  String get vault_created_success;

  /// No description provided for @vault_connected.
  ///
  /// In en, this message translates to:
  /// **'Connected to existing vault'**
  String get vault_connected;

  /// No description provided for @spent_today.
  ///
  /// In en, this message translates to:
  /// **'SPENT TODAY'**
  String get spent_today;

  /// No description provided for @nutrition.
  ///
  /// In en, this message translates to:
  /// **'NUTRITION'**
  String get nutrition;

  /// No description provided for @no_spending_yet.
  ///
  /// In en, this message translates to:
  /// **'No spending yet'**
  String get no_spending_yet;

  /// No description provided for @add_action.
  ///
  /// In en, this message translates to:
  /// **'+ Add'**
  String get add_action;

  /// No description provided for @log_action.
  ///
  /// In en, this message translates to:
  /// **'+ Log'**
  String get log_action;

  /// No description provided for @buy_me_a_coffee.
  ///
  /// In en, this message translates to:
  /// **'Buy Me a Coffee'**
  String get buy_me_a_coffee;

  /// No description provided for @dialog_select_new_vault.
  ///
  /// In en, this message translates to:
  /// **'Select folder for new vault'**
  String get dialog_select_new_vault;

  /// No description provided for @dialog_select_existing_vault.
  ///
  /// In en, this message translates to:
  /// **'Select existing vault folder'**
  String get dialog_select_existing_vault;

  /// No description provided for @vault_habits_loaded.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 habit loaded from vault} other{{count} habits loaded from vault}}'**
  String vault_habits_loaded(int count);

  /// No description provided for @vault_failed.
  ///
  /// In en, this message translates to:
  /// **'Failed to setup vault: {error}'**
  String vault_failed(String error);

  /// No description provided for @sync_with_s3.
  ///
  /// In en, this message translates to:
  /// **'Sync with S3'**
  String get sync_with_s3;

  /// No description provided for @s3_synced_success.
  ///
  /// In en, this message translates to:
  /// **'Synced with S3'**
  String get s3_synced_success;

  /// No description provided for @s3_synced_changes.
  ///
  /// In en, this message translates to:
  /// **'Synced with S3 (cloud changes merged)'**
  String get s3_synced_changes;

  /// No description provided for @s3_sync_error.
  ///
  /// In en, this message translates to:
  /// **'S3 sync error: {error}'**
  String s3_sync_error(String error);

  /// No description provided for @habits_overview.
  ///
  /// In en, this message translates to:
  /// **'Habits Overview'**
  String get habits_overview;

  /// No description provided for @tracker.
  ///
  /// In en, this message translates to:
  /// **'Tracker'**
  String get tracker;

  /// No description provided for @habits_completed_today.
  ///
  /// In en, this message translates to:
  /// **'{completed} of {total} completed today'**
  String habits_completed_today(int completed, int total);

  /// No description provided for @todo_tasks.
  ///
  /// In en, this message translates to:
  /// **'To-Do Tasks'**
  String get todo_tasks;

  /// No description provided for @view_all.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get view_all;

  /// No description provided for @all_tasks_completed.
  ///
  /// In en, this message translates to:
  /// **'All tasks completed! 🎉'**
  String get all_tasks_completed;

  /// No description provided for @tasks_remaining.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 task remaining} other{{count} tasks remaining}}'**
  String tasks_remaining(int count);

  /// No description provided for @tasks_pending.
  ///
  /// In en, this message translates to:
  /// **'{count} pending'**
  String tasks_pending(int count);

  /// No description provided for @transactions_count.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 transaction} other{{count} transactions}}'**
  String transactions_count(int count);

  /// No description provided for @zero_meals.
  ///
  /// In en, this message translates to:
  /// **'0 Meals'**
  String get zero_meals;

  /// No description provided for @clean_pct.
  ///
  /// In en, this message translates to:
  /// **'{pct}% Clean'**
  String clean_pct(int pct);

  /// No description provided for @tap_to_log_fuel.
  ///
  /// In en, this message translates to:
  /// **'Tap + to log fuel'**
  String get tap_to_log_fuel;

  /// No description provided for @today_nutrition.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Nutrition'**
  String get today_nutrition;

  /// No description provided for @log_meal.
  ///
  /// In en, this message translates to:
  /// **'Log Meal'**
  String get log_meal;

  /// No description provided for @no_meals_today.
  ///
  /// In en, this message translates to:
  /// **'No meals logged yet today'**
  String get no_meals_today;

  /// No description provided for @tap_to_log_meals.
  ///
  /// In en, this message translates to:
  /// **'Tap to log breakfast, lunch, dinner, or snacks'**
  String get tap_to_log_meals;

  /// No description provided for @today_spending.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Spending'**
  String get today_spending;

  /// No description provided for @add_expense.
  ///
  /// In en, this message translates to:
  /// **'Add Expense'**
  String get add_expense;

  /// No description provided for @no_spending_today.
  ///
  /// In en, this message translates to:
  /// **'No expenses recorded today'**
  String get no_spending_today;

  /// No description provided for @tap_to_log_spending.
  ///
  /// In en, this message translates to:
  /// **'Tap to log a purchase or expense'**
  String get tap_to_log_spending;

  /// No description provided for @about_tagline.
  ///
  /// In en, this message translates to:
  /// **'Mindful habits, finances, and nourishment.'**
  String get about_tagline;

  /// No description provided for @about_story.
  ///
  /// In en, this message translates to:
  /// **'Soul State is an offline-first life operating system developed by Shanmugananthan. Crafted to empower mindful daily living, it brings habit tracking, financial records, and meal logging into one unified private space. Your data lives exclusively in your Soul State Vault on your device — free from ads, subscriptions, and tracking. Open source, with your privacy first.'**
  String get about_story;

  /// No description provided for @developed_by.
  ///
  /// In en, this message translates to:
  /// **'Developed by {author}'**
  String developed_by(String author);

  /// No description provided for @license_label.
  ///
  /// In en, this message translates to:
  /// **'Open Source • GPL-3.0 License'**
  String get license_label;

  /// No description provided for @schedule_reminder.
  ///
  /// In en, this message translates to:
  /// **'Schedule Reminder'**
  String get schedule_reminder;

  /// No description provided for @reminder_time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get reminder_time;

  /// No description provided for @reminder_date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get reminder_date;

  /// No description provided for @reminder_scheduled.
  ///
  /// In en, this message translates to:
  /// **'Reminder scheduled for {time}'**
  String reminder_scheduled(String time);

  /// No description provided for @reminder_pick_future.
  ///
  /// In en, this message translates to:
  /// **'Please pick a future date and time for the reminder.'**
  String get reminder_pick_future;

  /// No description provided for @reminder_in_15m.
  ///
  /// In en, this message translates to:
  /// **'+15 mins'**
  String get reminder_in_15m;

  /// No description provided for @reminder_in_1h.
  ///
  /// In en, this message translates to:
  /// **'+1 hour'**
  String get reminder_in_1h;

  /// No description provided for @reminder_tonight.
  ///
  /// In en, this message translates to:
  /// **'Tonight'**
  String get reminder_tonight;

  /// No description provided for @reminder_tomorrow_morning.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow 9 AM'**
  String get reminder_tomorrow_morning;

  /// No description provided for @delete_reminder.
  ///
  /// In en, this message translates to:
  /// **'Delete Reminder'**
  String get delete_reminder;

  /// No description provided for @open_as_task.
  ///
  /// In en, this message translates to:
  /// **'Open as full task'**
  String get open_as_task;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
