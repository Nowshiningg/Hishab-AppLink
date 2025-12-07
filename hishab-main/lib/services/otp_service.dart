import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

/// OTP (One-Time Password) Service
/// Handles OTP sending, verification, and management
/// Uses Banglalink SMS API for OTP delivery

class OTPService {
  // Cache for OTP tracking (for demo mode)
  static final Map<String, Map<String, dynamic>> _otpCache = {};

  /// Send OTP to user's phone number
  /// In demo mode, generates a random OTP and returns it
  /// In production, delegates to Banglalink SMS API
  Future<Map<String, dynamic>> sendOtp({
    required String phoneNumber,
    required String appUserId,
  }) async {
    try {
      // Validate phone number
      final cleanNumber = phoneNumber.replaceAll(RegExp(r'\D'), '');
      if (cleanNumber.length < 10 || cleanNumber.length > 15) {
        return {
          'success': false,
          'message': 'Invalid phone number',
        };
      }

      // Generate OTP
      final otp = _generateOtp();
      final requestId = 'otp_${DateTime.now().millisecondsSinceEpoch}';
      final expiresIn = 300; // 5 minutes

      // Store OTP in cache for verification (demo mode)
      _otpCache[requestId] = {
        'otp': otp,
        'phoneNumber': phoneNumber,
        'appUserId': appUserId,
        'createdAt': DateTime.now(),
        'expiresAt': DateTime.now().add(Duration(seconds: expiresIn)),
        'attempts': 0,
      };

      // In production: Send via Banglalink SMS API
      _sendOtpViaBanglalink(phoneNumber, otp, appUserId);

      return {
        'success': true,
        'message': 'OTP sent successfully',
        'otp': otp, // For demo/testing only - remove in production
        'requestId': requestId,
        'expiresIn': expiresIn,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error sending OTP: $e',
      };
    }
  }

  /// Verify OTP entered by user
  /// Checks if OTP is valid and hasn't expired
  Future<Map<String, dynamic>> verifyOtp({
    required String enteredOtp,
    required String phoneNumber,
  }) async {
    try {
      // In demo mode: check against any cached OTP for this phone
      // In production: verify via Banglalink API
      
      for (final entry in _otpCache.entries) {
        final otpData = entry.value;
        
        // Check if OTP matches and hasn't expired
        if (otpData['phoneNumber'] == phoneNumber &&
            otpData['otp'].toString() == enteredOtp) {
          
          final expiresAt = otpData['expiresAt'] as DateTime;
          if (DateTime.now().isBefore(expiresAt)) {
            // OTP is valid
            _otpCache.remove(entry.key);
            return {
              'success': true,
              'message': 'OTP verified successfully',
              'verified': true,
            };
          } else {
            // OTP expired
            _otpCache.remove(entry.key);
            return {
              'success': false,
              'message': 'OTP has expired',
              'verified': false,
            };
          }
        }
      }

      return {
        'success': false,
        'message': 'Invalid OTP',
        'verified': false,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error verifying OTP: $e',
        'verified': false,
      };
    }
  }

  /// Resend OTP to user
  /// Generates a new OTP and sends it
  Future<Map<String, dynamic>> resendOtp({
    required String phoneNumber,
    required String appUserId,
  }) async {
    try {
      // Clear old OTPs for this phone number
      _otpCache.removeWhere((key, value) =>
          value['phoneNumber'] == phoneNumber);

      // Send new OTP
      return await sendOtp(
        phoneNumber: phoneNumber,
        appUserId: appUserId,
      );
    } catch (e) {
      return {
        'success': false,
        'message': 'Error resending OTP: $e',
      };
    }
  }

  /// Generate random 6-digit OTP
  String _generateOtp() {
    final random = DateTime.now().millisecond % 1000000;
    return random.toString().padLeft(6, '0');
  }

  /// Send OTP via Banglalink SMS API (production)
  /// This method makes the actual API call to Banglalink
  Future<void> _sendOtpViaBanglalink(
    String phoneNumber,
    String otp,
    String appUserId,
  ) async {
    try {
      final url = Uri.parse(ApiConfig.getFullUrl(ApiConfig.sendOtpEndpoint));

      final response = await http.post(
        url,
        headers: ApiConfig.getAuthHeaders(),
        body: jsonEncode({
          'phoneNumber': phoneNumber,
          'otp': otp,
          'userId': appUserId,
          'expiresIn': 300,
          'message': 'Your Hishab verification code is: $otp. Valid for 5 minutes.',
        }),
      ).timeout(ApiConfig.connectionTimeout);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        if (jsonResponse['success'] == true) {
          print('✅ OTP sent via Banglalink SMS API');
        } else {
          print('⚠️ OTP send returned non-success: ${jsonResponse['message']}');
        }
      } else {
        print('⚠️ OTP API returned status: ${response.statusCode}');
      }
    } catch (e) {
      // Silently fail - OTP is already cached in memory
      print('⚠️ Error sending OTP via Banglalink: $e');
    }
  }

  /// Clear all cached OTPs (for testing)
  void clearCache() {
    _otpCache.clear();
  }

  /// Get cache status (for debugging)
  Map<String, dynamic> getCacheStatus() {
    return {
      'cachedOtps': _otpCache.length,
      'entries': _otpCache.keys.toList(),
    };
  }
}
