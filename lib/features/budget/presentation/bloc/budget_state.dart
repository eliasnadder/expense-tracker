import 'package:equatable/equatable.dart';
import 'package:expense_tracker/features/budget/domain/entities/budget_entity.dart';

abstract class BudgetState extends Equatable {
  @override
  List<Object?> get props => [];
}

class BudgetInitial extends BudgetState {}

class BudgetLoading extends BudgetState {}

class BudgetLoaded extends BudgetState {
  final List<BudgetEntity> budgets;
  BudgetLoaded(this.budgets);

  double get totalAmount => budgets.fold(0, (sum, b) => sum + b.amount);

  double get totalAmountThisMonth {
    final now = DateTime.now();
    return budgets
        .where((b) => b.month == now.month && b.year == now.year)
        .fold(0, (sum, b) => sum + b.amount);
  }

  double get monthlyBudgetLimit => getCategoryLimit('Total');

  double getCategoryLimit(String category, {int? month, int? year}) {
    final now = DateTime.now();
    final targetMonth = month ?? now.month;
    final targetYear = year ?? now.year;
    try {
      return budgets
          .firstWhere(
            (b) =>
                b.id == category &&
                b.month == targetMonth &&
                b.year == targetYear,
          )
          .amount;
    } catch (_) {
      return 0;
    }
  }

  @override
  List<Object?> get props => [budgets];
}

class BudgetError extends BudgetState {
  final String message;
  BudgetError(this.message);

  @override
  List<Object?> get props => [message];
}
