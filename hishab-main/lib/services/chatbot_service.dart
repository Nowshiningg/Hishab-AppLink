import 'package:intl/intl.dart';
import '../providers/finance_provider.dart';

class ChatbotService {
  static Future<String> processQuestion(
    String question,
    FinanceProvider provider,
    String languageCode,
  ) async {
    final lowerQuestion = question.toLowerCase();

    // Get current month data
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);

    // Get last month data
    final startOfLastMonth = DateTime(now.year, now.month - 1, 1);
    final endOfLastMonth = DateTime(now.year, now.month, 0);

    // Question type detection and response
    try {
      // 1. Biggest expense
      if (_containsAny(lowerQuestion, ['biggest', 'largest', 'most expensive', 'সবচেয়ে বড়', 'সর্বোচ্চ'])) {
        return await _getBiggestExpense(provider, languageCode);
      }

      // 2. Monthly spending
      if (_containsAny(lowerQuestion, ['this month', 'monthly', 'total', 'মাসে', 'মোট'])) {
        return await _getMonthlySpending(provider, languageCode);
      }

      // 3. Can I spend today
      if (_containsAny(lowerQuestion, ['can i spend', 'afford', 'budget', 'পারি', 'বাজেট'])) {
        final amount = _extractAmount(lowerQuestion);
        return await _canISpend(provider, amount, languageCode);
      }

      // 4. Spending trend comparison
      if (_containsAny(lowerQuestion, ['more than last month', 'compared', 'trend', 'গত মাস', 'তুলনা'])) {
        return await _getSpendingTrend(provider, languageCode);
      }

      // 5. Category-specific spending
      if (_containsAny(lowerQuestion, ['food', 'transport', 'shopping', 'খাবার', 'যাতায়াত'])) {
        final category = _extractCategory(lowerQuestion, provider.categories.map((c) => c.name).toList());
        if (category != null) {
          return await _getCategorySpending(provider, category, languageCode);
        }
      }

      // 6. Today's spending
      if (_containsAny(lowerQuestion, ['today', 'আজ', 'আজকে'])) {
        return await _getTodaySpending(provider, languageCode);
      }

      // 7. Remaining days budget
      if (_containsAny(lowerQuestion, ['per day', 'daily', 'remaining', 'বাকি', 'প্রতিদিন'])) {
        return await _getDailyBudget(provider, languageCode);
      }

      // Default response
      return languageCode == 'bn'
          ? 'দুঃখিত, আমি বুঝতে পারিনি। আপনি জিজ্ঞাসা করতে পারেন:\n• আমার সবচেয়ে বড় খরচ কি?\n• এই মাসে আমি কত খরচ করেছি?\n• আজ আমি কত টাকা খরচ করতে পারি?'
          : 'Sorry, I didn\'t understand. You can ask:\n• What was my biggest expense?\n• How much did I spend this month?\n• How much can I spend today?';
    } catch (e) {
      return languageCode == 'bn'
          ? 'দুঃখিত, একটি ত্রুটি ঘটেছে।'
          : 'Sorry, an error occurred.';
    }
  }

  static Future<String> _getBiggestExpense(FinanceProvider provider, String lang) async {
    if (provider.expenses.isEmpty) {
      return lang == 'bn' ? 'আপনার কোনো খরচ নেই।' : 'You have no expenses yet.';
    }

    final biggestExpense = provider.expenses.reduce((a, b) => a.amount > b.amount ? a : b);
    final formattedAmount = NumberFormat('#,##0').format(biggestExpense.amount);

    if (lang == 'bn') {
      return 'আপনার সবচেয়ে বড় খরচ হল ৳$formattedAmount ${biggestExpense.category} ক্যাটাগরিতে।';
    } else {
      return 'Your biggest expense was ৳$formattedAmount on ${biggestExpense.category}.';
    }
  }

  static Future<String> _getMonthlySpending(FinanceProvider provider, String lang) async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

    double total = 0;
    for (var expense in provider.expenses) {
      if (expense.date.isAfter(startOfMonth.subtract(const Duration(days: 1))) &&
          expense.date.isBefore(endOfMonth.add(const Duration(days: 1)))) {
        total += expense.amount;
      }
    }

    final formattedAmount = NumberFormat('#,##0').format(total);

    if (lang == 'bn') {
      return 'এই মাসে আপনি মোট ৳$formattedAmount খরচ করেছেন।';
    } else {
      return 'You have spent ৳$formattedAmount this month.';
    }
  }

  static Future<String> _canISpend(FinanceProvider provider, double? amount, String lang) async {
    final monthlyIncome = provider.income?.monthlyIncome ?? 0;

    if (monthlyIncome == 0) {
      return lang == 'bn'
          ? 'প্রথমে আপনার মাসিক আয় সেট করুন।'
          : 'Please set your monthly income first.';
    }

    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

    double totalSpent = 0;
    for (var expense in provider.expenses) {
      if (expense.date.isAfter(startOfMonth.subtract(const Duration(days: 1))) &&
          expense.date.isBefore(endOfMonth.add(const Duration(days: 1)))) {
        totalSpent += expense.amount;
      }
    }

    final remaining = monthlyIncome - totalSpent;
    final daysLeft = endOfMonth.difference(now).inDays + 1;
    final perDayBudget = remaining / daysLeft;

    if (amount != null) {
      if (amount <= perDayBudget) {
        return lang == 'bn'
            ? 'হ্যাঁ, আপনি ৳${NumberFormat('#,##0').format(amount)} খরচ করতে পারেন। আপনার প্রতিদিনের বাজেট ৳${NumberFormat('#,##0').format(perDayBudget)}।'
            : 'Yes, you can spend ৳${NumberFormat('#,##0').format(amount)}. Your daily budget is ৳${NumberFormat('#,##0').format(perDayBudget)}.';
      } else {
        return lang == 'bn'
            ? 'সাবধান! এটি আপনার দৈনিক বাজেট (৳${NumberFormat('#,##0').format(perDayBudget)}) অতিক্রম করবে।'
            : 'Warning! This exceeds your daily budget of ৳${NumberFormat('#,##0').format(perDayBudget)}.';
      }
    }

    return lang == 'bn'
        ? 'আপনি প্রতিদিন ৳${NumberFormat('#,##0').format(perDayBudget)} খরচ করতে পারেন। মাসে বাকি আছে ৳${NumberFormat('#,##0').format(remaining)}।'
        : 'You can spend ৳${NumberFormat('#,##0').format(perDayBudget)} per day. You have ৳${NumberFormat('#,##0').format(remaining)} left this month.';
  }

  static Future<String> _getSpendingTrend(FinanceProvider provider, String lang) async {
    final now = DateTime.now();

    // This month
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

    // Last month
    final startOfLastMonth = DateTime(now.year, now.month - 1, 1);
    final endOfLastMonth = DateTime(now.year, now.month, 0, 23, 59, 59);

    double thisMonthTotal = 0;
    double lastMonthTotal = 0;

    for (var expense in provider.expenses) {
      if (expense.date.isAfter(startOfMonth.subtract(const Duration(days: 1))) &&
          expense.date.isBefore(endOfMonth.add(const Duration(days: 1)))) {
        thisMonthTotal += expense.amount;
      } else if (expense.date.isAfter(startOfLastMonth.subtract(const Duration(days: 1))) &&
          expense.date.isBefore(endOfLastMonth.add(const Duration(days: 1)))) {
        lastMonthTotal += expense.amount;
      }
    }

    if (lastMonthTotal == 0) {
      return lang == 'bn'
          ? 'গত মাসে কোনো খরচ ছিল না।'
          : 'No expenses recorded for last month.';
    }

    final difference = thisMonthTotal - lastMonthTotal;
    final percentageChange = ((difference / lastMonthTotal) * 100).abs();

    if (difference > 0) {
      return lang == 'bn'
          ? 'হ্যাঁ, আপনি গত মাসের চেয়ে ${percentageChange.toStringAsFixed(1)}% বেশি খরচ করছেন। (৳${NumberFormat('#,##0').format(difference.abs())} বেশি)'
          : 'Yes, you\'re spending ${percentageChange.toStringAsFixed(1)}% more than last month. (৳${NumberFormat('#,##0').format(difference.abs())} more)';
    } else if (difference < 0) {
      return lang == 'bn'
          ? 'না, আপনি গত মাসের চেয়ে ${percentageChange.toStringAsFixed(1)}% কম খরচ করছেন। (৳${NumberFormat('#,##0').format(difference.abs())} কম)'
          : 'No, you\'re spending ${percentageChange.toStringAsFixed(1)}% less than last month. (৳${NumberFormat('#,##0').format(difference.abs())} less)';
    } else {
      return lang == 'bn' ? 'আপনার খরচ গত মাসের সমান।' : 'Your spending is the same as last month.';
    }
  }

  static Future<String> _getTodaySpending(FinanceProvider provider, String lang) async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    double total = 0;
    for (var expense in provider.expenses) {
      if (expense.date.isAfter(startOfDay.subtract(const Duration(seconds: 1))) &&
          expense.date.isBefore(endOfDay.add(const Duration(seconds: 1)))) {
        total += expense.amount;
      }
    }

    final formattedAmount = NumberFormat('#,##0').format(total);

    return lang == 'bn'
        ? 'আজ আপনি ৳$formattedAmount খরচ করেছেন।'
        : 'Today you have spent ৳$formattedAmount.';
  }

  static Future<String> _getDailyBudget(FinanceProvider provider, String lang) async {
    final monthlyIncome = provider.income?.monthlyIncome ?? 0;

    if (monthlyIncome == 0) {
      return lang == 'bn'
          ? 'প্রথমে আপনার মাসিক আয় সেট করুন।'
          : 'Please set your monthly income first.';
    }

    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);

    double totalSpent = 0;
    for (var expense in provider.expenses) {
      if (expense.date.isAfter(startOfMonth.subtract(const Duration(days: 1))) &&
          expense.date.isBefore(endOfMonth.add(const Duration(days: 1)))) {
        totalSpent += expense.amount;
      }
    }

    final remaining = monthlyIncome - totalSpent;
    final daysLeft = endOfMonth.difference(now).inDays + 1;
    final perDayBudget = remaining / daysLeft;

    return lang == 'bn'
        ? 'মাসের বাকি $daysLeft দিনের জন্য, আপনি প্রতিদিন ৳${NumberFormat('#,##0').format(perDayBudget)} খরচ করতে পারেন।'
        : 'For the remaining $daysLeft days of the month, you can spend ৳${NumberFormat('#,##0').format(perDayBudget)} per day.';
  }

  static Future<String> _getCategorySpending(FinanceProvider provider, String category, String lang) async {
    double total = 0;
    for (var expense in provider.expenses) {
      if (expense.category.toLowerCase() == category.toLowerCase()) {
        total += expense.amount;
      }
    }

    final formattedAmount = NumberFormat('#,##0').format(total);

    return lang == 'bn'
        ? '$category ক্যাটাগরিতে আপনি মোট ৳$formattedAmount খরচ করেছেন।'
        : 'You have spent ৳$formattedAmount on $category.';
  }

  // Helper methods
  static bool _containsAny(String text, List<String> keywords) {
    return keywords.any((keyword) => text.contains(keyword.toLowerCase()));
  }

  static double? _extractAmount(String text) {
    final RegExp numberRegex = RegExp(r'\d+(?:\.\d+)?');
    final match = numberRegex.firstMatch(text);
    if (match != null) {
      return double.tryParse(match.group(0)!);
    }
    return null;
  }

  static String? _extractCategory(String text, List<String> categories) {
    for (var category in categories) {
      if (text.toLowerCase().contains(category.toLowerCase())) {
        return category;
      }
    }
    return null;
  }
}
