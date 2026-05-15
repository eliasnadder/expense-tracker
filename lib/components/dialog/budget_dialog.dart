import 'package:expense_tracker/features/budget/presentation/bloc/budget_bloc.dart';
import 'package:expense_tracker/features/budget/presentation/bloc/budget_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SetBudgetDialog extends StatefulWidget {
  final bool isAr;
  final double currentBudget;
  final String userId;

  const SetBudgetDialog({
    super.key,
    required this.isAr,
    required this.currentBudget,
    required this.userId,
  });

  @override
  State<SetBudgetDialog> createState() => _SetBudgetDialogState();
}

class _SetBudgetDialogState extends State<SetBudgetDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();

    _controller = TextEditingController(
      text: widget.currentBudget > 0
          ? widget.currentBudget.toStringAsFixed(0)
          : '',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _saveBudget() {
    final amount = double.tryParse(_controller.text.trim());

    if (amount == null || amount <= 0) {
      return;
    }

    final now = DateTime.now();

    context.read<BudgetBloc>().add(
      SetBudget(
        userId: widget.userId,
        category: 'Total',
        amount: amount,
        month: now.month,
        year: now.year,
      ),
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Text(widget.isAr ? 'تحديد الميزانية' : 'Set Budget'),

      content: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(75),
        ),
        child: Row(
          children: [
            Icon(Icons.attach_money, color: theme.colorScheme.onSurfaceVariant),

            const SizedBox(width: 12),

            Expanded(
              child: TextField(
                controller: _controller,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                style: theme.textTheme.bodyLarge?.copyWith(fontSize: 24),
                cursorHeight: theme.textTheme.bodyLarge
                    ?.copyWith(fontSize: 24)
                    .fontSize,
                decoration: InputDecoration(
                  hintText: widget.isAr ? 'المبلغ الشهري' : 'Monthly Amount',
                  border: InputBorder.none,
                  fillColor: Colors.transparent,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                ),
              ),
            ),
          ],
        ),
      ),

      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(widget.isAr ? 'إلغاء' : 'Cancel'),
        ),

        FilledButton(
          onPressed: _saveBudget,
          child: Text(widget.isAr ? 'حفظ' : 'Save'),
        ),
      ],
    );
  }
}
