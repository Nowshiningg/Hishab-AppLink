import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

/// USSD API Service
/// Handles USSD session management for feature phone users

class UssdApiService {
  /// Handle USSD session
  /// 
  /// [phoneNumber]: User's phone number
  /// [sessionId]: USSD session ID
  /// [input]: User input from USSD menu
  /// 
  /// Returns: Map with menu response
  static Future<Map<String, dynamic>?> handleUssdSession({
    required String phoneNumber,
    required String sessionId,
    String? input,
  }) async {
    try {
      final url = Uri.parse(ApiConfig.getFullUrl(ApiConfig.ussdSessionEndpoint));
      
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phoneNumber': phoneNumber,
          'sessionId': sessionId,
          if (input != null) 'input': input,
        }),
      ).timeout(ApiConfig.connectionTimeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        if (jsonResponse['success'] == true) {
          return jsonResponse['data'] as Map<String, dynamic>;
        }
      }
      
      return null;
    } catch (e) {
      throw Exception('USSD session error: $e');
    }
  }

  /// Get USSD menu
  /// 
  /// [phoneNumber]: User's phone number
  /// [menuId]: Menu identifier
  /// 
  /// Returns: Map with menu content
  static Future<Map<String, dynamic>?> getUssdMenu({
    required String phoneNumber,
    required String menuId,
  }) async {
    try {
      final url = Uri.parse(ApiConfig.getFullUrl(ApiConfig.ussdMenuEndpoint));
      
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phoneNumber': phoneNumber,
          'menuId': menuId,
        }),
      ).timeout(ApiConfig.connectionTimeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        if (jsonResponse['success'] == true) {
          return jsonResponse['data'] as Map<String, dynamic>;
        }
      }
      
      return null;
    } catch (e) {
      throw Exception('USSD menu error: $e');
    }
  }

  /// Quick expense summary via USSD
  /// 
  /// [phoneNumber]: User's phone number
  /// [period]: 'today', 'week', or 'month'
  /// 
  /// Returns: Formatted expense summary text for USSD display
  static Future<String?> getExpenseSummaryUssd({
    required String phoneNumber,
    required String period,
  }) async {
    try {
      final response = await handleUssdSession(
        phoneNumber: phoneNumber,
        sessionId: 'SUMMARY_${DateTime.now().millisecondsSinceEpoch}',
        input: period,
      );
      
      if (response != null && response['menu'] != null) {
        return response['menu']['text'] as String?;
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }
}
