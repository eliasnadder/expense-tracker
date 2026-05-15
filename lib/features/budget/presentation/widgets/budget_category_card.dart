import 'package:expense_tracker/features/budget/presentation/bloc/budget_state.dart';
import 'package:expense_tracker/features/expenses/presentation/bloc/expense_state.dart';
import 'package:flutter/material.dart';

class BudgetCategoryCard extends StatelessWidget {
  final String title;
  final String category;
  final IconData icon;
  final BudgetState budgetState;
  final ExpenseState expenseState;
  final bool isAr;

  const BudgetCategoryCard({
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
        mainAxisSize: MainAxisSize.min,
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
                      ? Theme.of(context).colorScheme.error
                      : Theme.of(context).colorScheme.secondaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: isCritical
                      ? Theme.of(context).colorScheme.error
                      : Colors.white,
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
                      ? Theme.of(context).colorScheme.error
                      : (isWarning
                            ? Theme.of(context).colorScheme.secondary
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
          const SizedBox(height: 20),
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
