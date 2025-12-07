import 'package:sqflite_common/sqflite.dart';
import 'package:sqflite/sqflite.dart' if (dart.library.html) 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/expense.dart';
import '../models/category_model.dart';
import '../models/income.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('hishab.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    if (kIsWeb) {
      // For web, use in-memory database with web factory
      databaseFactory = databaseFactoryFfiWeb;
      return await openDatabase(
        inMemoryDatabasePath,
        version: 2,
        onCreate: _createDB,
        onUpgrade: _upgradeDB,
      );
    } else {
      // For mobile platforms
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, filePath);
      return await openDatabase(
        path,
        version: 2,
        onCreate: _createDB,
        onUpgrade: _upgradeDB,
      );
    }
  }

  Future<void> _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const realType = 'REAL NOT NULL';

    // Create expenses table
    await db.execute('''
      CREATE TABLE expenses (
        id $idType,
        amount $realType,
        category $textType,
        note TEXT,
        date $textType,
        timestamp $textType
      )
    ''');

    // Create income table
    await db.execute('''
      CREATE TABLE income (
        id $idType,
        monthly_income $realType,
        date_set $textType
      )
    ''');

    // Create categories table
    await db.execute('''
      CREATE TABLE categories (
        id $idType,
        name $textType,
        icon $textType,
        color $textType
      )
    ''');

    // Create rewards table
    await db.execute('''
      CREATE TABLE rewards (
        id $idType,
        points INTEGER NOT NULL,
        reason $textType,
        timestamp $textType,
        type $textType
      )
    ''');

    // Create category budgets table
    await db.execute('''
      CREATE TABLE category_budgets (
        id $idType,
        category_name $textType,
        budget_amount $realType,
        month $textType,
        year INTEGER NOT NULL
      )
    ''');

    // Insert default categories
    await _insertDefaultCategories(db);
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    // Migration from version 1 to version 2
    if (oldVersion < 2) {
      // Create rewards table if it doesn't exist
      try {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS rewards (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            points INTEGER NOT NULL,
            reason TEXT NOT NULL,
            timestamp TEXT NOT NULL,
            type TEXT NOT NULL
          )
        ''');
      } catch (e) {
        print('Error creating rewards table: $e');
      }

      // Create category_budgets table if it doesn't exist
      try {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS category_budgets (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            category_name TEXT NOT NULL,
            budget_amount REAL NOT NULL,
            month TEXT NOT NULL,
            year INTEGER NOT NULL
          )
        ''');
      } catch (e) {
        print('Error creating category_budgets table: $e');
      }
    }
  }

  Future<void> _insertDefaultCategories(Database db) async {
    final defaultCategories = [
      {'name': 'Food', 'icon': 'restaurant', 'color': '#FF6B6B'},
      {'name': 'Transport', 'icon': 'directions_car', 'color': '#4ECDC4'},
      {'name': 'Shopping', 'icon': 'shopping_bag', 'color': '#45B7D1'},
      {'name': 'Bills', 'icon': 'receipt', 'color': '#FFA07A'},
      {'name': 'Entertainment', 'icon': 'movie', 'color': '#98D8C8'},
      {'name': 'Health', 'icon': 'local_hospital', 'color': '#F7DC6F'},
      {'name': 'Other', 'icon': 'more_horiz', 'color': '#BB8FCE'},
    ];

    for (var category in defaultCategories) {
      await db.insert('categories', category);
    }
  }

  // Expense operations
  Future<int> insertExpense(Expense expense) async {
    final db = await database;
    return await db.insert('expenses', expense.toMap());
  }

  Future<List<Expense>> getAllExpenses() async {
    final db = await database;
    final result = await db.query('expenses', orderBy: 'timestamp DESC');
    return result.map((map) => Expense.fromMap(map)).toList();
  }

  Future<List<Expense>> getExpensesByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final db = await database;
    final result = await db.query(
      'expenses',
      where: 'date >= ? AND date <= ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'timestamp DESC',
    );
    return result.map((map) => Expense.fromMap(map)).toList();
  }

  Future<double> getTotalExpensesByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM expenses WHERE date >= ? AND date <= ?',
      [start.toIso8601String(), end.toIso8601String()],
    );
    return (result.first['total'] as double?) ?? 0.0;
  }

  Future<Map<String, double>> getExpensesByCategory(
    DateTime start,
    DateTime end,
  ) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT category, SUM(amount) as total FROM expenses WHERE date >= ? AND date <= ? GROUP BY category',
      [start.toIso8601String(), end.toIso8601String()],
    );

    Map<String, double> categoryTotals = {};
    for (var row in result) {
      categoryTotals[row['category'] as String] = row['total'] as double;
    }
    return categoryTotals;
  }

  Future<int> deleteExpense(int id) async {
    final db = await database;
    return await db.delete('expenses', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateExpense(Expense expense) async {
    final db = await database;
    return await db.update(
      'expenses',
      expense.toMap(),
      where: 'id = ?',
      whereArgs: [expense.id],
    );
  }

  // Income operations
  Future<int> insertIncome(Income income) async {
    final db = await database;
    // Delete all previous income records (we only keep the latest)
    await db.delete('income');
    return await db.insert('income', income.toMap());
  }

  Future<Income?> getLatestIncome() async {
    final db = await database;
    final result = await db.query('income', orderBy: 'date_set DESC', limit: 1);
    if (result.isEmpty) return null;
    return Income.fromMap(result.first);
  }

  Future<int> updateIncome(Income income) async {
    final db = await database;
    return await db.update(
      'income',
      income.toMap(),
      where: 'id = ?',
      whereArgs: [income.id],
    );
  }

  // Category operations
  Future<int> insertCategory(CategoryModel category) async {
    final db = await database;
    return await db.insert('categories', category.toMap());
  }

  Future<List<CategoryModel>> getAllCategories() async {
    final db = await database;
    final result = await db.query('categories', orderBy: 'name ASC');
    return result.map((map) => CategoryModel.fromMap(map)).toList();
  }

  Future<CategoryModel?> getCategoryByName(String name) async {
    final db = await database;
    final result = await db.query(
      'categories',
      where: 'name = ?',
      whereArgs: [name],
    );
    if (result.isEmpty) return null;
    return CategoryModel.fromMap(result.first);
  }

  Future<int> deleteCategory(int id) async {
    final db = await database;
    return await db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateCategory(CategoryModel category) async {
    final db = await database;
    return await db.update(
      'categories',
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  // Reward operations
  Future<int> insertReward(Map<String, dynamic> reward) async {
    final db = await database;
    return await db.insert('rewards', reward);
  }

  Future<List<Map<String, dynamic>>> getAllRewards() async {
    final db = await database;
    return await db.query('rewards', orderBy: 'timestamp DESC');
  }

  Future<int> getTotalPoints() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT SUM(CASE WHEN type = "earned" THEN points ELSE -points END) as total FROM rewards',
    );
    return (result.first['total'] as int?) ?? 0;
  }

  Future<List<Map<String, dynamic>>> getRecentRewards({int limit = 10}) async {
    final db = await database;
    return await db.query(
      'rewards',
      orderBy: 'timestamp DESC',
      limit: limit,
    );
  }

  // Category budget operations
  Future<int> setCategoryBudget(String categoryName, double budgetAmount, int month, int year) async {
    final db = await database;

    // Check if budget already exists
    final existing = await db.query(
      'category_budgets',
      where: 'category_name = ? AND month = ? AND year = ?',
      whereArgs: [categoryName, month.toString().padLeft(2, '0'), year],
    );

    if (existing.isNotEmpty) {
      // Update existing budget
      return await db.update(
        'category_budgets',
        {'budget_amount': budgetAmount},
        where: 'category_name = ? AND month = ? AND year = ?',
        whereArgs: [categoryName, month.toString().padLeft(2, '0'), year],
      );
    } else {
      // Insert new budget
      return await db.insert('category_budgets', {
        'category_name': categoryName,
        'budget_amount': budgetAmount,
        'month': month.toString().padLeft(2, '0'),
        'year': year,
      });
    }
  }

  Future<double?> getCategoryBudget(String categoryName, int month, int year) async {
    final db = await database;
    final result = await db.query(
      'category_budgets',
      where: 'category_name = ? AND month = ? AND year = ?',
      whereArgs: [categoryName, month.toString().padLeft(2, '0'), year],
    );

    if (result.isEmpty) return null;
    return result.first['budget_amount'] as double;
  }

  Future<Map<String, double>> getAllCategoryBudgets(int month, int year) async {
    final db = await database;
    final result = await db.query(
      'category_budgets',
      where: 'month = ? AND year = ?',
      whereArgs: [month.toString().padLeft(2, '0'), year],
    );

    Map<String, double> budgets = {};
    for (var row in result) {
      budgets[row['category_name'] as String] = row['budget_amount'] as double;
    }
    return budgets;
  }

  Future<int> deleteCategoryBudget(String categoryName, int month, int year) async {
    final db = await database;
    return await db.delete(
      'category_budgets',
      where: 'category_name = ? AND month = ? AND year = ?',
      whereArgs: [categoryName, month.toString().padLeft(2, '0'), year],
    );
  }

  // Clear all data
  Future<void> clearAllData() async {
    final db = await database;
    try {
      await db.delete('expenses');
    } catch (e) {
      print('Error clearing expenses: $e');
    }
    try {
      await db.delete('income');
    } catch (e) {
      print('Error clearing income: $e');
    }
    try {
      await db.delete('rewards');
    } catch (e) {
      print('Error clearing rewards: $e');
    }
    try {
      await db.delete('category_budgets');
    } catch (e) {
      print('Error clearing category_budgets: $e');
    }
    try {
      // Don't delete categories, just reset them
      await db.delete('categories');
      await _insertDefaultCategories(db);
    } catch (e) {
      print('Error clearing categories: $e');
    }
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
