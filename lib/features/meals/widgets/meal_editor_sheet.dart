import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:soulstate/app/theme/app_tokens.dart';
import 'package:soulstate/features/meals/data/meal_entry.dart';
import 'package:soulstate/features/meals/state/meals_controller.dart';
import 'package:uuid/uuid.dart';

/// Bottom sheet or dialog to create or edit a meal entry.
class MealEditorSheet extends StatefulWidget {
  const MealEditorSheet({
    super.key,
    this.initialMeal,
    this.initialDate,
    this.initialType,
  });

  final MealEntry? initialMeal;
  final DateTime? initialDate;
  final MealType? initialType;

  static Future<void> show(
    BuildContext context, {
    MealEntry? meal,
    DateTime? date,
    MealType? type,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => MealEditorSheet(
        initialMeal: meal,
        initialDate: date,
        initialType: type,
      ),
    );
  }

  @override
  State<MealEditorSheet> createState() => _MealEditorSheetState();
}

class _MealEditorSheetState extends State<MealEditorSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _caloriesController;
  late final TextEditingController _notesController;

  late MealType _type;
  late bool _isHealthy;
  late DateTime _dateTime;

  static const _healthySuggestions = [
    'Oatmeal & Berries',
    'Avocado Toast',
    'Greek Salad',
    'Grilled Chicken',
    'Fruit Bowl',
    'Protein Shake',
    'Steamed Veggies',
    'Brown Rice & Salmon',
  ];

  static const _unhealthySuggestions = [
    'Cheeseburger & Fries',
    'Pepperoni Pizza',
    'Fried Chicken',
    'Potato Chips',
    'Doughnut & Coffee',
    'Soda & Candy',
    'Loaded Nachos',
    'Ice Cream Sundae',
  ];

  static MealType _defaultMealType(DateTime now) {
    final h = now.hour;
    if (h >= 5 && h < 11) return MealType.breakfast;
    if (h >= 11 && h < 16) return MealType.lunch;
    if (h >= 16 && h < 21) return MealType.dinner;
    return MealType.snack;
  }

  @override
  void initState() {
    super.initState();
    final meal = widget.initialMeal;
    _nameController = TextEditingController(text: meal?.name ?? '');
    _caloriesController = TextEditingController(
      text: meal?.calories != null ? meal!.calories.toString() : '',
    );
    _notesController = TextEditingController(text: meal?.notes ?? '');

    final now = DateTime.now();
    _type = meal?.type ?? widget.initialType ?? _defaultMealType(now);
    _isHealthy = meal?.isHealthy ?? true;

    if (meal != null) {
      _dateTime = meal.dateTime;
    } else if (widget.initialDate != null) {
      final d = widget.initialDate!;
      _dateTime = DateTime(d.year, d.month, d.day, now.hour, now.minute);
    } else {
      _dateTime = now;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _caloriesController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_dateTime),
    );
    if (picked != null) {
      setState(() {
        _dateTime = DateTime(
          _dateTime.year,
          _dateTime.month,
          _dateTime.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  void _save() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final calories = int.tryParse(_caloriesController.text.trim());
    final notes = _notesController.text.trim().isEmpty
        ? null
        : _notesController.text.trim();

    final controller = context.read<MealsController>();

    if (widget.initialMeal != null) {
      final updated = widget.initialMeal!.copyWith(
        name: name,
        type: _type,
        isHealthy: _isHealthy,
        dateTime: _dateTime,
        calories: calories,
        notes: notes,
      );
      controller.updateMeal(updated);
    } else {
      final entry = MealEntry(
        id: const Uuid().v4(),
        name: name,
        type: _type,
        isHealthy: _isHealthy,
        dateTime: _dateTime,
        calories: calories,
        notes: notes,
      );
      controller.addMeal(entry);
    }

    Navigator.of(context).pop();
  }

  void _delete() {
    if (widget.initialMeal != null) {
      context.read<MealsController>().deleteMeal(widget.initialMeal!.id);
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.initialMeal != null;
    final viewInsets = MediaQuery.of(context).viewInsets;

    return Container(
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: viewInsets.bottom + 24,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.tokens.muted.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Sheet title
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isEditing ? 'Edit Meal' : 'Log Meal',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (isEditing)
                  IconButton(
                    icon: const Icon(LucideIcons.trash2, color: Colors.redAccent),
                    onPressed: _delete,
                  ),
              ],
            ),
            const SizedBox(height: 18),

            // Health Selector: Healthy vs Unhealthy
            const Text(
              'HEALTH CLASSIFICATION',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _HealthOption(
                    title: 'Healthy',
                    subtitle: 'Clean & Nutritious',
                    emoji: '🥗',
                    isSelected: _isHealthy,
                    selectedColor: const Color(0xFF10B981),
                    onTap: () => setState(() => _isHealthy = true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _HealthOption(
                    title: 'Unhealthy',
                    subtitle: 'Indulgence / Fast Food',
                    emoji: '🍔',
                    isSelected: !_isHealthy,
                    selectedColor: const Color(0xFFF59E0B),
                    onTap: () => setState(() => _isHealthy = false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Meal Type Segmented Selector
            const Text(
              'MEAL TIME',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: MealType.values.map((type) {
                final selected = _type == type;
                return ChoiceChip(
                  label: Text('${type.iconEmoji} ${type.label}'),
                  selected: selected,
                  onSelected: (_) => setState(() => _type = type),
                  selectedColor: theme.colorScheme.primaryContainer,
                  labelStyle: TextStyle(
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: selected
                        ? theme.colorScheme.onPrimaryContainer
                        : theme.colorScheme.onSurface,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 18),

            // Meal Name Input
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'What did you eat?',
                hintText: 'e.g. Avocado Toast with Eggs',
                prefixIcon: const Icon(LucideIcons.utensils),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 10),

            // Suggestion chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: (_isHealthy
                        ? _healthySuggestions
                        : _unhealthySuggestions)
                    .map((food) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ActionChip(
                            label: Text(food, style: const TextStyle(fontSize: 12)),
                            onPressed: () => _nameController.text = food,
                          ),
                        ))
                    .toList(),
              ),
            ),
            const SizedBox(height: 16),

            // Calories & Time in a row
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _caloriesController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Calories (kcal)',
                      hintText: 'Optional',
                      prefixIcon: const Icon(LucideIcons.flame),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: _pickTime,
                    icon: const Icon(LucideIcons.clock),
                    label: Text(DateFormat.jm().format(_dateTime)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Notes input
            TextField(
              controller: _notesController,
              decoration: InputDecoration(
                labelText: 'Notes or Ingredients (Optional)',
                hintText: 'e.g. Homemade, olive oil, gluten-free',
                prefixIcon: const Icon(LucideIcons.fileText),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 24),

            // Save button
            SizedBox(
              height: 54,
              child: FilledButton(
                onPressed: _save,
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  isEditing ? 'Save Changes' : 'Log Meal',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
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

class _HealthOption extends StatelessWidget {
  const _HealthOption({
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.isSelected,
    required this.selectedColor,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String emoji;
  final bool isSelected;
  final Color selectedColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? selectedColor.withValues(alpha: 0.12)
              : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? selectedColor
                : theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 30)),
            const SizedBox(height: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: isSelected ? selectedColor : theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: context.tokens.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
