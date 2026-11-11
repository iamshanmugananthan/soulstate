import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:soulstate/app/theme/app_palette.dart';
import 'package:soulstate/app/theme/app_tokens.dart';
import 'package:soulstate/core/extensions/date_extensions.dart';
import 'package:soulstate/core/extensions/color_extensions.dart';
import 'package:soulstate/core/extensions/inset_extensions.dart';
import 'package:soulstate/core/i18n/l10n.dart';
import 'package:soulstate/core/icons/habit_icons.dart';
import 'package:soulstate/core/routing/app_navigator.dart';
import 'package:soulstate/core/utils/amount_format.dart';
import 'package:soulstate/core/utils/app_snackbar.dart';
import 'package:soulstate/core/utils/cover_storage.dart';
import 'package:soulstate/core/widgets/app_confirm_dialog.dart';
import 'package:soulstate/core/widgets/app_text_field.dart';
import 'package:soulstate/core/widgets/section_label.dart';
import 'package:soulstate/features/habits/data/habit.dart';
import 'package:soulstate/features/habits/data/reminder.dart';
import 'package:soulstate/features/habits/data/substep.dart';
import 'package:soulstate/features/habits/state/habits_controller.dart';
import 'package:soulstate/features/habits/widgets/color_picker.dart';
import 'package:soulstate/features/habits/widgets/habit_form_basics.dart';
import 'package:soulstate/features/habits/widgets/habit_form_kind.dart';
import 'package:soulstate/features/habits/widgets/habit_form_schedule.dart';
import 'package:soulstate/features/habits/widgets/habit_time_fields.dart';
import 'package:soulstate/features/habits/widgets/avoid_stats.dart';
import 'package:soulstate/features/habits/widgets/reminder_editor_sheet.dart';
import 'package:soulstate/features/habits/widgets/reminder_sound_picker.dart';
import 'package:soulstate/features/habits/widgets/reminder_tile.dart';
import 'package:soulstate/features/settings/state/settings_controller.dart';
import 'package:soulstate/services/health_steps.dart';
import 'package:soulstate/services/notification_service.dart';
import 'package:soulstate/services/reminder_sounds.dart';

class HabitFormPage extends StatefulWidget {
  const HabitFormPage({super.key, this.habit, this.template});

  final Habit? habit;
  final Habit? template;

  bool get isEditing => habit != null;

  @override
  State<HabitFormPage> createState() => _HabitFormPageState();
}

class _HabitFormPageState extends State<HabitFormPage> {
  late final TextEditingController _name;
  late final TextEditingController _description;
  late final TextEditingController _unitLabel;
  late final TextEditingController _dailyCost;
  final _scroll = ScrollController();
  final _nameFocus = FocusNode();
  final _unitFocus = FocusNode();
  final _noDaysKey = GlobalKey();

  String _icon = HabitIcons.defaultIcon;
  String _category = '';
  Color _color = AppPalette.brand;
  HabitInterval _interval = HabitInterval.daily;
  int _frequency = 1;
  List<int> _scheduleWeekdays = const [1, 3, 5];
  int _scheduleEvery = 2;
  DateTime? _scheduleStart;
  bool _fromLastDone = false;
  bool _monthWeekday = false;
  ScheduleUnit _scheduleUnit = ScheduleUnit.days;
  String _cover = '';
  int _coverClarity = 100;
  late List<Reminder> _reminders;
  ReminderSound _sound = defaultReminderSound;

  HabitKind _kind = HabitKind.positive;
  QuantKind _quantKind = QuantKind.generic;
  double _quantTarget = 8;
  bool _noGoal = false;
  double _quantIncrement = 1;
  String _bookCover = '';
  double _bookPages = 0;
  bool _tracking = false;
  bool _anyAmount = false;
  bool _healthSteps = false;
  bool _trackSpent = false;
  int _cleanGoal = 0;
  double _totalGoal = 0;
  bool _anySteps = false;
  int _stepsNeeded = 1;
  int _difficulty = 0;
  int _startMinute = -1;
  int _durationMinutes = 0;
  late List<Substep> _substeps;
  late final String _opened;

