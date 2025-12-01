
class RewardSystemService {
  // Reward calculation rules based on spending behavior
  static const int BUDGET_ADHERENCE_BONUS = 50; // Points for staying under budget daily
  static const int WEEKLY_CONSISTENCY_BONUS = 100; // Points for consistent tracking
  static const int MILESTONE_BONUS = 200; // Points for reaching spending milestones

  // Default rewards for Banglalink integration
  static const List<Map<String, dynamic>> defaultBanglaLinkRewards = [
    {
      'title': '500MB Data',
      'description': 'Get 500MB of free data on Banglalink',
      'points_required': 100,
      'reward_type': 'data',
      'reward_value': '500MB',
    },
    {
      'title': '1GB Data',
      'description': 'Get 1GB of free data on Banglalink',
      'points_required': 200,
      'reward_type': 'data',
      'reward_value': '1GB',
    },
    {
      'title': '50 Minutes',
      'description': 'Get 50 free minutes for calls on Banglalink',
      'points_required': 120,
      'reward_type': 'minutes',
      'reward_value': '50 minutes',
    },
    {
      'title': '100 Minutes',
      'description': 'Get 100 free minutes for calls on Banglalink',
      'points_required': 250,
      'reward_type': 'minutes',
      'reward_value': '100 minutes',
    },
    {
      'title': '50 Taka Discount',
      'description': 'Get 50 Taka discount on next recharge',
      'points_required': 80,
      'reward_type': 'discount',
      'reward_value': '50 Taka',
    },
    {
      'title': 'Budget Master Badge',
      'description': 'Unlock when you maintain budget for 30 days',
      'points_required': 500,
      'reward_type': 'badge',
      'reward_value': 'Budget Master',
    },
  ];

  /// Calculate points earned based on daily budget adherence
  /// If today's spending is under daily allowance, earn BUDGET_ADHERENCE_BONUS points
  static int calculateDailyBudgetPoints(double dailySpent, double dailyAllowance) {
    if (dailyAllowance <= 0) return 0;
    
    final percentage = (dailySpent / dailyAllowance) * 100;
    
    if (percentage <= 80) {
      return BUDGET_ADHERENCE_BONUS; // Great spending - full points
    } else if (percentage <= 100) {
      return (BUDGET_ADHERENCE_BONUS * 0.5).toInt(); // Moderate spending - half points
    }
    
    return 0; // Over budget - no points
  }

  /// Calculate points for weekly consistency
  /// More days tracked = more bonus points (up to weekly maximum)
  static int calculateWeeklyConsistencyBonus(int daysTrackedThisWeek) {
    if (daysTrackedThisWeek >= 7) {
      return WEEKLY_CONSISTENCY_BONUS;
    } else if (daysTrackedThisWeek >= 5) {
      return (WEEKLY_CONSISTENCY_BONUS * 0.75).toInt();
    } else if (daysTrackedThisWeek >= 3) {
      return (WEEKLY_CONSISTENCY_BONUS * 0.5).toInt();
    }
    
    return 0;
  }

  /// Calculate milestone bonus for total months tracked
  /// Accumulates points as user tracks for more months
  static int calculateMilestoneBonus(int monthsTracked) {
    if (monthsTracked >= 6) {
      return MILESTONE_BONUS * 2; // 6+ months tracked
    } else if (monthsTracked >= 3) {
      return MILESTONE_BONUS; // 3+ months tracked
    }
    
    return 0;
  }

  /// Calculate total monthly spending savings vs budget
  /// Reward user if actual spending is significantly less than income
  static int calculateSavingsBonus(double monthlyIncome, double monthlySpent) {
    if (monthlyIncome <= 0 || monthlySpent > monthlyIncome) return 0;
    
    final savingsPercentage = ((monthlyIncome - monthlySpent) / monthlyIncome) * 100;
    
    if (savingsPercentage >= 30) {
      return 300; // Excellent savings
    } else if (savingsPercentage >= 20) {
      return 200; // Good savings
    } else if (savingsPercentage >= 10) {
      return 100; // Moderate savings
    }
    
    return 0;
  }

  /// Get category spending ratio to identify problem areas
  /// Returns map of category -> spending percentage
  static Map<String, double> analyzeCategorySpending(
    Map<String, double> categoryBreakdown,
    double totalSpent,
  ) {
    if (totalSpent <= 0) return {};
    
    return categoryBreakdown.map(
      (category, amount) => MapEntry(
        category,
        (amount / totalSpent) * 100,
      ),
    );
  }

