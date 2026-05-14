import 'package:expense_tracker/core/theme/app_theme.dart';
import 'package:expense_tracker/features/ai_insight/presentation/bloc/ai_bloc.dart';
import 'package:expense_tracker/features/ai_insight/presentation/bloc/ai_event.dart';
import 'package:expense_tracker/features/ai_insight/presentation/bloc/ai_state.dart';
import 'package:expense_tracker/features/budget/presentation/bloc/budget_bloc.dart';
import 'package:expense_tracker/features/budget/presentation/bloc/budget_state.dart';
import 'package:expense_tracker/features/expenses/domain/entities/expense_entity.dart';
import 'package:expense_tracker/features/expenses/presentation/bloc/expense_bloc.dart';
import 'package:expense_tracker/features/expenses/presentation/bloc/expense_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final monthLabel = DateFormat('MMMM yyyy').format(DateTime.now());

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: BlocBuilder<ExpenseBloc, ExpenseState>(
        builder: (context, state) {
          if (state is ExpenseLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is! ExpenseLoaded) {
            return const SizedBox();
          }

          final totalIncome = state.totalIncome;
          final totalExpenses = state.totalExpenses;
          final netSavings = totalIncome - totalExpenses;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isAr ? 'التقارير الشهرية' : 'Monthly Reports',
                  style: textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  isAr
                      ? 'راجع أداءك المالي لشهر $monthLabel.'
                      : 'Review your financial performance for $monthLabel.',
                  style: textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),

                // Bento Grid Summary
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 1, // Simple for mobile
                  mainAxisSpacing: 16,
                  childAspectRatio: 2.2,
                  children: [
                    _SummaryCard(
                      title: isAr ? 'إجمالي الدخل' : 'Total Income',
                      amount: totalIncome,
                      trend: '+12.5%',
                      icon: Icons.arrow_upward,
                      iconBg: Theme.of(
                        context,
                      ).colorScheme.tertiary.withValues(alpha: 0.1),
                      iconColor: Theme.of(context).colorScheme.tertiary,
                    ),
                    _SummaryCard(
                      title: isAr ? 'إجمالي المصاريف' : 'Total Expenses',
                      amount: totalExpenses,
                      trend: '-4.2%',
                      icon: Icons.arrow_downward,
                      iconBg: Theme.of(
                        context,
                      ).colorScheme.onError.withValues(alpha: 0.1),
                      iconColor: Theme.of(context).colorScheme.onError,
                    ),
                    _SavingsCard(
                      title: isAr ? 'صافي الادخار' : 'Net Savings',
                      amount: netSavings,
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                _AiInsightPanel(
                  expenses: state.currentMonthExpenses,
                  isAr: isAr,
                ),
                const SizedBox(height: 32),

                // Downloadable Reports
                Text(
                  isAr ? 'التقارير القابلة للتحميل' : 'Downloadable Reports',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.outlineVariant.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Column(
                    children: [
                      _ReportItem(
                        title: isAr ? 'تقرير PDF شهري' : 'Monthly PDF Report',
                        subtitle: isAr
                            ? 'ملخص مرئي مفصل لشهر $monthLabel'
                            : 'Detailed visual summary of $monthLabel',
                        icon: Icons.picture_as_pdf,
                        iconColor: Theme.of(context).colorScheme.primary,
                        isLast: false,
                      ),
                      _ReportItem(
                        title: isAr ? 'تصدير CSV' : 'CSV Export',
                        subtitle: isAr
                            ? 'بيانات المعاملات الخام للجداول'
                            : 'Raw transaction data for spreadsheets',
                        icon: Icons.table_view,
                        iconColor: Theme.of(context).colorScheme.tertiary,
                        isLast: false,
                      ),
                      _ReportItem(
                        title: isAr ? 'ملخص ضريبي' : 'Tax Summary',
                        subtitle: isAr
                            ? 'عرض مصنف لإعداد الضرائب'
                            : 'Categorized view for tax preparation',
                        icon: Icons.request_quote,
                        iconColor: Theme.of(context).colorScheme.secondary,
                        isLast: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Generate Report Button
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isAr
                                ? 'إنشاء التقارير غير متاح بعد.'
                                : 'Report generation is not available yet.',
                          ),
                        ),
                      );
                    },
                    icon: Icon(
                      Icons.add,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                    label: Text(
                      isAr ? 'إنشاء تقرير جديد' : 'Generate New Report',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 100),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final double amount;
  final String trend;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;

  const _SummaryCard({
    required this.title,
    required this.amount,
    required this.trend,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: Theme.of(
            context,
          ).colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  trend,
                  style: textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                '\$${NumberFormat("#,##0.00").format(amount)}',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SavingsCard extends StatelessWidget {
  final String title;
  final double amount;

  const _SavingsCard({required this.title, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.onPrimary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.onPrimary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.account_balance,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.onPrimary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(
                      'Target Met',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    '\$${NumberFormat("#,##0.00").format(amount)}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AiInsightPanel extends StatelessWidget {
  final List<ExpenseEntity> expenses;
  final bool isAr;

  const _AiInsightPanel({required this.expenses, required this.isAr});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final budgetState = context.watch<BudgetBloc>().state;
    final budget = budgetState is BudgetLoaded
        ? budgetState.monthlyBudgetLimit
        : 0.0;

    return BlocBuilder<AiBloc, AiState>(
      builder: (context, aiState) {
        final isLoading = aiState is AiLoading;
        final insight = aiState is AiLoaded ? aiState.insight : null;
        final hasError = aiState is AiError;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.18),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.auto_awesome,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isAr ? 'رؤية ذكية' : 'Smart Insight',
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          isAr
                              ? 'تحليل مختصر لهذا الشهر'
                              : 'A short read on this month',
                          style: textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 40,
                    child: FilledButton.icon(
                      onPressed: isLoading
                          ? null
                          : () {
                              context.read<AiBloc>().add(
                                AnalyzeExpenses(
                                  expenses: expenses,
                                  budget: budget,
                                  isAr: isAr,
                                ),
                              );
                            },
                      icon: isLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.bolt, size: 18),
                      label: Text(isAr ? 'حلل' : 'Analyze'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        minimumSize: const Size(0, 40),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (insight != null)
                Text(
                  insight,
                  style: textTheme.bodyMedium?.copyWith(height: 1.45),
                )
              else if (hasError)
                Text(
                  isAr
                      ? 'تعذر تشغيل التحليل. تحقق من مفتاح Gemini أو الاتصال.'
                      : 'Analysis failed. Check the Gemini key or connection.',
                  style: textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onError,
                  ),
                )
              else
                Text(
                  isAr
                      ? 'اضغط تحليل للحصول على ملاحظات عن الإنفاق، أعلى الفئات، وخطوة عملية للشهر.'
                      : 'Tap Analyze for spending notes, top categories, and one practical next step.',
                  style: textTheme.bodyMedium,
                ),
            ],
          ),
        );
      },
    );
  }
}

class _ReportItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final bool isLast;

  const _ReportItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return InkWell(
      onTap: () {
        final isAr = Localizations.localeOf(context).languageCode == 'ar';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isAr
                  ? 'تصدير التقارير غير متاح بعد.'
                  : 'Report export is not available yet.',
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : Border(
                  bottom: BorderSide(
                    color: Theme.of(
                      context,
                    ).colorScheme.outlineVariant.withValues(alpha: 0.3),
                  ),
                ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.download,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}
