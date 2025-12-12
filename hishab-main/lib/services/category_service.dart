import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class CategoryService {
  static const String baseUrl = 'https://hishab-backend.onrender.com';

  // Get JWT Token
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  // ============================================
  // 1. CREATE CUSTOM CATEGORY
  // ============================================
  static Future<Map<String, dynamic>?> createCustomCategory({
    required String name,
    String? color, // Optional: defaults to gray on backend
  }) async {
    final token = await _getToken();
    if (token == null) {
      print('❌ No token found. Please login first.');
      return null;
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/categories/custom'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'name': name,
          if (color != null) 'color': color, // Only send if provided
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          print('✅ Custom category created: ${data['data']['name']}');
          return data['data'];
        }
      } else if (response.statusCode == 409) {
        print('❌ Category name already exists');
        return null;
      } else if (response.statusCode == 400) {
        final error = jsonDecode(response.body);
        print('❌ Error: ${error['error']}');
        return null;
      }
    } catch (e) {
      print('Error creating custom category: $e');
    }
    return null;
  }

  // ============================================
  // 2. GET ALL CATEGORIES (Default + Custom)
  // ============================================
  static Future<Map<String, dynamic>?> getAllCategories() async {
    final token = await _getToken();
    if (token == null) {
      print('❌ No token found. Please login first.');
      return null;
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/categories/all'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          print('✅ Loaded ${data['data']['default'].length} default categories');
          print('✅ Loaded ${data['data']['custom'].length} custom categories');
          return data['data']; // { default: [...], custom: [...] }
        }
      }
    } catch (e) {
      print('Error getting all categories: $e');
    }
    return null;
  }

  // ============================================
  // 3. GET ONLY CUSTOM CATEGORIES
  // ============================================
  static Future<List<dynamic>?> getCustomCategories() async {
    final token = await _getToken();
    if (token == null) {
      print('❌ No token found. Please login first.');
      return null;
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/categories/custom'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          print('✅ Loaded ${data['data'].length} custom categories');
          return data['data'];
        }
      }
    } catch (e) {
      print('Error getting custom categories: $e');
    }
    return null;
  }

  // ============================================
  // 4. GET DEFAULT CATEGORIES (Public - No Auth)
  // ============================================
  static Future<List<dynamic>?> getDefaultCategories() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/categories'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          print('✅ Loaded ${data['data'].length} default categories');
          return data['data'];
        }
      }
    } catch (e) {
      print('Error getting default categories: $e');
    }
    return null;
  }

  // ============================================
  // 5. DELETE CUSTOM CATEGORY
  // ============================================
  static Future<bool> deleteCustomCategory(int categoryId) async {
    final token = await _getToken();
    if (token == null) {
      print('❌ No token found. Please login first.');
      return false;
    }

    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/categories/custom/$categoryId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        print('✅ Custom category deleted successfully');
        return true;
      } else if (response.statusCode == 404) {
        print('❌ Category not found or access denied');
        return false;
      }
    } catch (e) {
      print('Error deleting custom category: $e');
    }
    return false;
  }
}
