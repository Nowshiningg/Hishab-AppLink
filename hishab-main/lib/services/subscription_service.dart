import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class SubscriptionService {
  /// Activate premium subscription (bypasses Banglalink - Direct activation)
  /// 
  /// [phoneNumber] - User's phone number
  /// 
  /// Returns subscription details or error message
  static Future<Map<String, dynamic>> activateSubscription(String phoneNumber) async {
    try {
      final url = Uri.parse(
        ApiConfig.getFullUrl(ApiConfig.devSubscribeEndpoint),
      );

      print('🔧 Activating subscription for: $phoneNumber');
      
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          // No Authorization needed for dev endpoint
        },
        body: jsonEncode({
          'phoneNumber': phoneNumber,
        }),
      );

      print('Subscription response status: ${response.statusCode}');
      
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        print('✅ Subscription activated successfully');
        return {
          'success': true,
          'userId': data['data']['userId'],
          'subscriptionId': data['data']['subscriptionId'],
          'status': data['data']['status'],
          'startDate': data['data']['startDate'],
          'nextBillingDate': data['data']['nextBillingDate'],
          'amount': data['data']['amount'],
          'features': data['data']['features'],
        };
      } else {
        print('❌ Subscription failed: ${data['message']}');
        return {
          'success': false,
          'message': data['message'] ?? 'Subscription failed',
        };
      }
    } catch (e) {
      print('❌ Network error: $e');
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  /// Check subscription status
  /// 
  /// [phoneNumber] - User's phone number
  /// 
  /// Returns subscription status
  static Future<Map<String, dynamic>> checkSubscriptionStatus(String phoneNumber) async {
    try {
      final url = Uri.parse(
        ApiConfig.getFullUrl('${ApiConfig.subscriptionBase}/status/$phoneNumber'),
      );

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'isActive': data['data']['isActive'],
          'status': data['data']['status'],
          'expiryDate': data['data']['expiryDate'],
        };
      } else {
        return {
          'success': false,
          'isActive': false,
        };
      }
    } catch (e) {
      print('❌ Error checking subscription: $e');
      return {
        'success': false,
        'isActive': false,
      };
    }
  }

  /// Cancel subscription
  /// 
  /// [phoneNumber] - User's phone number
  /// 
  /// Returns cancellation result
  static Future<Map<String, dynamic>> cancelSubscription(String phoneNumber) async {
    try {
      final url = Uri.parse(
        ApiConfig.getFullUrl(ApiConfig.devUnsubscribeEndpoint),
      );

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'phoneNumber': phoneNumber,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        print('✅ Subscription cancelled successfully');
        return {
          'success': true,
          'message': data['message'] ?? 'Subscription cancelled',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Cancellation failed',
        };
      }
    } catch (e) {
      print('❌ Error cancelling subscription: $e');
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }
}
