import 'package:expense_tracker/components/bars/app_bar.dart';
import 'package:expense_tracker/core/di/injection.dart';
import 'package:expense_tracker/features/categories/presentation/widgets/category_section.dart';
import 'package:expense_tracker/features/ai_insight/presentation/bloc/ai_bloc.dart';
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
import 'package:flutter_animate/flutter_animate.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

// ─── Layout Constants ──────────────────────────────────────────────────────────
const _kBottomBarOffset = 20.0;
const _kBottomBarWidthPad = 48.0;
const _kBottomBarRadius = 28.0;
const _kGradientHeight = 130.0;
const _kExpenseListBottomPad = 120.0;
const _kMaxRecent = 5;
const _kSectionFontSize = 18.0;
const _kSectionHPad = 18.0;
const _kSectionVPad = 8.0;
const _kExpenseCardVPad = 4.0;
const _kAvatarRadius = 18.0;
const _kLabelFontSize = 11.0;

// ─── Tab Configuration Model ───────────────────────────────────────────────────
class _TabConfig {
  const _TabConfig({
    required this.titleAr,
    required this.titleEn,
    required this.icon,
    required this.selectedIcon,
    required this.screenBuilder,
  });

  final String titleAr;
  final String titleEn;
  final Widget icon;
  final Widget selectedIcon;
  final Widget Function(UserEntity user) screenBuilder;
}

// ─── HomeScreen (Public Entry Point) ───────────────────────────────────────────
class HomeScreen extends StatelessWidget {
  final UserEntity user;
  const HomeScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) => _NavShell(user: user);
}

// ─── Home Body Content ─────────────────────────────────────────────────────────
class _HomeBody extends StatefulWidget {
  final UserEntity user;
  const _HomeBody({required this.user});

  @override
  State<_HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends State<_HomeBody> {
  String _selectedCategory = 'All';

  TextStyle? _sectionTitleStyle(BuildContext context) =>
      Theme.of(context).textTheme.titleMedium?.copyWith(
        fontSize: _kSectionFontSize,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.onSurface,
      );

  Widget _buildSectionHeader({
    required BuildContext context,
    required String title,
    Widget? action,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: _kSectionHPad,
        vertical: _kSectionVPad,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: _sectionTitleStyle(context)),
          if (action != null) action,
        ],
      ),
    );
  }

  Widget _buildMonthlyBudgetSection(
    BuildContext context,
    bool isAr,
    double spent,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
      ],
    );
  }

  Widget _buildCategoriesSection(BuildContext context, bool isAr) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          context: context,
          title: isAr ? 'الفئات' : 'Categories',
          action: TextButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CategoriesScreen()),
            ),
            child: Text(isAr ? 'إدارة' : 'Manage'),
          ),
        ),
        CategorySection(
          isAr: isAr,
          selectedCategory: _selectedCategory,
          onSelected: (category) =>
              setState(() => _selectedCategory = category),
        ),
      ],
    );
  }

  Widget _buildLoadingState() => SliverFillRemaining(
    hasScrollBody: false,
    child: Center(
      child: LoadingAnimationWidget.inkDrop(
        color: const Color(0xFF6750A4),
        size: 20,
      ),
    ),
  );

  Widget _buildEmptyState(bool isAr) {
    return NoExpense(
      isAr: isAr,
      userId: widget.user.id,
      mainAxisAlignment: MainAxisAlignment.start,
    );
  }

  Widget _buildRecentTransactionsHeader(BuildContext context, bool isAr) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              isAr ? 'المعاملات الأخيرة' : 'Recent Transactions',
              style: _sectionTitleStyle(context),
            ),
            TextButton(
              onPressed: () => _NavShellState.of(context)?.goToTab(1),
              child: Text(isAr ? 'رؤية الكل' : 'See All'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpenseList(List<ExpenseEntity> expenses) {
    return SliverPadding(
      padding: const EdgeInsets.only(bottom: _kExpenseListBottomPad),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: _kExpenseCardVPad),
            child: ExpenseCard(
              expense: expenses[index],
              userId: widget.user.id,
            ),
          );
        }, childCount: expenses.length),
      ),
    );
  }

  List<ExpenseEntity> _recentExpenses(List<ExpenseEntity> expenses) {
    final filtered = _selectedCategory == 'All'
        ? expenses
        : expenses
              .where((expense) => expense.category == _selectedCategory)
              .toList();
    return filtered.take(_kMaxRecent).toList();
  }

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

        final hasExpenses = expenseState is ExpenseLoaded;
        final hasRecentExpenses = recentExpenses.isNotEmpty;

        final scrollPhysics = hasRecentExpenses
            ? const ClampingScrollPhysics()
            : const NeverScrollableScrollPhysics();

        return CustomScrollView(
          physics: scrollPhysics,
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMonthlyBudgetSection(context, isAr, spent),
                  const SizedBox(height: 16),
                  _buildCategoriesSection(context, isAr),
                  const SizedBox(height: 16),
                ]
                    .animate(interval: 100.ms)
                    .fade(duration: 400.ms)
                    .slideY(begin: 0.1, duration: 400.ms, curve: Curves.easeOutQuad),
              ),
            ),
            if (expenseState is ExpenseLoading)
              _buildLoadingState()
            else if (hasExpenses && !hasRecentExpenses)
              _buildEmptyState(isAr)
            else ...[
              if (hasRecentExpenses)
                _buildRecentTransactionsHeader(context, isAr),
              _buildExpenseList(recentExpenses),
            ],
          ],
        );
      },
    );
  }
}

