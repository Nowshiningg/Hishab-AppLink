import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/expense.dart';
import '../models/category_model.dart';
import '../models/income.dart';
import '../database/database_helper.dart';

class FinanceProvider extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  List<Expense> _expenses = [];
  List<CategoryModel> _categories = [];
  Income? _income;
  bool _isLoading = false;
  ThemeMode _themeMode = ThemeMode.light;
  String _userName = '';
  Locale _locale = const Locale('bn'); // Default to Bangla
  int _totalPoints = 0;
  List<Map<String, dynamic>> _rewards = [];
  int _consecutiveDays = 0;
  bool _isPremiumSubscribed = false;
  bool _showPremiumThankYou = false;

  List<Expense> get expenses => _expenses;
  List<CategoryModel> get categories => _categories;
  Income? get income => _income;
  bool get isLoading => _isLoading;
  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  String get userName => _userName;
  String get firstName => _userName.split(' ').first;
  Locale get locale => _locale;
  int get totalPoints => _totalPoints;
  List<Map<String, dynamic>> get rewards => _rewards;
  int get consecutiveDays => _consecutiveDays;
  bool get isPremiumSubscribed => _isPremiumSubscribed;
  bool get showPremiumThankYou => _showPremiumThankYou;

  // Initialize data
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      await loadThemeMode();
      await loadLanguage();
      await loadName();
      await loadCategories();
      await loadExpenses();
      await loadIncome();
      await loadRewards();
      await calculateDailyStreak();
      await loadPremiumStatus();
    } catch (e) {
      debugPrint('Error initializing: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load language
  Future<void> loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString('language') ?? 'bn';
    _locale = Locale(languageCode);
    notifyListeners();
  }

  // Change language
  Future<void> changeLanguage(String languageCode) async {
    _locale = Locale(languageCode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', languageCode);
    notifyListeners();
  }

  // Load theme mode
  Future<void> loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('dark_mode') ?? false;
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  // Toggle theme mode
  Future<void> toggleThemeMode() async {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dark_mode', _themeMode == ThemeMode.dark);
    notifyListeners();
  }

  // Load user name
  Future<void> loadName() async {
    final prefs = await SharedPreferences.getInstance();
    _userName = prefs.getString('user_name') ?? '';
    notifyListeners();
  }

  // Save user name
  Future<void> saveName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', name);
    _userName = name;
    notifyListeners();
  }

  // Update user name
  Future<void> updateName(String name) async {
    await saveName(name);
  }

  // Load categories
  Future<void> loadCategories() async {
    _categories = await _dbHelper.getAllCategories();
    notifyListeners();
  }

  // Load expenses
  Future<void> loadExpenses() async {
    _expenses = await _dbHelper.getAllExpenses();
    notifyListeners();
  }

  // Load income
  Future<void> loadIncome() async {
    _income = await _dbHelper.getLatestIncome();
    notifyListeners();
  }

  // Add expense
  Future<void> addExpense(Expense expense) async {
    await _dbHelper.insertExpense(expense);
    await loadExpenses();
    await calculateDailyStreak();
    await checkBudgetGoals();
  }

  // Delete expense
  Future<void> deleteExpense(int id) async {
    await _dbHelper.deleteExpense(id);
    await loadExpenses();
  }

  // Update expense
  Future<void> updateExpense(Expense expense) async {
    await _dbHelper.updateExpense(expense);
    await loadExpenses();
  }

  // Set/Update income
  Future<void> setIncome(double amount) async {
    final newIncome = Income(monthlyIncome: amount, dateSet: DateTime.now());

    if (_income == null) {
      await _dbHelper.insertIncome(newIncome);
    } else {
      await _dbHelper.updateIncome(newIncome.copyWith(id: _income!.id));
    }

    await loadIncome();
  }

  // Add category
  Future<void> addCategory(CategoryModel category) async {
    await _dbHelper.insertCategory(category);
    await loadCategories();
  }

  // Delete category
  Future<void> deleteCategory(int id) async {
    await _dbHelper.deleteCategory(id);
    await loadCategories();
  }

  // Update category
  Future<void> updateCategory(CategoryModel category) async {
    await _dbHelper.updateCategory(category);
    await loadCategories();
  }

  // Get expenses for today
  List<Expense> getTodayExpenses() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return _expenses.where((expense) {
      final expenseDate = DateTime(
        expense.date.year,
        expense.date.month,
        expense.date.day,
      );
      return expenseDate.isAtSameMomentAs(today);
    }).toList();
  }

  // Get total spending for today
  double getTodayTotal() {
    return getTodayExpenses().fold(0, (sum, expense) => sum + expense.amount);
  }

  // Get expenses for this week
  List<Expense> getThisWeekExpenses() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startDate = DateTime(
      startOfWeek.year,
      startOfWeek.month,
      startOfWeek.day,
    );

    return _expenses.where((expense) {
      final expenseDate = DateTime(
        expense.date.year,
        expense.date.month,
        expense.date.day,
      );
      return expenseDate.isAfter(startDate.subtract(const Duration(days: 1)));
    }).toList();
  }

  // Get total spending for this week
  double getThisWeekTotal() {
    return getThisWeekExpenses().fold(
      0,
      (sum, expense) => sum + expense.amount,
    );
  }

  // Get expenses for this month
  List<Expense> getThisMonthExpenses() {
    final now = DateTime.now();
    return _expenses.where((expense) {
      return expense.date.year == now.year && expense.date.month == now.month;
    }).toList();
  }

  // Get total spending for this month
  double getThisMonthTotal() {
    return getThisMonthExpenses().fold(
      0,
      (sum, expense) => sum + expense.amount,
    );
  }

  // Calculate daily allowance
  double getDailyAllowance() {
    if (_income == null) return 0;

    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final daysRemaining = daysInMonth - now.day + 1;
    final totalSpent = getThisMonthTotal();
    final remaining = _income!.monthlyIncome - totalSpent;

    return daysRemaining > 0 ? remaining / daysRemaining : 0;
  }

  // Get spending status (green, yellow, red)
  SpendingStatus getSpendingStatus() {
    final todayTotal = getTodayTotal();
    final dailyAllowance = getDailyAllowance();

    if (dailyAllowance == 0) return SpendingStatus.green;

    final percentage = (todayTotal / dailyAllowance) * 100;

    if (percentage < 80) {
      return SpendingStatus.green;
    } else if (percentage < 100) {
      return SpendingStatus.yellow;
    } else {
      return SpendingStatus.red;
    }
  }

  // Get expenses grouped by date
  // Note: This method returns raw date strings. Translation should happen in the UI layer
  // using the context to access AppLocalizations
  Map<String, List<Expense>> getExpensesGroupedByDate() {
    final Map<String, List<Expense>> grouped = {};
    final now = DateTime.now();

    for (var expense in _expenses) {
      final expenseDate = DateTime(
        expense.date.year,
        expense.date.month,
        expense.date.day,
      );
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));

      String dateKey;
      if (expenseDate.isAtSameMomentAs(today)) {
        dateKey = 'Today';
      } else if (expenseDate.isAtSameMomentAs(yesterday)) {
        dateKey = 'Yesterday';
      } else {
        dateKey =
            '${expense.date.day}/${expense.date.month}/${expense.date.year}';
      }

      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(expense);
    }

    return grouped;
  }

  // Get category breakdown for current month
  Future<Map<String, double>> getCategoryBreakdown() async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

    return await _dbHelper.getExpensesByCategory(startOfMonth, endOfMonth);
  }

  // Clear all data
  Future<void> clearAllData() async {
    await _dbHelper.clearAllData();
    await initialize();
  }

  // Load rewards
  Future<void> loadRewards() async {
    _rewards = await _dbHelper.getAllRewards();
    _totalPoints = await _dbHelper.getTotalPoints();
    notifyListeners();
  }

  // Add reward
  Future<void> addReward(int points, String reason, String type) async {
    final reward = {
      'points': points,
      'reason': reason,
      'timestamp': DateTime.now().toIso8601String(),
      'type': type, // 'earned' or 'redeemed'
    };
    await _dbHelper.insertReward(reward);
    await loadRewards();
  }

  // Calculate daily streak
  Future<void> calculateDailyStreak() async {
    final prefs = await SharedPreferences.getInstance();
    final lastTrackedDate = prefs.getString('last_tracked_date');
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (lastTrackedDate == null) {
      // First time - initialize
      _consecutiveDays = getTodayExpenses().isNotEmpty ? 1 : 0;
      await prefs.setString('last_tracked_date', today.toIso8601String());
      await prefs.setInt('consecutive_days', _consecutiveDays);
      notifyListeners();
      return;
    }

    final lastDate = DateTime.parse(lastTrackedDate);
    final lastDay = DateTime(lastDate.year, lastDate.month, lastDate.day);
    final daysDifference = today.difference(lastDay).inDays;

    if (daysDifference == 0) {
      // Same day - load saved streak
      _consecutiveDays = prefs.getInt('consecutive_days') ?? 0;
    } else if (daysDifference == 1) {
      // Consecutive day
      if (getTodayExpenses().isNotEmpty) {
        _consecutiveDays = (prefs.getInt('consecutive_days') ?? 0) + 1;
        await prefs.setString('last_tracked_date', today.toIso8601String());
        await prefs.setInt('consecutive_days', _consecutiveDays);

        // Award streak bonus
        if (_consecutiveDays % 7 == 0) {
          await addReward(50, 'Weekly tracking streak!', 'earned');
        } else if (_consecutiveDays % 30 == 0) {
          await addReward(200, 'Monthly tracking streak!', 'earned');
        }
      } else {
        // Today has no expenses - keep current streak
        _consecutiveDays = prefs.getInt('consecutive_days') ?? 0;
      }
    } else {
      // Streak broken
      _consecutiveDays = getTodayExpenses().isNotEmpty ? 1 : 0;
      await prefs.setString('last_tracked_date', today.toIso8601String());
      await prefs.setInt('consecutive_days', _consecutiveDays);
    }

    notifyListeners();
  }

  // Check and award budget goals
  Future<void> checkBudgetGoals() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastRewardCheck = prefs.getString('last_reward_check');

    // Only check once per day
    if (lastRewardCheck != null) {
      final lastCheck = DateTime.parse(lastRewardCheck);
      final lastCheckDay = DateTime(lastCheck.year, lastCheck.month, lastCheck.day);
      if (today.isAtSameMomentAs(lastCheckDay)) {
        return;
      }
    }

    final dailyAllowance = getDailyAllowance();
    final todayTotal = getTodayTotal();

    if (dailyAllowance > 0) {
      final percentage = (todayTotal / dailyAllowance) * 100;

      if (percentage < 50) {
        // Excellent budget discipline
        await addReward(20, 'Stayed under 50% of daily budget!', 'earned');
      } else if (percentage < 80) {
        // Good budget discipline
        await addReward(10, 'Stayed under 80% of daily budget!', 'earned');
      } else if (percentage > 120) {
        // Exceeded budget
        await addReward(5, 'Exceeded daily budget', 'redeemed');
      }
    }

    await prefs.setString('last_reward_check', today.toIso8601String());
  }

  // Redeem reward
  Future<bool> redeemReward(String title, int pointsCost) async {
    if (_totalPoints >= pointsCost) {
      await addReward(pointsCost, 'Redeemed: $title', 'redeemed');
      return true;
    }
    return false;
  }

  // Get available redemptions
  List<Map<String, dynamic>> getAvailableRedemptions() {
    return [
      {
        'title': '50 MB Data',
        'pointsCost': 100,
        'type': 'data',
        'icon': 'signal_cellular_alt',
      },
      {
        'title': '100 MB Data',
        'pointsCost': 180,
        'type': 'data',
        'icon': 'signal_cellular_alt',
      },
      {
        'title': '20 Minutes Talk Time',
        'pointsCost': 150,
        'type': 'minutes',
        'icon': 'phone',
      },
      {
        'title': '50 Minutes Talk Time',
        'pointsCost': 300,
        'type': 'minutes',
        'icon': 'phone',
      },
      {
        'title': '10% Bill Discount',
        'pointsCost': 200,
        'type': 'discount',
        'icon': 'discount',
      },
      {
        'title': '20% Bill Discount',
        'pointsCost': 400,
        'type': 'discount',
        'icon': 'discount',
      },
    ];
  }

  // Category budget management
  Future<void> setCategoryBudget(String categoryName, double budgetAmount) async {
    final now = DateTime.now();
    await _dbHelper.setCategoryBudget(categoryName, budgetAmount, now.month, now.year);
    notifyListeners();
  }

  Future<double?> getCategoryBudget(String categoryName) async {
    final now = DateTime.now();
    return await _dbHelper.getCategoryBudget(categoryName, now.month, now.year);
  }

  Future<Map<String, double>> getAllCategoryBudgets() async {
    final now = DateTime.now();
    return await _dbHelper.getAllCategoryBudgets(now.month, now.year);
  }

  Future<double> getCategorySpending(String categoryName) async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

    final categoryBreakdown = await _dbHelper.getExpensesByCategory(startOfMonth, endOfMonth);
    return categoryBreakdown[categoryName] ?? 0.0;
  }

  Future<Map<String, Map<String, double>>> getCategoryBudgetStatus() async {
    final budgets = await getAllCategoryBudgets();
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    final spending = await _dbHelper.getExpensesByCategory(startOfMonth, endOfMonth);

    Map<String, Map<String, double>> status = {};

    for (var category in budgets.keys) {
      final budget = budgets[category]!;
      final spent = spending[category] ?? 0.0;
      final remaining = budget - spent;
      final percentage = budget > 0 ? (spent / budget) * 100 : 0.0;

      status[category] = {
        'budget': budget,
        'spent': spent,
        'remaining': remaining,
        'percentage': percentage,
      };
    }

    return status;
  }

  Future<void> deleteCategoryBudget(String categoryName) async {
    final now = DateTime.now();
    await _dbHelper.deleteCategoryBudget(categoryName, now.month, now.year);
    notifyListeners();
  }

  // Premium subscription management
  Future<void> loadPremiumStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _isPremiumSubscribed = prefs.getBool('is_premium_subscribed') ?? false;
    notifyListeners();
  }

  Future<void> subscribeToPremium() async {
    final prefs = await SharedPreferences.getInstance();
    _isPremiumSubscribed = true;
    _showPremiumThankYou = true;
    await prefs.setBool('is_premium_subscribed', true);
    notifyListeners();
  }

  Future<void> unsubscribeFromPremium() async {
    final prefs = await SharedPreferences.getInstance();
    _isPremiumSubscribed = false;
    await prefs.setBool('is_premium_subscribed', false);
    notifyListeners();
  }

  void dismissPremiumThankYou() {
    _showPremiumThankYou = false;
    notifyListeners();
  }
}

enum SpendingStatus { green, yellow, red }
