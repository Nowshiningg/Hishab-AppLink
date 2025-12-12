import 'dart:async';

class ReminderConfig {
  final int firstReminderHour; // e.g., 12 (noon)
  final int secondReminderHour; // e.g., 19 (7 PM)
  final bool enableMorningGreeting;
  final bool enableEveningReview;
  final bool enableWeeklyReview;
  final bool enableBudgetAlerts;

  ReminderConfig({
    this.firstReminderHour = 12,
    this.secondReminderHour = 19,
    this.enableMorningGreeting = true,
    this.enableEveningReview = true,
    this.enableWeeklyReview = true,
    this.enableBudgetAlerts = true,
  });

  ReminderConfig copyWith({
    int? firstReminderHour,
    int? secondReminderHour,
    bool? enableMorningGreeting,
    bool? enableEveningReview,
    bool? enableWeeklyReview,
    bool? enableBudgetAlerts,
  }) {
    return ReminderConfig(
      firstReminderHour: firstReminderHour ?? this.firstReminderHour,
      secondReminderHour: secondReminderHour ?? this.secondReminderHour,
      enableMorningGreeting: enableMorningGreeting ?? this.enableMorningGreeting,
      enableEveningReview: enableEveningReview ?? this.enableEveningReview,
      enableWeeklyReview: enableWeeklyReview ?? this.enableWeeklyReview,
      enableBudgetAlerts: enableBudgetAlerts ?? this.enableBudgetAlerts,
    );
  }
}

class ReminderNotification {
  final String id;
  final String title;
  final String message;
  final ReminderType type;
  final DateTime scheduledTime;
  final Map<String, dynamic> payload;
  final bool isScheduled;

  ReminderNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.scheduledTime,
    required this.payload,
    this.isScheduled = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type.toString(),
      'scheduled_time': scheduledTime.toIso8601String(),
      'payload': payload,
      'is_scheduled': isScheduled ? 1 : 0,
    };
  }

  factory ReminderNotification.fromMap(Map<String, dynamic> map) {
    return ReminderNotification(
      id: map['id'],
      title: map['title'],
      message: map['message'],
      type: _parseReminderType(map['type']),
      scheduledTime: DateTime.parse(map['scheduled_time']),
      payload: map['payload'] ?? {},
      isScheduled: map['is_scheduled'] == 1,
    );
  }

  static ReminderType _parseReminderType(String type) {
    switch (type) {
      case 'ReminderType.expenseUpdate':
        return ReminderType.expenseUpdate;
      case 'ReminderType.budgetAlert':
        return ReminderType.budgetAlert;
      case 'ReminderType.weeklyReview':
        return ReminderType.weeklyReview;
      case 'ReminderType.monthlyReview':
        return ReminderType.monthlyReview;
      case 'ReminderType.morningGreeting':
        return ReminderType.morningGreeting;
      case 'ReminderType.eveningReview':
        return ReminderType.eveningReview;
      case 'ReminderType.rewardNotification':
        return ReminderType.rewardNotification;
      default:
        return ReminderType.expenseUpdate;
    }
  }
}

enum ReminderType {
  expenseUpdate,
  budgetAlert,
  weeklyReview,
  monthlyReview,
  morningGreeting,
  eveningReview,
  rewardNotification,
}

class DailyRemindersService {
  static final DailyRemindersService _instance = DailyRemindersService._internal();
  
  factory DailyRemindersService() {
    return _instance;
  }

  DailyRemindersService._internal();

  Timer? _reminderTimer;
  final List<ReminderNotification> _scheduledReminders = [];
  final List<Function(ReminderNotification)> _onReminderCallbacks = [];

  /// Initialize reminder service with configuration
  void initialize(ReminderConfig config) {
    // Start daily reminder check
    _startReminderCheck();
  }

  /// Register callback for reminder notifications
  void onReminder(Function(ReminderNotification) callback) {
    _onReminderCallbacks.add(callback);
  }

  /// Start checking for reminders every minute
  void _startReminderCheck() {
    _reminderTimer?.cancel();
    _reminderTimer = Timer.periodic(
      const Duration(minutes: 1),
      (_) => _checkReminders(),
    );
  }

  /// Check if any reminders should be triggered
  void _checkReminders() {
    final now = DateTime.now();
    
    final triggeredReminders = _scheduledReminders
        .where((reminder) =>
            reminder.isScheduled &&
            reminder.scheduledTime.isBefore(now.add(const Duration(minutes: 1))) &&
            reminder.scheduledTime.isAfter(now.subtract(const Duration(minutes: 1))))
        .toList();

    for (var reminder in triggeredReminders) {
      _triggerReminder(reminder);
    }
  }

  /// Trigger reminder and call callbacks
  void _triggerReminder(ReminderNotification reminder) {
    for (var callback in _onReminderCallbacks) {
      callback(reminder);
    }
  }

  // ==================== Morning Greeting ====================

