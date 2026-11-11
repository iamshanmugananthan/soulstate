import 'package:flutter/material.dart';
import 'package:soulstate/app/app_lock_pin.dart';
import 'package:soulstate/features/habits/data/habit.dart';
import 'package:soulstate/app/theme/app_palette.dart';
import 'package:soulstate/app/theme/color_themes.dart';
import 'package:soulstate/core/database/local_store.dart';
import 'package:soulstate/core/extensions/date_extensions.dart';
import 'package:soulstate/core/utils/money_format.dart';
import 'package:soulstate/core/widgets/celebration_overlay.dart';
import 'package:soulstate/services/app_icon_service.dart';
import 'package:soulstate/services/backup_service.dart';
import 'package:soulstate/services/home_widget_service.dart';
import 'package:soulstate/services/s3_service.dart';
import 'package:soulstate/features/vault/services/vault_manager.dart';

Locale localeFromCode(String code) {
  final parts = code.split(RegExp('[_-]'));
  String? script;
  String? country;
  for (final part in parts.skip(1)) {
    if (part.length == 4) {
      script = part;
    } else if (part.isNotEmpty) {
      country = part;
    }
  }
  return Locale.fromSubtags(
    languageCode: parts.first,
    scriptCode: script,
    countryCode: country,
  );
}

class SettingsController extends ChangeNotifier {
  static const int defaultWidgetBg = 0xFF101014;

  SettingsController() {
    _load();
    if (_autoBackup > 0) Future.microtask(runAutoBackup);
  }

  Future<void> reloadFromStore() async {
    _load();
    notifyListeners();
  }

  void _load() {
    _themeMode = ThemeMode.values[LocalStore.setting('themeMode', 0)];
    _weekStart = LocalStore.setting('weekStart', 1);
    Habit.weekStart = _weekStart;
    _onboardingDone = LocalStore.setting('onboardingDone', false);
    _localeCode = LocalStore.setting('locale', '');
    _appBackground = LocalStore.setting('appBackground', 2);
    _bgImage = LocalStore.setting('bgImage', '');
    _checkStyle = LocalStore.setting('checkStyle', 0);
    _profileName = LocalStore.setting('profileName', 'Rabbit');
    _currency = LocalStore.setting('currency', defaultCurrencySymbol());
    _vacationAll = LocalStore.setting('vacationAll', false);
    _vacationAllIds =
        List<String>.from(LocalStore.setting('vacationAllIds', const <String>[]));
    _profilePhoto = LocalStore.setting('profilePhoto', '');
    _appIcon = LocalStore.setting('appIcon', 0);
    _accentColor = LocalStore.setting('accentColor', AppPalette.brand.toARGB32());
    _colorTheme = LocalStore.setting('colorTheme', '');
    _heatmapMode = LocalStore.setting('heatmapMode', 0);
    _todayCategory = LocalStore.setting('todayCategory', '');
    _heatmapPath = LocalStore.setting('heatmapPath', false);
    _heatmapRolling = LocalStore.setting('heatmapRolling', false);
    _consistencyPeriod = LocalStore.setting('consistencyPeriod', 2);
    _startView = LocalStore.setting('startView', 0);
    _swipeCards = LocalStore.setting('swipeCards', false);
    _cardActivity = LocalStore.setting('cardActivity', true);
    _viewSwitcher = LocalStore.setting('viewSwitcher', true);
    _compactCards = LocalStore.setting('compactCards', false);
    _glassEffects = LocalStore.setting('glassEffects', true);
    _animations = LocalStore.setting('animations', true);
    _todosEnabled = LocalStore.setting('todosEnabled', true);
    _moneyEnabled = LocalStore.setting('moneyEnabled', true);
    _mealsEnabled = LocalStore.setting('mealsEnabled', true);
    _compactMoney = LocalStore.setting('compactMoney', false);
    _moneyDecimals = LocalStore.setting('moneyDecimals', true);
    _calorieGoal = LocalStore.setting('calorieGoal', 2000);
    _showMealMacros = LocalStore.setting('showMealMacros', true);
    _showMealWater = LocalStore.setting('showMealWater', true);
    _todoPapers = false;
    _sortCompletedLast = LocalStore.setting('sortCompletedLast', true);
    _todayOnly = LocalStore.setting('todayOnly', false);
    _hideDone = LocalStore.setting('hideDone', false);
    _pastFirst = LocalStore.setting('pastFirst', false);
    _hideTracking = LocalStore.setting('hideTracking', false);
    _trackingOption = LocalStore.setting('trackingOption', false);
    _showTodayProgress = LocalStore.setting('showTodayProgress', true);
    _quietWhenDone = LocalStore.setting('quietWhenDone', true);
    _difficultyOption = LocalStore.setting('difficultyOption', false);
    Habit.weighDifficulty = _difficultyOption;
    _appLockMode = LocalStore.setting('appLockMode', 0);
    _quoteSource = LocalStore.setting('quoteSource', 0);
    _customQuotes =
        List<String>.from(LocalStore.setting('customQuotes', const <String>[]));
    _vaultFolder = LocalStore.setting('vaultFolder', '');
    _celebration = CelebrationStyle.values[LocalStore.setting('celebration', 0)
        .clamp(0, CelebrationStyle.values.length - 1)];
    _appLock = LocalStore.setting('appLock', false);
    _appLockDelay = LocalStore.setting('appLockDelay', 0);
    _dayCutoff = LocalStore.setting('dayCutoff', 0);
    AppClock.cutoffHour = _dayCutoff;
    _autoBackup = LocalStore.setting('autoBackup', 0);
    _autoBackupAt = LocalStore.setting('autoBackupAt', '');
    _autoBackupFolder = LocalStore.setting('autoBackupFolder', '');
    _readableCopy = LocalStore.setting('readableCopy', true);
    _autoSync = LocalStore.setting('autoSync', false);
    _widgetBgColor = LocalStore.setting('widgetBgColor', defaultWidgetBg);
    _widgetOpacity = LocalStore.setting('widgetOpacity', 100);
    _widgetBorder = LocalStore.setting('widgetBorder', false);
    _syncWidgetStyle();
  }

