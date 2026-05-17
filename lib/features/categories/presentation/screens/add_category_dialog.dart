import 'package:expense_tracker/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/auth_state.dart';
import 'package:expense_tracker/features/categories/domain/entities/category_entity.dart';
import 'package:expense_tracker/features/categories/presentation/bloc/category_bloc.dart';
import 'package:expense_tracker/features/categories/presentation/bloc/category_event.dart';
import 'package:expense_tracker/features/expenses/presentation/widgets/styled_input_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddCategoryDialog extends StatefulWidget {
  const AddCategoryDialog({super.key});

  @override
  State<AddCategoryDialog> createState() => _AddCategoryDialogState();
}

class _AddCategoryDialogState extends State<AddCategoryDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _limitController;
  String _selectedEmoji = '📦';
  bool _isSaving = false;

  final List<String> _emojis = [
    '🍔',
    '🚗',
    '🛍️',
    '💡',
    '💊',
    '🎮',
    '📚',
    '💰',
    '🎁',
    '📈',
    '🏠',
    '🐾',
    '👕',
    '✈️',
    '🎓',
    '🏋️',
    '🎬',
    '☕',
    '📦',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _limitController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _limitController.dispose();
    super.dispose();
  }

  void _saveCategory() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final limit = double.tryParse(_limitController.text.trim()) ?? 0.0;
    final now = DateTime.now();
    final id = 'cat_${now.millisecondsSinceEpoch}';

    // Get userId from the first authenticated expense or from AuthBloc
    String userId = '';
    try {
      final authState = context.read<AuthBloc>().state;
      if (authState is AuthAuthenticated) {
        userId = authState.user.id;
      }
    } catch (_) {
      Navigator.of(context).pop();
      return;
    }

    if (userId.isEmpty) {
      Navigator.of(context).pop();
      return;
    }

    setState(() => _isSaving = true);

    context.read<CategoryBloc>().add(
      AddCategory(
        CategoryEntity(
          id: id,
          userId: userId,
          name: name,
          icon: _selectedEmoji,
          limit: limit,
          isCustom: true,
          createdAt: now,
        ),
      ),
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final color = theme.colorScheme;
    return AlertDialog(
      title: Text(isAr ? 'إضافة فئة جديدة' : 'Add New Category'),
      backgroundColor: color.surface,
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category Name
            StyledInputField(
              controller: _nameController,
              label: isAr ? 'اسم الفئة' : 'Category Name',
              hintText: isAr ? 'مثال: تسوق' : 'e.g. Shopping',
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
            ),
            const SizedBox(height: 16),

            // Monthly Limit
            StyledInputField(
              controller: _limitController,
              label: isAr
                  ? 'الحد الشهري (اختياري)'
                  : 'Monthly Limit (optional)',
              hintText: isAr ? 'مثال: 500' : 'e.g. 500',
              prefixText: '\$ ',
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
            ),
            const SizedBox(height: 16),

            // Emoji picker
            Text(
              isAr ? 'اختر أيقونة' : 'Pick an Icon',
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _emojis.map((emoji) {
                final selected = emoji == _selectedEmoji;
                return GestureDetector(
                  onTap: () => setState(() => _selectedEmoji = emoji),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: selected
                          ? theme.colorScheme.primaryContainer
                          : theme.colorScheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(12),
                      border: selected
                          ? Border.all(
                              color: theme.colorScheme.primary,
                              width: 2,
                            )
                          : null,
                    ),
                    child: Center(
                      child: Text(emoji, style: const TextStyle(fontSize: 22)),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(isAr ? 'إلغاء' : 'Cancel'),
        ),
        FilledButton(
          onPressed: _isSaving ? null : _saveCategory,
          child: _isSaving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(isAr ? 'حفظ' : 'Save'),
        ),
      ],
    );
  }
}
