import 'package:equatable/equatable.dart';

class ExpenseEntity extends Equatable {
  final String id;
  final String userId;
  final double amount;
  final String category;
  final String description;
  final DateTime date;
  final String? emoji;
  final String type; // 'income' or 'expense'

  const ExpenseEntity({
    required this.id,
    required this.userId,
    required this.amount,
    required this.category,
    required this.description,
    required this.date,
    this.emoji,
    this.type = 'expense',
  });

  bool get isIncome => type == 'income';

  @override
  List<Object?> get props => [
    id,
    userId,
    amount,
    category,
    description,
    date,
    type,
  ];
}
