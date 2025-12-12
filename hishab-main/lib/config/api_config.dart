/// API Configuration for Hishab Backend
/// Contains all endpoint URLs and configuration for Banglalink AppLink APIs
library;

class ApiConfig {
  // Base URL - Update this with your deployed backend URL
  static const String baseUrl = 'https://hishab-backend.onrender.com';
  
  // For local development, use:
  // static const String baseUrl = 'http://localhost:3001';
  
  // API Key - Stored as environment variable on Render
  // This key is used for authentication with backend
  static const String apiKey = 'YOUR_API_KEY_HERE';
  
  // API Endpoints
  static const String subscriptionBase = '/api/banglalink/subscription';
  static const String caasBase = '/api/banglalink/caas';
  static const String smsBase = '/api/banglalink/sms';
  static const String ussdBase = '/api/banglalink/ussd';
  static const String downloadBase = '/api/banglalink/download';
  
  // Subscription API Endpoints
  static const String subscribeEndpoint = '$subscriptionBase/subscribe';
  static const String unsubscribeEndpoint = '$subscriptionBase/unsubscribe';
  static const String subscriptionStatusEndpoint = '$subscriptionBase/status';
  
  // CaaS (Charging-as-a-Service) API Endpoints
  static const String chargeEndpoint = '$caasBase/charge';
  static const String transactionStatusEndpoint = '$caasBase/transaction';
  static const String transactionHistoryEndpoint = '$caasBase/history';
  
  // SMS API Endpoints
  static const String sendSmsEndpoint = '$smsBase/send';
  static const String sendOtpEndpoint = '$smsBase/send-otp';
  static const String verifyOtpEndpoint = '$smsBase/verify-otp';
  static const String sendSummaryEndpoint = '$smsBase/send-summary';
  
  // USSD API Endpoints
  static const String ussdSessionEndpoint = '$ussdBase/session';
  static const String ussdMenuEndpoint = '$ussdBase/menu';
  
  // Download API Endpoints
  static const String apkDownloadEndpoint = '$downloadBase/apk';
  static const String apkInfoEndpoint = '$downloadBase/info';

  // Analytics API Endpoints
  static const String analyticsBase = '/analytics';
  static const String ruleBasedAnalyticsEndpoint = '$analyticsBase/rule-based';
  static const String aiPoweredAnalyticsEndpoint = '$analyticsBase/ai-powered';

  // PDF Report API Endpoints
  static const String pdfReportBase = '/api/pdf-report';
  static const String analyticsPdfEndpoint = '$pdfReportBase/analytics';
  static const String pdfReportHealthEndpoint = '$pdfReportBase/health';

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
  
  /// Get common headers for all API requests with authentication
  static Map<String, String> getAuthHeaders() {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'X-API-Key': apiKey,
    };
  }
}
