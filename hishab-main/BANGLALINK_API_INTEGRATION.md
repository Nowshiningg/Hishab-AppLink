# Banglalink AppLink API Integration Guide

## Overview

This document explains the integration of Banglalink AppLink APIs with the Hishab expense tracking app. The integration provides premium features through operator billing and enhances user engagement through multiple channels.

## Architecture

### API Services Structure

```
lib/
├── config/
│   └── api_config.dart              # API configuration and endpoints
├── models/
│   ├── subscription.dart            # Subscription data models
│   └── transaction.dart             # Transaction data models
└── services/
    ├── subscription_api_service.dart    # Subscription API client
    ├── caas_api_service.dart           # CaaS API client
    ├── sms_api_service.dart            # SMS API client
    ├── ussd_api_service.dart           # USSD API client
    ├── download_api_service.dart        # Download API client
    └── banglalink_integration_service.dart  # Unified API interface
```

## API Implementations

### 1. Subscription API

**Purpose**: Enable daily premium subscription (2 BDT/day) without cards or digital wallets

**Features**:
- Subscribe to premium plan
- Unsubscribe from plan
- Check subscription status
- Auto-renewal billing

**Implementation**:
```dart
// Initialize service
final blService = BanglalinkIntegrationService();
blService.initialize(
  userId: 'USER_ID',
  phoneNumber: '01912345678',
);

// Subscribe to premium
try {
  final subscription = await blService.subscribeToPremium();
  print('Subscribed! Features: ${subscription?.features}');
} catch (e) {
  print('Subscription failed: $e');
}

// Check subscription status
final isSubscribed = await blService.isPremiumSubscriber();
if (isSubscribed) {
  // Unlock premium features
}
```

**Premium Features Unlocked**:
- Cloud sync
- Advanced analytics
- Rewards redemption
- Smart assistant (AI chatbot)

### 2. CaaS (Charging-as-a-Service) API

**Purpose**: Enable micro-payments for specific premium actions

**Features**:
- PDF export charging
- Cloud storage purchase
- One-time feature purchases

**Implementation**:
```dart
// Charge for PDF export
try {
  final transaction = await blService.chargePdfExport(
    reportType: 'monthly_summary',
  );
  
  if (transaction?.isCompleted == true) {
    // Generate and download PDF
  }
} catch (e) {
  print('Payment failed: $e');
}

// Purchase cloud storage
final transaction = await blService.chargeCloudStorage(
  storageAmountGB: 5,
);

// Get transaction history
final history = await blService.getTransactionHistory(limit: 20);
print('Total charged: ${history?.totalCharged} BDT');
```

**Charge Types**:
- `pdf_export`: Export monthly reports
- `cloud_storage`: Purchase additional cloud storage
- `one_time_feature`: Buy individual premium features

### 3. SMS API

**Purpose**: Deliver transactional alerts and reminders

**Features**:
- OTP delivery
- Monthly summary SMS
- Budget alerts
- Custom notifications

**Implementation**:
```dart
// Send OTP
final otpData = await blService.sendOtp();
final requestId = otpData?['requestId'];

// Verify OTP
final isValid = await blService.verifyOtp(
  requestId: requestId!,
  otp: '123456',
);

// Send monthly summary
final summaryData = {
  'month': 'December',
  'totalExpense': 15000,
  'totalIncome': 30000,
  'savings': 15000,
  'topCategory': 'Food',
};

await blService.sendMonthlySummarySms(
  summaryData: summaryData,
);

// Send budget alert
await blService.sendBudgetAlertSms(
  alertMessage: 'Warning! You have exceeded 80% of your monthly budget.',
);
```

**Use Cases**:
- OTP verification for secure login when internet unavailable
- End-of-month expense summaries
- Budget threshold alerts
- Payment confirmations

### 4. USSD API

**Purpose**: Provide accessibility for users with limited internet or feature phones

**Features**:
- Quick expense summary
- Reward points check
- USSD menu navigation

**Implementation**:
```dart
// Get today's expenses via USSD
final summary = await blService.getUssdExpenseSummary(
  period: 'today',
);
print(summary); // "Today: 500 BDT spent. Daily limit: 1000 BDT"

// Handle USSD session
final response = await blService.handleUssdSession(
  sessionId: 'SESSION_123',
  input: '1', // User selected option 1
);
```

**USSD Menu Structure**:
```
*12345#
1. Today's expenses
2. This week's expenses
3. This month's expenses
4. Check rewards
5. Premium status
```

### 5. Downloadable API

**Purpose**: Allow users to download app APK

**Features**:
- Get APK information
- Download latest APK
- Check for updates

**Implementation**:
```dart
// Check if update available
final currentVersion = '1.0.0';
final updateAvailable = await blService.isUpdateAvailable(
  currentVersion: currentVersion,
);

if (updateAvailable) {
  // Get APK info
  final info = await blService.getApkInfo();
  print('Latest version: ${info?['version']}');
  print('Size: ${info?['size']} MB');
  
  // Download APK
  await blService.downloadApk(
    onProgress: (progress) {
      print('Download progress: ${(progress * 100).toStringAsFixed(0)}%');
    },
  );
}

// Get direct download URL
final downloadUrl = blService.getApkDownloadUrl();
```

## Integration Flow

