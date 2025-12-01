class Budget {
  final int? id;
  final String categoryName;
  final double monthlyLimit;
  final double? weeklyLimit;
  final bool isActive;
  final DateTime dateCreated;
  final DateTime? dateModified;
  final bool sendAlerts;
  final double alertThreshold; // Percentage (e.g., 80% of budget)

  Budget({
    this.id,
    required this.categoryName,
    required this.monthlyLimit,
    this.weeklyLimit,
    this.isActive = true,
    required this.dateCreated,
    this.dateModified,
    this.sendAlerts = true,
    this.alertThreshold = 80.0,
  });

  Budget copyWith({
    int? id,
    String? categoryName,
    double? monthlyLimit,
    double? weeklyLimit,
    bool? isActive,
    DateTime? dateCreated,
    DateTime? dateModified,
    bool? sendAlerts,
    double? alertThreshold,
  }) {
    return Budget(
      id: id ?? this.id,
      categoryName: categoryName ?? this.categoryName,
      monthlyLimit: monthlyLimit ?? this.monthlyLimit,
      weeklyLimit: weeklyLimit ?? this.weeklyLimit,
      isActive: isActive ?? this.isActive,
      dateCreated: dateCreated ?? this.dateCreated,
      dateModified: dateModified ?? this.dateModified,
      sendAlerts: sendAlerts ?? this.sendAlerts,
      alertThreshold: alertThreshold ?? this.alertThreshold,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category_name': categoryName,
      'monthly_limit': monthlyLimit,
      'weekly_limit': weeklyLimit,
      'is_active': isActive ? 1 : 0,
      'date_created': dateCreated.toIso8601String(),
      'date_modified': dateModified?.toIso8601String(),
      'send_alerts': sendAlerts ? 1 : 0,
      'alert_threshold': alertThreshold,
    };
  }

  factory Budget.fromMap(Map<String, dynamic> map) {
    return Budget(
      id: map['id'],
      categoryName: map['category_name'],
      monthlyLimit: (map['monthly_limit'] as num).toDouble(),
      weeklyLimit: map['weekly_limit'] != null ? (map['weekly_limit'] as num).toDouble() : null,
      isActive: map['is_active'] == 1,
      dateCreated: DateTime.parse(map['date_created']),
      dateModified: map['date_modified'] != null ? DateTime.parse(map['date_modified']) : null,
      sendAlerts: map['send_alerts'] == 1,
      alertThreshold: (map['alert_threshold'] as num).toDouble(),
    );
  }
}

class BudgetStatus {
  final Budget budget;
  final double spentThisMonth;
  final double spentThisWeek;
  final double remainingMonthly;
  final double remainingWeekly;
  final double monthlyPercentage;
  final double weeklyPercentage;
  final bool isExceeded;
  final bool shouldAlert;

  BudgetStatus({
    required this.budget,
    required this.spentThisMonth,
    required this.spentThisWeek,
    required this.remainingMonthly,
    required this.remainingWeekly,
    required this.monthlyPercentage,
    required this.weeklyPercentage,
    required this.isExceeded,
    required this.shouldAlert,
  });

  String getStatusColor() {
    if (monthlyPercentage >= 100) {
      return 'red'; // Over budget
    } else if (monthlyPercentage >= budget.alertThreshold) {
      return 'yellow'; // Warning
    } else {
      return 'green'; // Good
    }
  }

  String getStatusMessage() {
    if (monthlyPercentage >= 100) {
      return 'Over budget by ৳${(spentThisMonth - budget.monthlyLimit).toStringAsFixed(0)}';
    } else if (monthlyPercentage >= budget.alertThreshold) {
      final remaining = budget.monthlyLimit - spentThisMonth;
      return 'Only ৳${remaining.toStringAsFixed(0)} remaining (${(100 - monthlyPercentage).toStringAsFixed(1)}%)';
    } else {
      final remaining = budget.monthlyLimit - spentThisMonth;
      return 'On track: ৳${remaining.toStringAsFixed(0)} remaining';
    }
  }
}

class OverallBudgetStatus {
  final double totalMonthlyBudget;
  final double totalSpentThisMonth;
  final double totalRemainingMonthly;
  final double overallPercentage;
  final List<BudgetStatus> categoryStatuses;
  final int categoriesExceeded;
  final int categoriesWarning;

  OverallBudgetStatus({
    required this.totalMonthlyBudget,
    required this.totalSpentThisMonth,
    required this.totalRemainingMonthly,
    required this.overallPercentage,
    required this.categoryStatuses,
    required this.categoriesExceeded,
    required this.categoriesWarning,
  });

  String getOverallStatus() {
    if (overallPercentage >= 100) {
      return 'Over Budget';
    } else if (overallPercentage >= 80) {
      return 'Warning';
    } else if (overallPercentage >= 50) {
      return 'On Track';
    } else {
      return 'Excellent';
    }
  }

  String getMotivationalMessage() {
    if (overallPercentage >= 100) {
      return 'You\'ve exceeded your total budget. Focus on reducing spending.';
    } else if (overallPercentage >= 90) {
      return 'Almost at budget limit. Be careful with your spending!';
    } else if (overallPercentage >= 80) {
      return 'Getting close to budget limit. Control your spending!';
    } else if (overallPercentage >= 60) {
      return 'You\'re doing well! Keep maintaining discipline.';
    } else if (overallPercentage >= 40) {
      return 'Excellent budget control! Keep up the great work!';
    } else {
      return 'Outstanding! You\'re significantly under budget!';
    }
  }
}
