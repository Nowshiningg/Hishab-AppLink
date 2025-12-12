import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

/// Development Authentication Service
///
/// Provides methods to interact with dev endpoints for testing
/// without Banglalink API integration.
///
/// ⚠️ FOR DEVELOPMENT/TESTING ONLY - Remove in production
class DevAuthService {
  /// Register a new user (bypasses OTP)
  ///
  /// [phoneNumber] - Phone number (e.g., "01712345678" or "+8801712345678")
  ///
  /// Returns: {
  ///   'success': bool,
  ///   'user': { 'id', 'phone', 'subscriptionStatus' },
  ///   'token': JWT token string
  /// }
  static Future<Map<String, dynamic>> devRegister({
    required String phoneNumber,
  }) async {
    try {
      final url = Uri.parse(
        ApiConfig.getFullUrl(ApiConfig.devRegisterEndpoint),
      );

      print('🔧 DEV MODE: Registering user - $phoneNumber');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'phoneNumber': phoneNumber,
        }),
      ).timeout(ApiConfig.connectionTimeout);

      print('Dev register response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final token = data['data']['token'];
          final user = data['data']['user'];

          // Save token and user data locally
          await _saveAuthData(token, user);

          return {
            'success': true,
            'user': user,
            'token': token,
            'message': data['message'] ?? 'Registration successful',
          };
        }
      }

      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? 'Registration failed');
    } catch (e) {
      print('Error during dev registration: $e');
      return {
        'success': false,
        'message': 'Registration failed: $e',
      };
    }
  }

  /// Login existing user (get new JWT token)
  ///
  /// [phoneNumber] - Phone number
  ///
  /// Returns: {
  ///   'success': bool,
  ///   'user': { 'id', 'phone', 'subscriptionStatus' },
  ///   'token': JWT token string
  /// }
  static Future<Map<String, dynamic>> devLogin({
    required String phoneNumber,
  }) async {
    try {
      final url = Uri.parse(
        ApiConfig.getFullUrl(ApiConfig.devLoginEndpoint),
      );

      print('🔧 DEV MODE: Logging in user - $phoneNumber');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'phoneNumber': phoneNumber,
        }),
      ).timeout(ApiConfig.connectionTimeout);

      print('Dev login response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final token = data['data']['token'];
          final user = data['data']['user'];

          // Save token and user data locally
          await _saveAuthData(token, user);

          return {
            'success': true,
            'user': user,
            'token': token,
            'message': data['message'] ?? 'Login successful',
          };
        }
      } else if (response.statusCode == 404) {
        throw Exception(
            'User not found. Please register first using devRegister()');
      }

      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? 'Login failed');
    } catch (e) {
      print('Error during dev login: $e');
      return {
        'success': false,
        'message': 'Login failed: $e',
      };
    }
  }

  /// Activate premium subscription (bypasses Banglalink)
  ///
  /// [phoneNumber] - Phone number
  ///
  /// Returns: {
  ///   'success': bool,
  ///   'subscription': subscription details
  /// }
  static Future<Map<String, dynamic>> devSubscribe({
    required String phoneNumber,
  }) async {
    try {
      final url = Uri.parse(
        ApiConfig.getFullUrl(ApiConfig.devSubscribeEndpoint),
      );

      print('🔧 DEV MODE: Activating subscription - $phoneNumber');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'phoneNumber': phoneNumber,
        }),
      ).timeout(ApiConfig.connectionTimeout);

      print('Dev subscribe response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return {
            'success': true,
            'subscription': data['data'],
            'message': data['message'] ?? 'Subscription activated',
          };
        }
      } else if (response.statusCode == 404) {
        throw Exception('User not found. Please register first.');
      }

      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? 'Subscription failed');
    } catch (e) {
      print('Error during dev subscribe: $e');
      return {
        'success': false,
        'message': 'Subscription failed: $e',
      };
    }
  }

  /// Delete user and all data (bypasses Banglalink)
  ///
  /// [phoneNumber] - Phone number
  ///
  /// Returns: {
  ///   'success': bool,
  ///   'message': string
  /// }
  static Future<Map<String, dynamic>> devUnsubscribe({
    required String phoneNumber,
  }) async {
    try {
      final url = Uri.parse(
        ApiConfig.getFullUrl(ApiConfig.devUnsubscribeEndpoint),
      );

      print('🔧 DEV MODE: Unsubscribing/deleting user - $phoneNumber');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'phoneNumber': phoneNumber,
        }),
      ).timeout(ApiConfig.connectionTimeout);

      print('Dev unsubscribe response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          // Clear local auth data
          await clearAuthData();

          return {
            'success': true,
            'message': data['message'] ?? 'Unsubscribed successfully',
          };
        }
      } else if (response.statusCode == 404) {
        throw Exception('User not found');
      }

      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? 'Unsubscribe failed');
    } catch (e) {
      print('Error during dev unsubscribe: $e');
      return {
        'success': false,
        'message': 'Unsubscribe failed: $e',
      };
    }
  }

  /// Get user details by phone number
  ///
  /// [phoneNumber] - Phone number
  ///
  /// Returns user details or null on error
  static Future<Map<String, dynamic>?> devGetUser({
    required String phoneNumber,
  }) async {
    try {
      final url = Uri.parse(
        ApiConfig.getFullUrl('${ApiConfig.devGetUserEndpoint}/$phoneNumber'),
      );

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(ApiConfig.connectionTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return data['data'];
        }
      } else if (response.statusCode == 404) {
        return null;
      }

      return null;
    } catch (e) {
      print('Error getting user details: $e');
      return null;
    }
  }

  /// Save authentication data locally
  static Future<void> _saveAuthData(String token, Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt_token', token);
    await prefs.setString('user_id', user['id'].toString());
    await prefs.setString('user_phone', user['phone']);
    await prefs.setString(
        'subscription_status', user['subscriptionStatus'] ?? 'inactive');
    await prefs.setBool('is_logged_in', true);
  }

  /// Get saved JWT token
  static Future<String?> getSavedToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  /// Get saved user data
  static Future<Map<String, dynamic>?> getSavedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('is_logged_in') ?? false;

    if (!isLoggedIn) return null;

    return {
      'id': prefs.getString('user_id'),
      'phone': prefs.getString('user_phone'),
      'subscriptionStatus': prefs.getString('subscription_status'),
    };
  }

  /// Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_logged_in') ?? false;
  }

  /// Clear all authentication data
  static Future<void> clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    await prefs.remove('user_id');
    await prefs.remove('user_phone');
    await prefs.remove('subscription_status');
    await prefs.setBool('is_logged_in', false);
  }
}
