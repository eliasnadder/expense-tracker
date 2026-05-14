class ExpenseCategory {
  final String name;
  final String emoji;
  final String nameAr;
  final String type;

  const ExpenseCategory({
    required this.name,
    required this.emoji,
    required this.nameAr,
    this.type = 'expense',
  });
}

const List<ExpenseCategory> kCategories = [
  ExpenseCategory(name: 'Food', emoji: '🍔', nameAr: 'طعام'),
  ExpenseCategory(name: 'Transport', emoji: '🚗', nameAr: 'مواصلات'),
  ExpenseCategory(name: 'Shopping', emoji: '🛍️', nameAr: 'تسوق'),
  ExpenseCategory(name: 'Bills', emoji: '💡', nameAr: 'فواتير'),
  ExpenseCategory(name: 'Health', emoji: '💊', nameAr: 'صحة'),
  ExpenseCategory(name: 'Entertainment', emoji: '🎮', nameAr: 'ترفيه'),
  ExpenseCategory(name: 'Education', emoji: '📚', nameAr: 'تعليم'),
  ExpenseCategory(name: 'Salary', emoji: '💰', nameAr: 'راتب', type: 'income'),
  ExpenseCategory(name: 'Gift', emoji: '🎁', nameAr: 'هدية', type: 'income'),
  ExpenseCategory(
    name: 'Investment',
    emoji: '📈',
    nameAr: 'استثمار',
    type: 'income',
  ),
  ExpenseCategory(name: 'Other', emoji: '📦', nameAr: 'أخرى'),
];
