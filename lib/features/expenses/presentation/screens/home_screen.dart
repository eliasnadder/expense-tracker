import 'package:expense_tracker/core/constants/expense_categories.dart';
import 'package:expense_tracker/core/di/injection.dart';
import 'package:expense_tracker/core/theme/app_theme.dart';
import 'package:expense_tracker/utilities/icon_helper.dart';

import 'package:expense_tracker/features/ai_insight/presentation/bloc/ai_bloc.dart';
import 'package:expense_tracker/features/analytics/presentation/screens/analytics_screen.dart';
import 'package:expense_tracker/features/auth/domain/entities/user_entity.dart';
import 'package:expense_tracker/features/budget/presentation/bloc/budget_bloc.dart';
import 'package:expense_tracker/features/budget/presentation/bloc/budget_state.dart';
import 'package:expense_tracker/features/budget/presentation/widgets/budget_card.dart';
import 'package:expense_tracker/features/expenses/domain/entities/expense_entity.dart';
import 'package:expense_tracker/features/expenses/presentation/bloc/expense_bloc.dart';
import 'package:expense_tracker/features/expenses/presentation/bloc/expense_state.dart';
import 'package:expense_tracker/features/expenses/presentation/screens/add_expense_screen.dart';
import 'package:expense_tracker/features/expenses/presentation/widgets/expense_card.dart';
import 'package:expense_tracker/features/budget/presentation/screens/budgets_screen.dart';
import 'package:expense_tracker/features/expenses/presentation/screens/timeline_screen.dart';
import 'package:expense_tracker/features/auth/presentation/screens/profile_screen.dart';
import 'package:expense_tracker/features/expenses/presentation/screens/categories_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeScreen extends StatelessWidget {
  final UserEntity user;
  const HomeScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return _NavShell(user: user);
  }
}

class _HomeBody extends StatefulWidget {
  final UserEntity user;
  const _HomeBody({required this.user});

  @override
  State<_HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends State<_HomeBody> {
  String _selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    return BlocBuilder<ExpenseBloc, ExpenseState>(
      builder: (context, expenseState) {
        final spent = expenseState is ExpenseLoaded
            ? expenseState.totalExpenses
            : 0.0;

        final recentExpenses = expenseState is ExpenseLoaded
            ? _recentExpenses(expenseState.expenses)
            : <ExpenseEntity>[];

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (expenseState is ExpenseLoaded)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                  child: Text(
                    'Monthly Budget',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),

              BlocBuilder<BudgetBloc, BudgetState>(
                builder: (context, budgetState) {
                  final totalLimit = budgetState is BudgetLoaded
                      ? budgetState.monthlyBudgetLimit
                      : 0.0;
                  return BudgetCard(
                    budget: totalLimit,
                    spent: spent,
                    isAr: isAr,
                    userId: widget.user.id,
                    isBudgetScreen: false,
                  );
                },
              ),
              SizedBox(height: 16),
              // Category Chips
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isAr ? 'الفئات' : 'Categories',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CategoriesScreen(),
                        ),
                      ),
                      child: Text(isAr ? 'إدارة' : 'Manage'),
                    ),
                  ],
                ),
              ),
              _CategorySection(
                isAr: isAr,
                selectedCategory: _selectedCategory,
                onSelected: (category) =>
                    setState(() => _selectedCategory = category),
              ),
              SizedBox(height: 16),

              if (expenseState is ExpenseLoading)
                const Center(child: CircularProgressIndicator())
              else if (expenseState is ExpenseLoaded &&
                  recentExpenses.isNotEmpty)
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isAr ? 'المعاملات الأخيرة' : 'Recent Transactions',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              _NavShellState.of(context)?.goToTab(1);
                            },
                            child: Text(isAr ? 'رؤية الكل' : 'See All'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: recentExpenses.length,
                itemBuilder: (context, index) {
                  final expense = recentExpenses[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14.0,
                      vertical: 4.0,
                    ),
                    child: ExpenseCard(
                      expense: expense,
                      userId: widget.user.id,
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  List<ExpenseEntity> _recentExpenses(List<ExpenseEntity> expenses) {
    final filtered = _selectedCategory == 'All'
        ? expenses
        : expenses
              .where((expense) => expense.category == _selectedCategory)
              .toList();
    return filtered.take(5).toList();
  }
}

class _CategorySection extends StatelessWidget {
  final bool isAr;
  final String selectedCategory;
  final ValueChanged<String> onSelected;

  const _CategorySection({
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

class _NavShell extends StatefulWidget {
  final UserEntity user;
  const _NavShell({required this.user});

  @override
  State<_NavShell> createState() => _NavShellState();
}

class _NavShellState extends State<_NavShell> {
  int _currentIndex = 0;

  static _NavShellState? of(BuildContext context) {
    return context.findAncestorStateOfType<_NavShellState>();
  }

  void goToTab(int index) {
    if (index < 0 || index > 3) return;
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    final screens = [
      _HomeBody(user: widget.user),
      TimelineScreen(userId: widget.user.id),
      BudgetsScreen(userId: widget.user.id),
      BlocProvider(
        create: (_) => getIt<AiBloc>(),
        child: const AnalyticsScreen(),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: screens[_currentIndex] is _HomeBody
            ? Text(
                isAr ? 'الرئيسية' : 'Home',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: 28,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              )
            : screens[_currentIndex] is TimelineScreen
            ? Text(
                isAr ? 'الخط الزمني' : 'Timeline',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: 28,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              )
            : screens[_currentIndex] is BudgetsScreen
            ? Text(
                isAr ? 'الميزانيات' : 'Budgets',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: 28,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              )
            : Text(
                isAr ? 'التحليلات' : 'Analytics',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: 28,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
        actions: [
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            ),
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: CircleAvatar(
                radius: 18,
                backgroundImage: widget.user.photoUrl != null
                    ? NetworkImage(widget.user.photoUrl!)
                    : null,
                backgroundColor: AppColors.surfaceContainerHighest,
                child: widget.user.photoUrl == null
                    ? Text(
                        widget.user.displayName.isNotEmpty
                            ? widget.user.displayName.characters.first
                                  .toUpperCase()
                            : 'U',
                      )
                    : null,
              ),
            ),
          ),
        ],
      ),
      body: screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        indicatorColor: Theme.of(context).colorScheme.primaryContainer,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.dashboard_outlined),
            selectedIcon: const Icon(Icons.dashboard),
            label: isAr ? 'الرئيسية' : 'Home',
          ),
          NavigationDestination(
            icon: const Icon(Icons.receipt_long_outlined),
            selectedIcon: const Icon(Icons.receipt_long),
            label: isAr ? 'الخط الزمني' : 'Timeline',
          ),
          NavigationDestination(
            icon: const Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: const Icon(Icons.account_balance_wallet),
            label: isAr ? 'الميزانيات' : 'Budgets',
          ),
          NavigationDestination(
            icon: const Icon(Icons.bar_chart_outlined),
            selectedIcon: const Icon(Icons.bar_chart),
            label: isAr ? 'التحليلات' : 'Charts',
          ),
        ],
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddExpenseScreen(userId: widget.user.id),
                ),
              ),
              child: const Icon(Icons.add, size: 32),
            )
          : null,
    );
  }
}