// ─── Navigation Shell ──────────────────────────────────────────────────────────
class _NavShell extends StatefulWidget {
  final UserEntity user;
  const _NavShell({required this.user});

  @override
  State<_NavShell> createState() => _NavShellState();
}

class _NavShellState extends State<_NavShell> {
  int _currentIndex = 0;

  late final List<_TabConfig> _tabs = [
    _TabConfig(
      titleAr: 'الرئيسية',
      titleEn: 'Home',
      icon: const Icon(Icons.dashboard_outlined),
      selectedIcon: const Icon(Icons.dashboard),
      screenBuilder: (_) => _HomeBody(user: widget.user),
    ),
    _TabConfig(
      titleAr: 'الخط الزمني',
      titleEn: 'Timeline',
      icon: const Icon(Icons.receipt_long_outlined),
      selectedIcon: const Icon(Icons.receipt_long),
      screenBuilder: (_) => TimelineScreen(userId: widget.user.id),
    ),
    _TabConfig(
      titleAr: 'الميزانيات',
      titleEn: 'Budgets',
      icon: const Icon(Icons.account_balance_wallet_outlined),
      selectedIcon: const Icon(Icons.account_balance_wallet),
      screenBuilder: (_) => BlocProvider(
        create: (_) => getIt<AiBloc>(),
        child: BudgetsScreen(userId: widget.user.id),
      ),
    ),
    _TabConfig(
      titleAr: 'الملف الشخصي',
      titleEn: 'Profile',
      icon: const Icon(Icons.person_outline),
      selectedIcon: const Icon(Icons.person),
      screenBuilder: (_) => const ProfileScreen(),
    ),
  ];

  static _NavShellState? of(BuildContext context) {
    return context.findAncestorStateOfType<_NavShellState>();
  }

  void goToTab(int index) {
    if (index < 0 || index >= _tabs.length) return;
    setState(() => _currentIndex = index);
  }

  String _currentTitle(bool isAr) {
    final tab = _tabs[_currentIndex];
    return isAr ? tab.titleAr : tab.titleEn;
  }

  Widget _buildProfileAvatar({
    required bool isSelected,
    required Color activeColor,
  }) {
    final theme = Theme.of(context);
    final borderColor = isSelected
        ? activeColor
        : theme.colorScheme.outlineVariant;

    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: 2),
      ),
      child: CircleAvatar(
        radius: _kAvatarRadius,
        backgroundImage: widget.user.photoUrl != null
            ? NetworkImage(widget.user.photoUrl!)
            : null,
        backgroundColor: theme.colorScheme.surfaceContainerHighest,
        child: widget.user.photoUrl == null
            ? Text(
                widget.user.displayName.isNotEmpty
                    ? widget.user.displayName.characters.first.toUpperCase()
                    : 'U',
                style: TextStyle(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.bold,
                ),
              )
            : null,
      ),
    );
  }

  Widget _buildBottomBarItem({
    required int index,
    required bool isAr,
    required Color activeColor,
    required Color inactiveColor,
  }) {
    final tab = _tabs[index];
    final isSelected = _currentIndex == index;
    final label = isAr ? tab.titleAr : tab.titleEn;

    // Profile tab uses avatar instead of icon
    if (index == 3) {
      return BottomBarItem(
        icon: _buildProfileAvatar(
          isSelected: false,
          activeColor: inactiveColor,
        ),
        selectedIcon: _buildProfileAvatar(
          isSelected: true,
          activeColor: activeColor,
        ),
        selected: isSelected,
        label: Text(
          label,
          style: TextStyle(
            fontSize: _kLabelFontSize,
            color: isSelected ? activeColor : inactiveColor,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        onTap: () => setState(() => _currentIndex = index),
      );
    }

    return BottomBarItem(
      icon: IconTheme.merge(
        data: IconThemeData(color: inactiveColor),
        child: tab.icon,
      ),
      selectedIcon: IconTheme.merge(
        data: IconThemeData(color: activeColor),
        child: tab.selectedIcon,
      ),
      selected: isSelected,
      label: Text(
        label,
        style: TextStyle(
          fontSize: _kLabelFontSize,
          color: isSelected ? activeColor : inactiveColor,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      onTap: () => setState(() => _currentIndex = index),
    );
  }

  Widget _buildGradientOverlay(ThemeData theme) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      height: _kGradientHeight,
      child: IgnorePointer(
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final screenWidth = MediaQuery.of(context).size.width;
    final theme = Theme.of(context);
    final activeColor = theme.colorScheme.primary;
    final inactiveColor = theme.colorScheme.onSurfaceVariant.withValues(
      alpha: 0.6,
    );

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: CustomAppBar(
        title: _currentTitle(isAr),
        actions: [
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AddExpenseScreen(userId: widget.user.id),
              ),
            ),
            icon: const Icon(Icons.add, size: 32),
          ),
        ],
      ),
      body: BottomBar(
        body: Stack(
          children: [
            _tabs[_currentIndex].screenBuilder(widget.user),
            _buildGradientOverlay(theme),
          ],
        ),
        layout: BottomBarLayout(
          width: screenWidth - _kBottomBarWidthPad,
          offset: _kBottomBarOffset,
          borderRadius: BorderRadius.circular(_kBottomBarRadius),
          alignment: Alignment.bottomCenter,
        ),
        theme: BottomBarThemeData(
          barDecoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(_kBottomBarRadius),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.shadow.withValues(alpha: 0.18),
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
          children: List.generate(
            _tabs.length,
            (index) => _buildBottomBarItem(
              index: index,
              isAr: isAr,
              activeColor: activeColor,
              inactiveColor: inactiveColor,
            ),
          ),
        ),
      ),
    );
  }
}
