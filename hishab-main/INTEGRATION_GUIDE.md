# Hishab App - Integration & Setup Guide

## Quick Start for Developers

This guide explains how to integrate the newly implemented features into your app screens and provider.

---

## 1. Update FinanceProvider

**File:** `lib/providers/finance_provider.dart`

### Add to imports:
```dart
import '../services/reward_system_service.dart';
import '../services/daily_reminders_service.dart';
import '../services/budget_service.dart';
import '../models/budget.dart';
```

### Add to FinanceProvider class:
```dart
class FinanceProvider extends ChangeNotifier {
  // ... existing code ...

  // New additions:
  int _userRewardPoints = 0;
  List<Budget> _budgets = [];
  final DailyRemindersService _reminderService = DailyRemindersService();
  
  // Getters
  int get userRewardPoints => _userRewardPoints;
  List<Budget> get budgets => _budgets;

  // ... rest of initialization ...

  @override
  Future<void> initialize() async {
    // ... existing code ...
    
    // NEW: Initialize reminders
    await loadRewardPoints();
    await loadBudgets();
    _initializeReminders();
  }

  // NEW: Load reward points from database
  Future<void> loadRewardPoints() async {
    // TODO: Fetch from database when reward points table is added
    _userRewardPoints = await _dbHelper.getUserRewardPoints() ?? 0;
    notifyListeners();
  }

  // NEW: Load budgets from database
  Future<void> loadBudgets() async {
    _budgets = await _dbHelper.getAllBudgets();
    notifyListeners();
  }

  // NEW: Initialize daily reminders
  void _initializeReminders() {
    _reminderService.initialize(
      ReminderConfig(
        firstReminderHour: 12,
        secondReminderHour: 19,
        enableMorningGreeting: true,
        enableEveningReview: true,
        enableWeeklyReview: true,
        enableBudgetAlerts: true,
      ),
    );

    // Schedule today's reminders
    _scheduleReminders();
  }

  // NEW: Schedule reminders for today
  void _scheduleReminders() {
    _reminderService.scheduleDailyReminders(
      config: ReminderConfig(),
      userName: _userName,
      dailyAllowance: getDailyAllowance(),
      todaySpent: getTodayTotal(),
      weekTotal: getThisWeekTotal(),
    );
  }

  // NEW: Add reward points
  Future<void> addRewardPoints(int points, String reason) async {
    _userRewardPoints += points;
    // TODO: Save to database
    notifyListeners();
  }

  // NEW: Get overall budget status
  OverallBudgetStatus getOverallBudgetStatus() {
    return BudgetService.getOverallBudgetStatus(_budgets, _expenses);
  }

  // NEW: Add budget
  Future<void> addBudget(Budget budget) async {
    // TODO: Save to database when budget table is added
    _budgets.add(budget);
    notifyListeners();
  }

  // NEW: Update budget
  Future<void> updateBudget(Budget budget) async {
    // TODO: Update in database
    final index = _budgets.indexWhere((b) => b.id == budget.id);
    if (index >= 0) {
      _budgets[index] = budget;
      notifyListeners();
    }
  }

  // NEW: Delete budget
  Future<void> deleteBudget(int budgetId) async {
    // TODO: Delete from database
    _budgets.removeWhere((b) => b.id == budgetId);
    notifyListeners();
  }

  // NEW: Get reward points milestone
  int getNextRewardMilestone() {
    return RewardSystemService.getNextMilestoneTarget(_userRewardPoints);
  }

  // NEW: Get reward recommendations
  List<String> getBudgetRecommendations() {
    final budgetStatus = getOverallBudgetStatus();
    return BudgetService.getRecommendations(budgetStatus.categoryStatuses);
  }

  // NEW: Cleanup on dispose
  @override
  void dispose() {
    _reminderService.dispose();
    super.dispose();
  }
}
```

---

## 2. Update DatabaseHelper

**File:** `lib/database/database_helper.dart`

### Add constants:
```dart
static const String tableRewardPoints = 'user_reward_points';
static const String tableBudgets = 'budgets';
static const String tableRedemptions = 'redemption_records';
```

