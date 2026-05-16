import 'package:expense_tracker/components/bars/search_bar.dart';
import 'package:expense_tracker/core/constants/expense_categories.dart';
import 'package:expense_tracker/features/expenses/presentation/bloc/expense_bloc.dart';
import 'package:expense_tracker/features/expenses/presentation/bloc/expense_state.dart';
import 'package:expense_tracker/features/categories/presentation/widgets/category_ben_to_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        title: Text(
          isAr ? 'الفئات' : 'Categories',
          style: textTheme.titleLarge?.copyWith(
            fontSize: 22,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isAr ? 'إدارة الفئات' : 'Manage Categories',
              style: textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isAr
                  ? 'إدارة تصنيفات الإنفاق الخاصة بك.'
                  : 'Manage your spending classifications.',
              style: textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),

            // Search Bar
            MySearchBar(
              hintText: isAr ? 'البحث عن الفئات...' : 'Search categories...',
            ),
            const SizedBox(height: 32),

            // Categories Grid
            BlocBuilder<ExpenseBloc, ExpenseState>(
              builder: (context, state) {
                final expenses = state is ExpenseLoaded ? state.expenses : [];

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.1,
                  ),
                  itemCount: kCategories.length,
                  itemBuilder: (context, index) {
                    final cat = kCategories[index];
                    final count = expenses
                        .where((e) => e.category == cat.name)
                        .length;

                    return CategoryBentoCard(
                      title: isAr ? cat.nameAr : cat.name,
                      subtitle: isAr ? '$count معاملات' : '$count transactions',
                      emoji: cat.emoji,
                      iconBg: cat.type == 'income'
                          ? theme.colorScheme.primary.withValues(alpha: 0.1)
                          : theme.colorScheme.secondaryContainer.withValues(
                              alpha: 0.3,
                            ),
                      iconColor: cat.type == 'income'
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onPrimaryContainer,
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isAr
                    ? 'الفئات المخصصة غير متاحة بعد.'
                    : 'Custom categories are not available yet.',
              ),
            ),
          );
        },
        backgroundColor: theme.colorScheme.primaryContainer,
        foregroundColor: theme.colorScheme.onPrimaryContainer,
        child: const Icon(Icons.add),
      ),
    );
  }
}
