import 'package:sqflite_common/sqflite.dart';
import 'package:sqflite/sqflite.dart' if (dart.library.html) 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/expense.dart';
import '../models/category_model.dart';
import '../models/income.dart';
import '../models/savings_goal.dart';
import '../models/wishlist_item.dart';
import '../models/achievement.dart';
import '../models/streak.dart';

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
        version: 4,
        onCreate: _createDB,
        onUpgrade: _upgradeDB,
      );
    } else {
      // For mobile platforms
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, filePath);
      return await openDatabase(
        path,
        version: 4,
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

    // Create savings goals table
    await db.execute('''
      CREATE TABLE savings_goals (
        id $idType,
        title $textType,
        targetAmount $realType,
        currentAmount REAL NOT NULL DEFAULT 0,
        monthlyAllocation REAL NOT NULL DEFAULT 0,
        targetDate $textType,
        createdAt $textType,
        updatedAt $textType,
        isActive INTEGER NOT NULL DEFAULT 1,
        notifyOnMilestone INTEGER NOT NULL DEFAULT 1,
        colorHex TEXT
      )
    ''');

    // Create wishlist items table
    await db.execute('''
      CREATE TABLE wishlist_items (
        id $idType,
        title $textType,
        price $realType,
        savedAmount REAL NOT NULL DEFAULT 0,
        targetDate TEXT,
        imageUrl TEXT,
        priority INTEGER NOT NULL DEFAULT 999,
        createdAt $textType,
        updatedAt $textType,
        isPurchased INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // Create achievements table
    await db.execute('''
      CREATE TABLE achievements (
        id $idType,
        key $textType UNIQUE,
        title $textType,
        description $textType,
        unlockedAt TEXT
      )
    ''');

    // Create streaks table
    await db.execute('''
      CREATE TABLE streaks (
        id $idType,
        type $textType UNIQUE,
        current INTEGER NOT NULL DEFAULT 0,
        best INTEGER NOT NULL DEFAULT 0,
        lastActiveDate $textType
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

    // Migration from version 2 to version 3 - Gamification features
    if (oldVersion < 3) {
      // Create savings_goals table
      try {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS savings_goals (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            targetAmount REAL NOT NULL,
            savedAmount REAL NOT NULL DEFAULT 0,
            targetDate TEXT NOT NULL,
            createdAt TEXT NOT NULL,
            updatedAt TEXT NOT NULL,
            isActive INTEGER NOT NULL DEFAULT 1,
            notifyOnMilestone INTEGER NOT NULL DEFAULT 1,
            colorHex TEXT
          )
        ''');
      } catch (e) {
        print('Error creating savings_goals table: $e');
      }

      // Create wishlist_items table
      try {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS wishlist_items (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            price REAL NOT NULL,
            savedAmount REAL NOT NULL DEFAULT 0,
            targetDate TEXT,
            imageUrl TEXT,
            priority INTEGER NOT NULL DEFAULT 999,
            createdAt TEXT NOT NULL,
            updatedAt TEXT NOT NULL,
            isPurchased INTEGER NOT NULL DEFAULT 0
          )
        ''');
      } catch (e) {
        print('Error creating wishlist_items table: $e');
      }

      // Create achievements table
      try {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS achievements (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            key TEXT NOT NULL UNIQUE,
            title TEXT NOT NULL,
            description TEXT NOT NULL,
            unlockedAt TEXT
          )
        ''');
      } catch (e) {
        print('Error creating achievements table: $e');
      }

      // Create streaks table
      try {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS streaks (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            type TEXT NOT NULL UNIQUE,
            current INTEGER NOT NULL DEFAULT 0,
            best INTEGER NOT NULL DEFAULT 0,
            lastActiveDate TEXT NOT NULL
          )
        ''');
      } catch (e) {
        print('Error creating streaks table: $e');
      }
    }

    // Migration from version 3 to version 4 - Refactor to allocation-based tracking
    if (oldVersion < 4) {
      try {
        // Check if savings_goals table exists and needs migration
        var tables = await db.rawQuery(
          "SELECT name FROM sqlite_master WHERE type='table' AND name='savings_goals'"
        );
        
        if (tables.isNotEmpty) {
          // Rename savedAmount to currentAmount and add monthlyAllocation
          await db.execute('''
            CREATE TABLE savings_goals_new (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              title TEXT NOT NULL,
              targetAmount REAL NOT NULL,
              currentAmount REAL NOT NULL DEFAULT 0,
              monthlyAllocation REAL NOT NULL DEFAULT 0,
              targetDate TEXT NOT NULL,
              createdAt TEXT NOT NULL,
              updatedAt TEXT NOT NULL,
              isActive INTEGER NOT NULL DEFAULT 1,
              notifyOnMilestone INTEGER NOT NULL DEFAULT 1,
              colorHex TEXT
            )
          ''');

          // Copy data from old table to new table
          await db.execute('''
            INSERT INTO savings_goals_new 
            (id, title, targetAmount, currentAmount, monthlyAllocation, targetDate, createdAt, updatedAt, isActive, notifyOnMilestone, colorHex)
            SELECT id, title, targetAmount, savedAmount, 0.0, targetDate, createdAt, updatedAt, isActive, notifyOnMilestone, colorHex
            FROM savings_goals
          ''');

          // Drop old table and rename new one
          await db.execute('DROP TABLE savings_goals');
          await db.execute('ALTER TABLE savings_goals_new RENAME TO savings_goals');
        }
      } catch (e) {
        print('Error upgrading to version 4: $e');
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

  // Savings Goals operations
  Future<int> insertSavingsGoal(SavingsGoal goal) async {
    final db = await database;
    return await db.insert('savings_goals', goal.toMap());
  }

  Future<List<SavingsGoal>> getAllSavingsGoals() async {
    final db = await database;
    final result = await db.query('savings_goals', orderBy: 'createdAt DESC');
    return result.map((map) => SavingsGoal.fromMap(map)).toList();
  }

  Future<List<SavingsGoal>> getActiveSavingsGoals() async {
    final db = await database;
    final result = await db.query(
      'savings_goals',
      where: 'isActive = ?',
      whereArgs: [1],
      orderBy: 'createdAt DESC',
    );
    return result.map((map) => SavingsGoal.fromMap(map)).toList();
  }

  Future<SavingsGoal?> getSavingsGoalById(int id) async {
    final db = await database;
    final result = await db.query(
      'savings_goals',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isEmpty) return null;
    return SavingsGoal.fromMap(result.first);
  }

  Future<int> updateSavingsGoal(SavingsGoal goal) async {
    final db = await database;
    return await db.update(
      'savings_goals',
      goal.toMap(),
      where: 'id = ?',
      whereArgs: [goal.id],
    );
  }

  Future<int> deleteSavingsGoal(int id) async {
    final db = await database;
    return await db.delete('savings_goals', where: 'id = ?', whereArgs: [id]);
  }

  // Wishlist operations
  Future<int> insertWishlistItem(WishlistItem item) async {
    final db = await database;
    return await db.insert('wishlist_items', item.toMap());
  }

  Future<List<WishlistItem>> getAllWishlistItems() async {
    final db = await database;
    final result = await db.query(
      'wishlist_items',
      orderBy: 'priority ASC, createdAt DESC',
    );
    return result.map((map) => WishlistItem.fromMap(map)).toList();
  }

  Future<List<WishlistItem>> getActiveWishlistItems() async {
    final db = await database;
    final result = await db.query(
      'wishlist_items',
      where: 'isPurchased = ?',
      whereArgs: [0],
      orderBy: 'priority ASC, createdAt DESC',
    );
    return result.map((map) => WishlistItem.fromMap(map)).toList();
  }

  Future<WishlistItem?> getWishlistItemById(int id) async {
    final db = await database;
    final result = await db.query(
      'wishlist_items',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isEmpty) return null;
    return WishlistItem.fromMap(result.first);
  }

  Future<int> updateWishlistItem(WishlistItem item) async {
    final db = await database;
    return await db.update(
      'wishlist_items',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<int> deleteWishlistItem(int id) async {
    final db = await database;
    return await db.delete('wishlist_items', where: 'id = ?', whereArgs: [id]);
  }

  // Achievement operations
  Future<int> insertAchievement(Achievement achievement) async {
    final db = await database;
    return await db.insert(
      'achievements',
      achievement.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Achievement>> getAllAchievements() async {
    final db = await database;
    final result = await db.query('achievements', orderBy: 'unlockedAt DESC');
    return result.map((map) => Achievement.fromMap(map)).toList();
  }

  Future<Achievement?> getAchievementByKey(String key) async {
    final db = await database;
    final result = await db.query(
      'achievements',
      where: 'key = ?',
      whereArgs: [key],
    );
    if (result.isEmpty) return null;
    return Achievement.fromMap(result.first);
  }

  Future<int> updateAchievement(Achievement achievement) async {
    final db = await database;
    return await db.update(
      'achievements',
      achievement.toMap(),
      where: 'key = ?',
      whereArgs: [achievement.key],
    );
  }

  // Streak operations
  Future<int> insertStreak(Streak streak) async {
    final db = await database;
    return await db.insert(
      'streaks',
      streak.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Streak>> getAllStreaks() async {
    final db = await database;
    final result = await db.query('streaks', orderBy: 'current DESC');
    return result.map((map) => Streak.fromMap(map)).toList();
  }

  Future<Streak?> getStreakByType(String type) async {
    final db = await database;
    final result = await db.query(
      'streaks',
      where: 'type = ?',
      whereArgs: [type],
    );
    if (result.isEmpty) return null;
    return Streak.fromMap(result.first);
  }

  Future<int> updateStreak(Streak streak) async {
    final db = await database;
    return await db.update(
      'streaks',
      streak.toMap(),
      where: 'type = ?',
      whereArgs: [streak.type],
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
      await db.delete('savings_goals');
    } catch (e) {
      print('Error clearing savings_goals: $e');
    }
    try {
      await db.delete('wishlist_items');
    } catch (e) {
      print('Error clearing wishlist_items: $e');
    }
    try {
      await db.delete('achievements');
    } catch (e) {
      print('Error clearing achievements: $e');
    }
    try {
      await db.delete('streaks');
    } catch (e) {
      print('Error clearing streaks: $e');
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
