import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_tracker/features/expenses/domain/entities/expense_entity.dart';

class ExpenseModel extends ExpenseEntity {
  const ExpenseModel({
    required super.id,
    required super.userId,
    required super.amount,
    required super.category,
    required super.description,
    required super.date,
    super.emoji,
    super.type = 'expense',
  });

  factory ExpenseModel.fromMap(Map<String, dynamic> map, String id) {
    return ExpenseModel(
      id: id,
      userId: map['userId'] as String? ?? '',
      amount: (map['amount'] as num? ?? 0).toDouble(),
      category: map['category'] as String? ?? 'Other',
      description: map['description'] as String? ?? '',
      date: _readDate(map['date']),
      emoji: map['emoji'] as String?,
      type: map['type'] as String? ?? 'expense',
    );
  }

  factory ExpenseModel.fromEntity(ExpenseEntity expense) {
    if (expense is ExpenseModel) return expense;
    return ExpenseModel(
      id: expense.id,
      userId: expense.userId,
      amount: expense.amount,
      category: expense.category,
      description: expense.description,
      date: expense.date,
      emoji: expense.emoji,
      type: expense.type,
    );
  }

  static DateTime _readDate(Object? value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'amount': amount,
      'category': category,
      'description': description,
      'date': Timestamp.fromDate(date),
      'emoji': emoji,
      'type': type,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  ExpenseModel copyWith({
    String? id,
    String? userId,
    double? amount,
    String? category,
    String? description,
    DateTime? date,
    String? emoji,
    String? type,
  }) {
    return ExpenseModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      description: description ?? this.description,
      date: date ?? this.date,
      emoji: emoji ?? this.emoji,
      type: type ?? this.type,
    );
  }
}
