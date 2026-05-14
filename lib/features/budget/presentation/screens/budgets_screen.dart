import 'package:expense_tracker/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/auth_state.dart';
import 'package:expense_tracker/features/budget/presentation/bloc/budget_bloc.dart';
import 'package:expense_tracker/features/budget/presentation/bloc/budget_state.dart';
import 'package:expense_tracker/features/expenses/presentation/bloc/expense_bloc.dart';
import 'package:expense_tracker/features/expenses/presentation/bloc/expense_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class BudgetsScreen extends StatelessWidget {
  const BudgetsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is! AuthAuthenticated) return const SizedBox();
        return BlocBuilder<BudgetBloc, BudgetState>(
          builder: (context, budgetState) {
            return BlocBuilder<ExpenseBloc, ExpenseState>(
              builder: (context, expenseState) {
                final totalSpent = expenseState is ExpenseLoaded
                    ? expenseState.totalExpenses
                    : 0.0;
                final totalLimit = budgetState is BudgetLoaded
                    ? budgetState.monthlyBudgetLimit
                    : 0.0;
                final totalProgress = totalLimit > 0
                    ? (totalSpent / totalLimit).clamp(0.0, 1.0)
                    : 0.0;

                return Scaffold(
                  backgroundColor: theme.colorScheme.surface,
                  body: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 24,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isAr ? 'الميزانيات' : 'Budgets',
                          style: textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isAr
                              ? 'تتبع حدود الإنفاق عبر الفئات.'
                              : 'Track your spending limits across categories.',
                          style: textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Total Summary Card
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color: theme.colorScheme.primary.withValues(
                                  alpha: 0.2,
                                ),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    isAr
                                        ? 'إجمالي الميزانية الشهرية'
                                        : 'Total Monthly Budget',
                                    style: textTheme.titleMedium?.copyWith(
                                      color:
                                          theme.colorScheme.onPrimaryContainer,
                                    ),
                                  ),
                                  const Icon(
                                    Icons.account_balance_wallet_outlined,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text:
                                          '\$${NumberFormat('#,##0').format(totalSpent)}',
                                      style: textTheme.displayMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: theme
                                            .colorScheme
                                            .onPrimaryContainer,
                                      ),
                                    ),
                                    TextSpan(
                                      text:
                                          ' / \$${NumberFormat('#,##0').format(totalLimit)}',
                                      style: textTheme.titleLarge?.copyWith(
                                        color:
                                            theme.colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              Container(
                                height: 12,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.onSurfaceVariant
                                      .withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: FractionallySizedBox(
                                  alignment: Alignment.centerLeft,
                                  widthFactor: totalProgress,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.primary,
                                      borderRadius: BorderRadius.circular(100),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  '${(totalProgress * 100).toInt()}% utilized',
                                  style: textTheme.labelMedium?.copyWith(
                                    color: theme.colorScheme.onPrimaryContainer,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Budget Bento Grid
                        if (budgetState is BudgetLoading)
                          const Center(child: CircularProgressIndicator())
                        else
                          GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 1,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            childAspectRatio: 1.6,
                            children: [
                              _BudgetCategoryCard(
                                title: isAr ? 'طعام وشراب' : 'Food & Dining',
                                category: 'Food',
                                icon: Icons.restaurant,
                                budgetState: budgetState,
                                expenseState: expenseState,
                                isAr: isAr,
                              ),
                              _BudgetCategoryCard(
                                title: isAr ? 'نقل' : 'Transportation',
                                category: 'Transport',
                                icon: Icons.directions_car,
                                budgetState: budgetState,
                                expenseState: expenseState,
                                isAr: isAr,
                              ),
                              _BudgetCategoryCard(
                                title: isAr ? 'تسوق' : 'Shopping',
                                category: 'Shopping',
                                icon: Icons.shopping_bag,
                                budgetState: budgetState,
                                expenseState: expenseState,
                                isAr: isAr,
                              ),
                            ],
                          ),
                        const SizedBox(height: 16),
                        // Add Budget Button
                        const _AddBudgetButton(),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

class _AddBudgetButton extends StatelessWidget {
  const _AddBudgetButton();

  @override
  Widget build(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      height: 180,
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.add,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            isAr ? 'إنشاء ميزانية جديدة' : 'Create New Budget',
            style: textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _BudgetCategoryCard extends StatelessWidget {
  final String title;
  final String category;
  final IconData icon;
  final BudgetState budgetState;
  final ExpenseState expenseState;
  final bool isAr;

  const _BudgetCategoryCard({
    required this.title,
    required this.category,
    required this.icon,
    required this.budgetState,
    required this.expenseState,
    required this.isAr,
  });

  @override
  Widget build(BuildContext context) {
    final limit = budgetState is BudgetLoaded
        ? (budgetState as BudgetLoaded).getCategoryLimit(category)
        : 0.0;
    final spent = expenseState is ExpenseLoaded
        ? (expenseState as ExpenseLoaded).currentMonthExpenses
              .where((e) => e.category == category && !e.isIncome)
              .fold(0.0, (sum, e) => sum + e.amount)
        : 0.0;

    final progress = limit > 0 ? (spent / limit).clamp(0.0, 1.0) : 0.0;
    final isCritical = progress >= 1.0;
    final isWarning = progress >= 0.8 && progress < 1.0;

    return _BudgetBentoCard(
      title: title,
      subtitle: category,
      spent: spent,
      limit: limit,
      icon: icon,
      status: isCritical
          ? (isAr ? 'تجاوزت' : 'Exceeded')
          : (isWarning
                ? (isAr ? 'اقتربت' : 'Nearing')
                : (isAr ? 'جيد' : 'On Track')),
      statusColor: isCritical
          ? Theme.of(context).colorScheme.error
          : (isWarning ? Colors.orange : Theme.of(context).colorScheme.primary),
      progressColor: isCritical
          ? Theme.of(context).colorScheme.error
          : (isWarning ? Colors.orange : Theme.of(context).colorScheme.primary),
      isCritical: isCritical,
      isWarning: isWarning,
    );
  }
}

class _BudgetBentoCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final double spent;
  final double limit;
  final IconData icon;
  final String status;
  final Color statusColor;
  final Color progressColor;
  final bool isWarning;
  final bool isCritical;

  const _BudgetBentoCard({
    required this.title,
    required this.subtitle,
    required this.spent,
    required this.limit,
    required this.icon,
    required this.status,
    required this.statusColor,
    required this.progressColor,
    this.isWarning = false,
    this.isCritical = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final progress = limit > 0 ? (spent / limit).clamp(0.0, 1.0) : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isCritical
            ? Theme.of(context).colorScheme.error.withValues(alpha: 0.1)
            : Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isCritical
              ? Theme.of(context).colorScheme.error.withValues(alpha: 0.3)
              : Theme.of(
                  context,
                ).colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isCritical
                      ? Theme.of(
                          context,
                        ).colorScheme.error.withValues(alpha: 0.1)
                      : Theme.of(
                          context,
                        ).colorScheme.secondaryContainer.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: isCritical
                      ? Theme.of(context).colorScheme.error
                      : Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isCritical
                      ? Theme.of(
                          context,
                        ).colorScheme.error.withValues(alpha: 0.1)
                      : (isWarning
                            ? Theme.of(
                                context,
                              ).colorScheme.secondary.withValues(alpha: 0.1)
                            : Theme.of(
                                context,
                              ).colorScheme.surfaceContainerHigh),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  status,
                  style: textTheme.labelSmall?.copyWith(
                    color: isCritical
                        ? Colors.white
                        : (isWarning
                              ? Theme.of(context).colorScheme.secondary
                              : Theme.of(context).colorScheme.onSurfaceVariant),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          Text(
            subtitle,
            style: textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${spent.toInt()}',
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isCritical
                      ? Theme.of(context).colorScheme.error
                      : Theme.of(context).colorScheme.onSurface,
                ),
              ),
              Text(
                'of \$${limit.toInt()} limit',
                style: textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 6,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(100),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  color: progressColor,
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${(progress * 100).toInt()}% Spent',
              style: textTheme.labelSmall?.copyWith(
                color: progressColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