  ReminderNotification createMorningGreeting({
    required String userName,
    required double dailyAllowance,
    required DateTime scheduledTime,
  }) {
    return ReminderNotification(
      id: 'morning_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Good Morning, ${userName.split(' ').first}!',
      message: 'Your daily allowance is ৳${dailyAllowance.toStringAsFixed(0)}. '
          'Tap to start tracking your expenses.',
      type: ReminderType.morningGreeting,
      scheduledTime: scheduledTime,
      payload: {
        'daily_allowance': dailyAllowance,
        'user_name': userName,
      },
    );
  }

  // ==================== Expense Update Reminders ====================

  ReminderNotification createExpenseUpdateReminder({
    required String userName,
    required double todaySpent,
    required double dailyAllowance,
    required DateTime scheduledTime,
    required int reminderNumber, // 1st or 2nd reminder
  }) {
    final percentage = dailyAllowance > 0 ? (todaySpent / dailyAllowance) * 100 : 0;
    final statusEmoji = percentage > 100 ? '🔴' : percentage > 80 ? '🟡' : '🟢';
    
    return ReminderNotification(
      id: 'expense_${reminderNumber}_${DateTime.now().millisecondsSinceEpoch}',
      title: '$statusEmoji Time to Update Expenses',
      message: 'You\'ve spent ৳${todaySpent.toStringAsFixed(0)} today '
          '(${percentage.toStringAsFixed(0)}% of your allowance). '
          'Tap to add today\'s expenses.',
      type: ReminderType.expenseUpdate,
      scheduledTime: scheduledTime,
      payload: {
        'today_spent': todaySpent,
        'daily_allowance': dailyAllowance,
        'reminder_number': reminderNumber,
      },
    );
  }

  // ==================== Budget Alert ====================

  ReminderNotification createBudgetAlert({
    required String categoryName,
    required double spent,
    required double limit,
    required DateTime scheduledTime,
  }) {
    final percentage = (spent / limit) * 100;
    final isExceeded = percentage > 100;
    
    return ReminderNotification(
      id: 'budget_alert_${categoryName}_${DateTime.now().millisecondsSinceEpoch}',
      title: '⚠️ Budget Alert: $categoryName',
      message: isExceeded
          ? 'You\'ve exceeded your $categoryName budget by ৳${(spent - limit).toStringAsFixed(0)}.'
          : 'You\'ve spent ${percentage.toStringAsFixed(0)}% of your $categoryName budget. '
              '৳${(limit - spent).toStringAsFixed(0)} remaining.',
      type: ReminderType.budgetAlert,
      scheduledTime: scheduledTime,
      payload: {
        'category': categoryName,
        'spent': spent,
        'limit': limit,
        'percentage': percentage,
      },
    );
  }

  // ==================== Evening Review ====================

  ReminderNotification createEveningReview({
    required double todaySpent,
    required double dailyAllowance,
    required double weekTotal,
    required DateTime scheduledTime,
  }) {
    final percentage = dailyAllowance > 0 ? (todaySpent / dailyAllowance) * 100 : 0;
    final statusEmoji = percentage > 100 ? '🔴' : percentage > 80 ? '🟡' : '🟢';
    
    return ReminderNotification(
      id: 'evening_review_${DateTime.now().millisecondsSinceEpoch}',
      title: '$statusEmoji End of Day Review',
      message: 'Today: ৳${todaySpent.toStringAsFixed(0)} | This Week: ৳${weekTotal.toStringAsFixed(0)}. '
          'Tap to see your daily summary.',
      type: ReminderType.eveningReview,
      scheduledTime: scheduledTime,
      payload: {
        'today_spent': todaySpent,
        'daily_allowance': dailyAllowance,
        'week_total': weekTotal,
      },
    );
  }

  // ==================== Weekly Review ====================

  ReminderNotification createWeeklyReview({
    required double weekTotal,
    required double weekBudget,
    required String topCategory,
    required double topCategorySpent,
    required DateTime scheduledTime,
  }) {
    final percentage = weekBudget > 0 ? (weekTotal / weekBudget) * 100 : 0;
    
    return ReminderNotification(
      id: 'weekly_review_${DateTime.now().millisecondsSinceEpoch}',
      title: '📊 Weekly Spending Review',
      message: 'This week: ৳${weekTotal.toStringAsFixed(0)} (${percentage.toStringAsFixed(0)}% of budget). '
          'Top category: $topCategory (৳${topCategorySpent.toStringAsFixed(0)}). Tap for details.',
      type: ReminderType.weeklyReview,
      scheduledTime: scheduledTime,
      payload: {
        'week_total': weekTotal,
        'week_budget': weekBudget,
        'top_category': topCategory,
        'top_category_spent': topCategorySpent,
      },
    );
  }

  // ==================== Monthly Review ====================

