import 'package:equatable/equatable.dart';

abstract class BudgetEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadBudgets extends BudgetEvent {
  final String userId;
  LoadBudgets(this.userId);
  @override
  List<Object?> get props => [userId];
}

class SetBudget extends BudgetEvent {
  final String userId;
  final String category;
  final double amount;
  final int month;
  final int year;
  SetBudget({
    required this.userId,
    required this.category,
    required this.amount,
    required this.month,
    required this.year,
  });

  @override
  List<Object?> get props => [userId, category, amount, month, year];
}

class ClearBudgets extends BudgetEvent {}
