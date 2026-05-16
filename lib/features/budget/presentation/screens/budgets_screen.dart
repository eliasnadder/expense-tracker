import 'package:expense_tracker/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/auth_state.dart';
import 'package:expense_tracker/features/budget/presentation/bloc/budget_bloc.dart';
import 'package:expense_tracker/features/budget/presentation/bloc/budget_state.dart';
import 'package:expense_tracker/features/budget/presentation/widgets/budget_card.dart';
import 'package:expense_tracker/features/expenses/presentation/bloc/expense_bloc.dart';
import 'package:expense_tracker/features/expenses/presentation/bloc/expense_state.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum AnalyticsRange { week, month, year }

class BudgetsScreen extends StatefulWidget {
  const BudgetsScreen({super.key, required this.userId});
  final String userId;

  @override
  State<BudgetsScreen> createState() => _BudgetsScreenState();
}

class _BudgetsScreenState extends State<BudgetsScreen> {
  AnalyticsRange selectedRange = AnalyticsRange.month;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final color = theme.colorScheme;

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
                  if (expenseState is ExpenseLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (expenseState is! ExpenseLoaded) {
                    return const Center(
                      child: Text('Unable to load analytics'),
                    );
                  }

                  final expenses = expenseState.expenses;

                  if (expenses.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.analytics_outlined,
                              size: 96,
                              color: color.primary,
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'No Analytics Yet',
                              style: theme.textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Start adding expenses to view detailed insights and charts.',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final filteredExpenses = _filterExpenses(expenses);

                  final totalExpenses = filteredExpenses
                      .where((e) => e.type == 'expense')
                      .fold<double>(0, (sum, item) => sum + item.amount);

                  final totalIncome = filteredExpenses
                      .where((e) => e.type == 'income')
                      .fold<double>(0, (sum, item) => sum + item.amount);

                  final balance = totalIncome - totalExpenses;

                  final categoryTotals = _calculateCategoryTotals(
                    filteredExpenses,
                  );

                  final topCategory = categoryTotals.entries.isEmpty
                      ? 'None'
                      : categoryTotals.entries
                            .reduce((a, b) => a.value > b.value ? a : b)
                            .key;

                  final totalSpent = expenseState.totalExpenses;
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
                          userId: widget.userId,
                          isBudgetScreen: true,
                        ),
                        const SizedBox(height: 32),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isAr ? 'التحليلات' : 'Analytics Overview',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              _buildFilters(),

                              const SizedBox(height: 24),

                              GridView(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      crossAxisSpacing: 14,
                                      mainAxisSpacing: 14,
                                      childAspectRatio: 1.2,
                                    ),
                                children: [
                                  _OverviewCard(
                                    title: 'Expenses',
                                    value:
                                        '\$${totalExpenses.toStringAsFixed(0)}',
                                    icon: Icons.arrow_downward,
                                  ),
                                  _OverviewCard(
                                    title: 'Income',
                                    value:
                                        '\$${totalIncome.toStringAsFixed(0)}',
                                    icon: Icons.arrow_upward,
                                  ),
                                  _OverviewCard(
                                    title: 'Balance',
                                    value: '\$${balance.toStringAsFixed(0)}',
                                    icon: Icons.account_balance,
                                  ),
                                  _OverviewCard(
                                    title: 'Top Category',
                                    value: topCategory,
                                    icon: Icons.star,
                                  ),
                                ],
                              ).animate().fadeIn(),

                              const SizedBox(height: 28),

                              Text(
                                'Category Breakdown',
                                style: theme.textTheme.titleLarge,
                              ),

                              const SizedBox(height: 16),

                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: color.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(28),
                                ),
                                child: Column(
                                  children: [
                                    SizedBox(
                                      height: 220,
                                      child: PieChart(
                                        PieChartData(
                                          sections: _buildPieSections(
                                            categoryTotals,
                                            color,
                                          ),
                                          sectionsSpace: 2,
                                          centerSpaceRadius: 40,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    ...categoryTotals.entries.map(
                                      (e) => Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 6,
                                        ),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 14,
                                              height: 14,
                                              decoration: BoxDecoration(
                                                color: _getCategoryColor(e.key),
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(child: Text(e.key)),
                                            Text(
                                              '\$${e.value.toStringAsFixed(0)}',
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ).animate().fadeIn(delay: 400.ms),
                              const SizedBox(height: 28),

                              Text(
                                'Smart Insights',
                                style: theme.textTheme.titleLarge,
                              ),

                              const SizedBox(height: 16),

                              _InsightCard(
                                text:
                                    '$topCategory is your biggest spending category.',
                                colorScheme: color,
                              ),

                              _InsightCard(
                                text: balance >= 0
                                    ? 'You are saving money this period.'
                                    : 'Your expenses exceed your income.',
                                colorScheme: color,
                              ),

                              _InsightCard(
                                text:
                                    'You spent \$${totalExpenses.toStringAsFixed(0)} during this period.',
                                colorScheme: color,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        // const _AddBudgetButton(),
                        const SizedBox(height: 120),
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

  Widget _buildFilters() {
    return Row(
      children: AnalyticsRange.values.map((range) {
        final selected = selectedRange == range;

        return Padding(
          padding: const EdgeInsets.only(right: 10),
          child: ChoiceChip(
            label: Text(range.name.toUpperCase()),
            selected: selected,
            onSelected: (_) {
              setState(() {
                selectedRange = range;
              });
            },
          ),
        );
      }).toList(),
    );
  }

  List<dynamic> _filterExpenses(List<dynamic> expenses) {
    final now = DateTime.now();

    return expenses.where((expense) {
      switch (selectedRange) {
        case AnalyticsRange.week:
          return expense.date.isAfter(now.subtract(const Duration(days: 7)));

        case AnalyticsRange.month:
          return expense.date.month == now.month &&
              expense.date.year == now.year;

        case AnalyticsRange.year:
          return expense.date.year == now.year;
      }
    }).toList();
  }

  Map<String, double> _calculateCategoryTotals(List<dynamic> expenses) {
    final Map<String, double> totals = {};

    for (final expense in expenses) {
      if (expense.type != 'expense') {
        continue;
      }

      totals.update(
        expense.category,
        (value) => value + expense.amount,
        ifAbsent: () => expense.amount,
      );
    }

    return totals;
  }

  List<PieChartSectionData> _buildPieSections(
    Map<String, double> categoryTotals,
    ColorScheme colorScheme,
  ) {
    return categoryTotals.entries.map((entry) {
      return PieChartSectionData(
        value: entry.value,
        title: '\$${entry.value.toStringAsFixed(0)}',
        radius: 90,
        color: _getCategoryColor(entry.key),
      );
    }).toList();
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return Colors.orange;

      case 'shopping':
        return Colors.purple;

      case 'transport':
        return Colors.blue;

      case 'health':
        return Colors.red;

      case 'entertainment':
        return Colors.green;

      default:
        return Colors.teal;
    }
  }
}

class _OverviewCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _OverviewCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(title),
            ],
          ),
        ],
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  final String text;
  final ColorScheme colorScheme;

  const _InsightCard({required this.text, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Icon(Icons.lightbulb_outline, color: colorScheme.onPrimaryContainer),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: colorScheme.onPrimaryContainer),
            ),
          ),
        ],
      ),
    );
  }
}
