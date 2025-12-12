import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ExpenseService {
  static const String baseUrl = 'https://hishab-backend.onrender.com';

  // Get JWT Token
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  // ============================================
  // 1. Add Expense Manually (UPDATED)
  // ============================================
  // Now supports: expenseDate, customCategoryId
  static Future<Map<String, dynamic>?> addExpenseManually({
    required double amount,
    int? categoryId,           // Default category ID (optional if using custom)
    int? customCategoryId,     // Custom category ID (optional if using default)
    String? note,
    String? expenseDate,       // Format: YYYY-MM-DD (e.g., "2025-12-13")
  }) async {
    final token = await _getToken();
    if (token == null) {
      print('❌ No token found. Please login first.');
      return null;
    }

    // Validation: Must have either categoryId OR customCategoryId
    if (categoryId == null && customCategoryId == null) {
      print('❌ Error: Must provide either categoryId or customCategoryId');
      return null;
    }

    if (categoryId != null && customCategoryId != null) {
      print('❌ Error: Cannot use both categoryId and customCategoryId');
      return null;
    }

    try {
      final body = <String, dynamic>{
        'amount': amount,
        'note': note ?? '',
      };

      // Add category (either default or custom)
      if (categoryId != null) {
        body['category'] = categoryId;
      } else if (customCategoryId != null) {
        body['customCategoryId'] = customCategoryId;
      }

      // Add expense date if provided, otherwise backend uses today
      if (expenseDate != null) {
        body['expenseDate'] = expenseDate;
      }

      final response = await http.post(
        Uri.parse('$baseUrl/expenses'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          print('✅ Expense added successfully');
          return data['data'];
        }
      } else if (response.statusCode == 400) {
        final error = jsonDecode(response.body);
        print('❌ Validation error: ${error['error']}');
        return null;
      }
    } catch (e) {
      print('Error adding expense: $e');
    }
    return null;
  }

  // ============================================
  // 2. Add Expense via Voice/AI
  // ============================================
  static Future<String?> addExpenseViaVoice(String voiceMessage) async {
    final token = await _getToken();
    if (token == null) return null;

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/chatbot/chat'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'message': voiceMessage}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] ? data['data']['aiResponse'] : null;
      }
    } catch (e) {
      print('Error: $e');
    }
    return null;
  }

  // ============================================
  // 3. Get All Expenses (UPDATED)
  // ============================================
  // Now returns expense_date, category_type (default/custom)
  static Future<List<dynamic>?> getAllExpenses() async {
    final token = await _getToken();
    if (token == null) return null;

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/expenses'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          print('✅ Loaded ${data['data'].length} expenses');
          return data['data'];
        }
      }
    } catch (e) {
      print('Error: $e');
    }
    return null;
  }

  // ============================================
  // 4. Delete Expense
  // ============================================
  static Future<bool> deleteExpense(int expenseId) async {
    final token = await _getToken();
    if (token == null) return false;

    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/expenses/$expenseId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        print('✅ Expense deleted successfully');
        return true;
      }
    } catch (e) {
      print('Error: $e');
    }
    return false;
  }

  // ============================================
  // 5. Helper: Get Today's Date (YYYY-MM-DD)
  // ============================================
  static String getTodayDate() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  // ============================================
  // 6. Helper: Format Date for API
  // ============================================
  static String formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
