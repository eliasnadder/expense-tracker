import 'package:expense_tracker/components/bars/app_bar.dart';
import 'package:expense_tracker/components/bars/search_bar.dart';
import 'package:expense_tracker/features/categories/presentation/bloc/category_bloc.dart';
import 'package:expense_tracker/features/categories/presentation/bloc/category_state.dart';
import 'package:expense_tracker/features/categories/presentation/screens/add_category_dialog.dart';
import 'package:expense_tracker/features/categories/presentation/widgets/category_ben_to_card.dart';
import 'package:expense_tracker/features/expenses/presentation/bloc/expense_bloc.dart';
import 'package:expense_tracker/features/expenses/presentation/bloc/expense_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CategoriesScreen extends StatefulWidget {
  final String? userId;

  const CategoriesScreen({super.key, this.userId});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: CustomAppBar(title: isAr ? 'الفئات' : 'Categories'),
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
              controller: _searchController,
              onChanged: (query) => setState(() => _searchQuery = query.toLowerCase()),
            ),
            const SizedBox(height: 32),

            // Categories Grid - Only shows user's selected/created categories
            BlocBuilder<ExpenseBloc, ExpenseState>(
              builder: (context, expenseState) {
                final expenses =
                    expenseState is ExpenseLoaded ? expenseState.expenses : [];

                return BlocBuilder<CategoryBloc, CategoryState>(
                  builder: (context, state) {
                    if (state is CategoryLoading) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    // Get user's categories from Firestore
                    final userCategories = state is CategoryLoaded
                        ? state.categories
                        : <dynamic>[];

                    if (userCategories.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Text(
                            isAr
                                ? 'لم تقم بإضافة أي فئات بعد. أضف فئة جديدة باستخدام الزر أدناه.'
                                : "You haven't added any categories yet. Add one using the button below.",
                            textAlign: TextAlign.center,
                            style: textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      );
                    }

                    // Build items from user's stored categories
                    final allItems = userCategories.map((cat) => _CategoryItem(
                      name: cat.name,
                      nameAr: cat.name,
                      emoji: cat.icon,
                      limit: cat.limit,
                    )).toList();

                    // Filter by search query
                    final filteredItems = _searchQuery.isEmpty
                        ? allItems
                        : allItems.where((item) =>
                            item.name.toLowerCase().contains(_searchQuery) ||
                            item.nameAr.toLowerCase().contains(_searchQuery),
                          ).toList();

                    if (filteredItems.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Text(
                            isAr
                                ? 'لا توجد فئات تطابق بحثك.'
                                : 'No categories match your search.',
                            textAlign: TextAlign.center,
                            style: textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      );
                    }

                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 1.1,
                      ),
                      itemCount: filteredItems.length,
                      itemBuilder: (context, index) {
                        final cat = filteredItems[index];
                        final count = expenses
                            .where((e) => e.category == cat.name)
                            .length;

                        return CategoryBentoCard(
                          title: isAr ? cat.nameAr : cat.name,
                          subtitle: isAr
                              ? '$count معاملات'
                              : '$count transactions',
                          emoji: cat.emoji,
                          iconBg: theme.colorScheme.secondaryContainer
                              .withValues(alpha: 0.3),
                          iconColor: theme.colorScheme.onPrimaryContainer,
                        );
                      },
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
        onPressed: () => _showAddCategoryDialog(context),
        backgroundColor: theme.colorScheme.primaryContainer,
        foregroundColor: theme.colorScheme.onPrimaryContainer,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddCategoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AddCategoryDialog(),
    );
  }
}

class _CategoryItem {
  final String name;
  final String nameAr;
  final String emoji;
  final double limit;

  const _CategoryItem({
    required this.name,
    required this.nameAr,
    required this.emoji,
    this.limit = 0,
  });
}