  late ThemeMode _themeMode;
  late int _weekStart;
  late bool _onboardingDone;
  late String _localeCode;
  late int _appBackground;
  late String _bgImage;
  late int _checkStyle;
  late String _profileName;
  late String _currency;
  late bool _vacationAll;
  late List<String> _vacationAllIds;
  late String _profilePhoto;
  late int _appIcon;
  late int _accentColor;
  late String _colorTheme;
  late int _heatmapMode;
  late String _todayCategory;
  late bool _heatmapPath;
  late bool _heatmapRolling;
  late int _consistencyPeriod;
  late int _startView;
  late bool _todoPapers;
  late bool _swipeCards;
  late bool _cardActivity;
  late bool _viewSwitcher;
  late bool _compactCards;
  late bool _glassEffects;
  late bool _animations;
  late bool _todosEnabled;
  late bool _moneyEnabled;
  late bool _sortCompletedLast;
  late bool _todayOnly;
  late bool _hideDone;
  late bool _pastFirst;
  late bool _hideTracking;
  late bool _mealsEnabled;
  late bool _compactMoney;
  late bool _moneyDecimals;
  late int _calorieGoal;
  late bool _showMealMacros;
  late bool _showMealWater;
  late bool _trackingOption;
  late bool _showTodayProgress;
  late bool _quietWhenDone;
  late bool _difficultyOption;
  late int _appLockMode;
  late int _quoteSource;
  late List<String> _customQuotes;
  late String _vaultFolder;
  late CelebrationStyle _celebration;
  late bool _appLock;
  late int _appLockDelay;
  late int _dayCutoff;
  late int _autoBackup;
  late String _autoBackupAt;
  late String _autoBackupFolder;
  late bool _readableCopy;
  late bool _autoSync;
  late int _widgetBgColor;
  late int _widgetOpacity;
  late bool _widgetBorder;

  ThemeMode get themeMode => _themeMode;
  int get weekStart => _weekStart;
  bool get onboardingDone => _onboardingDone;
  String get localeCode => _localeCode;
  Locale? get locale => _localeCode.isEmpty ? null : localeFromCode(_localeCode);

