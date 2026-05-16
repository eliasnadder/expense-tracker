import 'package:expense_tracker/features/expenses/presentation/screens/add_expense_screen.dart';
import 'package:flutter/material.dart';

class NoExpense extends StatelessWidget {
  const NoExpense({
    super.key,
    required this.isAr,
    required this.userId,
    required this.mainAxisAlignment,
  });

  final bool isAr;
  final String userId;
  final MainAxisAlignment mainAxisAlignment;

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48.0),
        child: Column(
          mainAxisAlignment: mainAxisAlignment,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              isAr
                  ? 'لا توجد معاملات بعد.\nابدأ بإضافة مصاريفك!'
                  : 'No transactions yet.\nStart adding your expenses!',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddExpenseScreen(userId: userId),
                ),
              ),
              child: Container(
                width: 240,
                height: 48,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(24),
                ),
                alignment: Alignment.center,
                child: Text(
                  isAr ? 'إضافة مصاريف' : 'Add Expenses',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
