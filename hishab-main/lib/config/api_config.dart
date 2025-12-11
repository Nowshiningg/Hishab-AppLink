/// API Configuration for Hishab Backend
/// Contains all endpoint URLs and configuration for Banglalink AppLink APIs
library;

class ApiConfig {
  // Base URL for backend
  static const String baseUrl = 'https://hishab-backend.onrender.com';
  
  // For local development, use:
  // static const String baseUrl = 'http://localhost:3001';
  
  // API Endpoints
  static const String subscriptionBase = '/api/banglalink/subscription';
  static const String caasBase = '/api/banglalink/caas';
  static const String smsBase = '/api/banglalink/sms';
  static const String ussdBase = '/api/banglalink/ussd';
  static const String downloadBase = '/api/banglalink/download';
  
  // Subscription API Endpoints
  static const String subscribeEndpoint = '$subscriptionBase/subscribe-proxy';
  static const String unsubscribeEndpoint = '$subscriptionBase/unsubscribe-proxy';
  static const String subscriptionStatusEndpoint = '$subscriptionBase/status';
  
  // CaaS (Charging-as-a-Service) API Endpoints
  static const String chargeEndpoint = '$caasBase/charge';
  static const String transactionStatusEndpoint = '$caasBase/transaction';
  static const String transactionHistoryEndpoint = '$caasBase/history';
  
  // SMS API Endpoints
  static const String sendSmsEndpoint = '$smsBase/send';
  static const String sendOtpEndpoint = '$smsBase/send-otp';
  static const String verifyOtpEndpoint = '$smsBase/verify';
  // OTP request endpoint for Banglalink AppLink
  static const String otpRequestEndpoint = '/api/banglalink/otp/request';
  // OTP verify endpoint for Banglalink AppLink
  static const String otpVerifyEndpoint = '/api/banglalink/otp/verify';
  static const String sendSummaryEndpoint = '$smsBase/send-summary';
  
  // USSD API Endpoints
  static const String ussdSessionEndpoint = '$ussdBase/session';
  static const String ussdMenuEndpoint = '$ussdBase/menu';
  
  // Download API Endpoints
  static const String apkDownloadEndpoint = '$downloadBase/apk';
  static const String apkInfoEndpoint = '$downloadBase/info';
  
  // Charge Types for CaaS
  static const String pdfExportCharge = 'pdf_export';
  static const String cloudStorageCharge = 'cloud_storage';
  static const String oneTimeFeatureCharge = 'one_time_feature';
  
  // API Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  
  // Subscription pricing
  static const double dailySubscriptionCharge = 2.0; // BDT
  
  // Premium Features
  static const List<String> premiumFeatures = [
    'cloud_sync',
    'advanced_analytics',
    'rewards_redemption',
    'smart_assistant',
  ];
  
  /// Get full URL for an endpoint
  static String getFullUrl(String endpoint) {
    return '$baseUrl$endpoint';
  }
  
  /// Get common headers for all API requests
  /// Backend only requires Content-Type and Accept headers
  /// API authentication is handled server-side
  static Map<String, String> getAuthHeaders() {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }
}
