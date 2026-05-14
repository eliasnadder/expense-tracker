import 'package:equatable/equatable.dart';
import 'package:expense_tracker/features/expenses/domain/entities/expense_entity.dart';

abstract class AiEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class AnalyzeExpenses extends AiEvent {
  final List<ExpenseEntity> expenses;
  final double budget;
  final bool isAr;

  AnalyzeExpenses({
    required this.expenses,
    required this.budget,
    required this.isAr,
  });

  @override
  List<Object?> get props => [expenses, budget, isAr];
}
