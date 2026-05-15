import 'package:expense_tracker/features/ai_insight/presentation/bloc/ai_bloc.dart';
import 'package:expense_tracker/features/ai_insight/presentation/bloc/ai_event.dart';
import 'package:expense_tracker/features/ai_insight/presentation/bloc/ai_state.dart';
import 'package:expense_tracker/features/budget/presentation/bloc/budget_bloc.dart';
import 'package:expense_tracker/features/budget/presentation/bloc/budget_state.dart';
import 'package:expense_tracker/features/expenses/domain/entities/expense_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AiInsightPanel extends StatelessWidget {
  final List<ExpenseEntity> expenses;
  final bool isAr;

  const AiInsightPanel({required this.expenses, required this.isAr});

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
            borderRadius: BorderRadius.circular(30),
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
                      borderRadius: BorderRadius.circular(30),
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
