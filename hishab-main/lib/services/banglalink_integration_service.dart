import 'subscription_api_service.dart';
import 'caas_api_service.dart';
import 'sms_api_service.dart';
import 'ussd_api_service.dart';
import 'download_api_service.dart';
import '../models/subscription.dart';
import '../models/transaction.dart';

/// Banglalink Integration Service
/// Main service that integrates all Banglalink AppLink APIs
/// 
/// This service provides a unified interface for:
/// - Subscription Management (Premium subscriptions)
/// - CaaS (Charging-as-a-Service for micro-payments)
/// - SMS API (OTP, alerts, summaries)
/// - USSD API (Feature phone support)
/// - Download API (APK distribution)

class BanglalinkIntegrationService {
  // Singleton pattern
  static final BanglalinkIntegrationService _instance = 
      BanglalinkIntegrationService._internal();
  
  factory BanglalinkIntegrationService() => _instance;
  
  BanglalinkIntegrationService._internal();

  // Current user context
  String? _currentUserId;
  String? _currentPhoneNumber;

  /// Initialize with user context
  void initialize({
    required String userId,
    required String phoneNumber,
  }) {
    _currentUserId = userId;
    _currentPhoneNumber = phoneNumber;
  }

  /// Check if service is initialized
  bool get isInitialized => 
      _currentUserId != null && _currentPhoneNumber != null;

  /// Get current user ID
  String? get userId => _currentUserId;

  /// Get current phone number
  String? get phoneNumber => _currentPhoneNumber;

  // ==================== SUBSCRIPTION API ====================

  /// Subscribe to premium plan
  Future<Subscription?> subscribeToPremium() async {
    if (!isInitialized) throw Exception('Service not initialized');
    
    return await SubscriptionApiService.subscribe(
      phoneNumber: _currentPhoneNumber!,
      userId: _currentUserId!,
    );
  }

  /// Unsubscribe from premium plan
  Future<Subscription?> unsubscribeFromPremium() async {
    if (!isInitialized) throw Exception('Service not initialized');
    
    return await SubscriptionApiService.unsubscribe(
      userId: _currentUserId!,
    );
  }

  /// Check subscription status
  Future<SubscriptionStatusResponse> getSubscriptionStatus() async {
    if (!isInitialized) throw Exception('Service not initialized');
    
    return await SubscriptionApiService.getSubscriptionStatus(
      userId: _currentUserId!,
    );
  }

  /// Check if user has active subscription
  Future<bool> isPremiumSubscriber() async {
    if (!isInitialized) return false;
    
    return await SubscriptionApiService.isSubscribed(
      userId: _currentUserId!,
    );
  }

  /// Get available premium features
  Future<List<String>> getPremiumFeatures() async {
    if (!isInitialized) return [];
    
    return await SubscriptionApiService.getSubscriptionFeatures(
      userId: _currentUserId!,
    );
  }

  // ==================== CaaS API ====================

  /// Charge for PDF export
  Future<Transaction?> chargePdfExport({
    required String reportType,
  }) async {
    if (!isInitialized) throw Exception('Service not initialized');
    
    return await CaasApiService.chargePdfExport(
      phoneNumber: _currentPhoneNumber!,
      userId: _currentUserId!,
      reportType: reportType,
    );
  }

  /// Charge for cloud storage
  Future<Transaction?> chargeCloudStorage({
    required int storageAmountGB,
  }) async {
    if (!isInitialized) throw Exception('Service not initialized');
    
    return await CaasApiService.chargeCloudStorage(
      phoneNumber: _currentPhoneNumber!,
      userId: _currentUserId!,
      storageAmount: storageAmountGB,
    );
  }

  /// Charge for one-time feature
  Future<Transaction?> chargeOneTimeFeature({
    required String featureName,
  }) async {
    if (!isInitialized) throw Exception('Service not initialized');
    
    return await CaasApiService.chargeOneTimeFeature(
      phoneNumber: _currentPhoneNumber!,
      userId: _currentUserId!,
      featureName: featureName,
    );
  }

  /// Get transaction history
  Future<TransactionHistory?> getTransactionHistory({int? limit}) async {
    if (!isInitialized) throw Exception('Service not initialized');
    
    return await CaasApiService.getTransactionHistory(
      userId: _currentUserId!,
      limit: limit,
    );
  }

