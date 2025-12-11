import 'package:flutter_test/flutter_test.dart';
import 'package:hishab/models/savings_goal.dart';

void main() {
  group('SavingsGoal Model Tests', () {
    test('Goal progress calculation is correct', () {
      final goal = SavingsGoal(
        title: 'Test Goal',
        targetAmount: 10000,
        currentAmount: 5000,
        targetDate: DateTime.now().toIso8601String(),
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      );

      expect(goal.progressPercent, 0.5);
      expect(goal.remainingAmount, 5000);
      expect(goal.isCompleted, false);
    });

    test('Goal completion is detected correctly', () {
      final goal = SavingsGoal(
        title: 'Test Goal',
        targetAmount: 10000,
        currentAmount: 10000,
        targetDate: DateTime.now().toIso8601String(),
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      );

      expect(goal.progressPercent, 1.0);
      expect(goal.remainingAmount, 0);
      expect(goal.isCompleted, true);
    });

    test('Goal progress clamps at 100%', () {
      final goal = SavingsGoal(
        title: 'Test Goal',
        targetAmount: 10000,
        currentAmount: 15000,
        targetDate: DateTime.now().toIso8601String(),
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      );

      expect(goal.progressPercent, 1.0);
      expect(goal.isCompleted, true);
    });

    test('Goal serialization to/from Map works correctly', () {
      final goal = SavingsGoal(
        id: 1,
        title: 'Test Goal',
        targetAmount: 10000,
        currentAmount: 2500,
        monthlyAllocation: 1000,
        targetDate: DateTime.now().toIso8601String(),
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
        notifyOnMilestone: true,
        colorHex: '#FF0000',
      );

      final map = goal.toMap();
      final reconstructed = SavingsGoal.fromMap(map);

      expect(reconstructed.id, goal.id);
      expect(reconstructed.title, goal.title);
      expect(reconstructed.targetAmount, goal.targetAmount);
      expect(reconstructed.currentAmount, goal.currentAmount);
      expect(reconstructed.monthlyAllocation, goal.monthlyAllocation);
      expect(reconstructed.notifyOnMilestone, goal.notifyOnMilestone);
      expect(reconstructed.colorHex, goal.colorHex);
    });

    test('copyWith creates new instance with updated fields', () {
      final original = SavingsGoal(
        title: 'Original',
        targetAmount: 10000,
        currentAmount: 1000,
        targetDate: DateTime.now().toIso8601String(),
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      );

      final updated = original.copyWith(
        currentAmount: 5000,
        title: 'Updated',
      );

      expect(updated.title, 'Updated');
      expect(updated.currentAmount, 5000);
      expect(updated.targetAmount, original.targetAmount);
    });

    test('Monthly allocation projections work correctly', () {
      final targetDate = DateTime.now().add(const Duration(days: 180));
      final goal = SavingsGoal(
        title: 'Test Goal',
        targetAmount: 10000,
        currentAmount: 4000,
        monthlyAllocation: 1000,
        targetDate: targetDate.toIso8601String(),
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      );

      expect(goal.monthsToReachGoal, 6);
      expect(goal.remainingAmount, 6000);
    });

    test('isOnTrack works correctly', () {
      final targetDate = DateTime.now().add(const Duration(days: 180));
      final onTrackGoal = SavingsGoal(
        title: 'On Track',
        targetAmount: 10000,
        currentAmount: 4000,
        monthlyAllocation: 2000,
        targetDate: targetDate.toIso8601String(),
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      );

      final behindGoal = SavingsGoal(
        title: 'Behind',
        targetAmount: 10000,
        currentAmount: 4000,
        monthlyAllocation: 500,
        targetDate: targetDate.toIso8601String(),
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      );

      expect(onTrackGoal.isOnTrack, true);
      expect(behindGoal.isOnTrack, false);
    });
  });

  group('Milestone Detection Tests', () {
    test('Milestone detection at 25%', () {
      final oldGoal = SavingsGoal(
        title: 'Test',
        targetAmount: 10000,
        currentAmount: 2000,
        targetDate: DateTime.now().toIso8601String(),
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      );

      final newGoal = oldGoal.copyWith(currentAmount: 2500);

      // Simulate milestone check logic
      final oldPercent = (oldGoal.progressPercent * 100).floor();
      final newPercent = (newGoal.progressPercent * 100).floor();

      expect(oldPercent < 25, true);
      expect(newPercent >= 25, true);
    });

    test('Milestone detection at 50%', () {
      final oldGoal = SavingsGoal(
        title: 'Test',
        targetAmount: 10000,
        currentAmount: 4500,
        targetDate: DateTime.now().toIso8601String(),
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      );

      final newGoal = oldGoal.copyWith(currentAmount: 5000);

      final oldPercent = (oldGoal.progressPercent * 100).floor();
      final newPercent = (newGoal.progressPercent * 100).floor();

      expect(oldPercent < 50, true);
      expect(newPercent >= 50, true);
    });
  });
}
