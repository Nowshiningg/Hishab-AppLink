import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import '../config/api_config.dart';

/// Service to handle user registration and data persistence
class UserRegistrationService {
  static final UserRegistrationService _instance = UserRegistrationService._internal();

  factory UserRegistrationService() {
    return _instance;
  }

  UserRegistrationService._internal();

  /// Register a new user with name, phone number and password
  /// Saves locally and sends to backend
  Future<Map<String, dynamic>> registerUser({
    required String name,
    required String phoneNumber,
    required String password,
  }) async {
    try {
      // Save locally first
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_name', name);
      await prefs.setString('user_phone', phoneNumber);
      
      // Hash password using SHA256
      final hashedPassword = sha256.convert(utf8.encode(password)).toString();
      await prefs.setString('user_password_hash', hashedPassword);
      
      // Generate or use phone number as user ID
      final userId = 'user_${phoneNumber.replaceAll('+', '').replaceAll(' ', '')}';
      await prefs.setString('user_id', userId);
      await prefs.setBool('user_registered', true);

      // Send to backend asynchronously (don't wait for response)
      _sendUserDataToBackend(
        name: name,
        phoneNumber: phoneNumber,
        userId: userId,
        passwordHash: hashedPassword,
      );

      return {
        'success': true,
        'message': 'Registration successful',
        'userId': userId,
        'name': name,
        'phoneNumber': phoneNumber,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error during registration: $e',
      };
    }
  }

  /// Send user data to backend (fire-and-forget)
  Future<void> _sendUserDataToBackend({
    required String name,
    required String phoneNumber,
    required String userId,
    required String passwordHash,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/users/register'),
        headers: ApiConfig.getAuthHeaders(),
        body: jsonEncode({
          'userId': userId,
          'name': name,
          'phoneNumber': phoneNumber,
          'passwordHash': passwordHash,
          'registeredAt': DateTime.now().toIso8601String(),
          'appVersion': '1.0.0',
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ User registered successfully on backend');
      } else {
        print('Backend responded with status code: ${response.statusCode}');
      }
    } catch (e) {
      // Silently fail - user data is already saved locally
      print('⚠️ Error sending user data to backend: $e');
    }
  }

  /// Get current user data from local storage
  Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final name = prefs.getString('user_name');
      final phone = prefs.getString('user_phone');
      final userId = prefs.getString('user_id');
      final isRegistered = prefs.getBool('user_registered') ?? false;

      if (isRegistered && name != null && phone != null && userId != null) {
        return {
          'userId': userId,
          'name': name,
          'phoneNumber': phone,
        };
      }
      return null;
    } catch (e) {
      print('Error getting current user: $e');
      return null;
    }
  }

  /// Check if user is already registered
  Future<bool> isUserRegistered() async {
    final user = await getCurrentUser();
    return user != null;
  }

  /// Verify password against stored hash
  Future<bool> verifyPassword(String password) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedHash = prefs.getString('user_password_hash');

      if (storedHash == null) {
        return false;
      }

      final hashedInput = sha256.convert(utf8.encode(password)).toString();
      return hashedInput == storedHash;
    } catch (e) {
      print('Error verifying password: $e');
      return false;
    }
  }

  /// Update user profile (optional - for future use)
  Future<bool> updateUserProfile({
    String? name,
    String? phoneNumber,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (name != null) {
        await prefs.setString('user_name', name);
      }
      if (phoneNumber != null) {
        await prefs.setString('user_phone', phoneNumber);
      }
      return true;
    } catch (e) {
      print('Error updating user profile: $e');
      return false;
    }
  }

  /// Get all registered users count from backend
  Future<int> getRegisteredUsersCount() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/users/count'),
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['count'] ?? 0;
      }
      return 0;
    } catch (e) {
      print('Error getting users count: $e');
      return 0;
    }
  }
}
