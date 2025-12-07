import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/banglalink_config.dart';

/// Banglalink Applink API Service
///
/// This service integrates with Banglalink's Applink APIs:
/// - Subscription API: Premium subscription management (2 BDT/day)
/// - CaaS API: Micro-payment transactions
/// - SMS API: Send monthly expense summaries via SMS
/// - USSD API: Quick feature access via USSD codes
/// - Downloadable API: Generate and deliver PDF reports
///
/// API Keys and credentials should be configured in lib/config/banglalink_config.dart
class BangalinkApiService {
  // API endpoints
  static final String _subscriptionEndpoint = '/subscription/${BangalinkConfig.subscriptionApiVersion}';
  static final String _caasEndpoint = '/caas/${BangalinkConfig.caasApiVersion}';
  static final String _smsEndpoint = '/sms/${BangalinkConfig.smsApiVersion}';
  static final String _ussdEndpoint = '/ussd/${BangalinkConfig.ussdApiVersion}';
  static final String _downloadableEndpoint = '/downloadable/${BangalinkConfig.downloadableApiVersion}';

  // ========== SUBSCRIPTION API ==========

  /// Subscribe user to premium features (2 BDT/day)
  ///
  /// Returns: Subscription status and transaction ID
  Future<Map<String, dynamic>> subscribeToPremium(String phoneNumber) async {
    // Check if in test mode
    if (BangalinkConfig.testMode) {
      return {
        'success': true,
        'message': 'Subscription successful (TEST MODE)',
        'data': {
          'transaction_id': 'TEST_${DateTime.now().millisecondsSinceEpoch}',
          'status': 'active',
        },
      };
    }

    try {
      // TODO: Implement actual API call
      final response = await http.post(
        Uri.parse('${BangalinkConfig.apiBaseUrl}$_subscriptionEndpoint/subscribe'),
        headers: BangalinkConfig.getCommonHeaders(),
        body: jsonEncode({
          'phone_number': formatPhoneNumber(phoneNumber),
          'plan': BangalinkConfig.premiumPlanId,
          'amount': BangalinkConfig.dailySubscriptionCost,
          'currency': 'BDT',
        }),
      ).timeout(Duration(seconds: BangalinkConfig.apiTimeoutSeconds));

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Subscription successful',
          'data': jsonDecode(response.body),
        };
      } else {
        return {
          'success': false,
          'message': 'Subscription failed',
          'error': response.body,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error',
        'error': e.toString(),
      };
    }
  }

  /// Check subscription status
  Future<Map<String, dynamic>> checkSubscriptionStatus(String phoneNumber) async {
    try {
      // TODO: Implement actual API call
      final response = await http.get(
        Uri.parse('$_apiBaseUrl$_subscriptionEndpoint/status/$phoneNumber'),
        headers: {
          'X-API-Key': _apiKey,
          'X-App-Id': _appId,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'isSubscribed': data['is_subscribed'] ?? false,
          'expiryDate': data['expiry_date'],
          'data': data,
        };
      } else {
        return {
          'success': false,
          'isSubscribed': false,
          'message': 'Failed to check status',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'isSubscribed': false,
        'error': e.toString(),
      };
    }
  }

  /// Unsubscribe from premium
  Future<Map<String, dynamic>> unsubscribeFromPremium(String phoneNumber) async {
    try {
      // TODO: Implement actual API call
      final response = await http.post(
        Uri.parse('$_apiBaseUrl$_subscriptionEndpoint/unsubscribe'),
        headers: {
          'Content-Type': 'application/json',
          'X-API-Key': _apiKey,
          'X-App-Id': _appId,
        },
        body: jsonEncode({
          'phone_number': phoneNumber,
        }),
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Unsubscribed successfully',
        };
      } else {
        return {
          'success': false,
          'message': 'Unsubscription failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  // ========== CaaS (CHARGING AS A SERVICE) API ==========

  /// Process micro-payment for reward redemption
  ///
  /// Used when users redeem rewards for data, minutes, or discounts
  Future<Map<String, dynamic>> processPayment({
    required String phoneNumber,
    required double amount,
    required String description,
    required String rewardType,
  }) async {
    try {
      // TODO: Implement actual API call
      final response = await http.post(
        Uri.parse('$_apiBaseUrl$_caasEndpoint/charge'),
        headers: {
          'Content-Type': 'application/json',
          'X-API-Key': _apiKey,
          'X-App-Id': _appId,
        },
        body: jsonEncode({
          'phone_number': phoneNumber,
          'amount': amount,
          'currency': 'BDT',
          'description': description,
          'metadata': {
            'reward_type': rewardType,
            'app': 'Hishab',
          },
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'transactionId': data['transaction_id'],
          'message': 'Payment processed successfully',
          'data': data,
        };
      } else {
        return {
          'success': false,
          'message': 'Payment failed',
          'error': response.body,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Deliver data bundle to user
  Future<Map<String, dynamic>> deliverDataBundle({
    required String phoneNumber,
    required int dataMB,
  }) async {
    try {
      // TODO: Implement actual API call
      final response = await http.post(
        Uri.parse('$_apiBaseUrl$_caasEndpoint/deliver/data'),
        headers: {
          'Content-Type': 'application/json',
          'X-API-Key': _apiKey,
          'X-App-Id': _appId,
        },
        body: jsonEncode({
          'phone_number': phoneNumber,
          'data_mb': dataMB,
        }),
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Data bundle delivered',
          'data': jsonDecode(response.body),
        };
      } else {
        return {
          'success': false,
          'message': 'Delivery failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Deliver talk time minutes to user
  Future<Map<String, dynamic>> deliverTalkTime({
    required String phoneNumber,
    required int minutes,
  }) async {
    try {
      // TODO: Implement actual API call
      final response = await http.post(
        Uri.parse('$_apiBaseUrl$_caasEndpoint/deliver/minutes'),
        headers: {
          'Content-Type': 'application/json',
          'X-API-Key': _apiKey,
          'X-App-Id': _appId,
        },
        body: jsonEncode({
          'phone_number': phoneNumber,
          'minutes': minutes,
        }),
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Talk time delivered',
          'data': jsonDecode(response.body),
        };
      } else {
        return {
          'success': false,
          'message': 'Delivery failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  // ========== SMS API ==========

  /// Send monthly expense summary via SMS
  Future<Map<String, dynamic>> sendMonthlySummary({
    required String phoneNumber,
    required String summary,
  }) async {
    try {
      // TODO: Implement actual API call
      final response = await http.post(
        Uri.parse('$_apiBaseUrl$_smsEndpoint/send'),
        headers: {
          'Content-Type': 'application/json',
          'X-API-Key': _apiKey,
          'X-App-Id': _appId,
        },
        body: jsonEncode({
          'phone_number': phoneNumber,
          'message': summary,
          'sender_id': 'Hishab',
        }),
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'SMS sent successfully',
          'data': jsonDecode(response.body),
        };
      } else {
        return {
          'success': false,
          'message': 'SMS sending failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Send budget alert via SMS
  Future<Map<String, dynamic>> sendBudgetAlert({
    required String phoneNumber,
    required String categoryName,
    required double percentageUsed,
  }) async {
    final message = 'Hishab Alert: You have used $percentageUsed% of your $categoryName budget this month.';
    return await sendMonthlySummary(
      phoneNumber: phoneNumber,
      summary: message,
    );
  }

  // ========== USSD API ==========

  /// Register USSD short code for quick access
  ///
  /// Example: User can dial *123*45# to check their balance
  Future<Map<String, dynamic>> registerUssdCode({
    required String phoneNumber,
    required String shortCode,
  }) async {
    try {
      // TODO: Implement actual API call
      final response = await http.post(
        Uri.parse('$_apiBaseUrl$_ussdEndpoint/register'),
        headers: {
          'Content-Type': 'application/json',
          'X-API-Key': _apiKey,
          'X-App-Id': _appId,
        },
        body: jsonEncode({
          'phone_number': phoneNumber,
          'short_code': shortCode,
          'app': 'Hishab',
        }),
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'USSD code registered',
          'shortCode': shortCode,
        };
      } else {
        return {
          'success': false,
          'message': 'Registration failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Handle USSD query response
  Future<Map<String, dynamic>> handleUssdQuery({
    required String phoneNumber,
    required String query,
  }) async {
    try {
      // TODO: Implement actual API call
      // This would return expense data based on the USSD query
      return {
        'success': true,
        'response': 'Your daily allowance: 500 BDT\nToday spent: 200 BDT',
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  // ========== DOWNLOADABLE API ==========

  /// Generate and deliver PDF expense report
  Future<Map<String, dynamic>> generatePdfReport({
    required String phoneNumber,
    required String reportType, // 'monthly', 'yearly', 'custom'
    required DateTime startDate,
    required DateTime endDate,
    required Map<String, dynamic> reportData,
  }) async {
    try {
      // TODO: Implement actual API call
      final response = await http.post(
        Uri.parse('$_apiBaseUrl$_downloadableEndpoint/generate'),
        headers: {
          'Content-Type': 'application/json',
          'X-API-Key': _apiKey,
          'X-App-Id': _appId,
        },
        body: jsonEncode({
          'phone_number': phoneNumber,
          'report_type': reportType,
          'start_date': startDate.toIso8601String(),
          'end_date': endDate.toIso8601String(),
          'data': reportData,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'pdfUrl': data['pdf_url'],
          'downloadLink': data['download_link'],
          'message': 'Report generated successfully',
        };
      } else {
        return {
          'success': false,
          'message': 'Report generation failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Request SMS with download link for PDF report
  Future<Map<String, dynamic>> sendReportViaSmS({
    required String phoneNumber,
    required String reportUrl,
  }) async {
    final message = 'Your Hishab expense report is ready! Download: $reportUrl';
    return await sendMonthlySummary(
      phoneNumber: phoneNumber,
      summary: message,
    );
  }

  // ========== UTILITY METHODS ==========

  /// Validate phone number format (Banglalink Bangladesh)
  bool isValidBangladeshiNumber(String phoneNumber) {
    // Remove any spaces or special characters
    final cleaned = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');

    // Check if it's a valid Bangladeshi mobile number
    // Banglalink numbers typically start with 013, 014, or 019
    final regex = RegExp(r'^(013|014|019)\d{8}$');
    return regex.hasMatch(cleaned);
  }

  /// Get formatted phone number (adds +880 country code if needed)
  String formatPhoneNumber(String phoneNumber) {
    final cleaned = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');

    if (cleaned.startsWith('880')) {
      return '+$cleaned';
    } else if (cleaned.startsWith('0')) {
      return '+880${cleaned.substring(1)}';
    } else {
      return '+880$cleaned';
    }
  }
}
