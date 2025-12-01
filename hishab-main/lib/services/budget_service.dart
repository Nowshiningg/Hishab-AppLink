import '../models/budget.dart';
import '../models/expense.dart';

class BudgetService {
  /// Calculate spending for a specific category in the current month
  static double getMonthlySpendingForCategory(
    List<Expense> allExpenses,
    String categoryName,
  ) {
    final now = DateTime.now();
    return allExpenses
        .where((expense) =>
            expense.category == categoryName &&
            expense.date.year == now.year &&
            expense.date.month == now.month)
        .fold(0.0, (sum, expense) => sum + expense.amount);
  }

  /// Calculate spending for a specific category in the current week
  static double getWeeklySpendingForCategory(
    List<Expense> allExpenses,
    String categoryName,
  ) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startDate = DateTime(
      startOfWeek.year,
      startOfWeek.month,
      startOfWeek.day,
    );

    return allExpenses
        .where((expense) =>
            expense.category == categoryName &&
            expense.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
            expense.date.isBefore(now.add(const Duration(days: 1))))
        .fold(0.0, (sum, expense) => sum + expense.amount);
  }

  /// Get budget status for a specific category
  static BudgetStatus getBudgetStatusForCategory(
    Budget budget,
    double spentThisMonth,
    double spentThisWeek,
  ) {
    final monthlyRemaining = budget.monthlyLimit - spentThisMonth;
    final monthlyPercentage = (spentThisMonth / budget.monthlyLimit) * 100;
    
    double weeklyRemaining = 0;
    double weeklyPercentage = 0;
    
    if (budget.weeklyLimit != null && budget.weeklyLimit! > 0) {
      weeklyRemaining = budget.weeklyLimit! - spentThisWeek;
      weeklyPercentage = (spentThisWeek / budget.weeklyLimit!) * 100;
    }

    final isExceeded = monthlyPercentage >= 100;
    final shouldAlert = monthlyPercentage >= budget.alertThreshold;

    return BudgetStatus(
      budget: budget,
      spentThisMonth: spentThisMonth,
      spentThisWeek: spentThisWeek,
      remainingMonthly: monthlyRemaining,
      remainingWeekly: weeklyRemaining,
      monthlyPercentage: monthlyPercentage,
      weeklyPercentage: weeklyPercentage,
      isExceeded: isExceeded,
      shouldAlert: shouldAlert,
    );
  }

  /// Get overall budget status across all budgets
  static OverallBudgetStatus getOverallBudgetStatus(
    List<Budget> budgets,
    List<Expense> allExpenses,
  ) {
    final activeBudgets = budgets.where((b) => b.isActive).toList();
    
    double totalMonthlyBudget = 0;
    double totalSpentThisMonth = 0;
    int categoriesExceeded = 0;
    int categoriesWarning = 0;
    
    final categoryStatuses = <BudgetStatus>[];

    for (var budget in activeBudgets) {
      final spentThisMonth = getMonthlySpendingForCategory(allExpenses, budget.categoryName);
      final spentThisWeek = getWeeklySpendingForCategory(allExpenses, budget.categoryName);
      
      totalMonthlyBudget += budget.monthlyLimit;
      totalSpentThisMonth += spentThisMonth;
      
      final status = getBudgetStatusForCategory(budget, spentThisMonth, spentThisWeek);
      categoryStatuses.add(status);
      
      if (status.isExceeded) {
        categoriesExceeded++;
      } else if (status.shouldAlert) {
        categoriesWarning++;
      }
    }

    final totalRemainingMonthly = totalMonthlyBudget - totalSpentThisMonth;
    final overallPercentage = totalMonthlyBudget > 0
        ? (totalSpentThisMonth / totalMonthlyBudget) * 100
        : 0.0;

    return OverallBudgetStatus(
      totalMonthlyBudget: totalMonthlyBudget,
      totalSpentThisMonth: totalSpentThisMonth,
      totalRemainingMonthly: totalRemainingMonthly,
      overallPercentage: overallPercentage,
      categoryStatuses: categoryStatuses,
      categoriesExceeded: categoriesExceeded,
      categoriesWarning: categoriesWarning,
    );
  }

  /// Get categories that need attention (exceeding or warning)
  static List<BudgetStatus> getCategoriesNeedingAttention(
    List<BudgetStatus> categoryStatuses,
  ) {
    return categoryStatuses
        .where((status) => status.isExceeded || status.shouldAlert)
        .toList();
  }

  /// Get budgets by status
  static List<BudgetStatus> getBudgetsByStatus(
    List<BudgetStatus> categoryStatuses, {
    required String status, // 'exceeded', 'warning', 'good'
  }) {
    switch (status) {
      case 'exceeded':
        return categoryStatuses.where((s) => s.isExceeded).toList();
      case 'warning':
        return categoryStatuses
            .where((s) => !s.isExceeded && s.shouldAlert)
            .toList();
      case 'good':
        return categoryStatuses
            .where((s) => !s.isExceeded && !s.shouldAlert)
            .toList();
      default:
        return [];
    }
  }

  /// Calculate daily spending limit for a category
  /// (budget remaining ÷ days remaining in month)
  static double getDailyLimitForCategory(Budget budget, double spentThisMonth) {
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final daysRemaining = daysInMonth - now.day + 1;

    if (daysRemaining <= 0) return 0;

    final remaining = budget.monthlyLimit - spentThisMonth;
    return remaining / daysRemaining;
  }

  /// Get spending trend for a category (last 7 days)
  static List<double> getSpendingTrendForCategory(
    List<Expense> allExpenses,
    String categoryName,
  ) {
    final last7Days = <double>[];
    final now = DateTime.now();

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dayStart = DateTime(date.year, date.month, date.day);
      final dayEnd = dayStart.add(const Duration(days: 1));

      final daySpent = allExpenses
          .where((expense) =>
              expense.category == categoryName &&
              expense.date.isAfter(dayStart) &&
              expense.date.isBefore(dayEnd))
          .fold(0.0, (sum, expense) => sum + expense.amount);

      last7Days.add(daySpent);
    }

    return last7Days;
  }

  /// Predict if budget will be exceeded based on spending rate
  static bool predictBudgetExceeded(
    Budget budget,
    double spentThisMonth,
    List<double> last7DaysSpending,
  ) {
    if (last7DaysSpending.isEmpty) return false;

    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final daysRemaining = daysInMonth - now.day + 1;

    if (daysRemaining <= 0) {
      return spentThisMonth >= budget.monthlyLimit;
    }

    // Calculate average daily spending
    final averageDailySpending = last7DaysSpending.reduce((a, b) => a + b) / last7DaysSpending.length;
    
    // Project total spending by end of month
    final projectedTotal = spentThisMonth + (averageDailySpending * daysRemaining);

    return projectedTotal > budget.monthlyLimit;
  }

  /// Get spending recommendations based on budget status
  static List<String> getRecommendations(
    List<BudgetStatus> categoryStatuses,
  ) {
    final recommendations = <String>[];

    // Check for exceeded budgets
    final exceeded = categoryStatuses.where((s) => s.isExceeded).toList();
    if (exceeded.isNotEmpty) {
      recommendations.add(
        '⚠️ ${exceeded.length} categor${exceeded.length > 1 ? 'ies' : 'y'} exceeded budget. '
        'Reduce spending on ${exceeded.map((s) => s.budget.categoryName).join(', ')}.',
      );
    }

    // Check for warning budgets
    final warning = categoryStatuses
        .where((s) => !s.isExceeded && s.shouldAlert)
        .toList();
    if (warning.isNotEmpty) {
      recommendations.add(
        '💡 ${warning.length} categor${warning.length > 1 ? 'ies' : 'y'} approaching limit. '
        'Watch spending on ${warning.map((s) => s.budget.categoryName).join(', ')}.',
      );
    }

    // Check if overall is good
    final good = categoryStatuses
        .where((s) => !s.isExceeded && !s.shouldAlert)
        .toList();
    if (good.length == categoryStatuses.length && categoryStatuses.isNotEmpty) {
      recommendations.add('✅ Great job! All categories are on track.');
    }

    // General recommendations
    final averageSpending = categoryStatuses.isNotEmpty
        ? categoryStatuses
                .fold<double>(0, (sum, s) => sum + s.monthlyPercentage) /
            categoryStatuses.length
        : 0;

    if (averageSpending > 80) {
      recommendations.add(
        '💰 Your overall spending is high. Consider setting lower budget targets.',
      );
    }

    return recommendations;
  }

  /// Check if user should get motivated/rewarded for budget compliance
  static String getMotivationalMessage(OverallBudgetStatus status) {
    return status.getMotivationalMessage();
  }

  /// Calculate savings vs budget
  static double calculateSavings(
    Budget budget,
    double spentThisMonth,
  ) {
    return budget.monthlyLimit - spentThisMonth;
  }

  /// Get percentage savings vs budget
  static double calculateSavingsPercentage(
    Budget budget,
    double spentThisMonth,
  ) {
    if (budget.monthlyLimit <= 0) return 0;
    return ((budget.monthlyLimit - spentThisMonth) / budget.monthlyLimit) * 100;
  }
}
