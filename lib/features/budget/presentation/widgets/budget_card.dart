import 'package:expense_tracker/features/budget/presentation/widgets/budget_dialog.dart';
import 'package:expense_tracker/core/di/injection.dart';
import 'package:expense_tracker/core/service/notification_service.dart';
import 'package:expense_tracker/features/budget/presentation/bloc/budget_bloc.dart';
import 'package:expense_tracker/features/budget/presentation/bloc/budget_state.dart';
import 'package:expense_tracker/features/expenses/presentation/bloc/expense_bloc.dart';
import 'package:expense_tracker/features/expenses/presentation/bloc/expense_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

class BudgetCard extends StatefulWidget {
  final double budget;
  final double spent;
  final bool isAr;
  final String userId;
  final bool isBudgetScreen;

  const BudgetCard({
    super.key,
    required this.budget,
    required this.spent,
    required this.isAr,
    required this.userId,
    required this.isBudgetScreen,
  });

  @override
  State<BudgetCard> createState() => _BudgetCardState();
}

class _BudgetCardState extends State<BudgetCard> {
  double _lastProgress = 0;

  @override
  void didUpdateWidget(BudgetCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.budget > 0) {
      final progress = widget.spent / widget.budget;
      if (progress >= 0.8 && progress < 1.0 && _lastProgress < 0.8) {
        getIt<NotificationService>().showBudgetWarning(isAr: widget.isAr);
      }
      if (progress >= 1.0 && _lastProgress < 1.0) {
        getIt<NotificationService>().showBudgetExceeded(isAr: widget.isAr);
      }
      _lastProgress = progress;
    }
  }

  Future<void> _showSetBudgetDialog(
    BuildContext context,
    bool isAr,
    double currentBudget,
  ) async {
    await showDialog(
      context: context,
      builder: (_) => SetBudgetDialog(
        isAr: isAr,
        currentBudget: currentBudget,
        userId: widget.userId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final now = DateTime.now();
    final daysLeft = DateTime(now.year, now.month + 1, 0).day - now.day + 1;
    final progress = widget.budget > 0
        ? (widget.spent / widget.budget).clamp(0.0, 1.0)
        : 0.0;
    final remaining = widget.budget - widget.spent;
    final isOver = remaining < 0;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

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
            return Container(
              padding: const EdgeInsets.all(24),
              margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isOver
                    ? Theme.of(context).colorScheme.error
                    : theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.shadow.withValues(alpha: 0.4),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.budget == 0)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.isAr
                              ? 'لم تحدد ميزانية بعد'
                              : 'No budget set yet',
                          style: textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                        IconButton(
                          onPressed: () => _showSetBudgetDialog(
                            context,
                            widget.isAr,
                            widget.budget,
                          ),
                          icon: Icon(
                            Icons.edit_outlined,
                            size: 28,
                            color: Theme.of(
                              context,
                            ).colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ],
                    )
                  else ...[
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              isAr
                                  ? 'إجمالي الميزانية الشهرية'
                                  : 'Total Monthly Budget',
                              style: textTheme.titleMedium?.copyWith(
                                color: isOver
                                    ? Colors.white70
                                    : theme.colorScheme.onPrimaryContainer,
                              ),
                            ),
                            widget.isBudgetScreen
                                ? IconButton(
                                    onPressed: () => _showSetBudgetDialog(
                                      context,
                                      widget.isAr,
                                      widget.budget,
                                    ),
                                    icon: Icon(
                                      Icons.edit_outlined,
                                      size: 28,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onPrimaryContainer,
                                    ),
                                  )
                                : Icon(
                                    Icons.account_balance_wallet_outlined,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onPrimaryContainer,
                                    size: 28,
                                  ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text:
                                        '\$${NumberFormat().format(totalSpent)}',
                                    style: textTheme.displayMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: isOver
                                          ? Colors.white70
                                          : theme
                                                .colorScheme
                                                .onPrimaryContainer,
                                    ),
                                  ),
                                  TextSpan(
                                    text:
                                        ' / \$${NumberFormat().format(totalLimit)}',
                                    style: textTheme.titleLarge?.copyWith(
                                      color: isOver
                                          ? Colors.white70
                                          : theme
                                                .colorScheme
                                                .onPrimaryContainer,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      height: 12,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest.withAlpha(100),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: totalProgress,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(100),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.isAr
                              ? '$daysLeft يوم متبقي'
                              : '$daysLeft days left',
                          style: textTheme.labelMedium?.copyWith(
                            color: isOver
                                ? Colors.white70
                                : Theme.of(context)
                                      .colorScheme
                                      .onPrimaryContainer
                                      .withAlpha(200),
                          ),
                        ),
                        Text(
                          '${(progress * 100).toInt()}%',
                          style: textTheme.labelLarge?.copyWith(
                            color: isOver
                                ? Colors.white70
                                : Theme.of(context)
                                      .colorScheme
                                      .onPrimaryContainer
                                      .withAlpha(200),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            )
                .animate()
                .fade(duration: 400.ms)
                .scale(begin: const Offset(0.95, 0.95), duration: 400.ms, curve: Curves.easeOutQuad);
          },
        );
      },
    );
  }
}
