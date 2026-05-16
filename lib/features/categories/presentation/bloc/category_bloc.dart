import 'dart:async';

import 'package:expense_tracker/features/categories/domain/repositories/category_repository.dart';
import 'package:expense_tracker/features/categories/presentation/bloc/category_event.dart';
import 'package:expense_tracker/features/categories/presentation/bloc/category_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final CategoryRepository repository;

  StreamSubscription? _subscription;

  CategoryBloc(this.repository) : super(CategoryInitial()) {
    on<LoadCategories>(_onLoadCategories);

    on<AddCategory>(_onAddCategory);

    on<UpdateCategory>(_onUpdateCategory);

    on<DeleteCategory>(_onDeleteCategory);

    on<CategoriesUpdated>((event, emit) {
      emit(CategoryLoaded(event.categories));
    });
  }

  Future<void> _onLoadCategories(
    LoadCategories event,
    Emitter<CategoryState> emit,
  ) async {
    emit(CategoryLoading());

    await _subscription?.cancel();

    _subscription = repository.getCategories(event.userId).listen((categories) {
      add(CategoriesUpdated(categories));
    });
  }

  Future<void> _onAddCategory(
    AddCategory event,
    Emitter<CategoryState> emit,
  ) async {
    await repository.addCategory(event.category);
  }

  Future<void> _onUpdateCategory(
    UpdateCategory event,
    Emitter<CategoryState> emit,
  ) async {
    await repository.updateCategory(event.category);
  }

  Future<void> _onDeleteCategory(
    DeleteCategory event,
    Emitter<CategoryState> emit,
  ) async {
    await repository.deleteCategory(event.userId, event.categoryId);
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
