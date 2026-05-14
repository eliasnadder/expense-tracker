import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_tracker/features/budget/domain/entities/budget_entity.dart';
import 'package:expense_tracker/features/budget/presentation/bloc/budget_state.dart';
import 'package:expense_tracker/features/expenses/data/models/expense_model.dart';
import 'package:expense_tracker/features/expenses/domain/entities/expense_entity.dart';
import 'package:expense_tracker/features/expenses/presentation/bloc/expense_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ExpenseLoaded totals', () {
    test('separates current-month income and expenses', () {
      final now = DateTime.now();
      final state = ExpenseLoaded([
        ExpenseEntity(
          id: 'income',
          userId: 'user',
          amount: 1000,
          category: 'Salary',
          description: 'Paycheck',
          date: now,
          type: 'income',
        ),
        ExpenseEntity(
          id: 'expense',
          userId: 'user',
          amount: 125,
          category: 'Food',
          description: 'Groceries',
          date: now,
        ),
        ExpenseEntity(
          id: 'old-expense',
          userId: 'user',
          amount: 999,
          category: 'Food',
          description: 'Last month',
          date: DateTime(now.year, now.month - 1, 1),
        ),
      ]);

      expect(state.totalIncome, 1000);
      expect(state.totalExpenses, 125);
      expect(state.totalThisMonth, 875);
      expect(state.currentMonthExpenses, hasLength(2));
    });
  });

  group('ExpenseModel.fromMap', () {
    test('handles Firestore timestamps and missing optional fields', () {
      final date = DateTime(2026, 5, 14);
      final model = ExpenseModel.fromMap({
        'userId': 'user',
        'amount': 42,
        'category': 'Food',
        'date': Timestamp.fromDate(date),
      }, 'expense-id');

      expect(model.id, 'expense-id');
      expect(model.amount, 42);
      expect(model.description, '');
      expect(model.date, date);
      expect(model.type, 'expense');
    });
  });

  group('BudgetLoaded', () {
    test('keeps total monthly budget separate from category budgets', () {
      final now = DateTime.now();
      final state = BudgetLoaded([
        BudgetEntity(
          id: 'Total',
          userId: 'user',
          amount: 200,
          month: now.month,
          year: now.year,
        ),
        BudgetEntity(
          id: 'Food',
          userId: 'user',
          amount: 100,
          month: now.month,
          year: now.year,
        ),
        BudgetEntity(
          id: 'Food',
          userId: 'user',
          amount: 999,
          month: now.month == 1 ? 12 : now.month - 1,
          year: now.month == 1 ? now.year - 1 : now.year,
        ),
      ]);

      expect(state.monthlyBudgetLimit, 200);
      expect(state.getCategoryLimit('Food'), 100);
      expect(state.totalAmountThisMonth, 300);
    });
  });
}
