import 'package:equatable/equatable.dart';
import 'package:expense_tracker/features/expenses/domain/entities/expense_entity.dart';

abstract class ExpenseState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ExpenseInitial extends ExpenseState {}

class ExpenseLoading extends ExpenseState {}

class ExpenseLoaded extends ExpenseState {
  final List<ExpenseEntity> expenses;

  ExpenseLoaded(this.expenses);

  double get totalIncome {
    final now = DateTime.now();
    return expenses
        .where(
          (e) =>
              e.isIncome &&
              e.date.month == now.month &&
              e.date.year == now.year,
        )
        .fold(0, (sum, e) => sum + e.amount);
  }

  double get totalExpenses {
    final now = DateTime.now();
    return expenses
        .where(
          (e) =>
              !e.isIncome &&
              e.date.month == now.month &&
              e.date.year == now.year,
        )
        .fold(0, (sum, e) => sum + e.amount);
  }

  double get totalThisMonth => totalIncome - totalExpenses;

  List<ExpenseEntity> get currentMonthExpenses {
    final now = DateTime.now();
    return expenses
        .where((e) => e.date.month == now.month && e.date.year == now.year)
        .toList();
  }

  @override
  List<Object?> get props => [expenses];
}

class ExpenseError extends ExpenseState {
  final String message;
  ExpenseError(this.message);

  @override
  List<Object?> get props => [message];
}
