import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/expense.dart';
import '../models/category_model.dart';

/// Expense API Service
///
/// Provides methods to interact with the backend expense API
/// Syncs local SQLite data with cloud backend (Supabase)
class ExpenseApiService {
  /// Get all expenses for authenticated user
  ///
  /// [token] - JWT authentication token
  ///
  /// Returns list of expenses or empty list on error
  static Future<List<Expense>> getAllExpenses({
    required String token,
  }) async {
    try {
      final url = Uri.parse(
        ApiConfig.getFullUrl('/expenses'),
      );

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(ApiConfig.connectionTimeout);

      print('Get expenses response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final List<dynamic> expensesJson = data['data'];
          return expensesJson.map((json) => Expense.fromApiJson(json)).toList();
        }
      } else if (response.statusCode == 401) {
        throw Exception('Authentication failed. Please login again.');
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['error'] ?? 'Failed to fetch expenses');
      }

      return [];
    } catch (e) {
      print('Error fetching expenses: $e');
      rethrow;
    }
  }

  /// Create a new expense
  ///
  /// [token] - JWT authentication token
  /// [amount] - Expense amount
  /// [categoryId] - Category ID
  /// [note] - Optional note
  ///
  /// Returns created expense or null on error
  static Future<Expense?> createExpense({
    required String token,
    required double amount,
    required int categoryId,
    String? note,
  }) async {
    try {
      final url = Uri.parse(
        ApiConfig.getFullUrl('/expenses'),
      );

      print('Creating expense: amount=$amount, categoryId=$categoryId');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'amount': amount,
          'category': categoryId,
          'note': note ?? '',
        }),
      ).timeout(ApiConfig.connectionTimeout);

      print('Create expense response status: ${response.statusCode}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return Expense.fromApiJson(data['data']);
        }
      } else if (response.statusCode == 401) {
        throw Exception('Authentication failed. Please login again.');
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['error'] ?? 'Failed to create expense');
      }

      return null;
    } catch (e) {
      print('Error creating expense: $e');
      rethrow;
    }
  }

  /// Delete an expense
  ///
  /// [token] - JWT authentication token
  /// [expenseId] - ID of expense to delete
  ///
  /// Returns true if deleted successfully
  static Future<bool> deleteExpense({
    required String token,
    required int expenseId,
  }) async {
    try {
      final url = Uri.parse(
        ApiConfig.getFullUrl('/expenses/$expenseId'),
      );

      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(ApiConfig.connectionTimeout);

      print('Delete expense response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      } else if (response.statusCode == 401) {
        throw Exception('Authentication failed. Please login again.');
      } else if (response.statusCode == 404) {
        throw Exception('Expense not found or access denied.');
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['error'] ?? 'Failed to delete expense');
      }
    } catch (e) {
      print('Error deleting expense: $e');
      rethrow;
    }
  }

  /// Get all categories (public endpoint, no auth required)
  ///
  /// Returns list of categories or empty list on error
  static Future<List<CategoryModel>> getAllCategories() async {
    try {
      final url = Uri.parse(
        ApiConfig.getFullUrl('/categories'),
      );

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(ApiConfig.connectionTimeout);

      print('Get categories response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final List<dynamic> categoriesJson = data['data'];
          return categoriesJson
              .map((json) => CategoryModel.fromApiJson(json))
              .toList();
        }
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['error'] ?? 'Failed to fetch categories');
      }

      return [];
    } catch (e) {
      print('Error fetching categories: $e');
      rethrow;
    }
  }

  /// Sync local expenses to backend
  ///
  /// [token] - JWT authentication token
  /// [localExpenses] - List of local expenses to sync
  ///
  /// Returns list of successfully synced expenses
  static Future<List<Expense>> syncExpensesToBackend({
    required String token,
    required List<Expense> localExpenses,
  }) async {
    List<Expense> syncedExpenses = [];

    for (var expense in localExpenses) {
      try {
        // Find category by name to get category ID
        final categories = await getAllCategories();
        final category = categories.firstWhere(
          (cat) => cat.name == expense.category,
          orElse: () => categories.first, // Default to first category if not found
        );

        final syncedExpense = await createExpense(
          token: token,
          amount: expense.amount,
          categoryId: category.id!,
          note: expense.note,
        );

        if (syncedExpense != null) {
          syncedExpenses.add(syncedExpense);
        }
      } catch (e) {
        print('Failed to sync expense ${expense.id}: $e');
      }
    }

    return syncedExpenses;
  }
}
