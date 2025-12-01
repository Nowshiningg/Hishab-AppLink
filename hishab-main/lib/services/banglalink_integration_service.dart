import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

/// Banglalink Applink API Integration Service
/// Integrates with Banglalink's five main APIs:
/// 1. Subscription API - Premium subscription billing
/// 2. CaaS (Charging-as-a-Service) API - Micro-payments
/// 3. SMS API - Notifications and reminders
/// 4. USSD API - Feature accessibility for low-end devices
/// 5. Downloadable API - Resource management

class BanglaLinkIntegrationService {
  // API Base URLs (These are placeholders - replace with actual Banglalink endpoints)
  static const String _subscriptionApiUrl = 'https://api.banglalink.net/subscription';
  static const String _caasApiUrl = 'https://api.banglalink.net/caas';
  static const String _smsApiUrl = 'https://api.banglalink.net/sms';
  static const String _ussdApiUrl = 'https://api.banglalink.net/ussd';
  static const String _downloadApiUrl = 'https://api.banglalink.net/download';

  // API Credentials (Should be stored securely in production)
  late String _apiKey;
  late String _apiSecret;
  late String _appId;

  bool _isInitialized = false;

  /// Initialize Banglalink API credentials
  /// In production, these should come from secure configuration/environment variables
  void initialize({
    required String apiKey,
    required String apiSecret,
    required String appId,
  }) {
    _apiKey = apiKey;
    _apiSecret = apiSecret;
    _appId = appId;
    _isInitialized = true;
  }

  /// Check if service is initialized
  bool get isInitialized => _isInitialized;

  /// Validate credentials before making API calls
  void _validateInitialization() {
    if (!_isInitialized) {
      throw Exception('BanglaLinkIntegrationService not initialized. Call initialize() first.');
    }
  }

