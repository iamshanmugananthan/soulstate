// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get app_tagline => 'Habit tracker';

  @override
  String get today => 'Today';

  @override
  String get stats => 'Stats';

  @override
  String get settings => 'Settings';

  @override
  String get new_label => 'New';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get discard_changes => 'Discard changes?';

  @override
  String get discard_changes_body =>
      'The changes you made to this habit will be lost.';

  @override
  String get discard => 'Discard';

  @override
  String get todo_discard_body =>
      'The changes you made to this to-do will be lost.';

  @override
  String get keep_editing => 'Keep editing';

  @override
  String get delete => 'Delete';

  @override
  String get good_morning => 'Good morning';

  @override
  String get good_afternoon => 'Good afternoon';

  @override
  String get good_evening => 'Good evening';

  @override
  String get no_habits_yet => 'No habits yet';

  @override
  String get all_done_today => 'All done today!';

  @override
  String x_of_y_completed(String done, String total) {
    return '$done of $total completed';
  }

  @override
  String get empty_title => 'Start your first streak';

  @override
  String get empty_body =>
      'Create a habit and tap a day to log it. Small steps, every day.';

  @override
  String get add_habit => 'Add habit';

  @override
  String get all => 'All';

  @override
  String get onb1_title => 'Build real streaks';

  @override
  String get onb1_body =>
      'Log a habit in a single tap and watch your momentum grow day after day.';

  @override
  String get onb2_title => 'Stay on track';

  @override
  String get onb2_body =>
      'Daily, weekly or monthly goals with smart reminders so nothing slips.';

  @override
  String get onb3_title => 'See your progress';

  @override
  String get onb3_body =>
      'Rich statistics and a yearly grid reveal exactly how far you have come.';

  @override
  String get skip => 'Skip';

  @override
  String get next => 'Next';

  @override
  String get get_started => 'Get started';

  @override
  String get onb_kicker => 'Welcome to';

  @override
  String get onb_blurb =>
      'Small daily check-ins that turn into habits you keep.';

  @override
  String get onb_free_title => 'Free, forever';

  @override
  String get onb_free_body => 'No ads, no subscriptions, no locked features.';

  @override
  String get onb_private_title => 'Private and offline';

  @override
  String get onb_private_body =>
      'Everything stays on your device. No account needed.';

  @override
  String get onb_yours_title => 'Your data is yours';

  @override
  String get onb_yours_body =>
      'Back it up or take it with you whenever you want.';

  @override
  String onb_step(int step, int total) {
    return 'Step $step of $total';
  }

  @override
  String get statistics => 'Statistics';

  @override
  String get done_today => 'Done today';

  @override
  String get best_streak => 'Best streak';

  @override
  String get active_habits => 'Active habits';

  @override
  String get total_logs => 'Total logs';

  @override
  String get last_7_days => 'Last 7 days';

  @override
  String get last_30_days => 'Last 30 days';

  @override
  String get your_habits => 'Your habits';

  @override
  String get stats_empty => 'Add habits to see your statistics';

  @override
  String get completion_rate_short => 'Consistency';

  @override
  String get completion_rate => 'Completion rate';

  @override
  String get appearance => 'Appearance';

  @override
  String get theme => 'Theme';

  @override
  String get system => 'System';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get week_starts_on => 'Week starts';

  @override
  String get mon => 'Mon';

  @override
  String get sat => 'Sat';

  @override
  String get sun => 'Sun';

  @override
  String get language => 'Language';

  @override
  String get data => 'Data';

  @override
  String get export_backup => 'Export backup';

  @override
  String get export_backup_sub => 'Save all habits to a file';

  @override
  String get auto_backup => 'Automatic backup';

  @override
  String get auto_backup_sub => 'Off';

  @override
  String get auto_backup_off => 'Off';

  @override
  String get auto_backup_daily => 'Every day';

  @override
  String get auto_backup_weekly => 'Every week';

  @override
  String get auto_backup_where =>
      'When you open the app, Soul State saves a full backup: a .zip with everything, photos and music included, and a .json. It also writes a readable copy you can open in any editor. The last few backups are kept.';

  @override
  String get auto_backup_folder => 'Folder';

  @override
  String get auto_backup_folder_default =>
      'Inside the app (erased if you uninstall it)';

  @override
  String get auto_backup_folder_set => 'Folder saved';

  @override
  String get auto_backup_folder_failed => 'That folder can\'t be written to';

  @override
  String get auto_backup_no_permission => 'Storage permission denied';

  @override
  String get auto_backup_run_now => 'Back up now';

  @override
  String get refresh_now => 'Refresh';

  @override
  String get refresh_now_sub =>
      'Bring in what your other devices left in the folder';

  @override
  String get data_folder => 'Data folder';

  @override
  String get data_folder_documents => 'Documents';

  @override
  String get data_folder_app => 'Next to the app';

  @override
  String get data_folder_pick => 'Choose a folder';

  @override
  String get data_folder_inside => 'Pick a folder outside the current one.';

  @override
  String get data_folder_taken =>
      'That folder already has Soul State data in it.';

  @override
  String get data_folder_denied => 'Soul State can\'t write to that folder.';

  @override
  String get data_folder_move_title => 'Move your data';

  @override
  String data_folder_move_body(String path) {
    return 'Soul State will close and move your data to $path. Open it again when it closes. If anything goes wrong, your data stays where it is.';
  }

  @override
  String get data_folder_move_confirm => 'Move and close';

  @override
  String get refresh_brought => 'Your habits are up to date';

  @override
  String get refresh_nothing => 'Nothing new in the folder';

  @override
  String get import_backup => 'Import backup';

  @override
  String get import_backup_sub => 'Restore habits from a file';

  @override
  String get import_from_app => 'Import from another app';

  @override
  String get import_from_app_sub => 'Loop Habit Tracker, HabitKit…';

  @override
  String import_from_app_done(int habits, int days, String source) {
    return 'Imported $habits habits ($days days) from $source';
  }

  @override
  String get import_failed => 'Couldn\'t import that file';

  @override
  String get about => 'About';

  @override
  String get backup_saved => 'Backup saved';

  @override
  String get export_cancelled => 'Export cancelled';

  @override
  String get habits_imported => 'Habits imported';

  @override
  String get new_habit => 'New habit';

  @override
  String get edit_habit => 'Edit habit';

  @override
  String get name => 'Name';

  @override
  String get name_hint => 'e.g. Morning run';

  @override
  String get description => 'Description';

  @override
  String get description_hint => 'Optional note';

  @override
  String get icon => 'Icon';

  @override
  String get color => 'Color';

  @override
  String get category => 'Category';

  @override
  String get category_health => 'Health';

  @override
  String get category_fitness => 'Fitness';

  @override
  String get category_mindfulness => 'Mindfulness';

  @override
  String get category_productivity => 'Productivity';

  @override
  String get category_learning => 'Learning';

  @override
  String get category_finance => 'Finance';

  @override
  String count_days(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '1 day',
    );
    return '$_temp0';
  }

  @override
  String count_weeks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count weeks',
      one: '1 week',
    );
    return '$_temp0';
  }

  @override
  String count_months(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count months',
      one: '1 month',
    );
    return '$_temp0';
  }

  @override
  String streak_unit_week(String count) {
    return '${count}w';
  }

  @override
  String streak_unit_month(String count) {
    return '${count}mo';
  }

  @override
  String get habit_kind => 'Habit type';

  @override
  String get kind_positive => 'Normal';

  @override
  String get kind_negative => 'Avoid';

  @override
  String get kind_quantitative => 'Amount';

  @override
  String get kind_locked_hint =>
      'Type can\'t be changed after creating the habit.';

  @override
  String get kind_negative_hint =>
      'Every day counts as clean by default — your streak grows on its own. Tap the check only if you slip; that day turns red and you can undo it.';

  @override
  String get cost_per_day => 'Cost per day';

  @override
  String get cost_note =>
      'Optional. Leave it empty if this habit does not cost money.';

  @override
  String get currency => 'Currency';

  @override
  String get currency_custom => 'Custom';

  @override
  String get currency_hint => 'Symbol or code';

  @override
  String get money_saved => 'Money saved';

  @override
  String get clean_days => 'Clean days';

  @override
  String get quant_preset_water => 'Water';

  @override
  String get quant_preset_reading => 'Reading';

  @override
  String get quant_preset_generic => 'Custom';

  @override
  String get quant_unit_hint => 'Unit (e.g. ml, pages, reps)';

  @override
  String get quant_unit_ml => 'ml';

  @override
  String get quant_unit_pages => 'pages';

  @override
  String get quant_edit_title => 'Today\'s amount';

  @override
  String get quant_daily_goal => 'Daily goal';

  @override
  String get quant_tap_amount => 'Amount per tap';

  @override
  String get quant_per_day => 'Amount per day';

  @override
  String get quant_average => 'Average per day';

  @override
  String get quant_logged_days => 'Days logged';

  @override
  String get quant_best_day => 'Best day';

  @override
  String get quant_goal_days => 'Goal reached';

  @override
  String get quant_stats_empty =>
      'Log an amount and it adds up here, even on the days you fall short of the goal.';

  @override
  String get frequency => 'Frequency';

  @override
  String get pick_one_day => 'Pick at least one day';

  @override
  String get reminder_habit_days => 'On the habit\'s days';

  @override
  String get reminder_habit_days_hint =>
      'It rings on the days the habit is due.';

  @override
  String get by_label => 'By label';

  @override
  String get tracking_hide => 'Hide just tracking';

  @override
  String get tracking_hide_sub => 'Habits you only track stay out of this list';

  @override
  String tracking_show(int count) {
    return 'Show just tracking ($count)';
  }

  @override
  String get daily => 'Daily';

  @override
  String get weekly => 'Weekly';

  @override
  String get monthly => 'Monthly';

  @override
  String get sched_days => 'Days';

  @override
  String get sched_interval => 'Interval';

  @override
  String times_per_week(String n) {
    return '$n times per week';
  }

  @override
  String times_per_month(String n) {
    return '$n times per month';
  }

  @override
  String freq_per_week_short(String n) {
    return '$n×/week';
  }

  @override
  String freq_per_month_short(String n) {
    return '$n×/month';
  }

  @override
  String get reminders => 'Reminders';

  @override
  String get reminders_ready_title => 'Reminders are on';

  @override
  String get reminders_ready_body => 'Soul State will remind you here.';

  @override
  String get add_reminder => 'Add reminder';

  @override
  String get reminder_sound => 'Sound';

  @override
  String get reminder_sound_default => 'Default';

  @override
  String get reminder_sound_hint =>
      'Tap a sound to hear it. The reminders of this habit will use it.';

  @override
  String get delete_habit => 'Delete habit';

  @override
  String get archive_habit => 'Archive habit';

  @override
  String get archive => 'Archive';

  @override
  String get share_friends => 'Share with a friend';

  @override
  String get share_friends_sub => 'Send them the app';

  @override
  String get share_friends_message =>
      'I\'m keeping my streaks alive with Soul State — a private, offline life tracker with habits, finances, and meals. Explore here: https://shanmugananthan.com';

  @override
  String get copy_message => 'Copy message';

  @override
  String get message_copied => 'Message copied';

  @override
  String get app_lock => 'App lock';

  @override
  String get app_lock_sub =>
      'Ask for your fingerprint or face to open Soul State';

  @override
  String get app_lock_unavailable => 'This phone has no biometrics set up';

  @override
  String get app_lock_failed => 'Couldn\'t verify it was you';

  @override
  String get app_lock_title => 'Soul State is locked';

  @override
  String get app_lock_unlock => 'Unlock';

  @override
  String get app_lock_delay => 'Lock after';

  @override
  String get app_lock_delay_instant => 'Immediately';

  @override
  String app_lock_delay_seconds(String value) {
    return '$value seconds';
  }

  @override
  String get note_photos => 'Photos';

  @override
  String get note_take_photo => 'Camera';

  @override
  String get note_pick_photo => 'Gallery';

  @override
  String get journey => 'Journey';

  @override
  String journey_sub(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count photos',
      one: '1 photo',
    );
    return '$_temp0';
  }

  @override
  String get journey_empty => 'No photos yet';

  @override
  String get journey_empty_sub => 'Add a photo to a note and it shows up here.';

  @override
  String archive_habit_body(String name) {
    return 'Move \"$name\" to the archive? Its history is kept and you can restore it from Settings.';
  }

  @override
  String get archived_habits => 'Archived habits';

  @override
  String get archived_habits_sub => 'Restore them or delete them for good';

  @override
  String get archived_empty => 'Nothing archived';

  @override
  String get archived_empty_sub =>
      'Habits you delete land here, with all their history.';

  @override
  String get restore => 'Restore';

  @override
  String get restored => 'Habit restored';

  @override
  String get delete_forever => 'Delete for good';

  @override
  String delete_forever_body(String name) {
    return 'Delete \"$name\" and all of its history? This cannot be undone.';
  }

  @override
  String get deleted_forever => 'Habit deleted';

  @override
  String get clear_progress => 'Clear progress';

  @override
  String get clear_progress_sub => 'History and notes';

  @override
  String get clear_progress_warning =>
      'This erases every logged day and note, but keeps your habits, their schedules and your settings. It cannot be undone unless you have a backup file to import afterwards.';

  @override
  String get clear_progress_confirm => 'Clear progress';

  @override
  String get clear_progress_done => 'Progress cleared';

  @override
  String get wipe_data => 'Erase all data';

  @override
  String get wipe_data_sub =>
      'Habits, tasks, meals, finances, notes and settings';

  @override
  String get wipe_data_warning =>
      'This erases all habits, tasks, meals, finances, notes and settings on this phone. It cannot be undone unless you have a backup file to import afterwards.';

  @override
  String get wipe_data_sure => 'Really erase everything?';

  @override
  String get wipe_data_sure_body =>
      'Last chance. Without a backup, this data is gone for good.';

  @override
  String get wipe_data_confirm => 'Erase everything';

  @override
  String get wipe_data_done => 'All data erased';

  @override
  String get day_start => 'Day starts';

  @override
  String get day_start_sub => 'Late nights still count for the day before';

  @override
  String get day_start_midnight => 'Midnight';

  @override
  String day_start_hour(String hour) {
    return '$hour:00 AM';
  }

  @override
  String get share_photo => 'Photo';

  @override
  String get share_stats_short => 'Stats';

  @override
  String get undo => 'Undo';

  @override
  String get habit_archived => 'Habit archived';

  @override
  String get duplicate_habit => 'Duplicate habit';

  @override
  String habit_duplicated(String name) {
    return '$name added';
  }

  @override
  String get share_blur => 'Blur';

  @override
  String delete_habit_body(String name) {
    return 'Delete \"$name\"? This cannot be undone.';
  }

  @override
  String get log_relapse_title => 'Log a relapse?';

  @override
  String log_relapse_body(String name) {
    return 'This breaks today\'s clean streak for \"$name\". You can undo it by tapping again.';
  }

  @override
  String get log_relapse_confirm => 'Yes, log it';

  @override
  String get permission_required => 'Notification permission is required';

  @override
  String get streaks => 'Streaks';

  @override
  String get activity => 'Activity';

  @override
  String get current => 'Current';

  @override
  String get best => 'Best';

  @override
  String get total => 'Total';

  @override
  String get relapses => 'Relapses';

  @override
  String get strength => 'Strength';

  @override
  String get week => 'Week';

  @override
  String get month => 'Month';

  @override
  String get year => 'Year';

  @override
  String get new_reminder => 'New reminder';

  @override
  String get edit_reminder => 'Edit reminder';

  @override
  String get days => 'Days';

  @override
  String get time => 'Time';

  @override
  String get save_reminder => 'Save reminder';

  @override
  String get select_one_day => 'Select at least one day';

  @override
  String get every_day => 'Every day';

  @override
  String get no_days => 'No days';

  @override
  String get repeat_hours => 'Repeat during the day';

  @override
  String get repeat_until => 'Until';

  @override
  String get end_of_day => 'End of the day';

  @override
  String every_n_hours(String n) {
    return 'Every $n h';
  }

  @override
  String get repeat_weekly => 'Specific days';

  @override
  String get repeat_interval => 'Every N days';

  @override
  String every_n_days(int n) {
    return 'Every $n days';
  }

  @override
  String every_n_weeks(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Every $n weeks',
      one: 'Every week',
    );
    return '$_temp0';
  }

  @override
  String every_n_months(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Every $n months',
      one: 'Every month',
    );
    return '$_temp0';
  }

  @override
  String get sched_unit_days => 'Days';

  @override
  String get sched_unit_weeks => 'Weeks';

  @override
  String get sched_unit_months => 'Months';

  @override
  String get todo_tags => 'Tags';

  @override
  String get todo_projects => 'Projects';

  @override
  String get todo_project => 'Project';

  @override
  String get todo_project_new => 'New project';

  @override
  String get todo_project_name => 'Project name';

  @override
  String get todo_project_edit => 'Edit project';

  @override
  String get todo_project_arrange => 'Rearrange';

  @override
  String get todo_project_arrange_hint =>
      'Drag the folders where you want them.';

  @override
  String get todo_project_pick => 'Pick a project';

  @override
  String get todo_project_none => 'No project';

  @override
  String get todo_project_delete_body =>
      'The project goes away. The tasks stay.';

  @override
  String get todo_tag => 'Tag';

  @override
  String get todo_tag_new => 'New tag';

  @override
  String get todo_tag_name => 'Tag name';

  @override
  String get todo_tag_edit => 'Edit tag';

  @override
  String get todo_tag_delete_body => 'The tag goes away. The tasks stay.';

  @override
  String get todo_tag_none => 'No tag';

  @override
  String get todo_tag_all => 'All';

  @override
  String get todo_tag_manage => 'Manage tags';

  @override
  String get todo_tag_empty_title => 'No tags yet';

  @override
  String get todo_tag_empty_body =>
      'Group tasks by project, place or whatever you like.';

  @override
  String get todo_tag_folders => 'Folders';

  @override
  String get todo_tag_list => 'List';

  @override
  String todo_tag_count(int n) {
    return '$n open';
  }

  @override
  String get todo_tag_icon => 'Icon';

  @override
  String get todo_tag_pick => 'Pick tags';

  @override
  String todo_tag_filtered(String name) {
    return 'Filtered by $name';
  }

  @override
  String get uncategorized => 'Uncategorized';

  @override
  String get more_icons => 'More icons';

  @override
  String get less_icons => 'Fewer icons';

  @override
  String get completions => 'Completions';

  @override
  String get completion_time => 'Completion time';

  @override
  String get current_streak => 'Current streak';

  @override
  String get days_active => 'Days active';

  @override
  String get completions_per_month => 'Completions / Month';

  @override
  String get overview => 'Overview';

  @override
  String get preferences => 'Preferences';

  @override
  String get support => 'Support';

  @override
  String get profile => 'Profile';

  @override
  String get about_app => 'Soul State';

  @override
  String get about_app_sub => 'Version, credits and source code';

  @override
  String get my_heatmap => 'My heatmap';

  @override
  String get my_heatmap_sub => 'Open the yearly activity grid';

  @override
  String get rate_github => 'Star on GitHub';

  @override
  String get rate_github_sub => 'Support the project with a star';

  @override
  String get buy_coffee => 'Buy me a coffee';

  @override
  String get buy_coffee_sub => 'Help keep the app free';

  @override
  String get view_source => 'View source on GitHub';

  @override
  String get about_title => 'Built for you. Free, forever.';

  @override
  String get about_footer => 'Made with ☕ and a lot of free time.';

  @override
  String get about_body =>
      'Soul State was born from a simple idea: a private, mindful life operating system that respects you.\n\nThis app is completely open source. Anyone can see exactly how it works, suggest improvements, or even build their own version. No black boxes. No surprises.\n\nYour privacy is total — everything stays on your phone. No accounts, no servers, no ads. Not a single byte leaves your device.\n\nNo limits. Create as many habits as you want. No subscriptions, no \"pro version\", no pop-ups asking you to pay. Ever.\n\nIf the app brings you something, you can support it with a star on GitHub or by buying me a coffee. But it is completely optional — the app is yours either way.';

  @override
  String get close => 'Close';

  @override
  String get no_data_yet => 'No data yet';

  @override
  String get import_question_body =>
      'Replace all your current habits with the backup, or merge them together?';

  @override
  String get import_replace => 'Replace all';

  @override
  String get import_merge => 'Merge';

  @override
  String get go => 'Go';

  @override
  String get quote_1 => 'Small steps, every day.';

  @override
  String get quote_2 => 'Consistency beats intensity.';

  @override
  String get quote_3 => 'Show up for yourself.';

  @override
  String get quote_4 => 'One day at a time.';

  @override
  String get quote_5 => 'Progress, not perfection.';

  @override
  String get quote_6 => 'Done is better than perfect.';

  @override
  String get quote_7 => 'Keep the streak alive.';

  @override
  String get quote_8 => 'Tiny habits, big change.';

  @override
  String get quote_9 => 'Trust the process.';

  @override
  String get quote_10 => 'Win the morning.';

  @override
  String get quote_11 => 'Discipline equals freedom.';

  @override
  String get quote_12 => 'Today counts.';

  @override
  String get just_tracking_option => 'Offer just tracking';

  @override
  String get just_tracking_option_sub =>
      'Adds the switch when you create a habit';

  @override
  String get just_tracking => 'Just tracking';

  @override
  String get just_tracking_sub =>
      'Keep its own grid and numbers, but leave it out of Progress and the day\'s count';

  @override
  String get no_goal => 'No daily goal';

  @override
  String get no_goal_sub =>
      'Just log the value, like your weight. Any amount marks the day.';

  @override
  String get any_amount => 'Any amount counts';

  @override
  String get any_amount_sub =>
      'Logging any amount marks the day as done, even below the goal.';

  @override
  String get any_step => 'Done with some steps';

  @override
  String get any_step_sub =>
      'Checking one step marks the day as done, without doing them all.';

  @override
  String steps_needed_sub(int needed, int total) {
    return 'The day counts as done with $needed of $total steps.';
  }

  @override
  String get sched_start => 'Starts on';

  @override
  String get from_last_done => 'Count from the last time';

  @override
  String get month_weekday => 'Same weekday every month';

  @override
  String month_weekday_sub(String when) {
    return 'Falls on the $when of the month, not on a fixed date.';
  }

  @override
  String nth_weekday(String n, String day) {
    String _temp0 = intl.Intl.selectLogic(
      n,
      {
        'first': 'first',
        'second': 'second',
        'third': 'third',
        'fourth': 'fourth',
        'other': 'last',
      },
    );
    return '$_temp0 $day';
  }

  @override
  String get from_last_done_sub =>
      'Each time you do it, the wait starts again. A missed day still breaks the streak.';

  @override
  String get quotes => 'Quotes';

  @override
  String get quotes_which => 'Which quotes';

  @override
  String get quotes_app => 'From the app';

  @override
  String get quotes_mine => 'Mine';

  @override
  String get quotes_both => 'Both';

  @override
  String get quotes_off => 'Off';

  @override
  String get quotes_my_list => 'My quotes';

  @override
  String get quotes_add => 'Add quote';

  @override
  String get quotes_edit => 'Edit quote';

  @override
  String get quotes_hint => 'Write your quote';

  @override
  String get quotes_empty => 'No quotes of your own';

  @override
  String get quotes_empty_sub => 'Write your own and they show up on Today.';

  @override
  String get motiv_start => 'Start the day strong 💪';

  @override
  String get motiv_progress => 'You\'re on track, keep going';

  @override
  String get motiv_almost => 'Almost there! Just a bit more';

  @override
  String get motiv_perfect => 'Perfect day! 🔥';

  @override
  String get app_background => 'Background';

  @override
  String get widgets => 'Widgets';

  @override
  String get customize_widgets => 'Customize widgets';

  @override
  String get customize_widgets_sub => 'Background, opacity, border';

  @override
  String get widget_background => 'Background color';

  @override
  String get widget_opacity => 'Opacity';

  @override
  String get widget_border => 'Border';

  @override
  String get widget_preview => 'Preview';

  @override
  String get bg_solid => 'Solid';

  @override
  String get bg_gradient => 'Gradient';

  @override
  String get bg_dots => 'Dots';

  @override
  String get bg_oled => 'OLED';

  @override
  String get weekdays => 'Weekdays';

  @override
  String get weekends => 'Weekends';

  @override
  String get reminder_message => 'Message (optional)';

  @override
  String get reminder_message_hint => 'Leave empty for a motivational quote';

  @override
  String get new_category => 'New category';

  @override
  String get edit_category => 'Edit category';

  @override
  String get add_category => 'New';

  @override
  String get delete_category => 'Delete category';

  @override
  String get edit => 'Edit';

  @override
  String get cover_image => 'Cover image';

  @override
  String get book_cover => 'Book cover';

  @override
  String get add_image => 'Add image';

  @override
  String get when_best => 'When are you most consistent?';

  @override
  String get streak_evolution => 'Streak evolution';

  @override
  String get consistency => 'Consistency';

  @override
  String get consistency_trend => 'Consistency trend';

  @override
  String get by_habit => 'By habit';

  @override
  String get ranking => 'Ranking';

  @override
  String get active_days => 'Active days';

  @override
  String get perfect_days => 'Perfect days';

  @override
  String get per_week => 'Per week';

  @override
  String get best_month => 'Best month';

  @override
  String streak_on(String n) {
    return '🔥 $n days in a row. Don\'t break it!';
  }

  @override
  String get streak_off => '💪 Today you can start a new streak';

  @override
  String get not_enough_data => 'Not enough data yet';

  @override
  String get about_inline =>
      'Soul State is an open-source app for tracking your habits, finances, and nourishment. No accounts, no limits, no payments. Everything stays on your phone.\n\nAnyone can see the code, improve it, or use it freely.';

  @override
  String get about_subtitle => 'For the days you choose to show up.';

  @override
  String get made_by => 'Made with ❤️ by Shanmugananthan';

  @override
  String get share => 'Share';

  @override
  String get share_progress => 'Share progress';

  @override
  String get share_failed => 'Couldn\'t create the image';

  @override
  String get share_swipe_hint => 'Swipe the card to move through time';

  @override
  String get share_background => 'Background';

  @override
  String get share_size => 'Size';

  @override
  String get share_size_large => 'Tall';

  @override
  String get share_size_small => 'Square';

  @override
  String get share_show_stats => 'Show stats';

  @override
  String get share_save => 'Save';

  @override
  String get share_saved => 'Saved to your gallery';

  @override
  String get share_save_failed => 'Couldn\'t save the image';

  @override
  String get about_developer => 'The developer';

  @override
  String get about_legal =>
      'Soul State is free software under the GNU GPLv3, and comes with no warranty. Tap to read the license.';

  @override
  String get about_credits => 'Credits';

  @override
  String get about_credits_body =>
      'Built with Flutter. Icons by Lucide. Charts by fl_chart. Set in Figtree & Playfair Display.';

  @override
  String get dev_handle => '@iamshanmugananthan';

  @override
  String get dev_role => 'Shanmugananthan · Soul State';

  @override
  String get notes => 'Notes';

  @override
  String get notes_enable_sub => 'Attach notes to any day of a habit';

  @override
  String get add_note => 'Add note';

  @override
  String get edit_note => 'Edit note';

  @override
  String get view_notes => 'View notes';

  @override
  String get edit_entry => 'Edit entry';

  @override
  String get note_type => 'Type';

  @override
  String get note_kind_note => 'Note';

  @override
  String get note_kind_planned => 'Planned';

  @override
  String get note_kind_completed => 'Completed';

  @override
  String get note_hint => 'Write your note...';

  @override
  String get note_time_optional => 'Time (optional)';

  @override
  String get save_note => 'Save note';

  @override
  String get notes_empty => 'No notes for this day yet';

  @override
  String get delete_note => 'Delete note';

  @override
  String get legend_note_added => 'Note added';

  @override
  String get tomorrow => 'Tomorrow';

  @override
  String notes_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count notes',
      one: '1 note',
    );
    return '$_temp0';
  }

  @override
  String get todos => 'To-Do';

  @override
  String get todo_view_list => 'Simple';

  @override
  String get todo_view_papers => 'Folders';

  @override
  String get todo_style => 'To-do style';

  @override
  String get todo_style_sub =>
      'A simple list, or folders of sheets like Google Keep.';

  @override
  String get todos_enable_sub => 'A quick list beside your habits';

  @override
  String get todo_new => 'New to-do';

  @override
  String get todo_hint => 'What needs doing?';

  @override
  String get todo_subtasks => 'Subtasks';

  @override
  String get todo_subtask_hint => 'Subtask';

  @override
  String get todo_empty_title => 'Nothing on the list';

  @override
  String get todo_empty_body =>
      'Jot down what you want to get done over the next few days.';

  @override
  String get todo_date => 'Date';

  @override
  String get todo_no_date => 'No date';

  @override
  String get todo_time => 'Time';

  @override
  String get todo_repeat => 'Repeat';

  @override
  String get todo_repeat_never => 'Don\'t repeat';

  @override
  String get todo_repeat_workdays => 'Monday to Friday';

  @override
  String todo_repeat_days(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Every $count days',
      one: 'Every day',
    );
    return '$_temp0';
  }

  @override
  String todo_repeat_weeks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Every $count weeks',
      one: 'Every week',
    );
    return '$_temp0';
  }

  @override
  String todo_repeat_months(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Every $count months',
      one: 'Every month',
    );
    return '$_temp0';
  }

  @override
  String todo_repeat_years(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Every $count years',
      one: 'Every year',
    );
    return '$_temp0';
  }

  @override
  String get todo_repeat_custom => 'Custom';

  @override
  String get todo_repeat_unit_days => 'Days';

  @override
  String get todo_repeat_unit_weeks => 'Weeks';

  @override
  String get todo_repeat_unit_months => 'Months';

  @override
  String get todo_repeat_unit_years => 'Years';

  @override
  String todo_repeat_on_day(int day) {
    return 'On day $day';
  }

  @override
  String todo_repeat_on_weekday(String nth, String weekday) {
    String _temp0 = intl.Intl.selectLogic(
      nth,
      {
        '1': 'first',
        '2': 'second',
        '3': 'third',
        '4': 'fourth',
        'other': 'last',
      },
    );
    return 'On the $_temp0 $weekday';
  }

  @override
  String get todo_repeat_from_done => 'Count from when I finish it';

  @override
  String get todo_repeat_skip => 'Skip this one';

  @override
  String get todo_estimate => 'Duration';

  @override
  String get todo_estimate_none => 'No duration';

  @override
  String get todo_priority => 'Priority';

  @override
  String get todo_paper => 'Color';

  @override
  String get todo_add => 'Add';

  @override
  String get todo_list_item => 'List item';

  @override
  String get todo_title_hint => 'Title';

  @override
  String get todo_body_hint => 'Note';

  @override
  String get todo_sort => 'Priority order';

  @override
  String get todo_sort_high_first => 'High priority first';

  @override
  String get todo_sort_low_first => 'Low priority first';

  @override
  String get todo_project_empty => 'Nothing in this folder yet';

  @override
  String get todo_background => 'Background';

  @override
  String get todo_background_pick => 'Choose a photo';

  @override
  String get todo_deleted => 'Note deleted';

  @override
  String get todo_mark_done => 'Mark as done';

  @override
  String get todo_mark_open => 'Mark as not done';

  @override
  String get todo_pin => 'Pin';

  @override
  String get todo_unpin => 'Unpin';

  @override
  String get todo_select => 'Select';

  @override
  String todo_selected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count selected',
      one: '1 selected',
    );
    return '$_temp0';
  }

  @override
  String todo_deleted_many(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count notes deleted',
      one: 'Note deleted',
    );
    return '$_temp0';
  }

  @override
  String get priority_none => 'No priority';

  @override
  String get priority_low => 'Low';

  @override
  String get priority_medium => 'Medium';

  @override
  String get priority_high => 'High';

  @override
  String get todo_overdue => 'Overdue';

  @override
  String get todo_upcoming => 'Upcoming';

  @override
  String get todo_someday => 'Someday';

  @override
  String get pick_a_date => 'Pick a date';

  @override
  String todo_left(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count to do',
      one: '1 to do',
      zero: 'All done',
    );
    return '$_temp0';
  }

  @override
  String todo_completed_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Completed ($count)',
      one: 'Completed (1)',
    );
    return '$_temp0';
  }

  @override
  String get todo_search => 'Search to-dos';

  @override
  String get todo_search_empty => 'Nothing matches that';

  @override
  String get todo_clear_completed => 'Clear completed';

  @override
  String todo_clear_completed_body(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'This deletes the $count completed to-dos.',
      one: 'This deletes the completed to-do.',
    );
    return '$_temp0';
  }

  @override
  String get prefs_general => 'General';

  @override
  String get prefs_cards => 'Cards and calendar';

  @override
  String get prefs_habits => 'Habits';

  @override
  String get prefs_features => 'Features';

  @override
  String get prefs_privacy => 'Privacy';

  @override
  String get collapse_cards => 'Collapse cards';

  @override
  String get expand_cards => 'Expand cards';

  @override
  String get view_switcher => 'View switcher';

  @override
  String get view_switcher_sub =>
      'Show the Week / Month / Year buttons on Today. Off, they move to the filter menu';

  @override
  String get view_switcher_needs => 'Turn on activity on cards to use it';

  @override
  String get unit_hours => 'hours';

  @override
  String get unit_minutes => 'minutes';

  @override
  String get unit_seconds => 'seconds';

  @override
  String get unit_hour_short => 'h';

  @override
  String get unit_min_short => 'min';

  @override
  String get celebration => 'Completion effect';

  @override
  String get celebration_confetti => 'Confetti';

  @override
  String get celebration_fireworks => 'Fireworks';

  @override
  String get celebration_surprise => 'Surprise me';

  @override
  String get select_all => 'Select all';

  @override
  String selected_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count selected',
      one: '1 selected',
    );
    return '$_temp0';
  }

  @override
  String get unscheduled_title => 'Day not scheduled';

  @override
  String unscheduled_body(String day) {
    return 'This habit is not scheduled on $day. Log it anyway as an extra?';
  }

  @override
  String get unscheduled_confirm => 'Log anyway';

  @override
  String get paused_day_title => 'Day paused';

  @override
  String paused_day_body(String day) {
    return 'This habit is paused on $day. Log it anyway?';
  }

  @override
  String get rest_days_none => 'None';

  @override
  String get last_90_days => 'Last 90 days';

  @override
  String get last_12_months => 'Last 12 months';

  @override
  String consistency_vs_previous(String change) {
    return '$change vs previous';
  }

  @override
  String get plan_day => 'Plan the day';

  @override
  String get plan_day_sub =>
      'Give habits a time of day and see them on a timeline.';

  @override
  String get plan_todos => 'Tasks in Plan';

  @override
  String get plan_todos_sub =>
      'Show the to-dos dated that day below the habits.';

  @override
  String get plan_show_habits => 'Habits';

  @override
  String get plan_show_both => 'Both';

  @override
  String get plan_show_todos => 'To-dos';

  @override
  String get swipe_cards => 'Swipe habit cards';

  @override
  String get swipe_cards_sub =>
      'Swipe left to complete a habit and right to undo it.';

  @override
  String get habit_time => 'Time of day';

  @override
  String get habit_time_none => 'Anytime';

  @override
  String get habit_time_sub =>
      'Places the habit in Plan at this time. It still shows in Today all day.';

  @override
  String get habit_duration => 'Duration';

  @override
  String get habit_duration_none => 'No duration';

  @override
  String get day_timeline => 'Day';

  @override
  String day_timeline_free(String span) {
    return '$span free';
  }

  @override
  String get day_timeline_anytime => 'Anytime';

  @override
  String get day_timeline_empty => 'Nothing planned for this day';

  @override
  String get day_timeline_empty_sub =>
      'Give a habit a time of day and it will show up here.';

  @override
  String get day_timeline_empty_todos =>
      'Give a to-do this date and it will show up here.';

  @override
  String get clear => 'Clear';

  @override
  String get start_view => 'Today opens on';

  @override
  String get start_view_last => 'Last used';

  @override
  String get perfect_streak => 'Perfect day streak';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get notes_hint =>
      'Open a habit and long-press a day on its calendar to see or add notes';

  @override
  String get app_style => 'App style';

  @override
  String get app_style_sub => 'Choose how the whole app looks and feels.';

  @override
  String get style_classic => 'Classic';

  @override
  String get style_minimal => 'Minimal';

  @override
  String get style_classic_desc =>
      'Habit list, bottom bar and every setting on one screen.';

  @override
  String get style_minimal_desc =>
      'Habit grid and settings grouped into four sections.';

  @override
  String get appearance_sub => 'Theme, accent and background';

  @override
  String get preferences_sub => 'Language, week and sorting';

  @override
  String get data_sub => 'Backups, archive and import';

  @override
  String get about_sub => 'Version, source code and support';

  @override
  String get support_sub => 'Report a bug or ask for a feature';

  @override
  String get check_style => 'Check style';

  @override
  String get square => 'Square';

  @override
  String get circle => 'Circle';

  @override
  String get github_star_row => 'View source & give a star';

  @override
  String get github_star_sub =>
      'Give the project a star so more people find it';

  @override
  String get icons_tab => 'Icons';

  @override
  String get emojis_tab => 'Emojis';

  @override
  String get emoji_own => 'Type or paste any emoji';

  @override
  String get report_issue => 'Report an issue';

  @override
  String get report_issue_sub => 'Tell me about a bug or ask for a feature';

  @override
  String get advanced_options => 'Advanced options';

  @override
  String get default_user => 'Rabbit';

  @override
  String get your_name => 'Your name';

  @override
  String get edit_name => 'Edit name';

  @override
  String get change_photo => 'Change photo';

  @override
  String get remove_photo => 'Remove photo';

  @override
  String notif_greeting(String name) {
    return 'Hi $name, ';
  }

  @override
  String get app_icon => 'App icon';

  @override
  String get icon_default => 'Default';

  @override
  String get icon_neutral => 'Green';

  @override
  String get icon_accent => 'Tricolor';

  @override
  String get custom => 'Custom';

  @override
  String get see_more => 'See more';

  @override
  String get see_less => 'See less';

  @override
  String get colors_tab => 'Colors';

  @override
  String get reorder => 'Reorder';

  @override
  String get reorder_hint => 'Drag the habits to reorder them';

  @override
  String get category_order_empty =>
      'Give a habit a category and it will show up here';

  @override
  String get done => 'Done';

  @override
  String get accent_color => 'Accent color';

  @override
  String get heatmap_path => 'Connect the days';

  @override
  String get heatmap_path_sub => 'Draws the grid as one long walk';

  @override
  String get sort_completed_last => 'Completed last';

  @override
  String get sort_completed_last_sub =>
      'Sends what you finish to the bottom of the list';

  @override
  String get today_only => 'Only today\'s';

  @override
  String get today_only_sub =>
      'Hides the habits that are not scheduled for today';

  @override
  String get hide_done => 'Hide completed';

  @override
  String get hide_done_sub => 'What you finish today leaves the list';

  @override
  String get past_first => 'Open past days first';

  @override
  String get past_first_sub =>
      'Tapping a past day shows it first, so nothing changes by mistake';

  @override
  String get miss_reason_title => 'Why did you miss it?';

  @override
  String get miss_reasons => 'Why you missed';

  @override
  String get miss_other => 'Other';

  @override
  String get miss_other_hint => 'Write a reason';

  @override
  String get miss_overslept => 'Overslept';

  @override
  String get miss_busy => 'Busy';

  @override
  String get miss_traveling => 'Traveling';

  @override
  String get miss_sick => 'Sick';

  @override
  String get miss_tired => 'Tired';

  @override
  String get miss_forgot => 'Forgot';

  @override
  String get day_not_done => 'Not done';

  @override
  String get day_clean => 'Clean';

  @override
  String day_relapses(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count relapses',
      one: '1 relapse',
    );
    return '$_temp0';
  }

  @override
  String get day_log_relapse => 'Log relapse';

  @override
  String day_amount(String value, String goal) {
    return '$value of $goal';
  }

  @override
  String get today_filter => 'Show';

  @override
  String today_fold_done(int count) {
    return 'Done ($count)';
  }

  @override
  String today_fold_other(int count) {
    return 'Other days ($count)';
  }

  @override
  String today_fold_hidden(int count) {
    return 'Hidden ($count)';
  }

  @override
  String get card_activity => 'Activity on cards';

  @override
  String get card_activity_sub =>
      'Shows the last days on the card, ready to tick';

  @override
  String get readable_copy => 'Readable copy';

  @override
  String get readable_copy_sub => 'Also writes your habits as markdown files';

  @override
  String get auto_sync => 'Keep devices in sync';

  @override
  String get auto_sync_sub =>
      'Saves after each change and checks the folder every few minutes';

  @override
  String get sync_guide => 'How to sync two devices';

  @override
  String get theme_sub => 'Light, dark or the system one';

  @override
  String get accent_color_sub => 'Used on buttons and highlights';

  @override
  String get color_theme => 'Color theme';

  @override
  String get color_theme_sub => 'Full palettes like Catppuccin or Nord';

  @override
  String get color_theme_default => 'Soul State';

  @override
  String get color_theme_hint =>
      'Each theme brings its own background, text and accent color. It follows light and dark mode.';

  @override
  String get app_background_sub => 'What you see behind the cards';

  @override
  String get check_style_sub => 'Square or round marks';

  @override
  String get app_icon_sub => 'The icon on your home screen';

  @override
  String get language_sub => 'The language of the whole app';

  @override
  String get week_start_sub => 'The first column of every grid';

  @override
  String get celebration_sub => 'What you see when you tick a habit';

  @override
  String get start_view_sub => 'The view Today opens in';

  @override
  String get quotes_sub => 'Which quotes show up on Today';

  @override
  String get app_lock_delay_sub => 'How soon it asks again after you leave';

  @override
  String get on => 'On';

  @override
  String get off => 'Off';

  @override
  String get checklist => 'Checklist';

  @override
  String get checklist_hint =>
      'Break the habit into steps. It\'s done only when every step is checked.';

  @override
  String get add_step => 'Add step';

  @override
  String get step_hint => 'Step name';

  @override
  String get todays_checklist => 'Today\'s checklist';

  @override
  String steps_done(String done, String total) {
    return '$done/$total steps';
  }

  @override
  String get vacation_all => 'Pause every habit';

  @override
  String get vacation_all_sub => 'Nothing counts as missed while it is on';

  @override
  String get vacation_mode => 'Vacation mode';

  @override
  String get vacation_on_desc =>
      'Paused — these days won\'t count as missed or completed.';

  @override
  String get vacation_off_desc =>
      'Pause this habit. Skipped days won\'t break your streak.';

  @override
  String get paused => 'Paused';

  @override
  String get start_vacation => 'Start vacation';

  @override
  String get end_vacation => 'End vacation';

  @override
  String get vacation_day_on => 'Mark as vacation day';

  @override
  String get vacation_day_off => 'Remove vacation day';

  @override
  String get rest_days => 'Rest days';

  @override
  String get rest_days_desc =>
      'Pause it every week on these days. You can still log them, and they\'ll count.';

  @override
  String get widget_no_habits => 'No habits yet\nTap to open Soul State';

  @override
  String get widget_no_data => 'No data yet\nOpen Soul State to sync';

  @override
  String get widget_open_to_sync => 'Open Soul State to sync';

  @override
  String get widget_activity => 'Activity';

  @override
  String widget_today_progress(String done, String total) {
    return 'Today  $done/$total';
  }

  @override
  String widget_today_done(String done, String total) {
    return '$done of $total done';
  }

  @override
  String widget_todos_open(String count) {
    return 'To-do  $count';
  }

  @override
  String get widget_todos_empty => 'Nothing left for today';

  @override
  String get widget_done_today => 'done today';

  @override
  String get widget_streak_days => 'Streak days';

  @override
  String get widget_this_week => 'This week';

  @override
  String widget_last_days(String count) {
    return 'Last $count days';
  }

  @override
  String get widget_cfg_days => 'Days shown';

  @override
  String widget_week_done(String done, String total) {
    return '$done of $total';
  }

  @override
  String widget_best_streak(String streak) {
    return '🔥 $streak best streak';
  }

  @override
  String get widget_cfg_title => 'Customize widget';

  @override
  String get widget_cfg_content => 'Content';

  @override
  String get widget_cfg_background => 'Background';

  @override
  String get widget_cfg_color => 'Color';

  @override
  String get widget_cfg_image => 'Image';

  @override
  String get widget_cfg_choose_image => 'Choose image';

  @override
  String get widget_cfg_change_image => 'Change image';

  @override
  String get widget_cfg_custom_color => 'Custom color';

  @override
  String get widget_cfg_follow_system => 'Follow system theme';

  @override
  String get widget_cfg_dark_color => 'Dark theme';

  @override
  String get widget_cfg_light_color => 'Light theme';

  @override
  String widget_cfg_opacity(String value) {
    return 'Opacity  $value%';
  }

  @override
  String get widget_cfg_border => 'Border';

  @override
  String widget_cfg_thickness(String value) {
    return 'Thickness  ${value}dp';
  }

  @override
  String get widget_cfg_todos_all => 'Show every task';

  @override
  String get widget_cfg_todos_hint => 'Off: only today, late and undated tasks';

  @override
  String get widget_cfg_show_art => 'Show illustration';

  @override
  String get widget_cfg_show_header => 'Header';

  @override
  String get widget_cfg_show_icons => 'Habit icons';

  @override
  String get widget_cfg_show_cards => 'Background behind each habit';

  @override
  String get widget_cfg_show_details => 'Streak under the name';

  @override
  String get widget_cfg_buttons => 'Buttons';

  @override
  String get widget_cfg_buttons_round => 'Round';

  @override
  String get widget_cfg_buttons_square => 'Square';

  @override
  String get widget_cfg_buttons_flower => 'Flower';

  @override
  String get widget_cfg_tick => 'Checkmark';

  @override
  String get widget_cfg_tick_hint =>
      'Off: done buttons are only filled with color';

  @override
  String get widget_cfg_hide_done => 'Hide completed';

  @override
  String get widget_cfg_compact => 'Compact';

  @override
  String get widget_cfg_compact_hint => 'Smaller rows, streak next to the name';

  @override
  String get widget_cfg_compact_todos_hint =>
      'Smaller rows, time next to the task';

  @override
  String get widget_cfg_today_band => 'Highlight today';

  @override
  String get widget_cfg_show_activity => 'Show activity of';

  @override
  String get widget_cfg_dot_color => 'Dot color';

  @override
  String get widget_cfg_style => 'Style';

  @override
  String get widget_cfg_style_classic => 'Classic';

  @override
  String get widget_cfg_style_card => 'Card';

  @override
  String get widget_cfg_all_habits => 'All habits';

  @override
  String get widget_cfg_show_habits => 'Habits to show';

  @override
  String get widget_cfg_show_habits_hint =>
      'Pick one or more. With one habit, the summary shows its streak.';

  @override
  String get widget_cfg_save => 'Save';

  @override
  String get widget_cfg_add => 'Add widget';

  @override
  String get widget_cfg_reset => 'Reset to default';

  @override
  String get widget_cfg_hue => 'Hue';

  @override
  String get widget_cfg_saturation => 'Saturation';

  @override
  String get widget_cfg_brightness => 'Brightness';

  @override
  String get widget_demo_read => 'Read';

  @override
  String get widget_demo_run => 'Run';

  @override
  String get widget_demo_water => 'Water';

  @override
  String notif_streak(String streak) {
    return '🔥 $streak day streak';
  }

  @override
  String notif_streak_week(String streak) {
    return '🔥 $streak week streak';
  }

  @override
  String notif_streak_month(String streak) {
    return '🔥 $streak month streak';
  }

  @override
  String get notif_action_done => 'Done';

  @override
  String get notif_action_snooze => 'Snooze';

  @override
  String get notif_action_add => 'Add amount';

  @override
  String get notif_action_add_hint => 'How much?';

  @override
  String get snooze_duration => 'Snooze for';

  @override
  String get snooze_custom => 'Custom';

  @override
  String get snooze_custom_hint => 'Minutes';

  @override
  String minutes_short(String value) {
    return '$value min';
  }

  @override
  String a11y_mark_done(String name) {
    return 'Mark $name as done';
  }

  @override
  String a11y_mark_not_done(String name) {
    return 'Mark $name as not done';
  }

  @override
  String a11y_add_amount(String name) {
    return 'Add to $name';
  }

  @override
  String a11y_log_relapse(String name) {
    return 'Log a relapse for $name';
  }

  @override
  String a11y_clear_relapse(String name) {
    return 'Clear today\'s relapse for $name';
  }

  @override
  String get a11y_not_done => 'not done';

  @override
  String get a11y_previous_week => 'Previous week';

  @override
  String get a11y_next_week => 'Next week';

  @override
  String get a11y_previous_month => 'Previous month';

  @override
  String get a11y_next_month => 'Next month';

  @override
  String get plan_show_month => 'Show the whole month';

  @override
  String get plan_show_week => 'Show one week';

  @override
  String get a11y_increase => 'Increase';

  @override
  String get a11y_decrease => 'Decrease';

  @override
  String get a11y_pick_color => 'Pick a colour';

  @override
  String get period_this_week => 'This week';

  @override
  String tracked_week(int n) {
    return '$n this week';
  }

  @override
  String tracked_month(int n) {
    return '$n this month';
  }

  @override
  String tracked_year(int n) {
    return '$n this year';
  }

  @override
  String get period_last_week => 'Last week';

  @override
  String get period_this_month => 'This month';

  @override
  String get period_last_month => 'Last month';

  @override
  String get period_this_year => 'This year';

  @override
  String get period_all_time => 'All time';

  @override
  String get times_completed => 'Times completed';

  @override
  String get period_last_year => 'Last year';

  @override
  String period_week_of(String date) {
    return 'Week of $date';
  }

  @override
  String get notes_all => 'All notes';

  @override
  String get notes_empty_all => 'No notes yet';

  @override
  String get quant_preset_time => 'Time';

  @override
  String get style_express => 'Express';

  @override
  String get style_express_desc =>
      'Rounded shapes, springy motion and a wider typeface.';

  @override
  String get celebration_none => 'None';

  @override
  String get quant_mode_add => 'Add';

  @override
  String get quant_mode_replace => 'Replace';

  @override
  String get quant_add_title => 'Add amount';

  @override
  String get pane_hint => 'Open something from the list to see it here';

  @override
  String get average_short => 'Avg';

  @override
  String get gamification => 'Gamification';

  @override
  String get gamification_beta => 'Gamification (beta)';

  @override
  String get last_check => 'Last logged';

  @override
  String get check_history => 'Check history';

  @override
  String check_history_sub(String count) {
    return '$count days checked off';
  }

  @override
  String get check_never => 'Never';

  @override
  String get check_no_time => 'no time saved';

  @override
  String get heatmap_rolling => 'Last 12 months';

  @override
  String get heatmap_rolling_sub =>
      'The yearly grid ends today instead of on 31 December';

  @override
  String check_marks(String count) {
    return '$count marks';
  }

  @override
  String get today_progress_option => 'Progress on Today';

  @override
  String get today_progress_option_sub =>
      'The day\'s ring and the strength bar on each habit';

  @override
  String get quiet_when_done => 'Quiet once done';

  @override
  String get quiet_when_done_sub =>
      'No more reminders today for a habit you already completed';

  @override
  String get plan_tab => 'Plan';

  @override
  String get difficulty => 'Difficulty';

  @override
  String get difficulty_hint =>
      'Harder habits count for more in the day\'s progress';

  @override
  String get difficulty_easy => 'Easy';

  @override
  String get difficulty_medium => 'Medium';

  @override
  String get difficulty_hard => 'Hard';

  @override
  String get pin_lock => 'PIN code';

  @override
  String get pin_lock_sub => 'Your own code, separate from the phone\'s lock';

  @override
  String get pin_choose => 'Choose a PIN';

  @override
  String get pin_choose_sub => '4 to 8 digits';

  @override
  String get pin_repeat => 'Enter it again';

  @override
  String get pin_mismatch => 'They don\'t match. Start again.';

  @override
  String get pin_enter => 'Enter your PIN';

  @override
  String get pin_wrong => 'Wrong PIN';

  @override
  String pin_wait(String seconds) {
    return 'Too many tries. Wait $seconds s';
  }

  @override
  String get pin_recovery_title => 'Your recovery code';

  @override
  String get pin_recovery_body =>
      'If you forget the PIN, this code opens Soul State and turns the lock off. Keep it somewhere safe: it won\'t be shown again.';

  @override
  String get pin_copy => 'Copy code';

  @override
  String get pin_copied => 'Code copied';

  @override
  String get pin_forgot => 'Forgot your PIN?';

  @override
  String get pin_recovery_hint => 'Recovery code';

  @override
  String get pin_recovery_wrong => 'That code isn\'t right';

  @override
  String get pin_recovered =>
      'Lock turned off. You can set a new PIN in Settings.';

  @override
  String get pin_change => 'Change PIN';

  @override
  String get pin_remove => 'Remove PIN';

  @override
  String get pin_fingerprint => 'Use fingerprint';

  @override
  String get app_lock_method => 'Unlock with';

  @override
  String get app_lock_biometric => 'Fingerprint or face';

  @override
  String get difficulty_option => 'Habit difficulty';

  @override
  String get difficulty_option_sub =>
      'Let harder habits count for more in the day\'s progress';

  @override
  String get todo_save_another => 'Save and add another';

  @override
  String get todo_add_subtask => 'Add subtask';

  @override
  String get pin_paste => 'Paste code';

  @override
  String get quant_preset_steps => 'Steps';

  @override
  String get health_steps_denied =>
      'Soul State can\'t read your steps without permission';

  @override
  String get health_permission => 'Permission';

  @override
  String get health_unit_steps => 'steps';

  @override
  String get health_intro =>
      'Soul State only reads your step count, so your step habits fill in by themselves.';

  @override
  String get health_point_read =>
      'It only reads steps. It never reads anything else and never writes to Health Connect.';

  @override
  String get health_point_local =>
      'Your steps stay on your phone. Soul State never connects to the internet.';

  @override
  String get health_point_off =>
      'You can turn it off at any time, in the habit or in Health Connect.';

  @override
  String get health_manage => 'Manage permission';

  @override
  String get performance => 'Performance';

  @override
  String get performance_sub => 'Lighter app for older or low-end phones';

  @override
  String get glass_effects => 'Glass effects';

  @override
  String get glass_effects_sub =>
      'Blur behind the bar and at the screen edges. It\'s what weighs the most';

  @override
  String get animations => 'Animations';

  @override
  String get animations_sub => 'Entrances, page changes and moving text';

  @override
  String get widgets_sub =>
      'Widget style, for phones without the widget editor';

  @override
  String get widgets_hint =>
      'If your home screen doesn\'t open the editor when you add or hold a widget, change its style here. It applies to every widget of that type that wasn\'t customized on its own.';

  @override
  String get widget_kind_habit => 'Habits';

  @override
  String get widget_kind_today => 'Today';

  @override
  String get widget_kind_stats => 'Summary';

  @override
  String get widget_kind_heatmap => 'Heatmap';

  @override
  String get widget_kind_todos => 'To-do';

  @override
  String get today_view => 'View';

  @override
  String get avoid_track_spent => 'Log what you spend';

  @override
  String get avoid_track_spent_sub =>
      'When you relapse, note how much it cost you. The cost per day is filled in for you';

  @override
  String get clean_goal => 'Clean days goal';

  @override
  String get clean_goal_sub =>
      'Pick how many days in a row you want to hold out';

  @override
  String clean_goal_left(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days to go',
      one: '1 day to go',
    );
    return '$_temp0';
  }

  @override
  String get clean_goal_reached => 'Goal reached';

  @override
  String get clean_goal_again => 'Your streak keeps going. Keep it up';

  @override
  String clean_goal_of(int goal) {
    return 'of $goal';
  }

  @override
  String get relapse_spent => 'Spent on this relapse';

  @override
  String get money_spent => 'Money spent';

  @override
  String get avoid_month => 'Month summary';

  @override
  String get avoid_by_month => 'Relapses by month';

  @override
  String get avoid_balance => 'Balance';

  @override
  String get total_goal => 'Total goal';

  @override
  String get total_goal_sub =>
      'A target for the whole habit, like 1000 pages or 50 times';

  @override
  String total_goal_left(String amount) {
    return '$amount to go';
  }

  @override
  String total_goal_of(String amount) {
    return 'of $amount';
  }

  @override
  String get book => 'Book';

  @override
  String get book_pages => 'Pages in the book';

  @override
  String get book_pages_sub =>
      'Counts from today. On the last page it adds a read and starts over';

  @override
  String get book_new => 'New book';

  @override
  String book_reads(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Read $count times',
      one: 'Read once',
      zero: 'First read',
    );
    return '$_temp0';
  }

  @override
  String book_read_number(int number) {
    return 'Read $number';
  }

  @override
  String book_since(String day) {
    return 'Since $day';
  }

  @override
  String get book_reading_now => 'Reading';

  @override
  String book_page(String page, String pages) {
    return 'Page $page of $pages';
  }

  @override
  String count_times(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count times',
      one: '1 time',
    );
    return '$_temp0';
  }

  @override
  String get money => 'Money';

  @override
  String get money_enable_sub =>
      'Track income and expenses next to your habits';

  @override
  String get money_overview => 'Overview';

  @override
  String get money_analysis => 'Analysis';

  @override
  String get money_calendar => 'Calendar';

  @override
  String get money_more => 'More';

  @override
  String get money_add => 'Add transaction';

  @override
  String get money_edit => 'Edit transaction';

  @override
  String get money_expense => 'Expense';

  @override
  String get money_income => 'Income';

  @override
  String get money_balance => 'Balance';

  @override
  String get money_quarter => 'Quarter';

  @override
  String get money_note => 'Add a note (optional)';

  @override
  String get money_choose_category => 'Choose a category';

  @override
  String get money_uncategorized => 'Uncategorized';

  @override
  String get money_empty_title => 'No transactions yet';

  @override
  String get money_empty_month => 'Nothing recorded this month';

  @override
  String get money_empty_body =>
      'Log what you earn and spend to see where your money goes.';

  @override
  String get money_empty_day => 'No transactions this day. Tap to add one.';

  @override
  String get money_no_data => 'Nothing to show for this period';

  @override
  String get money_deleted => 'Transaction deleted';

  @override
  String get money_delete_title => 'Delete transaction?';

  @override
  String get money_delete_body => 'This transaction will be removed.';

  @override
  String get money_categories => 'Categories';

  @override
  String get money_manage_categories => 'Manage categories';

  @override
  String get money_no_categories => 'No categories yet. Tap + to create one.';

  @override
  String get money_add_sub => 'Add sub-category';

  @override
  String get money_group => 'Group';

  @override
  String get money_top_level => 'No group';

  @override
  String get money_delete_category_title => 'Delete category?';

  @override
  String get money_delete_category_unused =>
      'No transaction uses this category.';

  @override
  String get money_reset_categories => 'Reset categories';

  @override
  String get money_reset_categories_body =>
      'Replace all categories with the defaults. Your transactions are kept.';

  @override
  String get money_reset_action => 'Reset';

  @override
  String get money_reset_done => 'Categories reset';

  @override
  String get money_delete_all => 'Delete all transactions';

  @override
  String get money_delete_all_body =>
      'Every income and expense you logged will be permanently removed. Your habits, to-dos and categories are not affected.';

  @override
  String get money_delete_all_done => 'All transactions deleted';

  @override
  String money_transactions_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count transactions',
      one: '1 transaction',
    );
    return '$_temp0';
  }

  @override
  String money_delete_category_used(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count transactions use it and will keep its name.',
      one: '1 transaction uses it and will keep its name.',
    );
    return '$_temp0';
  }

  @override
  String get nav_home => 'Home';

  @override
  String get nav_habits => 'Habits';

  @override
  String get nav_meals => 'Meals';

  @override
  String get vault_title => 'Soul State Vault';

  @override
  String get vault_desc =>
      'Choose where your habits, tracking data, and tasks are stored on your device in your Soul State Vault.';

  @override
  String get vault_open_title => 'Open Existing Vault';

  @override
  String get vault_open_desc =>
      'Open an existing folder where your Soul State Vault data is located to view all habits and entries.';

  @override
  String get vault_open_button => 'Open Folder';

  @override
  String get vault_create_title => 'Create New Vault';

  @override
  String get vault_create_desc =>
      'Select a folder on your storage to create a fresh vault. All tracker data will store there as markdown & JSON.';

  @override
  String get vault_create_button => 'Create Vault';

  @override
  String get vault_created_success => 'Vault created successfully';

  @override
  String get vault_connected => 'Connected to existing vault';

  @override
  String get spent_today => 'SPENT TODAY';

  @override
  String get nutrition => 'NUTRITION';

  @override
  String get no_spending_yet => 'No spending yet';

  @override
  String get add_action => '+ Add';

  @override
  String get log_action => '+ Log';

  @override
  String get buy_me_a_coffee => 'Buy Me a Coffee';

  @override
  String get dialog_select_new_vault => 'Select folder for new vault';

  @override
  String get dialog_select_existing_vault => 'Select existing vault folder';

  @override
  String vault_habits_loaded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count habits loaded from vault',
      one: '1 habit loaded from vault',
    );
    return '$_temp0';
  }

  @override
  String vault_failed(String error) {
    return 'Failed to setup vault: $error';
  }

  @override
  String get sync_with_s3 => 'Sync with S3';

  @override
  String get s3_synced_success => 'Synced with S3';

  @override
  String get s3_synced_changes => 'Synced with S3 (cloud changes merged)';

  @override
  String s3_sync_error(String error) {
    return 'S3 sync error: $error';
  }

  @override
  String get habits_overview => 'Habits Overview';

  @override
  String get tracker => 'Tracker';

  @override
  String habits_completed_today(int completed, int total) {
    return '$completed of $total completed today';
  }

  @override
  String get todo_tasks => 'To-Do Tasks';

  @override
  String get view_all => 'View all';

  @override
  String get all_tasks_completed => 'All tasks completed! 🎉';

  @override
  String tasks_remaining(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tasks remaining',
      one: '1 task remaining',
    );
    return '$_temp0';
  }

  @override
  String tasks_pending(int count) {
    return '$count pending';
  }

  @override
  String transactions_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count transactions',
      one: '1 transaction',
    );
    return '$_temp0';
  }

  @override
  String get zero_meals => '0 Meals';

  @override
  String clean_pct(int pct) {
    return '$pct% Clean';
  }

  @override
  String get tap_to_log_fuel => 'Tap + to log fuel';

  @override
  String get today_nutrition => 'Today\'s Nutrition';

  @override
  String get log_meal => 'Log Meal';

  @override
  String get no_meals_today => 'No meals logged yet today';

  @override
  String get tap_to_log_meals =>
      'Tap to log breakfast, lunch, dinner, or snacks';

  @override
  String get today_spending => 'Today\'s Spending';

  @override
  String get add_expense => 'Add Expense';

  @override
  String get no_spending_today => 'No expenses recorded today';

  @override
  String get tap_to_log_spending => 'Tap to log a purchase or expense';

  @override
  String get about_tagline => 'Mindful habits, finances, and nourishment.';

  @override
  String get about_story =>
      'Soul State is an offline-first life operating system developed by Shanmugananthan. Crafted to empower mindful daily living, it brings habit tracking, financial records, and meal logging into one unified private space. Your data lives exclusively in your Soul State Vault on your device — free from ads, subscriptions, and tracking. Open source, with your privacy first.';

  @override
  String developed_by(String author) {
    return 'Developed by $author';
  }

  @override
  String get license_label => 'Open Source • GPL-3.0 License';

  @override
  String get schedule_reminder => 'Schedule Reminder';

  @override
  String get reminder_time => 'Time';

  @override
  String get reminder_date => 'Date';

  @override
  String reminder_scheduled(String time) {
    return 'Reminder scheduled for $time';
  }

  @override
  String get reminder_pick_future =>
      'Please pick a future date and time for the reminder.';

  @override
  String get reminder_in_15m => '+15 mins';

  @override
  String get reminder_in_1h => '+1 hour';

  @override
  String get reminder_tonight => 'Tonight';

  @override
  String get reminder_tomorrow_morning => 'Tomorrow 9 AM';

  @override
  String get delete_reminder => 'Delete Reminder';

  @override
  String get open_as_task => 'Open as full task';
}
