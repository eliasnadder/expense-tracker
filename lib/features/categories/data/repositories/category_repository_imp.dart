import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_tracker/features/categories/data/models/category_model.dart';
import 'package:expense_tracker/features/categories/domain/entities/category_entity.dart';
import 'package:expense_tracker/features/categories/domain/repositories/category_repository.dart';

class CategoryRepositoryImp implements CategoryRepository {
  final FirebaseFirestore firestore;

  CategoryRepositoryImp({required this.firestore});

  CollectionReference<Map<String, dynamic>> _collection(String userId) {
    return firestore.collection('users').doc(userId).collection('categories');
  }

  @override
  Stream<List<CategoryEntity>> getCategories(String userId) {
    return _collection(userId).snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => CategoryModel.fromMap(doc.data()))
          .toList();
    });
  }

  @override
  Future<void> addCategory(CategoryEntity category) async {
    final model = CategoryModel(
      id: category.id,
      userId: category.userId,
      name: category.name,
      icon: category.icon,
      limit: category.limit,
      isCustom: category.isCustom,
      createdAt: category.createdAt,
    );

    await _collection(category.userId).doc(category.id).set(model.toMap());
  }

  @override
  Future<void> updateCategory(CategoryEntity category) async {
    final model = CategoryModel(
      id: category.id,
      userId: category.userId,
      name: category.name,
      icon: category.icon,
      limit: category.limit,
      isCustom: category.isCustom,
      createdAt: category.createdAt,
    );

    await _collection(category.userId).doc(category.id).update(model.toMap());
  }

  @override
  Future<void> deleteCategory(String userId, String categoryId) async {
    await _collection(userId).doc(categoryId).delete();
  }
}