  bool get _kindLocked => widget.isEditing;

  DateTime get _startShown =>
      (_scheduleStart ?? widget.habit?.createdAt ?? AppClock.today()).atMidnight;

  bool get _copying => widget.template != null;

  bool get _monthly =>
      _scheduleUnit == ScheduleUnit.months && !_fromLastDone;

  bool get _offersTracking =>
      _tracking || context.watch<SettingsController>().trackingOption;

  bool get _offersDifficulty =>
      _difficulty > 0 || context.watch<SettingsController>().difficultyOption;

  bool get _needsUnit =>
      _kind == HabitKind.quantitative &&
      _quantKind != QuantKind.time &&
      _unitLabel.text.trim().isEmpty;

  Future<void> _reveal(FocusNode node) async {
    if (node.context == null && _scroll.hasClients) {
      await _scroll.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    }
    node.requestFocus();
  }

  void _save() {
    if (_name.text.trim().isEmpty) {
      _reveal(_nameFocus);
    } else if (_needsUnit) {
      _reveal(_unitFocus);
    } else if (_noDays) {
      final hint = _noDaysKey.currentContext;
      if (hint != null) {
        Scrollable.ensureVisible(
          hint,
          alignment: 0.5,
          duration: const Duration(milliseconds: 300),
        );
      }
    } else {
      _submit();
    }
  }

  bool get _noDays =>
      _kind != HabitKind.negative &&
      _interval == HabitInterval.weekdays &&
      _scheduleWeekdays.isEmpty;

  @override
  void initState() {
    super.initState();
    final habit = widget.habit ?? widget.template;
    _name = TextEditingController(text: habit?.name ?? '');
    _name.selection = TextSelection.collapsed(offset: _name.text.length);
    _description = TextEditingController(text: habit?.description ?? '');
    _unitLabel = TextEditingController(text: habit?.unitLabel ?? '');
    _dailyCost = TextEditingController(
      text: (habit?.dailyCost ?? 0) > 0 ? formatAmount(habit!.dailyCost) : '',
    );
    if (habit != null) {
      _icon = habit.icon;
      _category = habit.category;
      _color = habit.color;
      _interval = habit.interval;
      _frequency = habit.targetFrequency;
      if (habit.scheduleWeekdays.isNotEmpty) {
        _scheduleWeekdays = List.of(habit.scheduleWeekdays);
      }
      _scheduleEvery = habit.scheduleEvery;
      _scheduleStart = habit.scheduleStart;
      _fromLastDone = habit.fromLastDone;
      _monthWeekday = habit.monthWeekday;
      if (_copying && habit.interval == HabitInterval.everyXDays) {
        _scheduleStart ??= habit.createdAt.atMidnight;
      }
      _scheduleUnit = habit.scheduleUnit;
      _cover = habit.coverPath;
      _coverClarity = habit.coverClarity;
      _reminders = List.of(habit.reminders);
      _sound = ReminderSound(habit.soundName, habit.soundUri);
      _kind = habit.kind;
      _quantKind = habit.quantKind;
      _noGoal = habit.kind == HabitKind.quantitative && habit.perDayTarget <= 0;
      _quantTarget = habit.kind == HabitKind.quantitative && !_noGoal ? habit.perDayTarget : 8;
      _quantIncrement = habit.incrementAmount;
      _bookCover = habit.bookCoverPath;
      _bookPages = habit.bookPages;
      _tracking = habit.tracking;
      _anyAmount = habit.anyAmount;
      _healthSteps = habit.readsSteps;
      _trackSpent = habit.trackSpent;
      _cleanGoal = habit.cleanGoal;
      _totalGoal = habit.totalGoal;
      _anySteps = habit.anySteps;
      _stepsNeeded = habit.stepsNeeded;
      _difficulty = habit.difficulty;
      _startMinute = habit.startMinute;
      _durationMinutes = habit.durationMinutes;
      _substeps = List.of(habit.substeps);
    } else {
      _reminders = [];
      _substeps = [];
    }
    _opened = _snapshot();
  }