### Add to onCreate method:
```dart
// Create reward points table
await db.execute('''
  CREATE TABLE $tableRewardPoints (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    total_points INTEGER NOT NULL,
    points_earned INTEGER NOT NULL,
    points_redeemed INTEGER NOT NULL,
    last_earned TEXT NOT NULL,
    last_redeemed TEXT NOT NULL
  )
''');

// Create budgets table
await db.execute('''
  CREATE TABLE $tableBudgets (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    category_name TEXT NOT NULL,
    monthly_limit REAL NOT NULL,
    weekly_limit REAL,
    is_active INTEGER NOT NULL,
    date_created TEXT NOT NULL,
    date_modified TEXT,
    send_alerts INTEGER NOT NULL,
    alert_threshold REAL NOT NULL
  )
''');

// Create redemptions table
await db.execute('''
  CREATE TABLE $tableRedemptions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    reward_id INTEGER NOT NULL,
    reward_title TEXT NOT NULL,
    points_used INTEGER NOT NULL,
    redeemed_date TEXT NOT NULL,
    status TEXT NOT NULL
  )
''');
```

### Add methods:
```dart
// Reward Points Methods
Future<int?> getUserRewardPoints() async {
  final db = await database;
  final result = await db.query(tableRewardPoints, limit: 1);
  if (result.isEmpty) return null;
  return result.first['total_points'] as int;
}

// Budget Methods
Future<List<Budget>> getAllBudgets() async {
  final db = await database;
  final result = await db.query(tableBudgets);
  return result.map((json) => Budget.fromMap(json)).toList();
}

Future<int> insertBudget(Budget budget) async {
  final db = await database;
  return await db.insert(tableBudgets, budget.toMap());
}

Future<int> updateBudget(Budget budget) async {
  final db = await database;
  return await db.update(
    tableBudgets,
    budget.toMap(),
    where: 'id = ?',
    whereArgs: [budget.id],
  );
}

Future<int> deleteBudget(int id) async {
  final db = await database;
  return await db.delete(tableBudgets, where: 'id = ?', whereArgs: [id]);
}
```

---

## 3. Reward Points Integration Example

**In an Expense Addition Screen:**

```dart
Future<void> _saveExpense() async {
  final expense = Expense(
    amount: _amountController.text as double,
    category: _selectedCategory,
    note: _noteController.text,
    date: DateTime.now(),
    timestamp: DateTime.now(),
  );

  await provider.addExpense(expense);

  // Calculate reward points
  final dailySpent = provider.getTodayTotal();
  final dailyAllowance = provider.getDailyAllowance();
  final points = RewardSystemService.calculateDailyBudgetPoints(
    dailySpent,
    dailyAllowance,
  );

  if (points > 0) {
    await provider.addRewardPoints(
      points,
      'Added expense: $_selectedCategory ৳${expense.amount}',
    );

    // Show achievement message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(RewardSystemService.getAchievementMessage(points)),
        backgroundColor: Colors.green,
      ),
    );
  }
}
```

---

## 4. Budget Status UI Example

**Create a new widget:** `lib/screens/home/budget_status_card.dart`

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/finance_provider.dart';

