import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

/// Chatbot API Service
///
/// Provides methods to interact with the AI chatbot backend
class ChatbotApiService {
  /// Send a message to the AI chatbot
  ///
  /// [token] - JWT authentication token
  /// [message] - User's question/message
  ///
  /// Returns AI response or null on error
  static Future<String?> chat({
    required String token,
    required String message,
  }) async {
    try {
      if (message.trim().isEmpty) {
        throw Exception('Message cannot be empty');
      }

      final url = Uri.parse(
        ApiConfig.getFullUrl(ApiConfig.chatbotChatEndpoint),
      );

      print('Sending message to chatbot: $message');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'message': message,
        }),
      ).timeout(const Duration(seconds: 30));

      print('Chatbot response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return data['data']['response'];
        }
      } else if (response.statusCode == 401) {
        throw Exception('Authentication failed. Please login again.');
      } else if (response.statusCode == 403) {
        throw Exception('Premium subscription required for AI chatbot.');
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to get chatbot response');
      }

      return null;
    } catch (e) {
      print('Error sending message to chatbot: $e');
      rethrow;
    }
  }

  /// Get quick financial summary
  ///
  /// [token] - JWT authentication token
  ///
  /// Returns financial summary data or null on error
  static Future<Map<String, dynamic>?> getQuickSummary({
    required String token,
  }) async {
    try {
      final url = Uri.parse(
        ApiConfig.getFullUrl(ApiConfig.chatbotSummaryEndpoint),
      );

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(ApiConfig.connectionTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return data['data'];
        }
      } else if (response.statusCode == 401) {
        throw Exception('Authentication failed. Please login again.');
      } else if (response.statusCode == 403) {
        throw Exception('Premium subscription required.');
      }

      return null;
    } catch (e) {
      print('Error fetching quick summary: $e');
      rethrow;
    }
  }

  /// Get detailed financial data
  ///
  /// [token] - JWT authentication token
  ///
  /// Returns financial analytics data or null on error
  static Future<Map<String, dynamic>?> getFinancialData({
    required String token,
  }) async {
    try {
      final url = Uri.parse(
        ApiConfig.getFullUrl(ApiConfig.chatbotFinancialDataEndpoint),
      );

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(ApiConfig.connectionTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return data['data'];
        }
      } else if (response.statusCode == 401) {
        throw Exception('Authentication failed. Please login again.');
      } else if (response.statusCode == 403) {
        throw Exception('Premium subscription required.');
      }

      return null;
    } catch (e) {
      print('Error fetching financial data: $e');
      rethrow;
    }
  }
}

/// Chat message model
class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}
