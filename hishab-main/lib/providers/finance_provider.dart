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

  List<Expense> get expenses => _expenses;
  List<CategoryModel> get categories => _categories;
  Income? get income => _income;
  bool get isLoading => _isLoading;
  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  String get userName => _userName;
  String get firstName => _userName.split(' ').first;
  Locale get locale => _locale;

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
}

enum SpendingStatus { green, yellow, red }
