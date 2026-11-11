enum MoneyKind { expense, income }

MoneyKind moneyKindFrom(Object? raw) =>
    raw == MoneyKind.income.name ? MoneyKind.income : MoneyKind.expense;

class MoneyTransaction {
  const MoneyTransaction({
    required this.id,
    required this.kind,
    required this.amount,
    required this.categoryId,
    required this.at,
    this.note = '',
    this.label = '',
  });

  final String id;
  final MoneyKind kind;
  final double amount;
  final String categoryId;
  final DateTime at;
  final String note;

  /// Name of the category when it was saved, shown if the category is deleted.
  final String label;

  bool get isExpense => kind == MoneyKind.expense;

  double get signed => isExpense ? -amount : amount;

  DateTime get day => DateTime(at.year, at.month, at.day);

  MoneyTransaction copyWith({
    MoneyKind? kind,
    double? amount,
    String? categoryId,
    DateTime? at,
    String? note,
    String? label,
  }) => MoneyTransaction(
    id: id,
    kind: kind ?? this.kind,
    amount: amount ?? this.amount,
    categoryId: categoryId ?? this.categoryId,
    at: at ?? this.at,
    note: note ?? this.note,
    label: label ?? this.label,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'kind': kind.name,
    'amount': amount,
    'category': categoryId,
    'at': at.millisecondsSinceEpoch,
    'note': note,
    'label': label,
  };

  factory MoneyTransaction.fromMap(Map<String, dynamic> map) =>
      MoneyTransaction(
        id: map['id'] as String,
        kind: moneyKindFrom(map['kind']),
        amount: ((map['amount'] ?? 0) as num).toDouble(),
        categoryId: (map['category'] ?? '') as String,
        at: DateTime.fromMillisecondsSinceEpoch(
          ((map['at'] ?? 0) as num).toInt(),
        ),
        note: (map['note'] ?? '') as String,
        label: (map['label'] ?? '') as String,
      );
}