  String _snapshot() => jsonEncode([
        _name.text,
        _description.text,
        _unitLabel.text,
        _dailyCost.text,
        _icon,
        _category,
        _color.toARGB32(),
        _interval.name,
        _frequency,
        _scheduleWeekdays,
        _scheduleEvery,
        _scheduleStart?.toIso8601String(),
        _fromLastDone,
        _monthWeekday,
        _scheduleUnit.name,
        _cover,
        _coverClarity,
        [for (final reminder in _reminders) reminder.toMap()],
        _sound.uri,
        _kind.name,
        _quantKind.name,
        _quantTarget,
        _noGoal,
        _quantIncrement,
        _bookCover,
        _bookPages,
        _tracking,
        _anyAmount,
        _healthSteps,
        _trackSpent,
        _cleanGoal,
        _totalGoal,
        _anySteps,
        _stepsNeeded,
        _difficulty,
        _startMinute,
        _durationMinutes,
        [for (final step in _substeps) step.toMap()],
      ]);

  Future<void> _close() async {
    if (_snapshot() != _opened) {
      final discard = await showAppConfirmDialog(
        context,
        title: context.l10n.discard_changes,
        message: context.l10n.discard_changes_body,
        confirmLabel: context.l10n.discard,
        cancelLabel: context.l10n.keep_editing,
        icon: LucideIcons.undo2,
      );
      if (discard != true || !mounted) return;
    }
    AppNavigator.pop();
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _unitLabel.dispose();
    _dailyCost.dispose();
    _scroll.dispose();
    _nameFocus.dispose();
    _unitFocus.dispose();
    super.dispose();
  }

  void _pickUnit(ScheduleUnit unit) {
    setState(() {
      _scheduleUnit = unit;
      _scheduleEvery = _scheduleEvery.clamp(
        scheduleEveryMin(unit),
        scheduleEveryMax(unit),
      );
    });
  }

  bool get _remindersFollowHabit =>
      _kind != HabitKind.negative && _interval == HabitInterval.everyXDays;

  void _applyQuantPreset(QuantKind preset) {
    setState(() {
      _quantKind = preset;
      _healthSteps = false;
      switch (preset) {
        case QuantKind.water:
          _unitLabel.text = context.l10n.quant_unit_ml;
          _quantTarget = 2000;
          _quantIncrement = 250;
          break;
        case QuantKind.reading:
          _unitLabel.text = context.l10n.quant_unit_pages;
          _quantTarget = 20;
          _quantIncrement = 1;
          break;
        case QuantKind.time:
          _unitLabel.text = context.l10n.unit_min_short;
          _quantTarget = 30;
          _quantIncrement = 5;
          break;
        case QuantKind.generic:
          break;
      }
    });
  }

  void _pickSteps() {
    setState(() {
      _quantKind = QuantKind.generic;
      _healthSteps = true;
      _unitLabel.text = context.l10n.health_unit_steps;
      _quantTarget = 10000;
      _quantIncrement = 1000;
    });
  }

