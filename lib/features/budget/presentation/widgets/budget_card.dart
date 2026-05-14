import 'package:expense_tracker/core/di/injection.dart';
import 'package:expense_tracker/core/service/notification_service.dart';
import 'package:expense_tracker/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class BudgetCard extends StatefulWidget {
  final double budget;
  final double spent;
  final bool isAr;
  final VoidCallback onSetBudget;

  const BudgetCard({
    super.key,
    required this.budget,
    required this.spent,
    required this.isAr,
    required this.onSetBudget,
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

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.isAr ? 'ميزانية الشهر' : 'Monthly Budget',
                style: textTheme.titleLarge?.copyWith(fontSize: 18),
              ),
              IconButton(
                onPressed: widget.onSetBudget,
                icon: const Icon(
                  Icons.edit_outlined,
                  size: 20,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (widget.budget == 0)
            Text(
              widget.isAr ? 'لم تحدد ميزانية بعد' : 'No budget set yet',
              style: textTheme.bodyMedium?.copyWith(color: AppColors.outline),
            )
          else ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.isAr ? 'المصروف' : 'Spent so far',
                      style: textTheme.labelMedium?.copyWith(
                        color: AppColors.outline,
                      ),
                    ),
                    Text(
                      '\$${widget.spent.toInt()}',
                      style: textTheme.headlineLarge?.copyWith(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: isOver ? AppColors.expense : AppColors.onSurface,
                      ),
                    ),
                  ],
                ),
                Text(
                  '/ \$${widget.budget.toInt()}',
                  style: textTheme.titleMedium?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              height: 4,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(100),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progress,
                child: Container(
                  decoration: BoxDecoration(
                    color: isOver ? AppColors.expense : AppColors.primary,
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
                  widget.isAr ? '$daysLeft يوم متبقي' : '$daysLeft days left',
                  style: textTheme.labelMedium?.copyWith(
                    color: AppColors.outline,
                  ),
                ),
                Text(
                  '${(progress * 100).toInt()}%',
                  style: textTheme.labelLarge?.copyWith(
                    color: isOver ? AppColors.expense : AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
