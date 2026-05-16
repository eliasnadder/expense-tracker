import 'package:expense_tracker/features/categories/domain/entities/category_entity.dart';

class CategoryModel extends CategoryEntity {
  const CategoryModel({
    required super.id,
    required super.userId,
    required super.name,
    required super.icon,
    required super.limit,
    required super.isCustom,
    required super.createdAt,
  });

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'],
      userId: map['userId'],
      name: map['name'],
      icon: map['icon'],
      limit: (map['limit'] as num).toDouble(),
      isCustom: map['isCustom'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'icon': icon,
      'limit': limit,
      'isCustom': isCustom,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
