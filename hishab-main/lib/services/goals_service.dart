import '../database/database_helper.dart';
import '../models/savings_goal.dart';

/// Service layer for Savings Goals operations
/// Handles CRUD operations, deposits, withdrawals, and progress calculations
class GoalsService {
  final DatabaseHelper _db = DatabaseHelper.instance;

  /// Create a new savings goal
  Future<int> createGoal({
    required String title,
    required double targetAmount,
    required DateTime targetDate,
    String? colorHex,
    bool notifyOnMilestone = true,
  }) async {
    final now = DateTime.now().toIso8601String();
    final goal = SavingsGoal(
      title: title,
      targetAmount: targetAmount,
      targetDate: targetDate.toIso8601String(),
      createdAt: now,
      updatedAt: now,
      colorHex: colorHex,
      notifyOnMilestone: notifyOnMilestone,
    );
    return await _db.insertSavingsGoal(goal);
  }

  /// Get all active savings goals
  Future<List<SavingsGoal>> getActiveGoals() async {
    return await _db.getActiveSavingsGoals();
  }

  /// Get all savings goals (including inactive)
  Future<List<SavingsGoal>> getAllGoals() async {
    return await _db.getAllSavingsGoals();
  }

  /// Get a specific goal by ID
  Future<SavingsGoal?> getGoalById(int id) async {
    return await _db.getSavingsGoalById(id);
  }

  /// Update progress amount for a savings goal (manual tracking)
  /// Returns the updated goal
  Future<SavingsGoal?> updateProgress(int goalId, double newAmount) async {
    final goal = await _db.getSavingsGoalById(goalId);
    if (goal == null) return null;

    final updatedGoal = goal.copyWith(
      currentAmount: newAmount,
      updatedAt: DateTime.now().toIso8601String(),
    );

    await _db.updateSavingsGoal(updatedGoal);
    return updatedGoal;
  }

  /// Add to current progress (convenience method)
  /// Returns the updated goal
  Future<SavingsGoal?> addProgress(int goalId, double amount) async {
    final goal = await _db.getSavingsGoalById(goalId);
    if (goal == null) return null;

    final updatedGoal = goal.copyWith(
      currentAmount: goal.currentAmount + amount,
      updatedAt: DateTime.now().toIso8601String(),
    );

    await _db.updateSavingsGoal(updatedGoal);
    return updatedGoal;
  }

  /// Set monthly allocation for a goal
  /// Returns the updated goal
  Future<SavingsGoal?> setMonthlyAllocation(int goalId, double amount) async {
    final goal = await _db.getSavingsGoalById(goalId);
    if (goal == null) return null;

    final updatedGoal = goal.copyWith(
      monthlyAllocation: amount,
      updatedAt: DateTime.now().toIso8601String(),
    );

    await _db.updateSavingsGoal(updatedGoal);
    return updatedGoal;
  }

  /// Update goal details
  Future<bool> updateGoal(SavingsGoal goal) async {
    final updatedGoal = goal.copyWith(
      updatedAt: DateTime.now().toIso8601String(),
    );
    final result = await _db.updateSavingsGoal(updatedGoal);
    return result > 0;
  }

  /// Mark goal as inactive (soft delete)
  Future<bool> deactivateGoal(int goalId) async {
    final goal = await _db.getSavingsGoalById(goalId);
    if (goal == null) return false;

    final updatedGoal = goal.copyWith(
      isActive: false,
      updatedAt: DateTime.now().toIso8601String(),
    );
    final result = await _db.updateSavingsGoal(updatedGoal);
    return result > 0;
  }

  /// Permanently delete a goal
  Future<bool> deleteGoal(int goalId) async {
    final result = await _db.deleteSavingsGoal(goalId);
    return result > 0;
  }

  /// Calculate progress percentage (0.0 - 1.0)
  double getProgressPercent(SavingsGoal goal) {
    return goal.progressPercent;
  }

  /// Calculate expected daily savings to reach target on time
  /// Returns 0 if target date is in the past
  double calculateExpectedDailySavings(SavingsGoal goal) {
    final targetDate = DateTime.parse(goal.targetDate);
    final now = DateTime.now();
    final daysRemaining = targetDate.difference(now).inDays;

    if (daysRemaining <= 0) return 0.0;

    final remainingAmount = goal.remainingAmount;
    return remainingAmount / daysRemaining;
  }

  /// Check if goal should trigger milestone notification
  /// Returns milestone percent (25, 50, 75, 100) or null
  int? checkMilestone(SavingsGoal oldGoal, SavingsGoal newGoal) {
    if (!newGoal.notifyOnMilestone) return null;

    final oldPercent = (oldGoal.progressPercent * 100).floor();
    final newPercent = (newGoal.progressPercent * 100).floor();

    // Check for milestone crossings
    for (final milestone in [25, 50, 75, 100]) {
      if (oldPercent < milestone && newPercent >= milestone) {
        return milestone;
      }
    }
    return null;
  }

  /// Get total progress across all active goals
  Future<double> getTotalProgress() async {
    final goals = await getActiveGoals();
    return goals.fold<double>(
      0.0,
      (sum, goal) => sum + goal.currentAmount,
    );
  }

  /// Get count of completed goals
  Future<int> getCompletedGoalsCount() async {
    final goals = await getAllGoals();
    return goals.where((g) => g.isCompleted).length;
  }
}