  int get appBackground => _appBackground;

  String get bgImage => _bgImage;

  int get checkStyle => _checkStyle;
  bool get isCircleCheck => _checkStyle == 1;

  String get currency => _currency;

  bool get vacationAll => _vacationAll;
  List<String> get vacationAllIds => List.unmodifiable(_vacationAllIds);

  Future<void> setVacationAll(bool on, List<String> ids) async {
    _vacationAll = on;
    _vacationAllIds = on ? ids : const [];
    await LocalStore.writeSetting('vacationAll', on);
    await LocalStore.writeSetting('vacationAllIds', _vacationAllIds);
    notifyListeners();
  }


  Future<void> setCurrency(String value) async {
    _currency = value;
    await LocalStore.writeSetting('currency', value);
    notifyListeners();
  }

  String get profileName => _profileName.isEmpty ? 'Rabbit' : _profileName;
  String get profilePhoto => _profilePhoto;

  int get appIcon => _appIcon;

  Color get accentColor => Color(_accentColor);

  Future<void> setAccentColor(Color color) async {
    _accentColor = color.toARGB32();
    await LocalStore.writeSetting('accentColor', _accentColor);
    notifyListeners();
  }

  ColorTheme? get colorTheme => ColorTheme.byId(_colorTheme);

  Future<void> setColorTheme(ColorTheme? theme) async {
    _colorTheme = theme?.id ?? '';
    await LocalStore.writeSetting('colorTheme', _colorTheme);
    notifyListeners();
  }

  int get heatmapMode => _heatmapMode;

  bool get heatmapPath => _heatmapPath;

  bool get heatmapRolling => _heatmapRolling;

  Future<void> setHeatmapRolling(bool value) async {
    _heatmapRolling = value;
    await LocalStore.writeSetting('heatmapRolling', value);
    notifyListeners();
  }

  Future<void> setHeatmapPath(bool value) async {
    _heatmapPath = value;
    await LocalStore.writeSetting('heatmapPath', value);
    notifyListeners();
  }

  int get consistencyPeriod => _consistencyPeriod;

  Future<void> setConsistencyPeriod(int value) async {
    _consistencyPeriod = value;
    await LocalStore.writeSetting('consistencyPeriod', value);
    notifyListeners();
  }

  Future<void> setHeatmapMode(int value) async {
    _heatmapMode = value;
    await LocalStore.writeSetting('heatmapMode', value);
    notifyListeners();
  }

  String get todayCategory => _todayCategory;

  Future<void> setTodayCategory(String value) async {
    _todayCategory = value;
    await LocalStore.writeSetting('todayCategory', value);
  }

  int get startView => _startView;

  int get openingMode => _startView == 0 ? _heatmapMode : _startView - 1;

  Future<void> setStartView(int value) async {
    _startView = value;
    await LocalStore.writeSetting('startView', value);
    notifyListeners();
  }

  bool get swipeCards => _swipeCards;

  Future<void> setSwipeCards(bool value) async {
    _swipeCards = value;
    await LocalStore.writeSetting('swipeCards', value);
    notifyListeners();
  }

  bool get cardActivity => _cardActivity;

  Future<void> setCardActivity(bool value) async {
    _cardActivity = value;
    await LocalStore.writeSetting('cardActivity', value);
    notifyListeners();
  }

  bool get viewSwitcher => _viewSwitcher;

  Future<void> setViewSwitcher(bool value) async {
    _viewSwitcher = value;
    await LocalStore.writeSetting('viewSwitcher', value);
    notifyListeners();
  }

  bool get compactCards => _compactCards;

  Future<void> setCompactCards(bool value) async {
    _compactCards = value;
    await LocalStore.writeSetting('compactCards', value);
    notifyListeners();
  }

  bool get glassEffects => _glassEffects;

  Future<void> setGlassEffects(bool value) async {
    _glassEffects = value;
    await LocalStore.writeSetting('glassEffects', value);
    notifyListeners();
  }

  bool get animations => _animations;

  Future<void> setAnimations(bool value) async {
    _animations = value;
    await LocalStore.writeSetting('animations', value);
    notifyListeners();
  }