  Future<void> _submit() async {
    final controller = context.read<HabitsController>();
    final name = _name.text.trim();
    final description = _description.text.trim();
    final quantitative = _kind == HabitKind.quantitative;
    final negative = _kind == HabitKind.negative;
    final dailyCost = negative
        ? double.tryParse(_dailyCost.text.trim().replaceAll(',', '.')) ?? 0
        : 0.0;
    final interval = negative ? HabitInterval.daily : _interval;
    final frequency = negative ? 1 : _frequency;
    final fromLastDone =
        interval == HabitInterval.everyXDays && _fromLastDone;
    final monthWeekday = interval == HabitInterval.everyXDays &&
        _scheduleUnit == ScheduleUnit.months &&
        !fromLastDone &&
        _monthWeekday;
    final healthSteps =
        quantitative && _quantKind == QuantKind.generic && _healthSteps;
    final substeps = _kind == HabitKind.positive
        ? _substeps.where((s) => s.title.trim().isNotEmpty).toList()
        : <Substep>[];

    if (widget.isEditing) {
      await controller.update(
        widget.habit!.copyWith(
          name: name,
          icon: _icon,
          category: _category,
          description: description,
          color: _color,
          interval: interval,
          targetFrequency: frequency,
          scheduleWeekdays: negative ? const [] : _scheduleWeekdays,
          scheduleEvery: negative ? 2 : _scheduleEvery,
          scheduleUnit: negative ? ScheduleUnit.days : _scheduleUnit,
          scheduleStart: _scheduleStart,
          clearScheduleStart: _scheduleStart == null,
          fromLastDone: fromLastDone,
          monthWeekday: monthWeekday,
          reminders: _reminders,
          soundUri: _sound.uri,
          soundName: _sound.title,
          coverPath: _cover,
          coverClarity: _coverClarity,
          dailyCost: dailyCost,
          trackSpent: negative && _trackSpent,
          cleanGoal: negative ? _cleanGoal : 0,
          totalGoal: negative ? 0 : _totalGoal,
          perDayTarget: quantitative ? (_noGoal ? 0 : _quantTarget) : widget.habit!.perDayTarget,
          unitLabel: quantitative ? _quantUnit : widget.habit!.unitLabel,
          incrementAmount:
              quantitative ? _quantIncrement : widget.habit!.incrementAmount,
          quantKind: quantitative ? _quantKind : widget.habit!.quantKind,
          bookCoverPath: quantitative ? _bookCover : widget.habit!.bookCoverPath,
          bookPages: _readsBook ? _bookPages : 0,
          tracking: _tracking,
          healthSteps: healthSteps,
          anyAmount: quantitative && _anyAmount,
          anySteps: substeps.isNotEmpty && _anySteps,
          stepsNeeded: _stepsNeeded.clamp(1, substeps.isEmpty ? 1 : substeps.length),
          difficulty: _difficulty,
          startMinute: negative ? -1 : _startMinute,
          durationMinutes: negative ? 0 : _durationMinutes,
          substeps: substeps,
        ).rememberGoal(widget.habit!).keepBook(widget.habit!),
      );
    } else {
      final template = widget.template;
      final cover = template != null && _cover == template.coverPath
          ? await CoverStorage.clone(_cover)
          : _cover;
      final bookCover = template != null && _bookCover == template.bookCoverPath
          ? await CoverStorage.clone(_bookCover)
          : _bookCover;
      await controller.create(
        name: name,
        icon: _icon,
        category: _category,
        description: description,
        color: _color.toARGB32(),
        interval: interval,
        targetFrequency: frequency,
        scheduleWeekdays: negative ? const [] : _scheduleWeekdays,
        scheduleEvery: negative ? 2 : _scheduleEvery,
        scheduleUnit: negative ? ScheduleUnit.days : _scheduleUnit,
        scheduleStart: _scheduleStart,
        fromLastDone: fromLastDone,
        monthWeekday: monthWeekday,
        reminders: _reminders,
        soundUri: _sound.uri,
        soundName: _sound.title,
        coverPath: cover,
        coverClarity: _coverClarity,
        kind: _kind,
        dailyCost: dailyCost,
        trackSpent: negative && _trackSpent,
        cleanGoal: negative ? _cleanGoal : 0,
        totalGoal: negative ? 0 : _totalGoal,
        perDayTarget: quantitative ? (_noGoal ? 0 : _quantTarget) : 1,
        unitLabel: quantitative ? _quantUnit : '',
        incrementAmount: quantitative ? _quantIncrement : 1,
        quantKind: quantitative ? _quantKind : QuantKind.generic,
        bookCoverPath: quantitative ? bookCover : '',
        bookPages: _readsBook ? _bookPages : 0,
        tracking: _tracking,
        healthSteps: healthSteps,
        anyAmount: quantitative && _anyAmount,
        anySteps: substeps.isNotEmpty && _anySteps,
        stepsNeeded: _stepsNeeded.clamp(1, substeps.isEmpty ? 1 : substeps.length),
        difficulty: _difficulty,
        startMinute: negative ? -1 : _startMinute,
        durationMinutes: negative ? 0 : _durationMinutes,
        substeps: substeps,
        restDays: template?.restDays ?? const [],
      );
    }
    if (healthSteps) unawaited(HealthSteps.sync(controller));
    AppNavigator.pop();
  }

