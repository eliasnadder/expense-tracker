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

class AiInsightsScreen extends StatelessWidget {
  const AiInsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('✨ '),
            Text(isAr ? 'تحليل الذكاء الاصطناعي' : 'AI Insights'),
          ],
        ),
      ),
      body: BlocBuilder<AiBloc, AiState>(
        builder: (context, aiState) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Header Card
                _HeaderCard(isAr: isAr, theme: theme),
                const SizedBox(height: 16),

                // Analyze Button
                _AnalyzeButton(isAr: isAr, aiState: aiState),
                const SizedBox(height: 24),

                // Result
                if (aiState is AiLoading) _LoadingWidget(isAr: isAr),
                if (aiState is AiLoaded)
                  _InsightCard(text: aiState.insight, theme: theme),
                if (aiState is AiError)
                  _ErrorWidget(message: aiState.message, isAr: isAr),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─── Header ──────────────────────────────────────────────────

class _HeaderCard extends StatelessWidget {
  final bool isAr;
  final ThemeData theme;
  const _HeaderCard({required this.isAr, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.colorScheme.primary, theme.colorScheme.tertiary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('🤖', style: TextStyle(fontSize: 36)),
          const SizedBox(height: 8),
          Text(
            isAr ? 'مستشارك المالي الذكي' : 'Your Smart Financial Advisor',
            style: TextStyle(
              color: theme.colorScheme.onPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isAr
                ? 'يحلل Gemini مصاريفك ويقترح أفضل الطرق للتوفير'
                : 'Gemini analyzes your expenses and suggests smart saving tips',
            style: TextStyle(
              color: theme.colorScheme.onPrimary.withValues(alpha: 0.7),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Analyze Button ──────────────────────────────────────────

class _AnalyzeButton extends StatelessWidget {
  final bool isAr;
  final AiState aiState;
  const _AnalyzeButton({required this.isAr, required this.aiState});

  @override
  Widget build(BuildContext context) {
    final expenseState = context.watch<ExpenseBloc>().state;
    final budgetState = context.watch<BudgetBloc>().state;

    final expenses = expenseState is ExpenseLoaded
        ? expenseState.expenses
        : <ExpenseEntity>[];
    final budget = budgetState is BudgetLoaded ? budgetState.totalAmount : 0.0;

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: FilledButton.icon(
        onPressed: aiState is AiLoading
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
        icon: const Icon(Icons.auto_awesome),
        label: Text(
          isAr ? 'تحليل مصاريفي' : 'Analyze My Expenses',
          style: const TextStyle(fontSize: 16),
        ),
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

// ─── Loading ─────────────────────────────────────────────────

class _LoadingWidget extends StatelessWidget {
  final bool isAr;
  const _LoadingWidget({required this.isAr});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 32),
        const CircularProgressIndicator(),
        const SizedBox(height: 16),
        Text(
          isAr
              ? 'يحلل Gemini مصاريفك...'
              : 'Gemini is analyzing your expenses...',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}

// ─── Insight Card ────────────────────────────────────────────

class _InsightCard extends StatelessWidget {
  final String text;
  final ThemeData theme;
  const _InsightCard({required this.text, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.auto_awesome,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Gemini',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.7),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Error ───────────────────────────────────────────────────

class _ErrorWidget extends StatelessWidget {
  final String message;
  final bool isAr;
  const _ErrorWidget({required this.message, required this.isAr});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                isAr
                    ? 'حدث خطأ، تحقق من اتصالك وحاول مجدداً'
                    : 'Error occurred, check connection and retry',
                style: TextStyle(color: Theme.of(context).colorScheme.onError),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
