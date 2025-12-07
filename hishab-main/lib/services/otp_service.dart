import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import '../config/api_config.dart';

/// Service to handle OTP generation, sending, and verification
class OTPService {
  static final OTPService _instance = OTPService._internal();
  
  static String? _lastGeneratedOtp;
  static DateTime? _otpExpiryTime;
  static const int _otpExpirySeconds = 300;

  factory OTPService() => _instance;

  OTPService._internal();

  String _generateOtp() {
    final random = Random();
    final otp = (100000 + random.nextInt(900000)).toString();
    _lastGeneratedOtp = otp;
    _otpExpiryTime = DateTime.now().add(const Duration(seconds: _otpExpirySeconds));
    print('🔐 OTP Generated (DEMO): $otp (Expires in $_otpExpirySeconds seconds)');
    return otp;
  }

  Future<Map<String, dynamic>> sendOtp({
    required String phoneNumber,
    required String appUserId,
  }) async {
    try {
      final otp = _generateOtp();
      final message = 'Your Hishab verification code is: $otp. Valid for 5 minutes.';

      try {
        await _sendViaBangalinkSMS(
          phoneNumber: phoneNumber,
          message: message,
          otp: otp,
        );
      } catch (e) {
        print('⚠️ Warning: Failed to send via Banglalink API: $e');
      }

      return {
        'success': true,
        'message': 'OTP sent successfully',
        'otp': otp,
        'phoneNumber': phoneNumber,
        'expiresIn': _otpExpirySeconds,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error sending OTP: $e',
      };
    }
  }

  Future<void> _sendViaBangalinkSMS({
    required String phoneNumber,
    required String message,
    required String otp,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.sendSmsEndpoint}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'phoneNumber': phoneNumber,
        'message': message,
        'smsType': 'otp_verification',
        'otp': otp,
      }),
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('SMS API responded with ${response.statusCode}');
    }
    print('✅ OTP sent via Banglalink SMS API');
  }

  Future<Map<String, dynamic>> verifyOtp({
    required String enteredOtp,
    required String phoneNumber,
  }) async {
    try {
      if (_otpExpiryTime == null || DateTime.now().isAfter(_otpExpiryTime!)) {
        return {
          'success': false,
          'message': 'OTP has expired. Please request a new one.',
        };
      }

      if (_lastGeneratedOtp == null) {
        return {
          'success': false,
          'message': 'No OTP found. Please request OTP first.',
        };
      }

      if (enteredOtp.trim() != _lastGeneratedOtp) {
        return {
          'success': false,
          'message': 'Invalid OTP. Please try again.',
        };
      }

      _lastGeneratedOtp = null;
      _otpExpiryTime = null;

      try {
        await _verifyOtpWithBackend(
          phoneNumber: phoneNumber,
          otp: enteredOtp,
        );
      } catch (e) {
        print('⚠️ Backend verification failed: $e');
      }

      return {
        'success': true,
        'message': 'OTP verified successfully',
        'phoneNumber': phoneNumber,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error verifying OTP: $e',
      };
    }
  }

  Future<void> _verifyOtpWithBackend({
    required String phoneNumber,
    required String otp,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.verifyOtpEndpoint}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'phoneNumber': phoneNumber, 'otp': otp}),
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Backend OTP verification failed');
    }
  }

  int getOtpRemainingSeconds() {
    if (_otpExpiryTime == null) return 0;
    final remaining = _otpExpiryTime!.difference(DateTime.now()).inSeconds;
    return remaining > 0 ? remaining : 0;
  }

  bool isOtpValid() {
    if (_otpExpiryTime == null || _lastGeneratedOtp == null) return false;
    return DateTime.now().isBefore(_otpExpiryTime!);
  }

  String? getDemoOtp() {
    if (isOtpValid()) {
      return _lastGeneratedOtp;
    }
    return null;
  }

  Future<Map<String, dynamic>> resendOtp({
    required String phoneNumber,
    required String appUserId,
  }) async {
    _lastGeneratedOtp = null;
    _otpExpiryTime = null;
    return sendOtp(phoneNumber: phoneNumber, appUserId: appUserId);
  }
}
