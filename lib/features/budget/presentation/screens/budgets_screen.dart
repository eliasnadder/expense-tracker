import 'package:expense_tracker/features/budget/presentation/widgets/budget_category_card.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/auth_state.dart';
import 'package:expense_tracker/features/budget/presentation/bloc/budget_bloc.dart';
import 'package:expense_tracker/features/budget/presentation/bloc/budget_state.dart';
import 'package:expense_tracker/features/budget/presentation/widgets/budget_card.dart';
import 'package:expense_tracker/features/expenses/presentation/bloc/expense_bloc.dart';
import 'package:expense_tracker/features/expenses/presentation/bloc/expense_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BudgetsScreen extends StatelessWidget {
  const BudgetsScreen({super.key, required this.userId});
  final String userId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final categories = [
      {
        'title': isAr ? 'طعام وشراب' : 'Food & Dining',
        'category': 'Food',
        'icon': Icons.restaurant,
      },
      {
        'title': isAr ? 'نقل' : 'Transportation',
        'category': 'Transport',
        'icon': Icons.directions_car,
      },
      {
        'title': isAr ? 'تسوق' : 'Shopping',
        'category': 'Shopping',
        'icon': Icons.shopping_bag,
      },
    ];

    // 1. Scaffold moved to the root to guarantee size constraints
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          if (authState is! AuthAuthenticated) {
            return const Center(child: CircularProgressIndicator());
          }
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

                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Total Summary Card
                        BudgetCard(
                          budget: totalLimit,
                          spent: totalSpent,
                          isAr: isAr,
                          userId: userId,
                          isBudgetScreen: true,
                        ),
                        const SizedBox(height: 32),

                        // Budget Bento Grid
                        if (budgetState is BudgetLoading)
                          const Center(child: CircularProgressIndicator())
                        else
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 18),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isAr ? 'دفعت على:' : 'You Spent On:',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),

                                Column(
                                  children: [
                                    for (
                                      int index = 0;
                                      index < categories.length;
                                      index++
                                    ) ...[
                                      BudgetCategoryCard(
                                        title: categories[index]['title']
                                            .toString(),
                                        category: categories[index]['category']
                                            .toString(),
                                        icon:
                                            categories[index]['icon']
                                                as IconData,
                                        budgetState: budgetState,
                                        expenseState: expenseState,
                                        isAr: isAr,
                                      ),
                                      if (index < categories.length - 1)
                                        const SizedBox(height: 16)
                                      else ...[
                                        const SizedBox(height: 16),
                                        // const Divider(),
                                      ],
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 32),
                        // Add Budget Button
                        // const _AddBudgetButton(),
                        // const SizedBox(height: 100),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
