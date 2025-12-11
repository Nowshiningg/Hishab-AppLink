import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/subscription.dart';

/// Subscription API Service
/// Handles all subscription-related API calls to Banglalink AppLink
/// Matches backend expected data structure from /api/banglalink/subscription/subscribe-proxy and unsubscribe-proxy

class SubscriptionApiService {
  /// Subscribe user to premium plan
  /// 
  /// [phoneNumber]: User's Banglalink phone number (e.g., '01711234567')
  /// [userId]: Unique user identifier
  /// 
  /// Returns: Subscription object if successful, null otherwise
  static Future<Subscription?> subscribe({
    required String phoneNumber,
    required String userId,
  }) async {
    try {
      final url = Uri.parse(ApiConfig.getFullUrl(ApiConfig.subscribeEndpoint));
      
      final response = await http.post(
        url,
        headers: ApiConfig.getAuthHeaders(),
        body: jsonEncode({
          'phoneNumber': phoneNumber,
          'userId': userId,
        }),
      ).timeout(ApiConfig.connectionTimeout);

      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      
      if (jsonResponse['success'] == true && response.statusCode == 200) {
        final subscriptionData = jsonResponse['data'];
        return Subscription(
          subscriptionId: subscriptionData['subscriptionId'] ?? '',
          userId: userId,
          phoneNumber: phoneNumber,
          status: subscriptionData['status'] ?? 'active',
          features: List<String>.from(subscriptionData['features'] ?? []),
          amount: (subscriptionData['amount'] as num?)?.toDouble() ?? 2.0,
          nextBillingDate: subscriptionData['nextBillingDate'] != null 
              ? DateTime.parse(subscriptionData['nextBillingDate'] as String)
              : null,
          startDate: subscriptionData['startDate'] != null
              ? DateTime.parse(subscriptionData['startDate'] as String)
              : null,
        );
      }
      
      throw Exception('Subscription failed: ${jsonResponse['message'] ?? 'Unknown error'}');
    } catch (e) {
      throw Exception('Subscription error: $e');
    }
  }

  /// Unsubscribe user from premium plan
  /// 
  /// [userId]: Unique user identifier
  /// 
  /// Returns: true if unsubscription was successful
  static Future<bool> unsubscribe({
    required String userId,
  }) async {
    try {
      final url = Uri.parse(ApiConfig.getFullUrl(ApiConfig.unsubscribeEndpoint));
      
      final response = await http.post(
        url,
        headers: ApiConfig.getAuthHeaders(),
        body: jsonEncode({
          'userId': userId,
        }),
      ).timeout(ApiConfig.connectionTimeout);

      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      
      if (jsonResponse['success'] == true && response.statusCode == 200) {
        return true;
      }
      
      throw Exception('Unsubscription failed: ${jsonResponse['message'] ?? 'Unknown error'}');
    } catch (e) {
      throw Exception('Unsubscribe error: $e');
    }
  }

  /// Get subscription status for a user
  /// 
  /// [userId]: Unique user identifier
  /// 
  /// Returns: SubscriptionStatusResponse with subscription details
  static Future<SubscriptionStatusResponse> getSubscriptionStatus({
    required String userId,
  }) async {
    try {
      final url = Uri.parse(
        ApiConfig.getFullUrl('${ApiConfig.subscriptionStatusEndpoint}/$userId')
      );
      
      final response = await http.get(
        url,
        headers: ApiConfig.getAuthHeaders(),
      ).timeout(ApiConfig.connectionTimeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        return SubscriptionStatusResponse.fromJson(jsonResponse);
      }
      
      throw Exception('Failed to get subscription status: ${response.body}');
    } catch (e) {
      throw Exception('Status check error: $e');
    }
  }

  /// Check if user has active subscription
  /// 
  /// [userId]: Unique user identifier
  /// 
  /// Returns: true if user has active subscription
  static Future<bool> isSubscribed({
    required String userId,
  }) async {
    try {
      final status = await getSubscriptionStatus(userId: userId);
      return status.subscribed && status.subscription?.isActive == true;
    } catch (e) {
      return false;
    }
  }

  /// Get subscription features
  /// 
  /// [userId]: Unique user identifier
  /// 
  /// Returns: List of premium features available to user
  static Future<List<String>> getSubscriptionFeatures({
    required String userId,
  }) async {
    try {
      final status = await getSubscriptionStatus(userId: userId);
      if (status.subscribed && status.subscription != null) {
        return status.subscription!.features;
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}