  ReminderNotification createMonthlyReview({
    required double monthTotal,
    required double monthBudget,
    required double averageDailySpending,
    required String savingsStatus,
    required DateTime scheduledTime,
  }) {
    final percentage = monthBudget > 0 ? (monthTotal / monthBudget) * 100 : 0;
    
    return ReminderNotification(
      id: 'monthly_review_${DateTime.now().millisecondsSinceEpoch}',
      title: '💰 Monthly Spending Review',
      message: 'This month: ৳${monthTotal.toStringAsFixed(0)} (${percentage.toStringAsFixed(0)}% of budget). '
          'Avg daily: ৳${averageDailySpending.toStringAsFixed(0)}. Status: $savingsStatus.',
      type: ReminderType.monthlyReview,
      scheduledTime: scheduledTime,
      payload: {
        'month_total': monthTotal,
        'month_budget': monthBudget,
        'average_daily': averageDailySpending,
        'savings_status': savingsStatus,
      },
    );
  }

  // ==================== Reward Notification ====================

  ReminderNotification createRewardNotification({
    required int pointsEarned,
    required int totalPoints,
    required String reason,
    required DateTime scheduledTime,
  }) {
    return ReminderNotification(
      id: 'reward_${DateTime.now().millisecondsSinceEpoch}',
      title: '🎉 Rewards Earned!',
      message: 'You earned $pointsEarned points! Total: $totalPoints points. Reason: $reason. '
          'Tap to see available rewards.',
      type: ReminderType.rewardNotification,
      scheduledTime: scheduledTime,
      payload: {
        'points_earned': pointsEarned,
        'total_points': totalPoints,
        'reason': reason,
      },
    );
  }

  // ==================== Schedule Management ====================

  /// Schedule a reminder
  void scheduleReminder(ReminderNotification reminder) {
    _scheduledReminders.add(reminder.copyWith(isScheduled: true));
  }

  /// Schedule daily reminders
  void scheduleDailyReminders({
    required ReminderConfig config,
    required String userName,
    required double dailyAllowance,
    required double todaySpent,
    required double weekTotal,
  }) {
    final now = DateTime.now();

    // Morning greeting (if enabled)
    if (config.enableMorningGreeting) {
      final morningTime = DateTime(now.year, now.month, now.day, 8, 0);
      if (morningTime.isAfter(now)) {
        scheduleReminder(
          createMorningGreeting(
            userName: userName,
            dailyAllowance: dailyAllowance,
            scheduledTime: morningTime,
          ),
        );
      }
    }

    // First expense update reminder
    final firstReminderTime = DateTime(
      now.year,
      now.month,
      now.day,
      config.firstReminderHour,
      0,
    );
    if (firstReminderTime.isAfter(now)) {
      scheduleReminder(
        createExpenseUpdateReminder(
          userName: userName,
          todaySpent: todaySpent,
          dailyAllowance: dailyAllowance,
          scheduledTime: firstReminderTime,
          reminderNumber: 1,
        ),
      );
    }

    // Second expense update reminder
    final secondReminderTime = DateTime(
      now.year,
      now.month,
      now.day,
      config.secondReminderHour,
      0,
    );
    if (secondReminderTime.isAfter(now)) {
      scheduleReminder(
        createExpenseUpdateReminder(
          userName: userName,
          todaySpent: todaySpent,
          dailyAllowance: dailyAllowance,
          scheduledTime: secondReminderTime,
          reminderNumber: 2,
        ),
      );
    }

    // Evening review (if enabled)
    if (config.enableEveningReview) {
      final eveningTime = DateTime(now.year, now.month, now.day, 21, 0);
      scheduleReminder(
        createEveningReview(
          todaySpent: todaySpent,
          dailyAllowance: dailyAllowance,
          weekTotal: weekTotal,
          scheduledTime: eveningTime,
        ),
      );
    }
  }

  /// Get next scheduled reminder
  ReminderNotification? getNextReminder() {
    if (_scheduledReminders.isEmpty) return null;

    _scheduledReminders.sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));
    return _scheduledReminders.firstWhere(
      (r) => r.scheduledTime.isAfter(DateTime.now()),
      orElse: () => _scheduledReminders.first,
    );
  }

  /// Get all scheduled reminders
  List<ReminderNotification> getScheduledReminders() {
    return _scheduledReminders
        .where((r) => r.isScheduled)
        .toList();
  }

  /// Clear all scheduled reminders
  void clearReminders() {
    _scheduledReminders.clear();
  }

  /// Cancel reminder
  void cancelReminder(String reminderId) {
    _scheduledReminders.removeWhere((r) => r.id == reminderId);
  }

  /// Dispose service
  void dispose() {
    _reminderTimer?.cancel();
    _scheduledReminders.clear();
    _onReminderCallbacks.clear();
  }
}

// Extension to add copyWith to ReminderNotification
extension ReminderNotificationCopyWith on ReminderNotification {
  ReminderNotification copyWith({
    String? id,
    String? title,
    String? message,
    ReminderType? type,
    DateTime? scheduledTime,
    Map<String, dynamic>? payload,
    bool? isScheduled,
  }) {
    return ReminderNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      payload: payload ?? this.payload,
      isScheduled: isScheduled ?? this.isScheduled,
    );
  }
}
