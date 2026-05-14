import 'package:expense_tracker/features/expenses/domain/entities/expense_entity.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:intl/intl.dart';

class GeminiService {
  static const _apiKey = String.fromEnvironment('GEMINI_API_KEY');
  late final GenerativeModel? _model;

  GeminiService() {
    _model = _apiKey.isEmpty
        ? null
        : GenerativeModel(model: 'gemini-2.5-flash', apiKey: _apiKey);
  }

  Future<String> analyzeExpenses({
    required List<ExpenseEntity> expenses,
    required double budget,
    required bool isAr,
  }) async {
    final model = _model;
    if (model == null) {
      throw StateError(
        'Missing GEMINI_API_KEY. Run Flutter with --dart-define=GEMINI_API_KEY=your_key.',
      );
    }

    if (expenses.isEmpty) {
      return isAr
          ? 'لا توجد بيانات كافية للتحليل. أضف بعض المصاريف أولاً.'
          : 'No data to analyze yet. Add some expenses first.';
    }

    final now = DateTime.now();
    final thisMonth = expenses
        .where((e) => e.date.month == now.month && e.date.year == now.year)
        .toList();

    final totalSpent = thisMonth
        .where((e) => !e.isIncome)
        .fold<double>(0, (s, e) => s + e.amount);

    // تجميع حسب الفئة
    final Map<String, double> byCategory = {};
    for (final e in thisMonth.where((e) => !e.isIncome)) {
      byCategory[e.category] = (byCategory[e.category] ?? 0) + e.amount;
    }

    final categoryLines = byCategory.entries
        .map((e) => '- ${e.key}: \$${e.value.toStringAsFixed(2)}')
        .join('\n');

    final prompt = isAr
        ? '''
أنت مستشار مالي ذكي. حلل مصاريف المستخدم وقدم نصائح باللغة العربية.

بيانات الشهر الحالي (${DateFormat('MMMM yyyy').format(now)}):
- إجمالي المصروف: \$${totalSpent.toStringAsFixed(2)}
- الميزانية المحددة: \$${budget.toStringAsFixed(2)}
- المتبقي: \$${(budget - totalSpent).toStringAsFixed(2)}

المصاريف حسب الفئة:
$categoryLines

المطلوب (بتنسيق واضح ومختصر):
1. 📊 تقييم سريع للإنفاق
2. ⚠️ أكثر فئة تستهلك الميزانية
3. 💡 3 نصائح عملية للتوفير
4. 🎯 هدف مقترح للشهر القادم

اكتب بأسلوب ودي ومشجع، ولا تتجاوز 200 كلمة.
'''
        : '''
You are a smart financial advisor. Analyze the user's expenses and provide advice in English.

Current month data (${DateFormat('MMMM yyyy').format(now)}):
- Total spent: \$${totalSpent.toStringAsFixed(2)}
- Budget: \$${budget.toStringAsFixed(2)}
- Remaining: \$${(budget - totalSpent).toStringAsFixed(2)}

Expenses by category:
$categoryLines

Required (clear and concise format):
1. 📊 Quick spending assessment
2. ⚠️ Top spending category
3. 💡 3 practical saving tips
4. 🎯 Suggested goal for next month

Write in a friendly and encouraging tone, max 150 words.
''';

    final response = await model.generateContent([Content.text(prompt)]);
    return response.text ??
        (isAr ? 'تعذر التحليل، حاول مجدداً.' : 'Analysis failed, try again.');
  }
}
