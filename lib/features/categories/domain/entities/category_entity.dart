class CategoryEntity {
  final String id;
  final String userId;

  final String name;
  final String icon;

  final double limit;

  final bool isCustom;

  final DateTime createdAt;

  const CategoryEntity({
    required this.id,
    required this.userId,
    required this.name,
    required this.icon,
    required this.limit,
    required this.isCustom,
    required this.createdAt,
  });
}
