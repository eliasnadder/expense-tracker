import 'package:expense_tracker/features/categories/domain/entities/category_entity.dart';
import 'package:expense_tracker/features/categories/presentation/bloc/category_bloc.dart';
import 'package:expense_tracker/features/categories/presentation/bloc/category_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
    return BlocBuilder<CategoryBloc, CategoryState>(
      builder: (context, state) {
        final userCategories = state is CategoryLoaded
            ? state.categories
            : <CategoryEntity>[];

        final categories = [
          {'id': 'All', 'name': isAr ? 'الكل' : 'All'},
          ...userCategories.map(
            (c) => {
              'id': c.name,
              'name': c.name,
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
      },
    );
  }
}