  /// Build common headers for API requests
  Map<String, String> _buildHeaders() {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $_apiKey',
      'X-App-ID': _appId,
      'X-Timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
    };
  }

  // ==================== SUBSCRIPTION API ====================

  /// Subscribe user to premium plan (2 BDT/day)
  /// Enables through Banglalink mobile balance
  Future<SubscriptionResponse> subscribeToPremium(
    String phoneNumber,
    String planType, // 'daily', 'weekly', 'monthly'
  ) async {
    _validateInitialization();

    try {
      final body = jsonEncode({
        'phone_number': phoneNumber,
        'plan_type': planType,
        'amount': _getPlanAmount(planType),
        'service_id': 'hishab_premium',
        'timestamp': DateTime.now().toIso8601String(),
      });

      final response = await http.post(
        Uri.parse('$_subscriptionApiUrl/subscribe'),
        headers: _buildHeaders(),
        body: body,
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw TimeoutException('Subscription API request timed out'),
      );

      if (response.statusCode == 200) {
        return SubscriptionResponse.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Subscription failed: ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Cancel premium subscription
  Future<SubscriptionResponse> cancelSubscription(String phoneNumber) async {
    _validateInitialization();

    try {
      final body = jsonEncode({
        'phone_number': phoneNumber,
        'service_id': 'hishab_premium',
      });

      final response = await http.post(
        Uri.parse('$_subscriptionApiUrl/cancel'),
        headers: _buildHeaders(),
        body: body,
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw TimeoutException('Cancel subscription request timed out'),
      );

      if (response.statusCode == 200) {
        return SubscriptionResponse.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Cancellation failed: ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Check subscription status
  Future<SubscriptionStatus> checkSubscriptionStatus(String phoneNumber) async {
    _validateInitialization();

    try {
      final response = await http.get(
        Uri.parse('$_subscriptionApiUrl/status?phone=$phoneNumber'),
        headers: _buildHeaders(),
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () => throw TimeoutException('Check status request timed out'),
      );

      if (response.statusCode == 200) {
        return SubscriptionStatus.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to check subscription status: ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

  // ==================== CaaS API (Charging-as-a-Service) ====================

  /// Charge user for specific premium actions
  Future<ChargeResponse> chargePremiumFeature(
    String phoneNumber,
    String featureName,
    double amount,
    String description,
  ) async {
    _validateInitialization();

    try {
      final body = jsonEncode({
        'phone_number': phoneNumber,
        'feature_name': featureName,
        'amount': amount,
        'description': description,
        'service_id': 'hishab_caas',
        'timestamp': DateTime.now().toIso8601String(),
      });

      final response = await http.post(
        Uri.parse('$_caasApiUrl/charge'),
        headers: _buildHeaders(),
        body: body,
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw TimeoutException('CaaS charge request timed out'),
      );

      if (response.statusCode == 200) {
        return ChargeResponse.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Charge failed: ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Export monthly PDF report (CaaS - 5 BDT per export)
  Future<ChargeResponse> exportMonthlyReport(String phoneNumber) async {
    return chargePremiumFeature(
      phoneNumber,
      'monthly_pdf_export',
      5.0,
      'Monthly expense report PDF export',
    );
  }

  /// Purchase extra cloud storage (CaaS - 10 BDT for 100MB)
  Future<ChargeResponse> purchaseCloudStorage(String phoneNumber, int sizeInMB) async {
    final amount = (sizeInMB / 100) * 10.0;
    return chargePremiumFeature(
      phoneNumber,
      'cloud_storage',
      amount,
      'Cloud storage for $sizeInMB MB',
    );
  }

  /// Get transaction history
  Future<List<ChargeTransaction>> getTransactionHistory(String phoneNumber) async {
    _validateInitialization();

    try {
      final response = await http.get(
        Uri.parse('$_caasApiUrl/transactions?phone=$phoneNumber'),
        headers: _buildHeaders(),
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () => throw TimeoutException('Get transactions request timed out'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final transactions = (data['transactions'] as List)
            .map((item) => ChargeTransaction.fromJson(item))
            .toList();
        return transactions;
      } else {
        throw Exception('Failed to get transactions: ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

  // ==================== SMS API ====================

  /// Send transactional SMS alert
  Future<SmsResponse> sendAlert(
    String phoneNumber,
    String message,
  ) async {
    _validateInitialization();

    try {
      final body = jsonEncode({
        'phone_number': phoneNumber,
        'message': message,
        'type': 'transactional',
        'service_id': 'hishab_alerts',
      });

      final response = await http.post(
        Uri.parse('$_smsApiUrl/send'),
        headers: _buildHeaders(),
        body: body,
      ).timeout(
        const Duration(seconds: 20),
        onTimeout: () => throw TimeoutException('SMS send request timed out'),
      );

      if (response.statusCode == 200) {
        return SmsResponse.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('SMS send failed: ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Send monthly summary via SMS
  Future<SmsResponse> sendMonthlySummary(
    String phoneNumber,
    double totalSpent,
    double monthlyIncome,
    double remaining,
  ) async {
    final message = 'Hishab Monthly Summary: Total spent ৳${totalSpent.toStringAsFixed(0)}, '
        'Income ৳${monthlyIncome.toStringAsFixed(0)}, Remaining ৳${remaining.toStringAsFixed(0)}';

    return sendAlert(phoneNumber, message);
  }

  /// Send OTP for secure login
  Future<SmsResponse> sendLoginOtp(String phoneNumber, String otp) async {
    final message = 'Your Hishab login OTP is: $otp. Valid for 10 minutes.';
    return sendAlert(phoneNumber, message);
  }

  /// Send spending alert
  Future<SmsResponse> sendSpendingAlert(String phoneNumber, double spentToday, double dailyAllowance) async {
    final percentage = (spentToday / dailyAllowance) * 100;
    late String message;

    if (percentage > 100) {
      message = 'Alert: You\'ve exceeded your daily budget by ৳${(spentToday - dailyAllowance).toStringAsFixed(0)}';
    } else if (percentage >= 80) {
      message = 'Caution: You\'ve spent ${percentage.toStringAsFixed(0)}% of your daily budget.';
    }

    return sendAlert(phoneNumber, message);
  }

  // ==================== USSD API ====================

  /// Process USSD code requests
  /// Allows users with low-end devices to access features via USSD
  Future<UssdResponse> processUssdRequest(
    String phoneNumber,
    String ussdCode,
  ) async {
    _validateInitialization();

    try {
      final body = jsonEncode({
        'phone_number': phoneNumber,
        'ussd_code': ussdCode,
        'service_id': 'hishab',
      });

      final response = await http.post(
        Uri.parse('$_ussdApiUrl/process'),
        headers: _buildHeaders(),
        body: body,
      ).timeout(
        const Duration(seconds: 20),
        onTimeout: () => throw TimeoutException('USSD request timed out'),
      );

      if (response.statusCode == 200) {
        return UssdResponse.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('USSD processing failed: ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// USSD: Get today's expenses
  Future<UssdResponse> ussdGetTodayExpenses(
    String phoneNumber,
    double todayExpense,
  ) async {
    return processUssdRequest(
      phoneNumber,
      '*123*hishab*expenses#',
    );
  }

  /// USSD: Get monthly totals
  Future<UssdResponse> ussdGetMonthlyTotals(
    String phoneNumber,
    double monthlySpent,
    double monthlyIncome,
  ) async {
    return processUssdRequest(
      phoneNumber,
      '*123*hishab*summary#',
    );
  }

  /// USSD: Redeem reward points
  Future<UssdResponse> ussdRedeemRewards(String phoneNumber) async {
    return processUssdRequest(
      phoneNumber,
      '*123*hishab*rewards#',
    );
  }

  // ==================== DOWNLOADABLE API ====================

  /// Initiate download of a resource
  Future<DownloadResponse> initiateResourceDownload(
    String phoneNumber,
    String resourceType, // 'pdf_report', 'language_pack', 'speech_model'
    String resourceId,
  ) async {
    _validateInitialization();

    try {
      final body = jsonEncode({
        'phone_number': phoneNumber,
        'resource_type': resourceType,
        'resource_id': resourceId,
        'service_id': 'hishab_downloads',
      });

      final response = await http.post(
        Uri.parse('$_downloadApiUrl/initiate'),
        headers: _buildHeaders(),
        body: body,
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw TimeoutException('Download initiation timed out'),
      );

      if (response.statusCode == 200) {
        return DownloadResponse.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Download initiation failed: ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Download monthly PDF report
  Future<DownloadResponse> downloadMonthlyReport(String phoneNumber) async {
    return initiateResourceDownload(
      phoneNumber,
      'pdf_report',
      'monthly_expense_${DateTime.now().year}_${DateTime.now().month}',
    );
  }

  /// Download offline speech recognition model
  Future<DownloadResponse> downloadSpeechModel(String phoneNumber) async {
    return initiateResourceDownload(
      phoneNumber,
      'speech_model',
      'vosk_bengali_v1',
    );
  }

  /// Download language pack
  Future<DownloadResponse> downloadLanguagePack(String phoneNumber, String language) async {
    return initiateResourceDownload(
      phoneNumber,
      'language_pack',
      'hishab_lang_$language',
    );
  }

  // ==================== Helper Methods ====================

  double _getPlanAmount(String planType) {
    switch (planType) {
      case 'daily':
        return 2.0;
      case 'weekly':
        return 14.0;
      case 'monthly':
        return 60.0;
      default:
        return 2.0;
    }
  }
}

// ==================== Response Models ====================

class SubscriptionResponse {
  final bool success;
  final String message;
  final String transactionId;
  final DateTime timestamp;
  final String status; // 'active', 'pending', 'failed'

  SubscriptionResponse({
    required this.success,
    required this.message,
    required this.transactionId,
    required this.timestamp,
    required this.status,
  });

  factory SubscriptionResponse.fromJson(Map<String, dynamic> json) {
    return SubscriptionResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      transactionId: json['transaction_id'] ?? '',
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      status: json['status'] ?? 'pending',
    );
  }
}

class SubscriptionStatus {
  final bool isActive;
  final String planType;
  final DateTime activeSince;
  final DateTime? expiresAt;
  final double amount;
  final String renewalStatus; // 'auto_renew', 'manual', 'cancelled'

  SubscriptionStatus({
    required this.isActive,
    required this.planType,
    required this.activeSince,
    this.expiresAt,
    required this.amount,
    required this.renewalStatus,
  });

  factory SubscriptionStatus.fromJson(Map<String, dynamic> json) {
    return SubscriptionStatus(
      isActive: json['is_active'] ?? false,
      planType: json['plan_type'] ?? 'daily',
      activeSince: DateTime.parse(json['active_since'] ?? DateTime.now().toIso8601String()),
      expiresAt: json['expires_at'] != null ? DateTime.parse(json['expires_at']) : null,
      amount: (json['amount'] ?? 0).toDouble(),
      renewalStatus: json['renewal_status'] ?? 'auto_renew',
    );
  }
}

class ChargeResponse {
  final bool success;
  final String message;
  final String transactionId;
  final double chargedAmount;
  final DateTime timestamp;
  final String status; // 'success', 'pending', 'failed'

  ChargeResponse({
    required this.success,
    required this.message,
    required this.transactionId,
    required this.chargedAmount,
    required this.timestamp,
    required this.status,
  });

  factory ChargeResponse.fromJson(Map<String, dynamic> json) {
    return ChargeResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      transactionId: json['transaction_id'] ?? '',
      chargedAmount: (json['charged_amount'] ?? 0).toDouble(),
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      status: json['status'] ?? 'pending',
    );
  }
}

class ChargeTransaction {
  final String transactionId;
  final String featureName;
  final double amount;
  final String status;
  final DateTime timestamp;

  ChargeTransaction({
    required this.transactionId,
    required this.featureName,
    required this.amount,
    required this.status,
    required this.timestamp,
  });

  factory ChargeTransaction.fromJson(Map<String, dynamic> json) {
    return ChargeTransaction(
      transactionId: json['transaction_id'] ?? '',
      featureName: json['feature_name'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      status: json['status'] ?? 'completed',
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
    );
  }
}

class SmsResponse {
  final bool success;
  final String message;
  final String messageId;
  final DateTime timestamp;
  final String status; // 'sent', 'pending', 'failed'

  SmsResponse({
    required this.success,
    required this.message,
    required this.messageId,
    required this.timestamp,
    required this.status,
  });

  factory SmsResponse.fromJson(Map<String, dynamic> json) {
    return SmsResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      messageId: json['message_id'] ?? '',
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      status: json['status'] ?? 'pending',
    );
  }
}

class UssdResponse {
  final bool success;
  final String menuText;
  final String sessionId;
  final bool continueSession;

  UssdResponse({
    required this.success,
    required this.menuText,
    required this.sessionId,
    required this.continueSession,
  });

  factory UssdResponse.fromJson(Map<String, dynamic> json) {
    return UssdResponse(
      success: json['success'] ?? false,
      menuText: json['menu_text'] ?? '',
      sessionId: json['session_id'] ?? '',
      continueSession: json['continue_session'] ?? false,
    );
  }
}

class DownloadResponse {
  final bool success;
  final String downloadUrl;
  final String resourceId;
  final int fileSizeBytes;
  final String fileHash; // For integrity verification
  final DateTime expiresAt;

  DownloadResponse({
    required this.success,
    required this.downloadUrl,
    required this.resourceId,
    required this.fileSizeBytes,
    required this.fileHash,
    required this.expiresAt,
  });

  factory DownloadResponse.fromJson(Map<String, dynamic> json) {
    return DownloadResponse(
      success: json['success'] ?? false,
      downloadUrl: json['download_url'] ?? '',
      resourceId: json['resource_id'] ?? '',
      fileSizeBytes: json['file_size_bytes'] ?? 0,
      fileHash: json['file_hash'] ?? '',
      expiresAt: DateTime.parse(json['expires_at'] ?? DateTime.now().add(const Duration(hours: 24)).toIso8601String()),
    );
  }
}