class BudgetStatusCard extends StatelessWidget {
  const BudgetStatusCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<FinanceProvider>(
      builder: (context, provider, _) {
        final budgetStatus = provider.getOverallBudgetStatus();
        
        return Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Budget Overview',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Chip(
                      label: Text(budgetStatus.getOverallStatus()),
                      backgroundColor: _getStatusColor(budgetStatus.overallPercentage),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: (budgetStatus.overallPercentage / 100).clamp(0, 1),
                    minHeight: 8,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getStatusColor(budgetStatus.overallPercentage),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '${budgetStatus.overallPercentage.toStringAsFixed(1)}% of budget used',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                Text(
                  budgetStatus.getMotivationalMessage(),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getStatusColor(double percentage) {
    if (percentage >= 100) return Colors.red;
    if (percentage >= 80) return Colors.orange;
    return Colors.green;
  }
}
```

---

## 5. Reward Points Display Example

**Create widget:** `lib/screens/home/reward_points_badge.dart`

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/finance_provider.dart';
import '../../services/reward_system_service.dart';

class RewardPointsBadge extends StatelessWidget {
  const RewardPointsBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<FinanceProvider>(
      builder: (context, provider, _) {
        final points = provider.userRewardPoints;
        final nextMilestone = provider.getNextRewardMilestone();
        final progress = RewardSystemService.getProgressToNextMilestone(
          points,
          nextMilestone,
        );

        return GestureDetector(
          onTap: () {
            // Navigate to rewards screen
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const RewardsScreen()),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [const Color(0xFFF16725), const Color(0xFFFF8C42)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star, color: Colors.white, size: 16),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$points Points',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(
                      width: 100,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: Colors.white24,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                          minHeight: 4,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
```

---

## 6. Settings - Reminder Configuration

**Add to Settings Screen:**

```dart
class ReminderSettingsSection extends StatefulWidget {
  const ReminderSettingsSection({super.key});

  @override
  State<ReminderSettingsSection> createState() => _ReminderSettingsSectionState();
}

class _ReminderSettingsSectionState extends State<ReminderSettingsSection> {
  late ReminderConfig _config;

  @override
  void initState() {
    super.initState();
    _config = ReminderConfig();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SwitchListTile(
          title: const Text('Enable Reminders'),
          value: true, // Load from SharedPreferences
          onChanged: (value) {
            // Update reminder settings
          },
        ),
        ListTile(
          title: const Text('First Reminder'),
          subtitle: Text('${_config.firstReminderHour}:00'),
          onTap: () => _selectTime(context, 'first'),
        ),
        ListTile(
          title: const Text('Second Reminder'),
          subtitle: Text('${_config.secondReminderHour}:00'),
          onTap: () => _selectTime(context, 'second'),
        ),
        SwitchListTile(
          title: const Text('Morning Greeting'),
          value: _config.enableMorningGreeting,
          onChanged: (value) {
            setState(() => _config = _config.copyWith(enableMorningGreeting: value));
          },
        ),
        SwitchListTile(
          title: const Text('Evening Review'),
          value: _config.enableEveningReview,
          onChanged: (value) {
            setState(() => _config = _config.copyWith(enableEveningReview: value));
          },
        ),
      ],
    );
  }

  void _selectTime(BuildContext context, String which) {
    // Show time picker
  }
}
```

---

## 7. Banglalink Integration Setup

**In main.dart or splash screen:**

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Banglalink Integration
  final banglalink = BanglaLinkIntegrationService();
  banglalink.initialize(
    apiKey: String.fromEnvironment(
      'BANGLALINK_API_KEY',
      defaultValue: 'dev_key_placeholder',
    ),
    apiSecret: String.fromEnvironment(
      'BANGLALINK_API_SECRET',
      defaultValue: 'dev_secret_placeholder',
    ),
    appId: 'hishab_v1.0.0',
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FinanceProvider()..initialize()),
        Provider<BanglaLinkIntegrationService>(create: (_) => banglalink),
      ],
      child: const MyApp(),
    ),
  );
}
```

---

## 8. Testing the Implementations

### Test Voice Parsing:
```dart
void main() {
  group('Voice Parser Service Tests', () {
    test('Parse simple expense command', () {
      final result = VoiceParserService.parseVoiceInput(
        '200 for groceries',
        ['Food', 'Transport', 'Shopping'],
      );
      
      expect(result?.amount, 200);
      expect(result?.category, 'Food');
    });
  });
}
```

### Test Reward Calculation:
```dart
void main() {
  group('Reward System Tests', () {
    test('Calculate daily budget points', () {
      final points = RewardSystemService.calculateDailyBudgetPoints(300, 500);
      expect(points, 50); // Under 80%, full points
      
      final pointsWarning = RewardSystemService.calculateDailyBudgetPoints(400, 500);
      expect(pointsWarning, 25); // 80-100%, half points
    });
  });
}
```

---

## 9. Environment Variables (.env)

Create `.env` file in project root:
```env
BANGLALINK_API_KEY=your_api_key_here
BANGLALINK_API_SECRET=your_api_secret_here
BANGLALINK_APP_ID=hishab_v1.0.0
```

Load in pubspec.yaml:
```yaml
flutter:
  assets:
    - .env
```

---

## 10. Deployment Checklist

- [ ] Update FinanceProvider with new fields & methods
- [ ] Add database tables via DatabaseHelper migration
- [ ] Create UI screens for budgets, rewards, reminders
- [ ] Test all reminder types with local notifications
- [ ] Configure Banglalink API credentials
- [ ] Test voice logging with Bangla input
- [ ] Verify reward point calculations
- [ ] Test budget status calculations
- [ ] Verify localization for all new features
- [ ] Performance test with large datasets
- [ ] Security audit for API integration
- [ ] User acceptance testing

---

**Ready to integrate!** Each component is independent and can be integrated incrementally.
