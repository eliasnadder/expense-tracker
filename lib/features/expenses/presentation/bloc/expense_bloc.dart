import 'dart:async';

import 'package:expense_tracker/features/expenses/domain/entities/expense_entity.dart';
import 'package:expense_tracker/features/expenses/domain/repositories/expense_repository.dart';
import 'package:expense_tracker/features/expenses/presentation/bloc/expense_event.dart';
import 'package:expense_tracker/features/expenses/presentation/bloc/expense_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ExpenseBloc extends Bloc<ExpenseEvent, ExpenseState> {
  final ExpenseRepository expenseRepository;
  StreamSubscription? _expenseSubscription;

  ExpenseBloc({required this.expenseRepository}) : super(ExpenseInitial()) {
    on<LoadExpenses>(_onLoadExpenses);
    on<AddExpense>(_onAddExpense);
    on<UpdateExpense>(_onUpdateExpense);
    on<DeleteExpense>(_onDeleteExpense);
    on<ClearExpenses>(_onClearExpenses);
    on<_ExpensesUpdated>((event, emit) => emit(ExpenseLoaded(event.expenses)));
  }

  void _onClearExpenses(ClearExpenses event, Emitter<ExpenseState> emit) {
    _expenseSubscription?.cancel();
    emit(ExpenseInitial());
  }

  void _onLoadExpenses(LoadExpenses event, Emitter<ExpenseState> emit) {
    emit(ExpenseLoading());
    _expenseSubscription?.cancel();
    _expenseSubscription = expenseRepository
        .getExpenses(event.userId)
        .listen(
          (expenses) => add(_ExpensesUpdated(expenses)),
          onError: (e) => emit(ExpenseError(e.toString())),
        );
  }

  Future<void> _onAddExpense(
    AddExpense event,
    Emitter<ExpenseState> emit,
  ) async {
    try {
      await expenseRepository.addExpense(event.expense);
    } catch (e) {
      emit(ExpenseError(e.toString()));
    }
  }

  Future<void> _onUpdateExpense(
    UpdateExpense event,
    Emitter<ExpenseState> emit,
  ) async {
    try {
      await expenseRepository.updateExpense(event.expense);
    } catch (e) {
      emit(ExpenseError(e.toString()));
    }
  }

  Future<void> _onDeleteExpense(
    DeleteExpense event,
    Emitter<ExpenseState> emit,
  ) async {
    try {
      await expenseRepository.deleteExpense(event.userId, event.expenseId);
    } catch (e) {
      emit(ExpenseError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _expenseSubscription?.cancel();
    return super.close();
  }
}

class _ExpensesUpdated extends ExpenseEvent {
  final List<ExpenseEntity> expenses;
  _ExpensesUpdated(this.expenses);
  @override
  List<Object?> get props => [expenses];
}
