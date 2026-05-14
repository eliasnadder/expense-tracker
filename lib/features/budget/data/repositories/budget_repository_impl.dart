import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_tracker/features/budget/data/models/budget_model.dart';
import 'package:expense_tracker/features/budget/domain/entities/budget_entity.dart';
import 'package:expense_tracker/features/budget/domain/repositories/budget_repository.dart';

class BudgetRepositoryImpl implements BudgetRepository {
  final FirebaseFirestore firestore;

  BudgetRepositoryImpl({required this.firestore});

  CollectionReference _budgetsRef(String userId) =>
      firestore.collection('users').doc(userId).collection('budgets');

  @override
  Stream<List<BudgetEntity>> getBudgets(String userId) {
    return _budgetsRef(userId).snapshots().map(
      (snapshot) => snapshot.docs
          .map(
            (doc) =>
                BudgetModel.fromMap(doc.data() as Map<String, dynamic>, doc.id),
          )
          .toList(),
    );
  }

  @override
  Future<void> setBudget(BudgetEntity budget) async {
    final model = budget is BudgetModel
        ? budget
        : BudgetModel(
            id: budget.id,
            userId: budget.userId,
            amount: budget.amount,
            month: budget.month,
            year: budget.year,
          );
    await _budgetsRef(budget.userId).doc(budget.id).set(model.toMap());
  }

  @override
  Future<void> deleteBudget(String userId, String category) async {
    await _budgetsRef(userId).doc(category).delete();
  }
}
