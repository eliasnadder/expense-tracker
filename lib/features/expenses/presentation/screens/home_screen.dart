import 'package:expense_tracker/core/constants/expense_categories.dart';
import 'package:expense_tracker/core/di/injection.dart';
import 'package:expense_tracker/core/theme/app_theme.dart';
 import 'package:expense_tracker/utilities/icon_helper.dart';


import 'package:expense_tracker/features/ai_insight/presentation/bloc/ai_bloc.dart';
import 'package:expense_tracker/features/analytics/presentation/screens/analytics_screen.dart';
import 'package:expense_tracker/features/auth/domain/entities/user_entity.dart';
import 'package:expense_tracker/features/budget/presentation/bloc/budget_bloc.dart';
import 'package:expense_tracker/features/budget/presentation/bloc/budget_event.dart';
import 'package:expense_tracker/features/budget/presentation/bloc/budget_state.dart';
import 'package:expense_tracker/features/budget/presentation/widgets/budget_card.dart';
import 'package:expense_tracker/features/expenses/domain/entities/expense_entity.dart';
import 'package:expense_tracker/features/expenses/presentation/bloc/expense_bloc.dart';
import 'package:expense_tracker/features/expenses/presentation/bloc/expense_event.dart';
import 'package:expense_tracker/features/expenses/presentation/bloc/expense_state.dart';
import 'package:expense_tracker/features/expenses/presentation/screens/add_expense_screen.dart';
import 'package:expense_tracker/features/expenses/presentation/widgets/expense_card.dart';
import 'package:expense_tracker/features/budget/presentation/screens/budgets_screen.dart';
import 'package:expense_tracker/features/expenses/presentation/screens/timeline_screen.dart';
import 'package:expense_tracker/features/auth/presentation/screens/profile_screen.dart';
import 'package:expense_tracker/features/expenses/presentation/screens/categories_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

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

  Future<void> _showSetBudgetDialog(
    BuildContext context,
    bool isAr,
    double currentBudget,
  ) async {
    final controller = TextEditingController(
      text: currentBudget > 0 ? currentBudget.toStringAsFixed(0) : '',
    );
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(isAr ? 'تحديد الميزانية' : 'Set Budget'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: isAr ? 'المبلغ الشهري' : 'Monthly Amount',
            prefixText: '\$ ',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(isAr ? 'إلغاء' : 'Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final amount = double.tryParse(controller.text.trim());
              if (amount != null && amount > 0) {
                final now = DateTime.now();
                context.read<BudgetBloc>().add(
                  SetBudget(
                    userId: widget.user.id,
                    category: 'Total',
                    amount: amount,
                    month: now.month,
                    year: now.year,
                  ),
                );
                Navigator.pop(dialogContext);
              }
            },
            child: Text(isAr ? 'حفظ' : 'Save'),
          ),
        ],
      ),
    );
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
                _SummaryCard(
                  total: expenseState.totalThisMonth,
                  name: widget.user.displayName,
                  isAr: isAr,
                  theme: theme,
                ),

              // Category Chips
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
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

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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
                    onSetBudget: () =>
                        _showSetBudgetDialog(context, isAr, totalLimit),
                  );
                },
              ),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
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

              if (expenseState is ExpenseLoading)
                const Center(child: CircularProgressIndicator())
              else if (expenseState is ExpenseLoaded && recentExpenses.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: Text(
                      isAr
                          ? (_selectedCategory == 'All'
                                ? 'لا توجد معاملات بعد'
                                : 'لا توجد معاملات لهذه الفئة')
                          : (_selectedCategory == 'All'
                                ? 'No transactions yet'
                                : 'No transactions for this category'),
                      style: theme.textTheme.bodyLarge,
                    ),
                  ),
                )
              else if (expenseState is ExpenseLoaded)
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 100),
                  itemCount: recentExpenses.length,
                  itemBuilder: (context, index) {
                    final expense = recentExpenses[index];
                    return ExpenseCard(
                      expense: expense,
                      onDelete: () => context.read<ExpenseBloc>().add(
                        DeleteExpense(widget.user.id, expense.id),
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
      ...kCategories.take(6).map((c) => {
        'id': c.name,
        'name': isAr ? c.nameAr : c.name,
        'icon': getIconForCategory(c.name),
      }),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
              backgroundColor: AppColors.surfaceContainerLowest,
              selectedColor: AppColors.secondaryContainer,
              labelStyle: TextStyle(
                color: isSelected
                    ? AppColors.onSecondaryContainer
                    : AppColors.onSurface,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
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
      const BudgetsScreen(),
      BlocProvider(
        create: (_) => getIt<AiBloc>(),
        child: const AnalyticsScreen(),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isAr ? 'المحفظة الذكية' : 'Financial Hub',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
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

class _SummaryCard extends StatelessWidget {
  final double total;
  final String name;
  final bool isAr;
  final ThemeData theme;

  const _SummaryCard({
    required this.total,
    required this.name,
    required this.isAr,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.1),
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -20,
            right: -20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.primaryContainer.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isAr ? 'إجمالي الرصيد' : 'Total Balance',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              if (name.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  isAr ? 'مرحباً، $name' : 'Hi, $name',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Text(
                '\$${NumberFormat('#,##0.00').format(total)}',
                style: theme.textTheme.displayLarge?.copyWith(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ],
      ),
    );
  }
}
