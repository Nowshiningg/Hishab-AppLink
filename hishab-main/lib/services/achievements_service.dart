import '../database/database_helper.dart';
import '../models/achievement.dart';
import '../models/streak.dart';

/// Service layer for Achievements and Streaks
/// Handles achievement unlocking, streak tracking, and gamification logic
class AchievementsService {
  final DatabaseHelper _db = DatabaseHelper.instance;

  // Predefined achievements
  static const Map<String, Map<String, String>> achievementDefinitions = {
    'first_goal': {
      'title': 'Goal Setter',
      'description': 'Created your first savings goal',
    },
    'goal_completed_1': {
      'title': 'First Victory',
      'description': 'Completed your first savings goal',
    },
    'goal_completed_5': {
      'title': 'Go-Getter',
      'description': 'Completed 5 savings goals',
    },
    'goal_completed_10': {
      'title': 'Master Saver',
      'description': 'Completed 10 savings goals',
    },
    'streak_7_days': {
      'title': 'Week Warrior',
      'description': 'Maintained a 7-day streak',
    },
    'streak_30_days': {
      'title': 'Monthly Champion',
      'description': 'Maintained a 30-day streak',
    },
    'budget_master_month': {
      'title': 'Budget Master',
      'description': 'Stayed under budget for an entire month',
    },
    'budget_master_3months': {
      'title': 'Budget Grandmaster',
      'description': 'No budget overflows for 3 consecutive months',
    },
    'savings_rate_50': {
      'title': 'Half Saver',
      'description': 'Achieved 50% savings rate in a month',
    },
    'savings_rate_75': {
      'title': 'Super Saver',
      'description': 'Achieved 75% savings rate in a month',
    },
    'wishlist_purchased_1': {
      'title': 'Wish Granted',
      'description': 'Purchased your first wishlist item',
    },
    'total_saved_10k': {
      'title': 'Ten Thousand Club',
      'description': 'Saved a total of ৳10,000',
    },
    'total_saved_50k': {
      'title': 'Fifty Thousand Club',
      'description': 'Saved a total of ৳50,000',
    },
  };

  /// Initialize predefined achievements (call on app start)
  Future<void> initializeAchievements() async {
    for (final entry in achievementDefinitions.entries) {
      final existing = await _db.getAchievementByKey(entry.key);
      if (existing == null) {
        final achievement = Achievement(
          key: entry.key,
          title: entry.value['title']!,
          description: entry.value['description']!,
        );
        await _db.insertAchievement(achievement);
      }
    }
  }

  /// Get all achievements
  Future<List<Achievement>> getAllAchievements() async {
    return await _db.getAllAchievements();
  }

  /// Get unlocked achievements only
  Future<List<Achievement>> getUnlockedAchievements() async {
    final all = await getAllAchievements();
    return all.where((a) => a.isUnlocked).toList();
  }

  /// Get locked achievements only
  Future<List<Achievement>> getLockedAchievements() async {
    final all = await getAllAchievements();
    return all.where((a) => !a.isUnlocked).toList();
  }

  /// Unlock an achievement
  /// Returns true if unlocked, false if already unlocked
  Future<bool> unlockAchievement(String key) async {
    final achievement = await _db.getAchievementByKey(key);
    if (achievement == null || achievement.isUnlocked) return false;

    final updated = achievement.copyWith(
      unlockedAt: DateTime.now().toIso8601String(),
    );
    await _db.updateAchievement(updated);
    return true;
  }

  /// Check and unlock goal-related achievements
  Future<List<String>> checkGoalAchievements(int completedGoalsCount) async {
    final unlocked = <String>[];

    if (completedGoalsCount >= 1) {
      if (await unlockAchievement('goal_completed_1')) {
        unlocked.add('goal_completed_1');
      }
    }
    if (completedGoalsCount >= 5) {
      if (await unlockAchievement('goal_completed_5')) {
        unlocked.add('goal_completed_5');
      }
    }
    if (completedGoalsCount >= 10) {
      if (await unlockAchievement('goal_completed_10')) {
        unlocked.add('goal_completed_10');
      }
    }

    return unlocked;
  }

  /// Check and unlock savings rate achievements
  Future<List<String>> checkSavingsRateAchievements(double savingsRate) async {
    final unlocked = <String>[];

    if (savingsRate >= 0.50) {
      if (await unlockAchievement('savings_rate_50')) {
        unlocked.add('savings_rate_50');
      }
    }
    if (savingsRate >= 0.75) {
      if (await unlockAchievement('savings_rate_75')) {
        unlocked.add('savings_rate_75');
      }
    }

    return unlocked;
  }

  /// Check and unlock total saved achievements
  Future<List<String>> checkTotalSavedAchievements(double totalSaved) async {
    final unlocked = <String>[];

    if (totalSaved >= 10000) {
      if (await unlockAchievement('total_saved_10k')) {
        unlocked.add('total_saved_10k');
      }
    }
    if (totalSaved >= 50000) {
      if (await unlockAchievement('total_saved_50k')) {
        unlocked.add('total_saved_50k');
      }
    }

    return unlocked;
  }

  // ===== Streak Operations =====

  /// Get or create a streak by type
  Future<Streak> getOrCreateStreak(String type) async {
    var streak = await _db.getStreakByType(type);
    if (streak == null) {
      final newStreak = Streak(
        type: type,
        current: 0,
        best: 0,
        lastActiveDate: DateTime.now().toIso8601String().split('T').first,
      );
      await _db.insertStreak(newStreak);
      streak = await _db.getStreakByType(type);
    }
    return streak!;
  }

  /// Update streak for today
  /// Returns the updated streak
  Future<Streak> updateStreak(String type) async {
    final streak = await getOrCreateStreak(type);
    final today = DateTime.now();
    final todayStr = today.toIso8601String().split('T').first;
    final yesterday = today.subtract(const Duration(days: 1));
    final yesterdayStr = yesterday.toIso8601String().split('T').first;

    int newCurrent;
    if (streak.lastActiveDate == todayStr) {
      // Already updated today
      return streak;
    } else if (streak.lastActiveDate == yesterdayStr) {
      // Continue streak
      newCurrent = streak.current + 1;
    } else {
      // Streak broken, restart
      newCurrent = 1;
    }

    final newBest = newCurrent > streak.best ? newCurrent : streak.best;
    final updated = streak.copyWith(
      current: newCurrent,
      best: newBest,
      lastActiveDate: todayStr,
    );

    await _db.updateStreak(updated);
    return updated;
  }

  /// Check and unlock streak achievements
  Future<List<String>> checkStreakAchievements(int currentStreak) async {
    final unlocked = <String>[];

    if (currentStreak >= 7) {
      if (await unlockAchievement('streak_7_days')) {
        unlocked.add('streak_7_days');
      }
    }
    if (currentStreak >= 30) {
      if (await unlockAchievement('streak_30_days')) {
        unlocked.add('streak_30_days');
      }
    }

    return unlocked;
  }

  /// Get all streaks
  Future<List<Streak>> getAllStreaks() async {
    return await _db.getAllStreaks();
  }

  /// Get specific streak
  Future<Streak?> getStreak(String type) async {
    return await _db.getStreakByType(type);
  }
}