  /// Identify which categories the user is overspending on
  static List<String> identifyOverspendingCategories(
    Map<String, double> categorySpending,
  ) {
    return categorySpending.entries
        .where((entry) => entry.value > 25) // More than 25% in one category
        .map((entry) => entry.key)
        .toList();
  }

  /// Generate reward recommendation based on user behavior
  static String generateRewardRecommendation(
    double dailySpent,
    double dailyAllowance,
    Map<String, double> categorySpending,
    int monthsTracked,
  ) {
    if (monthsTracked < 1) {
      return 'Start tracking consistently to earn rewards';
    }
    
    final percentage = dailyAllowance > 0 ? (dailySpent / dailyAllowance) * 100 : 0;
    
    if (percentage > 100) {
      return 'Over budget! Focus on reducing spending to earn rewards';
    } else if (percentage > 80) {
      return 'Almost at budget limit. Control spending to earn extra points!';
    } else if (percentage < 50) {
      return 'Excellent spending control! You\'re on track to earn rewards';
    } else {
      return 'Good progress! Keep maintaining discipline to earn rewards';
    }
  }

  /// Check if user qualifies for milestone rewards
  static bool checkMilestoneAchievement(
    int totalPointsEarned,
    int currentMilestone,
  ) {
    final milestones = [100, 500, 1000, 2500, 5000];
    
    if (currentMilestone < milestones.length) {
      return totalPointsEarned >= milestones[currentMilestone];
    }
    
    return false;
  }

  /// Get next milestone target
  static int getNextMilestoneTarget(int totalPointsEarned) {
    final milestones = [100, 500, 1000, 2500, 5000, 10000];
    
    for (var milestone in milestones) {
      if (totalPointsEarned < milestone) {
        return milestone;
      }
    }
    
    return totalPointsEarned + 5000; // Continue adding 5000 point milestones
  }

  /// Calculate progress to next milestone
  static double getProgressToNextMilestone(
    int totalPointsEarned,
    int nextMilestone,
  ) {
    if (nextMilestone <= 0) return 0;
    
    final previousMilestones = [0, 100, 500, 1000, 2500, 5000];
    int previousMilestone = 0;
    
    for (var i = 0; i < previousMilestones.length; i++) {
      if (previousMilestones[i] <= totalPointsEarned) {
        previousMilestone = previousMilestones[i];
      } else {
        break;
      }
    }
    
    final rangeSize = nextMilestone - previousMilestone;
    final currentProgress = totalPointsEarned - previousMilestone;
    
    return (currentProgress / rangeSize).clamp(0, 1);
  }

  /// Generate achievement message
  static String getAchievementMessage(int pointsEarned) {
    if (pointsEarned >= 500) {
      return '🏆 Amazing achievement! You\'ve earned exceptional rewards points!';
    } else if (pointsEarned >= 200) {
      return '🎉 Great job! You\'ve earned significant rewards points!';
    } else if (pointsEarned >= 100) {
      return '👍 Good work! You\'ve earned rewards points!';
    } else if (pointsEarned >= 50) {
      return '⭐ Nice! You\'ve earned some rewards points!';
    } else {
      return '✓ You\'ve earned points. Keep it up!';
    }
  }

  /// Get spending advice based on user patterns
  static String getSpendingAdvice(
    List<double> last7DaysSpending,
    double dailyAllowance,
  ) {
    if (last7DaysSpending.isEmpty || dailyAllowance <= 0) {
      return 'Keep tracking your expenses to get personalized advice';
    }
    
    final average = last7DaysSpending.reduce((a, b) => a + b) / last7DaysSpending.length;
    final overBudgetDays = last7DaysSpending.where((spent) => spent > dailyAllowance).length;
    
    if (overBudgetDays >= 4) {
      return 'You\'re over budget most days. Try reducing discretionary spending.';
    } else if (average > dailyAllowance) {
      return 'Your average spending exceeds your daily allowance. Adjust your budget or cut expenses.';
    } else if (average < (dailyAllowance * 0.6)) {
      return 'Excellent control! You\'re spending well below your budget.';
    } else {
      return 'Good balance! You\'re on track with your spending habits.';
    }
  }
}
