import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import 'dart:io' show Platform;
import '../config/api_config.dart';

/// Service to handle OTP generation, sending, and verification
class OTPService {
  static final OTPService _instance = OTPService._internal();
  
  static String? _lastGeneratedOtp;
  static String? _lastReferenceNo;
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
      // generate a demo OTP locally (kept for demo mode)
      final otp = _generateOtp();

      // Prepare application metadata
      String deviceName = 'unknown';
      String osName = 'unknown';
      try {
        deviceName = Platform.isAndroid ? 'Android device' : (Platform.isIOS ? 'iOS device' : 'device');
        osName = Platform.operatingSystem;
      } catch (_) {
        // Platform might not be available on some targets; fall back to defaults
      }

      final body = {
        'phoneNumber': _normalizePhoneNumber(phoneNumber),
        'applicationHash': '',
        'applicationMetaData': {
          'client': 'mobile_app',
          'device': deviceName,
          'os': osName,
          'appCode': 'hishab_app',
        }
      };

      // Call backend OTP request endpoint and capture reference number if provided.
      try {
        final resp = await http.post(
          Uri.parse(ApiConfig.getFullUrl(ApiConfig.otpRequestEndpoint)),
          headers: ApiConfig.getAuthHeaders(),
          body: jsonEncode(body),
        ).timeout(const Duration(seconds: 10));

        if (resp.statusCode != 200 && resp.statusCode != 201) {
          print('⚠️ OTP request API responded with ${resp.statusCode}');
        } else {
          try {
            final Map<String, dynamic> data = jsonDecode(resp.body);
            if (data.containsKey('referenceNo')) {
              _lastReferenceNo = data['referenceNo']?.toString();
            }
            if (data.containsKey('expiresIn')) {
              // if backend provides expiry, update local expiry
              final expires = int.tryParse(data['expiresIn']?.toString() ?? '');
              if (expires != null && expires > 0) {
                _otpExpiryTime = DateTime.now().add(Duration(seconds: expires));
              }
            }
          } catch (_) {
            // Non-fatal: response not JSON or doesn't contain referenceNo
          }
          print('✅ OTP request API called successfully for $phoneNumber');
        }
      } catch (e) {
        print('⚠️ Failed to call OTP request API: $e');
      }

      // Keep returning demo OTP for development/testing. In production, rely on backend verification.
      return {
        'success': true,
        'message': 'OTP requested (backend called).',
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

  String _normalizePhoneNumber(String raw) {
    var s = raw.trim();
    // Remove whitespace
    s = s.replaceAll(RegExp(r'\s+'), '');
    if (s.startsWith('+880')) return '0' + s.substring(4);
    if (s.startsWith('880')) return '0' + s.substring(3);
    return s;
  }

  // Note: direct SMS helper removed; backend `/api/banglalink/otp/request` should handle delivery.

  Future<Map<String, dynamic>> verifyOtp({
    required String enteredOtp,
    required String phoneNumber,
  }) async {
    try {
      // Prefer server-side verification when a reference number is available
      if (_lastReferenceNo != null) {
        try {
          final resp = await http.post(
            Uri.parse(ApiConfig.getFullUrl(ApiConfig.otpVerifyEndpoint)),
            headers: ApiConfig.getAuthHeaders(),
            body: jsonEncode({
              'referenceNo': _lastReferenceNo,
              'otp': enteredOtp.trim(),
            }),
          ).timeout(const Duration(seconds: 10));

          if (resp.statusCode == 200 || resp.statusCode == 201) {
            try {
              final Map<String, dynamic> data = jsonDecode(resp.body);
              final success = data['success'] == true || resp.statusCode == 200;
              if (success) {
                // clear local demo OTP
                _lastGeneratedOtp = null;
                _otpExpiryTime = null;
                _lastReferenceNo = null;
                return {
                  'success': true,
                  'message': data['message'] ?? 'OTP verified successfully (server)',
                  'phoneNumber': phoneNumber,
                };
              }
              return {
                'success': false,
                'message': data['message'] ?? 'OTP verification failed (server)',
              };
            } catch (_) {
              // Non-JSON success — treat as success
              _lastGeneratedOtp = null;
              _otpExpiryTime = null;
              _lastReferenceNo = null;
              return {
                'success': true,
                'message': 'OTP verified (server)',
                'phoneNumber': phoneNumber,
              };
            }
          } else {
            // server returned non-success
            return {
              'success': false,
              'message': 'OTP verification failed (server ${resp.statusCode})',
            };
          }
        } catch (e) {
          // if server verification fails due to network, fall back to local demo verification
          print('⚠️ Server verify failed: $e — falling back to local verification');
        }
      }

      // Fallback: local demo verification (only for dev/test)
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

      return {
        'success': true,
        'message': 'OTP verified successfully (local)',
        'phoneNumber': phoneNumber,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error verifying OTP: $e',
      };
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