  bool get todoPapers => _todoPapers;

  Future<void> setTodoPapers(bool value) async {
    _todoPapers = value;
    notifyListeners();
    await LocalStore.writeSetting('todoPapers', value);
  }

  bool get moneyEnabled => _moneyEnabled;

  Future<void> setMoneyEnabled(bool value) async {
    _moneyEnabled = value;
    await LocalStore.writeSetting('moneyEnabled', value);
    notifyListeners();
  }

  bool get todosEnabled => _todosEnabled;

  Future<void> setTodosEnabled(bool value) async {
    _todosEnabled = value;
    await LocalStore.writeSetting('todosEnabled', value);
    notifyListeners();
  }

  bool get sortCompletedLast => _sortCompletedLast;
  bool get todayOnly => _todayOnly;
  bool get hideDone => _hideDone;
  bool get pastFirst => _pastFirst;
  bool get hideTracking => _hideTracking;
  bool get mealsEnabled => _mealsEnabled;

  bool get compactMoney => _compactMoney;
  Future<void> setCompactMoney(bool val) async {
    _compactMoney = val;
    await LocalStore.writeSetting('compactMoney', val);
    notifyListeners();
  }

  bool get moneyDecimals => _moneyDecimals;
  Future<void> setMoneyDecimals(bool val) async {
    _moneyDecimals = val;
    await LocalStore.writeSetting('moneyDecimals', val);
    notifyListeners();
  }

  int get calorieGoal => _calorieGoal;
  Future<void> setCalorieGoal(int val) async {
    _calorieGoal = val;
    await LocalStore.writeSetting('calorieGoal', val);
    notifyListeners();
  }

  bool get showMealMacros => _showMealMacros;
  Future<void> setShowMealMacros(bool val) async {
    _showMealMacros = val;
    await LocalStore.writeSetting('showMealMacros', val);
    notifyListeners();
  }

  bool get showMealWater => _showMealWater;
  Future<void> setShowMealWater(bool val) async {
    _showMealWater = val;
    await LocalStore.writeSetting('showMealWater', val);
    notifyListeners();
  }

  String get vaultFolder => _vaultFolder;
  bool get hasVault => _vaultFolder.isNotEmpty;

  Future<void> setVaultFolder(String path) async {
    _vaultFolder = path;
    await LocalStore.writeSetting('vaultFolder', path);
    if (path.isNotEmpty) {
      await setAutoBackupFolder(path);
      await setAutoSync(true);
      await setReadableCopy(true);
    }
    notifyListeners();
  }

  int get appLockDelay => _appLockDelay;

  Future<void> setAppLockDelay(int seconds) async {
    _appLockDelay = seconds;
    await LocalStore.writeSetting('appLockDelay', seconds);
    notifyListeners();
  }

  CelebrationStyle get celebration => _celebration;

  Future<void> setCelebration(int index) async {
    _celebration = CelebrationStyle.values[index];
    await LocalStore.writeSetting('celebration', index);
    notifyListeners();
  }

  bool get appLock => _appLock;

  Future<void> setAppLock(bool value) async {
    _appLock = value;
    await LocalStore.writeSetting('appLock', value);
    notifyListeners();
  }

  int get dayCutoff => _dayCutoff;

  Future<void> setDayCutoff(int hour) async {
    _dayCutoff = hour.clamp(0, 6);
    AppClock.cutoffHour = _dayCutoff;
    await LocalStore.writeSetting('dayCutoff', _dayCutoff);
    notifyListeners();
    await HomeWidgetService.sync(LocalStore.readHabits());
  }

  int get autoBackup => _autoBackup;
  DateTime? get autoBackupAt => DateTime.tryParse(_autoBackupAt);
  String get autoBackupFolder => _autoBackupFolder;

  bool get readableCopy => _readableCopy;

  Future<void> setReadableCopy(bool value) async {
    _readableCopy = value;
    await LocalStore.writeSetting('readableCopy', value);
    notifyListeners();
  }

  bool get autoSync => _autoSync;

