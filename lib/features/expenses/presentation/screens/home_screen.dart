import 'package:expense_tracker/core/di/injection.dart';
import 'package:expense_tracker/features/categories/presentation/widgets/category_section.dart';
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
import 'package:expense_tracker/features/categories/presentation/screens/categories_screen.dart';
import 'package:expense_tracker/features/expenses/presentation/widgets/no_expnese.dart';
import 'package:flutter/material.dart';
import 'package:flutter_floating_bottom_bar/flutter_floating_bottom_bar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

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

        final scrollPhysics = recentExpenses.isEmpty
            ? const NeverScrollableScrollPhysics()
            : const BouncingScrollPhysics();

        return CustomScrollView(
          physics: scrollPhysics, 
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (expenseState is ExpenseLoaded)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 8,
                      ),
                      child: Text(
                        'Monthly Budget',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
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
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isAr ? 'الفئات' : 'Categories',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
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
                  CategorySection(
                    isAr: isAr,
                    selectedCategory: _selectedCategory,
                    onSelected: (category) =>
                        setState(() => _selectedCategory = category),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
            if (expenseState is ExpenseLoading)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: LoadingAnimationWidget.inkDrop(
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                ),
              )
            else if (expenseState is ExpenseLoaded && recentExpenses.isEmpty)
              NoExpense(
                isAr: isAr,
                userId: widget.user.id,
                mainAxisAlignment: MainAxisAlignment.start,
              )
            else if (expenseState is ExpenseLoaded && recentExpenses.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isAr ? 'المعاملات الأخيرة' : 'Recent Transactions',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
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
              ),
            SliverPadding(
              padding: const EdgeInsets.only(
                bottom: 120,
              ), // Padding for scrolling past FAB/Bar
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final expense = recentExpenses[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: ExpenseCard(
                      expense: expense,
                      userId: widget.user.id,
                    ),
                  );
                }, childCount: recentExpenses.length),
              ),
            ),
          ],
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

    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final theme = Theme.of(context);
    final bottomBarShadow = theme.colorScheme.shadow.withValues(alpha: 0.18);

    // Consistent offset for both the Bar and the FAB
    const double bottomOffset = 20.0;

    final currentTitle = screens[_currentIndex] is _HomeBody
        ? isAr
              ? 'الرئيسية'
              : 'Home'
        : screens[_currentIndex] is TimelineScreen
        ? isAr
              ? 'الخط الزمني'
              : 'Timeline'
        : screens[_currentIndex] is BudgetsScreen
        ? isAr
              ? 'الميزانيات'
              : 'Budgets'
        : isAr
        ? 'التحليلات'
        : 'Analytics';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        title: Text(
          currentTitle,
          style: theme.textTheme.titleLarge?.copyWith(
            fontSize: 28,
            color: theme.colorScheme.onSurface,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddExpenseScreen(userId: widget.user.id),
            ),
          ),
          icon: const Icon(Icons.add, size: 32),
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
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
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
      body: BottomBar(
        // Wrap the body in a Stack to layer the gradient behind the content
        body: Stack(
          children: [
            screens[_currentIndex],

            // The Gradient Layer at the bottom
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 130, // Height of the fade effect
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      theme.colorScheme.surface.withValues(alpha: 0),
                      theme.colorScheme.surface,
                      theme.colorScheme.surface,
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        layout: BottomBarLayout(
          width: screenWidth - 48,
          offset: bottomOffset, // Matches the FAB offset
          borderRadius: BorderRadius.circular(28),
          alignment: Alignment.bottomCenter,
        ),
        theme: BottomBarThemeData(
          barDecoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: bottomBarShadow,
                blurRadius: 28,
                offset: const Offset(0, 12),
              ),
              BoxShadow(
                color: theme.colorScheme.shadow.withValues(alpha: 0.08),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
        motion: const BottomBarMotion.cupertino(
          preset: BottomBarCupertinoMotion.smooth,
          transition: BottomBarTransition.slideAndFade,
        ),
        child: BottomBarItems(
          children: [
            BottomBarItem(
              icon: const Icon(Icons.dashboard_outlined),
              selectedIcon: const Icon(Icons.dashboard),
              label: Text(isAr ? 'الرئيسية' : 'Home'),
              selected: _currentIndex == 0,
              onTap: () => setState(() => _currentIndex = 0),
            ),
            BottomBarItem(
              icon: const Icon(Icons.receipt_long_outlined),
              selectedIcon: const Icon(Icons.receipt_long),
              label: Text(isAr ? 'الخط الزمني' : 'Timeline'),
              selected: _currentIndex == 1,
              onTap: () => setState(() => _currentIndex = 1),
            ),
            BottomBarItem(
              icon: const Icon(Icons.account_balance_wallet_outlined),
              selectedIcon: const Icon(Icons.account_balance_wallet),
              label: Text(isAr ? 'الميزانيات' : 'Budgets'),
              selected: _currentIndex == 2,
              onTap: () => setState(() => _currentIndex = 2),
            ),
            BottomBarItem(
              icon: const Icon(Icons.bar_chart_outlined),
              selectedIcon: const Icon(Icons.bar_chart),
              label: Text(isAr ? 'التحليلات' : 'Charts'),
              selected: _currentIndex == 3,
              onTap: () => setState(() => _currentIndex = 3),
            ),
          ],
        ),
      ),
    );
  }
}
