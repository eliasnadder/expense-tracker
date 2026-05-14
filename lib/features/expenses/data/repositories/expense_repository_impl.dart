import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_tracker/features/expenses/data/models/expense_model.dart';
import 'package:expense_tracker/features/expenses/domain/entities/expense_entity.dart';
import 'package:expense_tracker/features/expenses/domain/repositories/expense_repository.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  final FirebaseFirestore firestore;

  ExpenseRepositoryImpl({required this.firestore});

  CollectionReference _expensesRef(String userId) =>
      firestore.collection('users').doc(userId).collection('expenses');

  @override
  Stream<List<ExpenseEntity>> getExpenses(String userId) {
    return _expensesRef(userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => ExpenseModel.fromMap(
                  doc.data() as Map<String, dynamic>,
                  doc.id,
                ),
              )
              .toList(),
        );
  }

  @override
  Future<void> addExpense(ExpenseEntity expense) async {
    final model = ExpenseModel.fromEntity(expense);
    await _expensesRef(expense.userId).doc(expense.id).set(model.toMap());
  }

  @override
  Future<void> updateExpense(ExpenseEntity expense) async {
    final model = ExpenseModel.fromEntity(expense);
    await _expensesRef(expense.userId).doc(expense.id).update(model.toMap());
  }

  @override
  Future<void> deleteExpense(String userId, String expenseId) async {
    await _expensesRef(userId).doc(expenseId).delete();
  }
}