  bool get syncsFolder =>
      _autoSync && _autoBackup > 0 && _autoBackupFolder.isNotEmpty;

  Future<void> setAutoSync(bool value) async {
    _autoSync = value;
    await LocalStore.writeSetting('autoSync', value);
    notifyListeners();
  }

  Future<void> setAutoBackup(int value) async {
    if (_autoBackup == value) return;
    _autoBackup = value;
    await LocalStore.writeSetting('autoBackup', value);
    notifyListeners();
    if (value > 0) await runAutoBackup(force: true);
  }

  Future<void> setAutoBackupFolder(String path) async {
    _autoBackupFolder = path;
    await LocalStore.writeSetting('autoBackupFolder', path);
    notifyListeners();
  }

  Future<bool> runAutoBackup({bool force = false, bool archive = true}) async {
    final folder = _vaultFolder.isNotEmpty ? _vaultFolder : _autoBackupFolder;
    if (folder.isEmpty) return false;
    try {
      if (_vaultFolder.isNotEmpty) {
        await VaultManager.syncVault(_vaultFolder);
        return true;
      }
      final path = await BackupService.runAuto(
        folder: folder,
        readable: _readableCopy,
        archive: archive,
      );
      return path != null;
    } catch (e) {
      debugPrint('Auto backup failed: $e');
      return false;
    }
  }

  Future<void> setMealsEnabled(bool value) async {
    _mealsEnabled = value;
    await LocalStore.writeSetting('mealsEnabled', value);
    notifyListeners();
  }

  bool get trackingOption => _trackingOption;

  Future<void> setTrackingOption(bool value) async {
    _trackingOption = value;
    await LocalStore.writeSetting('trackingOption', value);
    notifyListeners();
  }

  bool get showTodayProgress => _showTodayProgress;

  Future<void> setShowTodayProgress(bool value) async {
    _showTodayProgress = value;
    await LocalStore.writeSetting('showTodayProgress', value);
    notifyListeners();
  }

  bool get quietWhenDone => _quietWhenDone;

  Future<void> setQuietWhenDone(bool value) async {
    _quietWhenDone = value;
    await LocalStore.writeSetting('quietWhenDone', value);
    notifyListeners();
  }

  bool get difficultyOption => _difficultyOption;

  Future<void> setDifficultyOption(bool value) async {
    _difficultyOption = value;
    Habit.weighDifficulty = value;
    await LocalStore.writeSetting('difficultyOption', value);
    notifyListeners();
  }

  int get appLockMode => _appLockMode;

  Future<void> setAppLockMode(int mode) async {
    _appLockMode = mode;
    await LocalStore.writeSetting('appLockMode', mode);
    notifyListeners();
  }

  bool get hasAppLockPin => AppLockPin.isSet;

  Future<String> saveAppLockPin(String pin) async {
    final code = await AppLockPin.save(pin);
    notifyListeners();
    return code;
  }

  Future<void> clearAppLockPin() async {
    await AppLockPin.clear();
    notifyListeners();
  }

  int get quoteSource => _quoteSource;

  List<String> get customQuotes => List.unmodifiable(_customQuotes);

  Future<void> setQuoteSource(int value) async {
    _quoteSource = value;
    await LocalStore.writeSetting('quoteSource', value);
    notifyListeners();
  }

  Future<void> addCustomQuote(String text) async {
    final quote = text.trim();
    if (quote.isEmpty || _customQuotes.contains(quote)) return;
    _customQuotes = [..._customQuotes, quote];
    await LocalStore.writeSetting('customQuotes', _customQuotes);
    notifyListeners();
  }

  Future<void> editCustomQuote(int index, String text) async {
    final quote = text.trim();
    if (index < 0 || index >= _customQuotes.length || quote.isEmpty) return;
    _customQuotes = [..._customQuotes]..[index] = quote;
    await LocalStore.writeSetting('customQuotes', _customQuotes);
    notifyListeners();
  }

  Future<void> removeCustomQuote(int index) async {
    if (index < 0 || index >= _customQuotes.length) return;
    _customQuotes = [..._customQuotes]..removeAt(index);
    await LocalStore.writeSetting('customQuotes', _customQuotes);
    notifyListeners();
  }

