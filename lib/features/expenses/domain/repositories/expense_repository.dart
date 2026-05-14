import 'package:expense_tracker/features/expenses/domain/entities/expense_entity.dart';

abstract class ExpenseRepository {
  Stream<List<ExpenseEntity>> getExpenses(String userId);
  Future<void> addExpense(ExpenseEntity expense);
  Future<void> updateExpense(ExpenseEntity expense);
  Future<void> deleteExpense(String userId, String expenseId);
}
