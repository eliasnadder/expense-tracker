import 'package:expense_tracker/core/constants/expense_categories.dart';
import 'package:expense_tracker/utilities/icon_helper.dart';
import 'package:flutter/material.dart';

class CategorySection extends StatelessWidget {
  final bool isAr;
  final String selectedCategory;
  final ValueChanged<String> onSelected;

  const CategorySection({
    required this.isAr,
    required this.selectedCategory,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final categories = [
      {'id': 'All', 'name': isAr ? 'الكل' : 'All', 'icon': Icons.grid_view},
      ...kCategories
          .take(6)
          .map(
            (c) => {
              'id': c.name,
              'name': isAr ? c.nameAr : c.name,
              'icon': getIconForCategory(c.name),
            },
          ),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: categories.map((cat) {
          final id = cat['id'] as String;
          final isSelected = id == selectedCategory;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              selected: isSelected,
              onSelected: (_) => onSelected(id),
              label: Text(cat['name'] as String),
              avatar: Icon(cat['icon'] as IconData, size: 16),
              backgroundColor: Theme.of(
                context,
              ).colorScheme.surfaceContainerLowest,
              selectedColor: Theme.of(context).colorScheme.primaryContainer,
              labelStyle: TextStyle(
                color: isSelected
                    ? Theme.of(context).colorScheme.onSecondaryContainer
                    : Theme.of(context).colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
