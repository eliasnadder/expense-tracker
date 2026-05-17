import 'package:expense_tracker/core/constants/expense_categories.dart';
import 'package:expense_tracker/core/di/injection.dart';
import 'package:expense_tracker/features/auth/domain/repositories/auth_repository.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/auth_event.dart';
import 'package:expense_tracker/features/categories/domain/entities/category_entity.dart';
import 'package:expense_tracker/features/categories/presentation/bloc/category_bloc.dart';
import 'package:expense_tracker/features/categories/presentation/bloc/category_event.dart';
import 'package:expense_tracker/features/expenses/presentation/widgets/styled_input_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SetupCategoriesScreen extends StatefulWidget {
  final String userId;

  const SetupCategoriesScreen({super.key, required this.userId});

  @override
  State<SetupCategoriesScreen> createState() => _SetupCategoriesScreenState();
}

class _SetupCategoriesScreenState extends State<SetupCategoriesScreen> {
  // Track which default categories are selected with their limits
  final Map<String, bool> _selectedCategories = {};
  final Map<String, double> _categoryLimits = {};

  // Custom categories
  final List<Map<String, dynamic>> _customCategories = [];
  final TextEditingController _customNameController = TextEditingController();
  final TextEditingController _customLimitController = TextEditingController();
  String _customEmoji = '📦';
  bool _showCustomForm = false;

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
    // Initialize selection map - all unchecked by default
    for (final cat in kCategories) {
      _selectedCategories[cat.name] = false;
      _categoryLimits[cat.name] = 0;
    }
  }

  @override
  void dispose() {
    _customNameController.dispose();
    _customLimitController.dispose();
    super.dispose();
  }

  void _addCustomCategory() {
    final name = _customNameController.text.trim();
    if (name.isEmpty) return;

    final limit = double.tryParse(_customLimitController.text.trim()) ?? 0.0;

    setState(() {
      _customCategories.add({
        'name': name,
        'emoji': _customEmoji,
        'limit': limit,
      });
      _customNameController.clear();
      _customLimitController.clear();
      _customEmoji = '📦';
      _showCustomForm = false;
    });
  }

  void _removeCustomCategory(int index) {
    setState(() {
      _customCategories.removeAt(index);
    });
  }

  Future<void> _saveAndContinue() async {
    final now = DateTime.now();
    final selectedDefaults = kCategories
        .where((cat) => _selectedCategories[cat.name] == true)
        .toList();

    if (selectedDefaults.isEmpty && _customCategories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            Localizations.localeOf(context).languageCode == 'ar'
                ? 'يرجى اختيار فئة واحدة على الأقل'
                : 'Please select at least one category',
          ),
        ),
      );
      return;
    }

    // Save selected default categories
    for (final cat in selectedDefaults) {
      final id = 'cat_${cat.name.toLowerCase()}_${widget.userId}';
      final category = CategoryEntity(
        id: id,
        userId: widget.userId,
        name: cat.name,
        icon: cat.emoji,
        limit: _categoryLimits[cat.name] ?? 0,
        isCustom: false,
        createdAt: now,
      );
      context.read<CategoryBloc>().add(AddCategory(category));
    }

    // Save custom categories
    for (final custom in _customCategories) {
      final id = 'cat_${now.millisecondsSinceEpoch}_${custom['name']}';
      final category = CategoryEntity(
        id: id,
        userId: widget.userId,
        name: custom['name'] as String,
        icon: custom['emoji'] as String,
        limit: (custom['limit'] as double),
        isCustom: true,
        createdAt: now,
      );
      context.read<CategoryBloc>().add(AddCategory(category));
    }

    // Mark setup as complete in Firestore
    final authRepo = getIt<AuthRepository>();
    await authRepo.markSetupComplete(widget.userId);

    if (!mounted) return;

    // Dispatch SetupCompleted to update AuthBloc with fresh user data
    context.read<AuthBloc>().add(SetupCompleted(widget.userId));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(isAr ? 'إعداد الفئات' : 'Setup Categories'),
        backgroundColor: colorScheme.surface,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Text(
                  isAr ? 'اختر فئاتك المفضلة' : 'Choose Your Categories',
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isAr
                      ? 'اختر الفئات التي تناسب احتياجاتك وحدد حداً شهرياً لكل منها. يمكنك أيضاً إضافة فئات مخصصة.'
                      : 'Select categories that fit your needs and set a monthly limit for each. You can also add custom categories.',
                  style: textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 28),

                // Default Categories
                Text(
                  isAr ? 'الفئات الافتراضية' : 'Default Categories',
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                ...kCategories.map((cat) {
                  final isSelected = _selectedCategories[cat.name] == true;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: isSelected
                          ? BorderSide(color: colorScheme.primary, width: 2)
                          : BorderSide.none,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Text(
                                cat.emoji,
                                style: const TextStyle(fontSize: 28),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  isAr ? cat.nameAr : cat.name,
                                  style: textTheme.titleMedium,
                                ),
                              ),
                              Switch(
                                value: isSelected,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedCategories[cat.name] = value;
                                  });
                                },
                              ),
                            ],
                          ),
                          if (isSelected) ...[
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Text(
                                  isAr ? 'الحد الشهري:' : 'Monthly Limit:',
                                  style: textTheme.bodySmall,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: StyledInputField(
                                    height: 54,
                                    label: 'optinal',
                                    hintText: isAr ? 'اختياري' : 'Optional',
                                    keyboardType:
                                        const TextInputType.numberWithOptions(),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    onChanged: (value) {
                                      final parsed = double.tryParse(value);
                                      _categoryLimits[cat.name] = parsed ?? 0;
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                }),

                const SizedBox(height: 24),

                // Custom Categories Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isAr ? 'فئات مخصصة' : 'Custom Categories',
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (!_showCustomForm)
                      TextButton.icon(
                        onPressed: () => setState(() => _showCustomForm = true),
                        icon: const Icon(Icons.add),
                        label: Text(isAr ? 'إضافة' : 'Add'),
                      ),
                  ],
                ),
                const SizedBox(height: 8),

                // Custom Categories List
                ..._customCategories.asMap().entries.map((entry) {
                  final index = entry.key;
                  final custom = entry.value;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      leading: Text(
                        custom['emoji'] as String,
                        style: const TextStyle(fontSize: 28),
                      ),
                      title: Text(custom['name'] as String),
                      subtitle: (custom['limit'] as double) > 0
                          ? Text(
                              '\$${(custom['limit'] as double).toStringAsFixed(0)}',
                            )
                          : null,
                      trailing: IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        onPressed: () => _removeCustomCategory(index),
                      ),
                    ),
                  );
                }),

                // Add Custom Category Form
                if (_showCustomForm)
                  Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          StyledInputField(
                            controller: _customNameController,
                            label: isAr ? 'اسم الفئة' : 'Category Name',
                            hintText: isAr ? 'مثال: سفر' : 'e.g. Travel',
                          ),
                          const SizedBox(height: 12),
                          StyledInputField(
                            controller: _customLimitController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            label: isAr
                                ? 'الحد الشهري (اختياري)'
                                : 'Monthly Limit (optional)',
                            prefixText: '\$ ',
                          ),
                          const SizedBox(height: 12),
                          Text(
                            isAr ? 'اختر أيقونة' : 'Pick an Icon',
                            style: textTheme.bodySmall,
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: _emojis.map((emoji) {
                              final selected = emoji == _customEmoji;
                              return GestureDetector(
                                onTap: () =>
                                    setState(() => _customEmoji = emoji),
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: selected
                                        ? colorScheme.primaryContainer
                                        : colorScheme.surfaceContainerHigh,
                                    borderRadius: BorderRadius.circular(10),
                                    border: selected
                                        ? Border.all(
                                            color: colorScheme.primary,
                                            width: 2,
                                          )
                                        : null,
                                  ),
                                  child: Center(
                                    child: Text(
                                      emoji,
                                      style: const TextStyle(fontSize: 20),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _showCustomForm = false;
                                    _customNameController.clear();
                                    _customLimitController.clear();
                                  });
                                },
                                child: Text(isAr ? 'إلغاء' : 'Cancel'),
                              ),
                              const SizedBox(width: 8),
                              FilledButton(
                                onPressed: _addCustomCategory,
                                child: Text(isAr ? 'إضافة' : 'Add'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Fixed Bottom Button - styled like AddExpenseScreen
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    colorScheme.surface.withValues(alpha: 0),
                    colorScheme.surface,
                    colorScheme.surface,
                  ],
                ),
              ),
              child: ElevatedButton(
                onPressed: _saveAndContinue,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primaryContainer,
                  foregroundColor: colorScheme.onPrimaryContainer,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                  elevation: 8,
                  shadowColor: colorScheme.primary.withValues(alpha: 0.4),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check),
                    const SizedBox(width: 8),
                    Text(
                      isAr ? 'حفظ والمتابعة' : 'Save & Continue',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
