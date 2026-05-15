import 'package:expense_tracker/features/analytics/presentation/widgets/ai_insight_panel.dart';
import 'package:expense_tracker/features/analytics/presentation/widgets/report_item.dart';
import 'package:expense_tracker/features/analytics/presentation/widgets/saving_card.dart';
import 'package:expense_tracker/features/analytics/presentation/widgets/summary_card.dart';
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
                // Bento Grid Summary
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  childAspectRatio: 12 / 11,
                  children: [
                    SummaryCard(
                      title: isAr ? 'إجمالي الدخل' : 'Total Income',
                      amount: totalIncome,
                      trend: '+12.5%',
                      icon: Icons.arrow_upward,
                      iconBg: Theme.of(
                        context,
                      ).colorScheme.tertiary.withValues(alpha: 0.1),
                      iconColor: Theme.of(context).colorScheme.tertiary,
                    ),
                    SummaryCard(
                      title: isAr ? 'إجمالي المصاريف' : 'Total Expenses',
                      amount: totalExpenses,
                      trend: '-4.2%',
                      icon: Icons.arrow_downward,
                      iconBg: Theme.of(
                        context,
                      ).colorScheme.onError.withValues(alpha: 0.1),
                      iconColor: Theme.of(context).colorScheme.onError,
                    ),
                    // SavingsCard(
                    //   title: isAr ? 'صافي الادخار' : 'Net Savings',
                    //   amount: netSavings,
                    // ),
                  ],
                ),
                const SizedBox(height: 32),

                AiInsightPanel(
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
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.outlineVariant.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Column(
                    children: [
                      ReportItem(
                        title: isAr ? 'تقرير PDF شهري' : 'Monthly PDF Report',
                        subtitle: isAr
                            ? 'ملخص مرئي مفصل لشهر $monthLabel'
                            : 'Detailed visual summary of $monthLabel',
                        icon: Icons.picture_as_pdf,
                        iconColor: Theme.of(context).colorScheme.primary,
                        isLast: false,
                      ),
                      ReportItem(
                        title: isAr ? 'تصدير CSV' : 'CSV Export',
                        subtitle: isAr
                            ? 'بيانات المعاملات الخام للجداول'
                            : 'Raw transaction data for spreadsheets',
                        icon: Icons.table_view,
                        iconColor: Theme.of(context).colorScheme.tertiary,
                        isLast: false,
                      ),
                      ReportItem(
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
