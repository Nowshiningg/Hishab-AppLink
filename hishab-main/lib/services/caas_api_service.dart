import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/transaction.dart';

/// CaaS (Charging-as-a-Service) API Service
/// Handles micro-payments for premium features

class CaasApiService {
  /// Charge user for a specific action/feature
  /// 
  /// [phoneNumber]: User's Banglalink phone number
  /// [userId]: Unique user identifier
  /// [chargeType]: Type of charge (pdf_export, cloud_storage, one_time_feature)
  /// [amount]: Optional custom amount (if not provided, uses default for charge type)
  /// [metadata]: Optional metadata for the transaction
  /// 
  /// Returns: Transaction object if successful
  static Future<Transaction?> chargeUser({
    required String phoneNumber,
    required String userId,
    required String chargeType,
    double? amount,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final url = Uri.parse(ApiConfig.getFullUrl(ApiConfig.chargeEndpoint));
      
      final body = {
        'phoneNumber': phoneNumber,
        'userId': userId,
        'chargeType': chargeType,
        if (amount != null) 'amount': amount,
        if (metadata != null) 'metadata': metadata,
      };

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      ).timeout(ApiConfig.connectionTimeout);

      if (response.statusCode == 201) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        if (jsonResponse['success'] == true) {
          return Transaction.fromJson(jsonResponse['data']);
        }
      }
      
      throw Exception('Failed to charge: ${response.body}');
    } catch (e) {
      throw Exception('Charge error: $e');
    }
  }

  /// Charge for PDF export
  /// 
  /// [phoneNumber]: User's Banglalink phone number
  /// [userId]: Unique user identifier
  /// [reportType]: Type of report being exported
  /// 
  /// Returns: Transaction object if successful
  static Future<Transaction?> chargePdfExport({
    required String phoneNumber,
    required String userId,
    required String reportType,
  }) async {
    return chargeUser(
      phoneNumber: phoneNumber,
      userId: userId,
      chargeType: ApiConfig.pdfExportCharge,
      metadata: {'reportType': reportType},
    );
  }

  /// Charge for cloud storage
  /// 
  /// [phoneNumber]: User's Banglalink phone number
  /// [userId]: Unique user identifier
  /// [storageAmount]: Amount of storage in GB
  /// 
  /// Returns: Transaction object if successful
  static Future<Transaction?> chargeCloudStorage({
    required String phoneNumber,
    required String userId,
    required int storageAmount,
  }) async {
    return chargeUser(
      phoneNumber: phoneNumber,
      userId: userId,
      chargeType: ApiConfig.cloudStorageCharge,
      metadata: {'storageAmount': storageAmount},
    );
  }

  /// Charge for one-time feature purchase
  /// 
  /// [phoneNumber]: User's Banglalink phone number
  /// [userId]: Unique user identifier
  /// [featureName]: Name of the feature
  /// 
  /// Returns: Transaction object if successful
  static Future<Transaction?> chargeOneTimeFeature({
    required String phoneNumber,
    required String userId,
    required String featureName,
  }) async {
    return chargeUser(
      phoneNumber: phoneNumber,
      userId: userId,
      chargeType: ApiConfig.oneTimeFeatureCharge,
      metadata: {'feature': featureName},
    );
  }

  /// Get transaction status
  /// 
  /// [transactionId]: Transaction ID to check
  /// 
  /// Returns: Transaction object with updated status
  static Future<Transaction?> getTransactionStatus({
    required String transactionId,
  }) async {
    try {
      final url = Uri.parse(
        ApiConfig.getFullUrl('${ApiConfig.transactionStatusEndpoint}/$transactionId')
      );
      
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      ).timeout(ApiConfig.connectionTimeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        if (jsonResponse['success'] == true) {
          return Transaction.fromJson(jsonResponse['data']);
        }
      }
      
      throw Exception('Failed to get transaction status: ${response.body}');
    } catch (e) {
      throw Exception('Transaction status error: $e');
    }
  }

  /// Get transaction history for user
  /// 
  /// [userId]: Unique user identifier
  /// [limit]: Optional limit on number of transactions
  /// 
  /// Returns: TransactionHistory object
  static Future<TransactionHistory?> getTransactionHistory({
    required String userId,
    int? limit,
  }) async {
    try {
      final queryParams = {
        if (limit != null) 'limit': limit.toString(),
      };
      
      final url = Uri.parse(
        ApiConfig.getFullUrl('${ApiConfig.transactionHistoryEndpoint}/$userId')
      ).replace(queryParameters: queryParams);
      
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      ).timeout(ApiConfig.connectionTimeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        if (jsonResponse['success'] == true) {
          return TransactionHistory.fromJson(jsonResponse);
        }
      }
      
      throw Exception('Failed to get transaction history: ${response.body}');
    } catch (e) {
      throw Exception('Transaction history error: $e');
    }
  }
}