  Future<void> _pickCover() async {
    final dest = await CoverStorage.pick();
    if (dest != null && mounted) setState(() => _cover = dest);
  }

  Future<void> _pickBookCover() async {
    final dest = await CoverStorage.pick();
    if (dest != null && mounted) setState(() => _bookCover = dest);
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showAppConfirmDialog(
      context,
      title: context.l10n.delete_habit,
      message: context.l10n.delete_habit_body(widget.habit!.name),
      confirmLabel: context.l10n.delete,
      icon: LucideIcons.trash2,
      danger: true,
    );
    if (confirmed == true && mounted) {
      await context.read<HabitsController>().remove(widget.habit!.id);
      AppNavigator.pop(true);
    }
  }

  Future<void> _addReminder() async {
    final granted = await NotificationService().requestPermissions();
    if (!granted) {
      if (mounted) AppSnackbar.error(context, context.l10n.permission_required);
      return;
    }
    if (!mounted) return;
    final reminder = await _reminderSheet(null);
    if (reminder != null) setState(() => _reminders.add(reminder));
  }

  Future<Reminder?> _reminderSheet(Reminder? initial) async {
    return showModalBottomSheet<Reminder>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => ReminderEditorSheet(
        initial: initial,
        followsHabit: _remindersFollowHabit,
      ),
    );
  }

  Future<void> _editReminder(Reminder reminder) async {
    final updated = await _reminderSheet(reminder);
    if (updated == null) return;
    setState(() {
      final index = _reminders.indexWhere((r) => r.id == reminder.id);
      if (index == -1) {
        _reminders.add(updated);
      } else {
        _reminders[index] = updated;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final form = GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      excludeFromSemantics: true,
      child: _buildClassic(context),
    );
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _close();
      },
      child: form,
    );
  }

  List<Widget> _soundRow({bool compact = false}) => [
        if (ReminderSounds.supported && _reminders.isNotEmpty) ...[
          SizedBox(height: compact ? 7 : 8),
          ReminderSoundRow(
            name: _sound.title,
            compact: compact,
            onTap: () => pickReminderSound(
              context,
              uri: _sound.uri,
              onChanged: (sound) => setState(() => _sound = sound),
            ),
          ),
        ],
      ];


  Widget _totalGoalField({bool compact = false}) => TotalGoalField(
        goal: _totalGoal,
        compact: compact,
        unit: _kind == HabitKind.quantitative ? _quantUnit : '',
        label: (value) => goalAmount(
          context,
          kind: _kind,
          time: _quantKind == QuantKind.time,
          unit: _quantUnit,
          value: value,
        ),
        color: _color,
        onChanged: (value) => setState(() => _totalGoal = value),
      );

  bool get _readsBook =>
      _kind == HabitKind.quantitative && _quantKind == QuantKind.reading;

  Widget _bookPagesField({bool compact = false}) => BookPagesField(
        pages: _bookPages,
        unit: _quantUnit,
        compact: compact,
        color: _color,
        onChanged: (value) => setState(() => _bookPages = value),
      );

  String get _quantUnit => _quantKind == QuantKind.time
      ? context.l10n.unit_min_short
      : _unitLabel.text.trim();

  double get _quantStep => switch (_quantKind) {
        QuantKind.water => 50,
        QuantKind.time => 5,
        QuantKind.generic when _healthSteps => 500,
        _ => 1,
      };

  Widget _buildClassic(BuildContext context) {
    final title =
        widget.isEditing ? context.l10n.edit_habit : context.l10n.new_habit;
    return Scaffold(
        appBar: AppBar(
          title: Text(title),
          leading: IconButton(
            icon: const Icon(LucideIcons.x),
            onPressed: _close,
          ),
          actions: [
            if (widget.isEditing)
              IconButton(
                icon: Icon(LucideIcons.trash2, color: context.tokens.danger),
                tooltip: context.l10n.delete_habit,
                onPressed: _confirmDelete,
              ),
            TextButton(
              onPressed: _save,
              child: Text(
                context.l10n.save,
                style:
                    const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: ListView(
          controller: _scroll,
          padding: context.pagePadding(16, 16, 16, 16),
          children: [
            HabitPreview(
              icon: _icon,
              color: _color,
              name: _name.text.trim(),
            ),
            const SizedBox(height: 20),
            SectionLabel(context.l10n.name),
            AppTextField(
              hint: context.l10n.name_hint,
              controller: _name,
              focusNode: _nameFocus,
              autofocus: _copying,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 20),
            SectionLabel(context.l10n.description),
            AppTextField(
              hint: context.l10n.description_hint,
              controller: _description,
            ),
            const SizedBox(height: 20),
            SectionLabel(context.l10n.habit_kind),
            KindSelector(
              kind: _kind,
              locked: _kindLocked,
              onChanged: (kind) => setState(() => _kind = kind),
            ),
            if (_kind == HabitKind.quantitative) ...[
              const SizedBox(height: 12),
              QuantitativeFields(
                quantKind: _quantKind,
                unitController: _unitLabel,
                unitFocus: _unitFocus,
                target: _quantTarget,
                increment: _quantIncrement,
                steps: _healthSteps,
                color: _color,
                onPresetSelected: _applyQuantPreset,
                onSteps: _pickSteps,
                onUnitChanged: () => setState(() {}),
                onTargetChanged: (v) => setState(() => _quantTarget = v),
                onIncrementChanged: (v) => setState(() => _quantIncrement = v),
                showGoal: !_noGoal,
                step: _quantStep,
              ),
              const SizedBox(height: 12),
              NoGoalToggle(
                value: _noGoal,
                color: _color,
                onChanged: (v) => setState(() => _noGoal = v),
              ),
              if (!_noGoal) const SizedBox(height: 12),
              if (!_noGoal) AnyAmountToggle(
                value: _anyAmount,
                color: _color,
                onChanged: (v) => setState(() => _anyAmount = v),
              ),
              if (_quantKind == QuantKind.reading) ...[
                const SizedBox(height: 20),
                SectionLabel(context.l10n.book_cover),
                CoverPicker(
                  path: _bookCover,
                  color: _color,
                  onPick: _pickBookCover,
                  onRemove: () => setState(() => _bookCover = ''),
                ),
                const SizedBox(height: 12),
                _bookPagesField(),
              ],
            ],
            if (_kind == HabitKind.negative) ...[
              const SizedBox(height: 12),
              NegativeHint(color: _color),
              const SizedBox(height: 12),
              CostField(controller: _dailyCost, color: _color),
              const SizedBox(height: 12),
              AvoidExtras(
                trackSpent: _trackSpent,
                cleanGoal: _cleanGoal,
                color: _color,
                onTrackSpent: (v) => setState(() => _trackSpent = v),
                onCleanGoal: (v) => setState(() => _cleanGoal = v),
              ),
            ],
            if (_kind != HabitKind.negative) ...[
              const SizedBox(height: 12),
              _totalGoalField(),
            ],
            if (_kind != HabitKind.negative) ...[
              const SizedBox(height: 20),
              SectionLabel(context.l10n.frequency),
              IntervalSelector(
                interval: _interval,
                frequency: _frequency,
                weekdays: _scheduleWeekdays,
                every: _scheduleEvery,
                unit: _scheduleUnit,
                onIntervalChanged: (interval) => setState(() {
                  _interval = interval;
                  _frequency = switch (interval) {
                    HabitInterval.weekly => 3,
                    HabitInterval.monthly => 10,
                    _ => 1,
                  };
                }),
                onFrequencyChanged: (value) =>
                    setState(() => _frequency = value),
                onWeekdaysChanged: (days) =>
                    setState(() => _scheduleWeekdays = days),
                onEveryChanged: (v) => setState(() => _scheduleEvery = v),
                onUnitChanged: _pickUnit,
                start: _startShown,
                onStartChanged: (day) => setState(() => _scheduleStart = day),
              ),
              if (_interval == HabitInterval.everyXDays) ...[
                const SizedBox(height: 8),
                FromLastDoneToggle(
                  value: _fromLastDone,
                  color: _color,
                  onChanged: (v) => setState(() => _fromLastDone = v),
                ),
                if (_monthly) ...[
                  const SizedBox(height: 8),
                  MonthWeekdayToggle(
                    value: _monthWeekday,
                    start: _startShown,
                    color: _color,
                    onChanged: (v) => setState(() => _monthWeekday = v),
                  ),
                ],
              ],
              if (_noDays) _NoDaysHint(key: _noDaysKey),
            ],
            if (_kind != HabitKind.negative) ...[
              const SizedBox(height: 20),
              SectionLabel(context.l10n.habit_time),
              HabitTimeFields(
                startMinute: _startMinute,
                durationMinutes: _durationMinutes,
                color: _color,
                onChanged: (start, duration) => setState(() {
                  _startMinute = start;
                  _durationMinutes = duration;
                }),
              ),
            ],
            const SizedBox(height: 20),
            SectionLabel(context.l10n.reminders),
            for (final reminder in _reminders)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: ReminderTile(
                  reminder: reminder,
                  followsHabit: _remindersFollowHabit,
                  onEdit: () => _editReminder(reminder),
                  onDelete: () =>
                      setState(() => _reminders.remove(reminder)),
                ),
              ),
            AddReminderButton(onTap: _addReminder),
            ..._soundRow(),
            if (_kind == HabitKind.positive) ...[
              const SizedBox(height: 20),
              SectionLabel(context.l10n.checklist),
              SubstepsEditor(
                substeps: _substeps,
                color: _color,
                onChanged: (list) => setState(() => _substeps = list),
              ),
              const SizedBox(height: 12),
              AnyStepsToggle(
                value: _anySteps,
                color: _color,
                onChanged: (v) => setState(() => _anySteps = v),
                needed: _stepsNeeded,
                total: _substeps.length,
                onNeeded: (n) => setState(() => _stepsNeeded = n),
              ),
            ],
            if (_offersTracking) ...[
              const SizedBox(height: 20),
              TrackingToggle(
                value: _tracking,
                color: _color,
                onChanged: (v) => setState(() => _tracking = v),
              ),
            ],
            if (_offersDifficulty) ...[
              const SizedBox(height: 20),
              DifficultyPicker(
                value: _difficulty,
                color: _color,
                onChanged: (v) => setState(() => _difficulty = v),
              ),
            ],
            const SizedBox(height: 20),
            SectionLabel(context.l10n.icon),
            IconPicker(
              selected: _icon,
              color: _color.shownIn(context),
              onSelected: (icon) => setState(() => _icon = icon),
            ),
            const SizedBox(height: 20),
            SectionLabel(context.l10n.color),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: ColorPicker(
                  selected: _color,
                  onSelected: (c) => setState(() => _color = c),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SectionLabel(context.l10n.cover_image),
            CoverPicker(
              path: _cover,
              color: _color,
              clarity: _coverClarity,
              onPick: _pickCover,
              onRemove: () => setState(() => _cover = ''),
            ),
            if (_cover.isNotEmpty)
              CoverClarity(
                value: _coverClarity,
                color: _color,
                onChanged: (value) => setState(() => _coverClarity = value),
              ),
            const SizedBox(height: 24),
          ],
        ),
    );
  }
}

class _NoDaysHint extends StatelessWidget {
  const _NoDaysHint({super.key});

  @override
  Widget build(BuildContext context) {
    final color = context.tokens.danger;
    return Padding(
      padding: const EdgeInsets.only(top: 10, left: 4),
      child: Row(
        children: [
          Icon(LucideIcons.circleAlert, size: 15, color: color),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              context.l10n.pick_one_day,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
