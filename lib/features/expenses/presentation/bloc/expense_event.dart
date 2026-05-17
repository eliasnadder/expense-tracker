import 'package:equatable/equatable.dart';
import 'package:expense_tracker/features/expenses/domain/entities/expense_entity.dart';

abstract class ExpenseEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadExpenses extends ExpenseEvent {
  final String userId;
  LoadExpenses(this.userId);

  @override
  List<Object?> get props => [userId];
}

class AddExpense extends ExpenseEvent {
  final ExpenseEntity expense;
  AddExpense(this.expense);

  @override
  List<Object?> get props => [expense];
}

class UpdateExpense extends ExpenseEvent {
  final ExpenseEntity expense;
  UpdateExpense(this.expense);

  @override
  List<Object?> get props => [expense];
}

class DeleteExpense extends ExpenseEvent {
  final String userId;
  final String expenseId;
  DeleteExpense(this.userId, this.expenseId);

  @override
  List<Object?> get props => [userId, expenseId];
}

class ClearExpenses extends ExpenseEvent {}
