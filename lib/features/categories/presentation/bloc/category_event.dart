
import 'package:expense_tracker/features/categories/domain/entities/category_entity.dart';

abstract class CategoryEvent {}

class LoadCategories extends CategoryEvent {
  final String userId;

  LoadCategories(this.userId);
}

class AddCategory extends CategoryEvent {
  final CategoryEntity category;

  AddCategory(this.category);
}

class UpdateCategory extends CategoryEvent {
  final CategoryEntity category;

  UpdateCategory(this.category);
}

class DeleteCategory extends CategoryEvent {
  final String userId;
  final String categoryId;

  DeleteCategory(
    this.userId,
    this.categoryId,
  );
}

class CategoriesUpdated extends CategoryEvent {
  final List<CategoryEntity> categories;

  CategoriesUpdated(this.categories);
}