### 1. App Initialization
```dart
// In main.dart or app initialization
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Get user data
  final prefs = await SharedPreferences.getInstance();
  final userId = prefs.getString('userId');
  final phoneNumber = prefs.getString('phoneNumber');
  
  if (userId != null && phoneNumber != null) {
    BanglalinkIntegrationService().initialize(
      userId: userId,
      phoneNumber: phoneNumber,
    );
  }
  
  runApp(MyApp());
}
```

### 2. Premium Subscription Flow
```dart
// Premium subscription screen
class PremiumSubscriptionScreen extends StatefulWidget {
  @override
  _PremiumSubscriptionScreenState createState() => _PremiumSubscriptionScreenState();
}

class _PremiumSubscriptionScreenState extends State<PremiumSubscriptionScreen> {
  final _blService = BanglalinkIntegrationService();
  bool _isLoading = false;
  
  Future<void> _subscribe() async {
    setState(() => _isLoading = true);
    
    try {
      final subscription = await _blService.subscribeToPremium();
      
      if (subscription != null && subscription.isActive) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Successfully subscribed to Premium!')),
        );
        
        // Update UI to show premium features
        Navigator.pop(context, true);
      }
    } catch (e) {
      // Show error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Subscription failed: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Go Premium')),
      body: Column(
        children: [
          Text('Premium Features:'),
          ListTile(
            leading: Icon(Icons.cloud),
            title: Text('Cloud Sync'),
          ),
          ListTile(
            leading: Icon(Icons.analytics),
            title: Text('Advanced Analytics'),
          ),
          ListTile(
            leading: Icon(Icons.star),
            title: Text('Rewards Redemption'),
          ),
          ListTile(
            leading: Icon(Icons.smart_toy),
            title: Text('Smart Assistant'),
          ),
          SizedBox(height: 20),
          Text('Only 2 BDT/day', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _isLoading ? null : _subscribe,
            child: _isLoading
                ? CircularProgressIndicator()
                : Text('Subscribe Now'),
          ),
        ],
      ),
    );
  }
}
```

### 3. PDF Export with Payment
```dart
Future<void> _exportPdf() async {
  final _blService = BanglalinkIntegrationService();
  
  // Check if user is subscribed
  final isSubscribed = await _blService.isPremiumSubscriber();
  
  if (isSubscribed) {
    // Free for premium users
    await _generatePdf();
  } else {
    // Charge non-premium users
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Export PDF'),
        content: Text('This will cost 5 BDT. Continue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              
              try {
                final transaction = await _blService.chargePdfExport(
                  reportType: 'monthly_report',
                );
                
                if (transaction?.isCompleted == true) {
                  await _generatePdf();
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Payment failed: $e')),
                );
              }
            },
            child: Text('Pay & Export'),
          ),
        ],
      ),
    );
  }
}
```

## Configuration

### Update API Base URL

Edit `lib/config/api_config.dart`:

```dart
class ApiConfig {
  // For development (local backend)
  static const String baseUrl = 'http://localhost:3001';
  
  // For production (deployed backend)
  // static const String baseUrl = 'https://your-backend-url.vercel.app';
  
  // ... rest of the configuration
}
```

### Environment-specific Configuration

For different environments, you can use:

```dart
class ApiConfig {
  static String get baseUrl {
    const environment = String.fromEnvironment('ENV', defaultValue: 'development');
    
    switch (environment) {
      case 'production':
        return 'https://api.hishab.com';
      case 'staging':
        return 'https://staging-api.hishab.com';
      default:
        return 'http://localhost:3001';
    }
  }
}
```

## Testing

### Unit Tests

```dart
// test/services/subscription_api_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:hishab/services/subscription_api_service.dart';

void main() {
  group('SubscriptionApiService', () {
    test('should subscribe user successfully', () async {
      // Mock API response
      final subscription = await SubscriptionApiService.subscribe(
        phoneNumber: '01912345678',
        userId: 'TEST_USER',
      );
      
      expect(subscription, isNotNull);
      expect(subscription?.status, equals('active'));
    });
  });
}
```

## Error Handling

All API services throw exceptions with descriptive messages:

```dart
try {
  await blService.subscribeToPremium();
} on Exception catch (e) {
  if (e.toString().contains('Insufficient balance')) {
    // Show balance low message
  } else if (e.toString().contains('Network error')) {
    // Show network error message
  } else {
    // Show generic error
  }
}
```

## Security Considerations

1. **API Keys**: Store securely, never commit to repository
2. **Phone Number Validation**: Always validate before API calls
3. **Transaction Verification**: Always verify transaction status before unlocking features
4. **OTP Expiry**: Implement OTP expiry on both client and server

## Backend Connection

The backend is located at: `d:\Sofftawer\FlutterInstall\BatteryLow\Applink\hishab-backend`

To start the backend:
```bash
cd d:\Sofftawer\FlutterInstall\BatteryLow\Applink\hishab-backend
npm install
npm start
```

Server runs on: http://localhost:3001

## Summary

This integration provides:
- ✅ Premium subscription (2 BDT/day)
- ✅ Micro-payments for features
- ✅ SMS notifications and OTP
- ✅ USSD support for feature phones
- ✅ APK distribution

All APIs are integrated through a unified `BanglalinkIntegrationService` that provides a simple, consistent interface for all Banglalink AppLink features.
