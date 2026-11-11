import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:soulstate/app/theme/app_tokens.dart';
import 'package:soulstate/core/extensions/date_extensions.dart';
import 'package:soulstate/core/i18n/l10n.dart';
import 'package:soulstate/core/routing/app_navigator.dart';
import 'package:soulstate/core/utils/app_snackbar.dart';
import 'package:soulstate/core/widgets/time_picker.dart';
import 'package:soulstate/features/todos/data/todo.dart';
import 'package:soulstate/features/todos/pages/todo_editor_page.dart';
import 'package:soulstate/features/todos/state/todos_controller.dart';
import 'package:soulstate/services/notification_service.dart';

Future<void> showReminderScheduleSheet(
  BuildContext context, {
  Todo? todo,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) => ReminderScheduleSheet(todo: todo),
  );
}

class ReminderScheduleSheet extends StatefulWidget {
  const ReminderScheduleSheet({super.key, this.todo});

  final Todo? todo;

  @override
  State<ReminderScheduleSheet> createState() => _ReminderScheduleSheetState();
}

class _ReminderScheduleSheetState extends State<ReminderScheduleSheet> {
  late final TextEditingController _messageController;
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final now = AppClock.now();
    _messageController = TextEditingController(text: widget.todo?.text ?? '');

    if (widget.todo != null) {
      _selectedDate = widget.todo!.due ?? AppClock.today();
      if (widget.todo!.minutes != null) {
        final m = widget.todo!.minutes!;
        _selectedTime = TimeOfDay(hour: m ~/ 60, minute: m % 60);
      } else {
        _selectedTime = _upcomingTime(now);
      }
    } else {
      _selectedDate = AppClock.today();
      _selectedTime = _upcomingTime(now);
    }
  }

  TimeOfDay _upcomingTime(DateTime now) {
    // Default to next hour or at least 15 mins ahead
    final nextHour = (now.hour + 1) % 24;
    return TimeOfDay(hour: nextHour, minute: 0);
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _setDate(DateTime date) {
    setState(() => _selectedDate = date);
  }

  void _presetInMinutes(int minutes) {
    final target = AppClock.now().add(Duration(minutes: minutes));
    setState(() {
      _selectedDate = DateTime(target.year, target.month, target.day);
      _selectedTime = TimeOfDay(hour: target.hour, minute: target.minute);
    });
  }

  void _presetTonight() {
    final now = AppClock.now();
    final tonight = DateTime(now.year, now.month, now.day, 20, 0);
    if (tonight.isAfter(now)) {
      setState(() {
        _selectedDate = AppClock.today();
        _selectedTime = const TimeOfDay(hour: 20, minute: 0);
      });
    } else {
      // Tomorrow 8 PM
      final tomorrow = now.add(const Duration(days: 1));
      setState(() {
        _selectedDate = DateTime(tomorrow.year, tomorrow.month, tomorrow.day);
        _selectedTime = const TimeOfDay(hour: 20, minute: 0);
      });
    }
  }

  void _presetTomorrowMorning() {
    final tomorrow = AppClock.now().add(const Duration(days: 1));
    setState(() {
      _selectedDate = DateTime(tomorrow.year, tomorrow.month, tomorrow.day);
      _selectedTime = const TimeOfDay(hour: 9, minute: 0);
    });
  }

  Future<void> _pickCustomDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: AppClock.today(),
      lastDate: AppClock.today().add(const Duration(days: 730)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickCustomTime() async {
    final picked = await pickTime(context, _selectedTime);
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _save() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) {
      AppSnackbar.error(context, 'Please enter a reminder message');
      return;
    }

    final targetAt = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    if (targetAt.isBefore(AppClock.now())) {
      AppSnackbar.error(context, context.l10n.reminder_pick_future);
      return;
    }

    setState(() => _saving = true);
    try {
      await NotificationService().requestPermissions();
      if (!mounted) return;

      final todosCtrl = context.read<TodosController>();
      final minutes = _selectedTime.hour * 60 + _selectedTime.minute;
      final dateKey = _selectedDate.dayKey;

      if (widget.todo != null) {
        final reminder = widget.todo!.copyWith(
          text: message,
          date: dateKey,
          minutes: minutes,
          done: false,
        );
        await todosCtrl.update(reminder);
      } else {
        await todosCtrl.create(
          text: message,
          date: dateKey,
          minutes: minutes,
        );
      }

      if (!mounted) return;
      final timeStr = _selectedTime.format(context);
      AppSnackbar.success(
        context,
        context.l10n.reminder_scheduled(timeStr),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        AppSnackbar.error(context, 'Failed to schedule reminder: $e');
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _delete() async {
    if (widget.todo == null) return;
    final todosCtrl = context.read<TodosController>();
    await NotificationService().cancelTodo(widget.todo!.id);
    await todosCtrl.remove(widget.todo!.id);
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  void _openAsFullTask() {
    Navigator.of(context).pop();
    if (widget.todo != null) {
      AppNavigator.push(TodoEditorPage(todo: widget.todo));
    } else {
      openTodoEditor(context, withReminder: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final tokens = context.tokens;
    final isEditing = widget.todo != null;
    final today = AppClock.today();
    final tomorrow = today.add(const Duration(days: 1));
    final isToday = _selectedDate.year == today.year &&
        _selectedDate.month == today.month &&
        _selectedDate.day == today.day;
    final isTomorrow = _selectedDate.year == tomorrow.year &&
        _selectedDate.month == tomorrow.month &&
        _selectedDate.day == tomorrow.day;

    final dateLabel = isToday
        ? context.l10n.today
        : (isTomorrow
            ? 'Tomorrow'
            : DateFormat('EEE, MMM d', Localizations.localeOf(context).toString())
                .format(_selectedDate));

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 8,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: scheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    LucideIcons.alarmClock,
                    color: scheme.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isEditing
                            ? context.l10n.edit_reminder
                            : context.l10n.schedule_reminder,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: scheme.onSurface,
                        ),
                      ),
                      Text(
                        'Set date, time, and alert message',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: tokens.muted,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isEditing)
                  IconButton(
                    icon: Icon(LucideIcons.trash2, color: tokens.danger, size: 20),
                    tooltip: context.l10n.delete_reminder,
                    onPressed: _delete,
                  ),
              ],
            ),
            const SizedBox(height: 20),

            // Message text input
            TextField(
              controller: _messageController,
              autofocus: !isEditing,
              textCapitalization: TextCapitalization.sentences,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: scheme.onSurface,
              ),
              decoration: InputDecoration(
                labelText: context.l10n.reminder_message,
                hintText: 'What should Soul State remind you of?',
                hintStyle: TextStyle(
                  color: tokens.muted.withValues(alpha: 0.7),
                  fontWeight: FontWeight.normal,
                ),
                prefixIcon: const Icon(LucideIcons.bell, size: 20),
                filled: true,
                fillColor: scheme.surfaceContainerHighest.withValues(alpha: 0.4),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: scheme.outlineVariant.withValues(alpha: 0.3),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: scheme.outlineVariant.withValues(alpha: 0.3),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: scheme.primary, width: 1.8),
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Date & Time Picker Section Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: scheme.outlineVariant.withValues(alpha: 0.25),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date Picker Row
                  Row(
                    children: [
                      Icon(LucideIcons.calendar, size: 18, color: scheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        context.l10n.reminder_date,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: scheme.onSurface,
                        ),
                      ),
                      const Spacer(),
                      InkWell(
                        onTap: _pickCustomDate,
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                dateLabel,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: scheme.primary,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(LucideIcons.chevronRight, size: 16, color: scheme.primary),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Quick Date Chips
                  Wrap(
                    spacing: 8,
                    children: [
                      ChoiceChip(
                        label: Text(context.l10n.today),
                        selected: isToday,
                        onSelected: (v) {
                          if (v) _setDate(today);
                        },
                      ),
                      ChoiceChip(
                        label: const Text('Tomorrow'),
                        selected: isTomorrow,
                        onSelected: (v) {
                          if (v) _setDate(tomorrow);
                        },
                      ),
                      ActionChip(
                        avatar: const Icon(LucideIcons.calendarDays, size: 14),
                        label: const Text('Pick Date'),
                        onPressed: _pickCustomDate,
                      ),
                    ],
                  ),
                  const Divider(height: 24),

                  // Time Picker Row
                  Row(
                    children: [
                      Icon(LucideIcons.clock, size: 18, color: scheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        context.l10n.reminder_time,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: scheme.onSurface,
                        ),
                      ),
                      const Spacer(),
                      InkWell(
                        onTap: _pickCustomTime,
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: scheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _selectedTime.format(context),
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: scheme.primary,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(LucideIcons.pencil, size: 13, color: scheme.primary),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Quick Presets
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      ActionChip(
                        label: Text(context.l10n.reminder_in_15m),
                        onPressed: () => _presetInMinutes(15),
                      ),
                      ActionChip(
                        label: Text(context.l10n.reminder_in_1h),
                        onPressed: () => _presetInMinutes(60),
                      ),
                      ActionChip(
                        label: Text(context.l10n.reminder_tonight),
                        onPressed: _presetTonight,
                      ),
                      ActionChip(
                        label: Text(context.l10n.reminder_tomorrow_morning),
                        onPressed: _presetTomorrowMorning,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Submit Button
            FilledButton(
              onPressed: _saving ? null : _save,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(LucideIcons.check, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          isEditing
                              ? context.l10n.save_reminder
                              : context.l10n.schedule_reminder,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
            ),
            const SizedBox(height: 10),

            // Switch to full task editor option
            Center(
              child: TextButton.icon(
                onPressed: _openAsFullTask,
                icon: const Icon(LucideIcons.squareCheck, size: 15),
                label: Text(
                  context.l10n.open_as_task,
                  style: TextStyle(
                    fontSize: 13,
                    color: tokens.muted,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
