/// Banglalink Applink API Configuration
///
/// This file contains configuration values for Banglalink API integration.
/// Replace the placeholder values with actual credentials provided by Banglalink.
///
/// SECURITY NOTE: In production, these values should be stored securely
/// (e.g., in environment variables or secure key storage) and NOT committed to version control.
library;

class BangalinkConfig {
  // ========== API CREDENTIALS ==========
  // TODO: Replace with actual values from Banglalink Applink portal

  /// Base URL for Banglalink Applink APIs
  /// Example: 'https://api.banglalink.com.bd' or 'https://applink.banglalink.com.bd'
  static const String apiBaseUrl = 'YOUR_API_BASE_URL_HERE';

  /// API Key provided by Banglalink
  static const String apiKey = 'YOUR_API_KEY_HERE';

  /// API Secret for authentication
  static const String apiSecret = 'YOUR_API_SECRET_HERE';

  /// Application ID assigned by Banglalink
  static const String appId = 'YOUR_APP_ID_HERE';

  /// Application Name
  static const String appName = 'Hishab';

  // ========== SUBSCRIPTION CONFIGURATION ==========

  /// Premium subscription plan ID
  static const String premiumPlanId = 'premium_daily';

  /// Daily subscription cost in BDT
  static const double dailySubscriptionCost = 2.0;

  /// Subscription renewal frequency in days
  static const int subscriptionRenewalDays = 1;

  // ========== SMS CONFIGURATION ==========

  /// Sender ID for SMS (usually app name or short code)
  static const String smsSenderId = 'Hishab';

  /// Maximum SMS length
  static const int maxSmsLength = 160;

  // ========== USSD CONFIGURATION ==========

  /// USSD short code prefix (if assigned by Banglalink)
  /// Example: '*123*45#' where 123 is the prefix
  static const String ussdShortCodePrefix = '*123*';

  /// USSD short code suffix
  static const String ussdShortCodeSuffix = '#';

  /// App-specific USSD code (middle part)
  /// Full code would be: *123*45# (where 45 is your app code)
  static const String ussdAppCode = '45';

  // ========== API ENDPOINTS ==========

  /// Subscription API version
  static const String subscriptionApiVersion = 'v1';

  /// CaaS API version
  static const String caasApiVersion = 'v1';

  /// SMS API version
  static const String smsApiVersion = 'v1';

  /// USSD API version
  static const String ussdApiVersion = 'v1';

  /// Downloadable API version
  static const String downloadableApiVersion = 'v1';

  // ========== TIMEOUT CONFIGURATION ==========

  /// API request timeout in seconds
  static const int apiTimeoutSeconds = 30;

  /// Maximum retry attempts for failed requests
  static const int maxRetryAttempts = 3;

  // ========== FEATURE FLAGS ==========

  /// Enable/disable subscription feature
  static const bool enableSubscription = true;

  /// Enable/disable CaaS payments
  static const bool enableCaas = true;

  /// Enable/disable SMS notifications
  static const bool enableSms = true;

  /// Enable/disable USSD access
  static const bool enableUssd = true;

  /// Enable/disable PDF report generation
  static const bool enablePdfReports = true;

  // ========== REWARD REDEMPTION CONFIGURATION ==========

  /// Data bundle sizes available for redemption (in MB)
  static const List<int> dataRedemptionSizes = [50, 100, 250, 500, 1024];

  /// Talk time minutes available for redemption
  static const List<int> talkTimeRedemptionSizes = [20, 50, 100, 200];

  /// Discount percentages available
  static const List<int> discountRedemptionPercentages = [10, 20, 30, 50];

  // ========== TESTING MODE ==========

  /// Enable test mode (uses mock responses instead of real API calls)
  static const bool testMode = true; // Set to false in production

  /// Test phone number for development
  static const String testPhoneNumber = '01312345678';

  // ========== HELPER METHODS ==========

  /// Get full USSD code
  static String getFullUssdCode() {
    return '$ussdShortCodePrefix$ussdAppCode$ussdShortCodeSuffix';
  }

  /// Check if all required credentials are configured
  static bool isConfigured() {
    return apiBaseUrl != 'YOUR_API_BASE_URL_HERE' &&
           apiKey != 'YOUR_API_KEY_HERE' &&
           apiSecret != 'YOUR_API_SECRET_HERE' &&
           appId != 'YOUR_APP_ID_HERE';
  }

  /// Get API endpoint URL
  static String getEndpoint(String endpoint) {
    return '$apiBaseUrl$endpoint';
  }

  /// Get common headers for API requests
  static Map<String, String> getCommonHeaders() {
    return {
      'Content-Type': 'application/json',
      'X-API-Key': apiKey,
      'X-App-Id': appId,
      'X-App-Name': appName,
    };
  }
}