  int get appStyle => 0;

  Future<void> setSortCompletedLast(bool value) async {
    _sortCompletedLast = value;
    await LocalStore.writeSetting('sortCompletedLast', value);
    notifyListeners();
  }

  Future<void> setTodayOnly(bool value) async {
    _todayOnly = value;
    await LocalStore.writeSetting('todayOnly', value);
    notifyListeners();
  }

  Future<void> setHideDone(bool value) async {
    _hideDone = value;
    await LocalStore.writeSetting('hideDone', value);
    notifyListeners();
  }

  Future<void> setPastFirst(bool value) async {
    _pastFirst = value;
    await LocalStore.writeSetting('pastFirst', value);
    notifyListeners();
  }

  Future<void> setHideTracking(bool value) async {
    _hideTracking = value;
    await LocalStore.writeSetting('hideTracking', value);
    notifyListeners();
  }

  Future<void> setLanguage(String code) async {
    _localeCode = code;
    await LocalStore.writeSetting('locale', code);
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await LocalStore.writeSetting('themeMode', mode.index);
    notifyListeners();
  }

  Future<void> setWeekStart(int weekday) async {
    _weekStart = weekday;
    Habit.weekStart = weekday;
    await LocalStore.writeSetting('weekStart', weekday);
    notifyListeners();
  }

  Future<void> setAppBackground(int value) async {
    _appBackground = value;
    await LocalStore.writeSetting('appBackground', value);
    notifyListeners();
  }

  Future<void> setBackgroundImage(String path) async {
    _bgImage = path;
    await LocalStore.writeSetting('bgImage', path);
    notifyListeners();
  }

  Future<void> setCheckStyle(int value) async {
    _checkStyle = value;
    await LocalStore.writeSetting('checkStyle', value);
    notifyListeners();
  }

  Future<void> setProfileName(String name) async {
    _profileName = name.trim();
    await LocalStore.writeSetting('profileName', _profileName);
    notifyListeners();
  }

  Future<void> setProfilePhoto(String path) async {
    _profilePhoto = path;
    await LocalStore.writeSetting('profilePhoto', path);
    notifyListeners();
  }

  Future<void> setAppIcon(int index) async {
    _appIcon = index;
    await LocalStore.writeSetting('appIcon', index);
    notifyListeners();
    await AppIconService.apply(index);
  }

  Color get widgetBgColor => Color(_widgetBgColor);

  int get widgetOpacity => _widgetOpacity;

  bool get widgetBorder => _widgetBorder;

  Future<void> setWidgetBgColor(Color color) async {
    _widgetBgColor = color.toARGB32();
    await LocalStore.writeSetting('widgetBgColor', _widgetBgColor);
    notifyListeners();
    await _syncWidgetStyle();
  }

  Future<void> setWidgetOpacity(int percent) async {
    _widgetOpacity = percent.clamp(0, 100);
    await LocalStore.writeSetting('widgetOpacity', _widgetOpacity);
    notifyListeners();
    await _syncWidgetStyle();
  }

  Future<void> setWidgetBorder(bool value) async {
    _widgetBorder = value;
    await LocalStore.writeSetting('widgetBorder', value);
    notifyListeners();
    await _syncWidgetStyle();
  }

  Future<void> _syncWidgetStyle() => HomeWidgetService.syncWidgetStyle(
        bgColor: _widgetBgColor,
        opacity: _widgetOpacity,
        border: _widgetBorder,
      );

  Future<void> completeOnboarding() async {
    _onboardingDone = true;
    await LocalStore.writeSetting('onboardingDone', true);
    notifyListeners();
  }

  bool get isS3Configured => S3Service.loadConfig().isConfigured;
  bool get isS3Enabled => S3Service.loadConfig().enabled;
  bool get isS3SyncActive => S3Service.loadConfig().isSyncActive;

  Future<void> setS3Enabled(bool enabled) async {
    final cfg = S3Service.loadConfig();
    await S3Service.saveConfig(cfg.copyWith(enabled: enabled));
    notifyListeners();
  }

  void notifyS3Changed() {
    notifyListeners();
  }
}
