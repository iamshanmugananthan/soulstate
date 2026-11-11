import 'package:flutter/foundation.dart';

/// Categories of meals tracked throughout the day.
enum MealType {
  breakfast,
  lunch,
  dinner,
  snack;

  String get label {
    switch (this) {
      case MealType.breakfast:
        return 'Breakfast';
      case MealType.lunch:
        return 'Lunch';
      case MealType.dinner:
        return 'Dinner';
      case MealType.snack:
        return 'Snack';
    }
  }

  String get iconEmoji {
    switch (this) {
      case MealType.breakfast:
        return '🌅';
      case MealType.lunch:
        return '☀️';
      case MealType.dinner:
        return '🌙';
      case MealType.snack:
        return '🍎';
    }
  }
}

/// Represents an individual meal entry logged by the user.
@immutable
class MealEntry {
  const MealEntry({
    required this.id,
    required this.name,
    required this.type,
    required this.isHealthy,
    required this.dateTime,
    this.calories,
    this.notes,
    this.tags = const [],
  });

  final String id;
  final String name;
  final MealType type;
  final bool isHealthy;
  final DateTime dateTime;
  final int? calories;
  final String? notes;
  final List<String> tags;

  MealEntry copyWith({
    String? id,
    String? name,
    MealType? type,
    bool? isHealthy,
    DateTime? dateTime,
    int? calories,
    String? notes,
    List<String>? tags,
  }) {
    return MealEntry(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      isHealthy: isHealthy ?? this.isHealthy,
      dateTime: dateTime ?? this.dateTime,
      calories: calories ?? this.calories,
      notes: notes ?? this.notes,
      tags: tags ?? this.tags,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'type': type.name,
        'isHealthy': isHealthy,
        'dateTime': dateTime.toIso8601String(),
        'calories': calories,
        'notes': notes,
        'tags': tags,
      };

  factory MealEntry.fromMap(Map<String, dynamic> map) {
    return MealEntry(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      type: MealType.values.firstWhere(
        (t) => t.name == map['type'],
        orElse: () => MealType.breakfast,
      ),
      isHealthy: map['isHealthy'] as bool? ?? true,
      dateTime: DateTime.tryParse(map['dateTime'] as String? ?? '') ??
          DateTime.now(),
      calories: map['calories'] as int?,
      notes: map['notes'] as String?,
      tags: (map['tags'] as List?)?.map((e) => e.toString()).toList() ??
          const [],
    );
  }
}
