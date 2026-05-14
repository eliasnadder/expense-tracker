import 'package:expense_tracker/core/theme/app_theme.dart';
import 'package:expense_tracker/features/expenses/domain/entities/expense_entity.dart';
import 'package:expense_tracker/features/expenses/presentation/bloc/expense_bloc.dart';
import 'package:expense_tracker/features/expenses/presentation/bloc/expense_event.dart';
import 'package:expense_tracker/features/expenses/presentation/bloc/expense_state.dart';
import 'package:expense_tracker/features/expenses/presentation/widgets/expense_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class TimelineScreen extends StatefulWidget {
  final String userId;
  const TimelineScreen({super.key, required this.userId});

  @override
  State<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen> {
  final _searchController = TextEditingController();
  String _filter = 'All Time';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _matchesFilter(ExpenseEntity expense) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final expenseDate = DateTime(
      expense.date.year,
      expense.date.month,
      expense.date.day,
    );

    return switch (_filter) {
      'Week' => !expenseDate.isBefore(today.subtract(const Duration(days: 6))),
      'Month' =>
        expense.date.month == now.month && expense.date.year == now.year,
      'Year' => expense.date.year == now.year,
      _ => true,
    };
  }

  List<ExpenseEntity> _visibleExpenses(List<ExpenseEntity> expenses) {
    final query = _searchController.text.trim().toLowerCase();
    return expenses.where((expense) {
      final matchesSearch =
          query.isEmpty ||
          expense.description.toLowerCase().contains(query) ||
          expense.category.toLowerCase().contains(query);
      return matchesSearch && _matchesFilter(expense);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: BlocBuilder<ExpenseBloc, ExpenseState>(
        builder: (context, state) {
          if (state is ExpenseLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is! ExpenseLoaded) {
            return const SizedBox();
          }

          final groupedExpenses = _groupExpenses(
            _visibleExpenses(state.expenses),
          );

          return SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      children: [
                        // Search Bar
                        Container(
                          height: 56,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.search,
                                color: AppColors.onSurfaceVariant,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextField(
                                  controller: _searchController,
                                  onChanged: (_) => setState(() {}),
                                  decoration: InputDecoration(
                                    hintText: isAr
                                        ? 'البحث عن المعاملات...'
                                        : 'Search transactions...',
                                    border: InputBorder.none,
                                    hintStyle: const TextStyle(
                                      color: AppColors.outline,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Filter Chips
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: ['All Time', 'Week', 'Month', 'Year'].map(
                              (f) {
                                final isSelected = _filter == f;
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: ChoiceChip(
                                    label: Text(f),
                                    selected: isSelected,
                                    onSelected: (v) =>
                                        setState(() => _filter = f),
                                    backgroundColor:
                                        AppColors.surfaceContainerHigh,
                                    selectedColor: AppColors.secondaryContainer,
                                    labelStyle: TextStyle(
                                      color: isSelected
                                          ? AppColors.onSecondaryContainer
                                          : AppColors.onSurfaceVariant,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                );
                              },
                            ).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (groupedExpenses.isEmpty)
                  SliverFillRemaining(
                    child: Center(
                      child: Text(
                        isAr ? 'لا توجد معاملات' : 'No transactions found',
                      ),
                    ),
                  )
                else
                  ...groupedExpenses.entries.map((group) {
                    final dateLabel = _getDateLabel(group.key, isAr);
                    final totalForDay = group.value.fold<double>(
                      0,
                      (s, e) => s + (e.isIncome ? e.amount : -e.amount),
                    );

                    return SliverPadding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 8,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  dateLabel,
                                  style: textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${totalForDay >= 0 ? '+' : ''}\$${totalForDay.abs().toStringAsFixed(2)}',
                                  style: textTheme.labelLarge?.copyWith(
                                    color: totalForDay >= 0
                                        ? AppColors.income
                                        : AppColors.expense,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(28),
                            ),
                            child: Column(
                              children: group.value.map((expense) {
                                return Dismissible(
                                  key: Key(expense.id),
                                  direction: DismissDirection.endToStart,
                                  background: Container(
                                    alignment: Alignment.centerRight,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.expense,
                                      borderRadius: BorderRadius.circular(28),
                                    ),
                                    child: const Icon(
                                      Icons.delete,
                                      color: Colors.white,
                                    ),
                                  ),
                                  onDismissed: (_) {
                                    context.read<ExpenseBloc>().add(
                                      DeleteExpense(widget.userId, expense.id),
                                    );
                                  },
                                  child: ExpenseCard(
                                    expense: expense,
                                    onDelete: () =>
                                        context.read<ExpenseBloc>().add(
                                          DeleteExpense(
                                            widget.userId,
                                            expense.id,
                                          ),
                                        ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ]),
                      ),
                    );
                  }).toList(),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          );
        },
      ),
    );
  }

  Map<DateTime, List<ExpenseEntity>> _groupExpenses(
    List<ExpenseEntity> expenses,
  ) {
    final Map<DateTime, List<ExpenseEntity>> groups = {};
    for (final e in expenses) {
      final date = DateTime(e.date.year, e.date.month, e.date.day);
      if (!groups.containsKey(date)) groups[date] = [];
      groups[date]!.add(e);
    }
    return groups;
  }

  String _getDateLabel(DateTime date, bool isAr) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    if (date == today) return isAr ? 'اليوم' : 'Today';
    if (date == yesterday) return isAr ? 'أمس' : 'Yesterday';
    return DateFormat('EEEE, MMM dd').format(date);
  }
}
