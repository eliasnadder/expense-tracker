import 'package:expense_tracker/core/theme/app_theme.dart';
import 'package:expense_tracker/features/expenses/domain/entities/expense_entity.dart';
import 'package:expense_tracker/features/expenses/presentation/bloc/expense_bloc.dart';
import 'package:expense_tracker/features/expenses/presentation/bloc/expense_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class ExpenseCard extends StatelessWidget {
  final ExpenseEntity expense;
  final String userId;

  const ExpenseCard({super.key, required this.expense, required this.userId});

  Future<bool> _confirmDelete(BuildContext context) async {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final theme = Theme.of(context);

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: theme.colorScheme.surfaceContainerHigh,
          surfaceTintColor: Theme.of(
            dialogContext,
          ).colorScheme.surface.withValues(alpha: 0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
          ),
          contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),

          title: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.delete_outline_rounded,
                  color: theme.colorScheme.onErrorContainer,
                  size: 26,
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Text(
                  isAr ? 'حذف العملية؟' : 'Delete Transaction?',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          content: Text(
            isAr
                ? 'هل أنت متأكد من حذف هذه العملية؟ لا يمكن التراجع عن هذا الإجراء.'
                : 'Are you sure you want to delete this transaction? This action cannot be undone.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.onSurfaceVariant,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
                ),
              ),
              child: Text(isAr ? 'إلغاء' : 'Cancel'),
            ),

            FilledButton.icon(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              icon: const Icon(Icons.delete_rounded, size: 18),
              label: Text(isAr ? 'حذف' : 'Delete'),
              style: FilledButton.styleFrom(
                backgroundColor: theme.colorScheme.error,
                foregroundColor: theme.colorScheme.onError,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true && context.mounted) {
      context.read<ExpenseBloc>().add(DeleteExpense(userId, expense.id));
    }

    return shouldDelete ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colors = theme.colorScheme;
    final amountColor = expense.isIncome
        ? AppColors.income
        : theme.colorScheme.onSurface;

    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      child: Dismissible(
        key: Key(expense.id),
        direction: DismissDirection.endToStart,

        // --- ANIMATION SETTINGS ---
        // Smoothness of the card flying off screen
        movementDuration: const Duration(milliseconds: 400),
        // Smoothness of the empty space closing up
        resizeDuration: const Duration(milliseconds: 400),
        // Requires a longer swipe (75%) to trigger, preventing accidental deletes
        // CORRECTED SYNTAX HERE:
        dismissThresholds: const {DismissDirection.endToStart: 0.75},

        confirmDismiss: (_) => _confirmDelete(context),

        // --- ANIMATED BACKGROUND ---
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.symmetric(horizontal: 28),
          decoration: BoxDecoration(
            // Gradient makes the reveal feel premium and dynamic
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.errorContainer,
                theme.colorScheme.error,
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(32),
            // Add a subtle shadow to the background itself for depth
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.error.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(2, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Text that appears as you swipe
              Text(
                isAr ? 'حذف' : 'Delete',
                style: textTheme.titleMedium?.copyWith(
                  color: colors.onError,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(width: 12),
              // Icon with a slight rotation for dynamic feel
              Transform.rotate(
                angle: -0.2, // Rotate slightly counter-clockwise
                child: Icon(
                  Icons.delete_rounded,
                  color: colors.onError,
                  size: 32,
                ),
              ),
            ],
          ),
        ),

        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: colors.outlineVariant.withValues(alpha: 0.28),
            ),
          ),

          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: _getCategoryColor(
                    context,
                    expense.category,
                  ).withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  expense.emoji ?? '📦',
                  style: const TextStyle(fontSize: 26),
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      expense.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colors.onSurface,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      '${expense.category} • ${DateFormat('MMM dd, h:mm a').format(expense.date)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.labelMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 16),

              Text(
                '${expense.isIncome ? '+' : '-'}\$${expense.amount.toStringAsFixed(2)}',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: amountColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(BuildContext context, String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return AppColors.expense;

      case 'transport':
        return AppColors.secondary;

      case 'shopping':
        return AppColors.primary;

      case 'salary':
      case 'gift':
      case 'investment':
        return AppColors.income;

      default:
        return AppColors.outline;
    }
  }
}
