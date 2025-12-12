import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Authentication service for phone-based login/registration
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  static const String baseUrl = 'https://hishab-backend.onrender.com';

  /// Register a new user with phone number
  Future<Map<String, dynamic>> registerUser(String phoneNumber) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/dev/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phoneNumber': phoneNumber}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['success'] == true) {
          // Store token and user data in SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('jwt_token', data['data']['token']);
          await prefs.setString('user_id', data['data']['user']['id']);
          await prefs.setString('user_phone', data['data']['user']['phone']);
          await prefs.setBool('is_authenticated', true);
          
          print('✅ Registration successful!');
          return {
            'success': true,
            'message': 'Registration successful',
            'data': data['data'],
          };
        }
      }
      
      return {
        'success': false,
        'message': 'Registration failed. Please try again.',
      };
    } catch (e) {
      print('❌ Registration error: $e');
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  /// Login user with phone number
  Future<Map<String, dynamic>> loginUser(String phoneNumber) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/dev/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phoneNumber': phoneNumber}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['success'] == true) {
          // Store token and user data in SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('jwt_token', data['data']['token']);
          await prefs.setString('user_id', data['data']['user']['id']);
          await prefs.setString('user_phone', data['data']['user']['phone']);
          await prefs.setBool('is_authenticated', true);
          
          print('✅ Login successful!');
          return {
            'success': true,
            'message': 'Login successful',
            'data': data['data'],
          };
        }
      }
      
      return {
        'success': false,
        'message': 'Login failed. Please try again.',
      };
    } catch (e) {
      print('❌ Login error: $e');
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  /// Get stored JWT token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_authenticated') ?? false;
  }

  /// Get current user data
  Future<Map<String, String?>> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'userId': prefs.getString('user_id'),
      'phone': prefs.getString('user_phone'),
      'token': prefs.getString('jwt_token'),
    };
  }

  /// Logout user
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    await prefs.remove('user_id');
    await prefs.remove('user_phone');
    await prefs.setBool('is_authenticated', false);
    print('✅ Logged out successfully');
  }
}