  /// Check transaction status
  Future<Transaction?> checkTransactionStatus({
    required String transactionId,
  }) async {
    return await CaasApiService.getTransactionStatus(
      transactionId: transactionId,
    );
  }

  // ==================== SMS API ====================

  /// Send OTP for verification
  Future<Map<String, dynamic>?> sendOtp() async {
    if (!isInitialized) throw Exception('Service not initialized');
    
    return await SmsApiService.sendOtp(
      phoneNumber: _currentPhoneNumber!,
      userId: _currentUserId!,
    );
  }

  /// Verify OTP
  Future<bool> verifyOtp({
    required String requestId,
    required String otp,
  }) async {
    return await SmsApiService.verifyOtp(
      requestId: requestId,
      otp: otp,
    );
  }

  /// Send monthly expense summary via SMS
  Future<bool> sendMonthlySummarySms({
    required Map<String, dynamic> summaryData,
  }) async {
    if (!isInitialized) throw Exception('Service not initialized');
    
    return await SmsApiService.sendMonthlySummary(
      phoneNumber: _currentPhoneNumber!,
      userId: _currentUserId!,
      summaryData: summaryData,
    );
  }

  /// Send budget alert SMS
  Future<bool> sendBudgetAlertSms({
    required String alertMessage,
  }) async {
    if (!isInitialized) throw Exception('Service not initialized');
    
    return await SmsApiService.sendBudgetAlert(
      phoneNumber: _currentPhoneNumber!,
      alertMessage: alertMessage,
    );
  }

  /// Send custom SMS
  Future<bool> sendCustomSms({
    required String message,
  }) async {
    if (!isInitialized) throw Exception('Service not initialized');
    
    return await SmsApiService.sendSms(
      phoneNumber: _currentPhoneNumber!,
      message: message,
    );
  }

  // ==================== USSD API ====================

  /// Handle USSD session
  Future<Map<String, dynamic>?> handleUssdSession({
    required String sessionId,
    String? input,
  }) async {
    if (!isInitialized) throw Exception('Service not initialized');
    
    return await UssdApiService.handleUssdSession(
      phoneNumber: _currentPhoneNumber!,
      sessionId: sessionId,
      input: input,
    );
  }

  /// Get expense summary via USSD
  Future<String?> getUssdExpenseSummary({
    required String period, // 'today', 'week', 'month'
  }) async {
    if (!isInitialized) throw Exception('Service not initialized');
    
    return await UssdApiService.getExpenseSummaryUssd(
      phoneNumber: _currentPhoneNumber!,
      period: period,
    );
  }

  // ==================== DOWNLOAD API ====================

  /// Get APK information
  Future<Map<String, dynamic>?> getApkInfo() async {
    return await DownloadApiService.getApkInfo();
  }

  /// Download APK
  Future<String?> downloadApk({
    Function(double)? onProgress,
  }) async {
    return await DownloadApiService.downloadApk(
      onProgress: onProgress,
    );
  }

  /// Check if app update is available
  Future<bool> isUpdateAvailable({
    required String currentVersion,
  }) async {
    return await DownloadApiService.isUpdateAvailable(
      currentVersion: currentVersion,
    );
  }

  /// Get APK download URL
  String getApkDownloadUrl() {
    return DownloadApiService.getApkDownloadUrl();
  }

  // ==================== UTILITY METHODS ====================

  /// Clear user context (logout)
  void clearContext() {
    _currentUserId = null;
    _currentPhoneNumber = null;
  }

  /// Validate phone number format
  static bool isValidBanglalinkNumber(String phoneNumber) {
    // Banglalink numbers start with 019 in Bangladesh
    final regex = RegExp(r'^(\+880|880|0)?19\d{8}$');
    return regex.hasMatch(phoneNumber);
  }

  /// Format phone number to standard format
  static String formatPhoneNumber(String phoneNumber) {
    // Remove any non-digit characters
    String cleaned = phoneNumber.replaceAll(RegExp(r'\D'), '');
    
    // Add country code if missing
    if (cleaned.startsWith('19')) {
      cleaned = '880$cleaned';
    } else if (cleaned.startsWith('019')) {
      cleaned = '880${cleaned.substring(1)}';
    } else if (cleaned.startsWith('88019')) {
      cleaned = '880${cleaned.substring(3)}';
    }
    
    return cleaned;
  }
}
