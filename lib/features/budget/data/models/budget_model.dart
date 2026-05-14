import 'package:expense_tracker/features/budget/domain/entities/budget_entity.dart';

class BudgetModel extends BudgetEntity {
  const BudgetModel({
    required super.id,
    required super.userId,
    required super.amount,
    required super.month,
    required super.year,
  });

  factory BudgetModel.fromMap(Map<String, dynamic> map, String id) {
    return BudgetModel(
      id: id,
      userId: map['userId'] as String? ?? '',
      amount: (map['amount'] as num? ?? 0).toDouble(),
      month: (map['month'] as num? ?? DateTime.now().month).toInt(),
      year: (map['year'] as num? ?? DateTime.now().year).toInt(),
    );
  }

  Map<String, dynamic> toMap() {
    return {'userId': userId, 'amount': amount, 'month': month, 'year': year};
  }
}
