import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

/// SMS API Service
/// Handles SMS-related API calls for OTP, alerts, and summaries

class SmsApiService {
  /// Send SMS message
  /// 
  /// [phoneNumber]: Recipient's phone number
  /// [message]: SMS message content
  /// 
  /// Returns: true if SMS sent successfully
  static Future<bool> sendSms({
    required String phoneNumber,
    required String message,
  }) async {
    try {
      final url = Uri.parse(ApiConfig.getFullUrl(ApiConfig.sendSmsEndpoint));
      
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phoneNumber': phoneNumber,
          'message': message,
        }),
      ).timeout(ApiConfig.connectionTimeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        return jsonResponse['success'] == true;
      }
      
      return false;
    } catch (e) {
      throw Exception('SMS sending error: $e');
    }
  }

  /// Send OTP (One-Time Password)
  /// 
  /// [phoneNumber]: Recipient's phone number
  /// [userId]: User identifier
  /// 
  /// Returns: Map with requestId if successful
  static Future<Map<String, dynamic>?> sendOtp({
    required String phoneNumber,
    required String userId,
  }) async {
    try {
      final url = Uri.parse(ApiConfig.getFullUrl(ApiConfig.sendOtpEndpoint));
      
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phoneNumber': phoneNumber,
          'userId': userId,
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
      throw Exception('OTP sending error: $e');
    }
  }

  /// Verify OTP
  /// 
  /// [requestId]: OTP request ID from sendOtp
  /// [otp]: OTP code entered by user
  /// 
  /// Returns: true if OTP is valid
  static Future<bool> verifyOtp({
    required String requestId,
    required String otp,
  }) async {
    try {
      final url = Uri.parse(ApiConfig.getFullUrl(ApiConfig.verifyOtpEndpoint));
      
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'requestId': requestId,
          'otp': otp,
        }),
      ).timeout(ApiConfig.connectionTimeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        if (jsonResponse['success'] == true) {
          final data = jsonResponse['data'] as Map<String, dynamic>;
          return data['verified'] == true;
        }
      }
      
      return false;
    } catch (e) {
      throw Exception('OTP verification error: $e');
    }
  }

  /// Send monthly expense summary via SMS
  /// 
  /// [phoneNumber]: Recipient's phone number
  /// [userId]: User identifier
  /// [summaryData]: Summary data to be sent
  /// 
  /// Returns: true if SMS sent successfully
  static Future<bool> sendMonthlySummary({
    required String phoneNumber,
    required String userId,
    required Map<String, dynamic> summaryData,
  }) async {
    try {
      final url = Uri.parse(ApiConfig.getFullUrl(ApiConfig.sendSummaryEndpoint));
      
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phoneNumber': phoneNumber,
          'userId': userId,
          'summaryData': summaryData,
        }),
      ).timeout(ApiConfig.connectionTimeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        return jsonResponse['success'] == true;
      }
      
      return false;
    } catch (e) {
      throw Exception('Summary SMS error: $e');
    }
  }

  /// Send budget alert via SMS
  /// 
  /// [phoneNumber]: Recipient's phone number
  /// [alertMessage]: Alert message
  /// 
  /// Returns: true if SMS sent successfully
  static Future<bool> sendBudgetAlert({
    required String phoneNumber,
    required String alertMessage,
  }) async {
    return sendSms(
      phoneNumber: phoneNumber,
      message: alertMessage,
    );
  }
}
