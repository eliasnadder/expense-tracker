import 'dart:async';
import 'package:expense_tracker/features/budget/data/models/budget_model.dart';
import 'package:expense_tracker/features/budget/domain/entities/budget_entity.dart';
import 'package:expense_tracker/features/budget/domain/repositories/budget_repository.dart';
import 'package:expense_tracker/features/budget/presentation/bloc/budget_event.dart';
import 'package:expense_tracker/features/budget/presentation/bloc/budget_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class _BudgetsUpdated extends BudgetEvent {
  final List<BudgetEntity> budgets;
  _BudgetsUpdated(this.budgets);
  @override
  List<Object?> get props => [budgets];
}

class BudgetBloc extends Bloc<BudgetEvent, BudgetState> {
  final BudgetRepository budgetRepository;
  StreamSubscription? _budgetSubscription;

  BudgetBloc({required this.budgetRepository}) : super(BudgetInitial()) {
    on<LoadBudgets>(_onLoadBudgets);
    on<SetBudget>(_onSetBudget);
    on<ClearBudgets>(_onClearBudgets);
    on<_BudgetsUpdated>((event, emit) => emit(BudgetLoaded(event.budgets)));
  }

  void _onClearBudgets(ClearBudgets event, Emitter<BudgetState> emit) {
    _budgetSubscription?.cancel();
    emit(BudgetInitial());
  }

  Future<void> _onLoadBudgets(
    LoadBudgets event,
    Emitter<BudgetState> emit,
  ) async {
    emit(BudgetLoading());
    _budgetSubscription?.cancel();
    _budgetSubscription = budgetRepository
        .getBudgets(event.userId)
        .listen(
          (budgets) => add(_BudgetsUpdated(budgets)),
          onError: (e) => emit(BudgetError(e.toString())),
        );
  }

  Future<void> _onSetBudget(SetBudget event, Emitter<BudgetState> emit) async {
    try {
      final budget = BudgetModel(
        id: event.category,
        userId: event.userId,
        amount: event.amount,
        month: event.month,
        year: event.year,
      );
      await budgetRepository.setBudget(budget);
    } catch (e) {
      emit(BudgetError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _budgetSubscription?.cancel();
    return super.close();
  }
}
