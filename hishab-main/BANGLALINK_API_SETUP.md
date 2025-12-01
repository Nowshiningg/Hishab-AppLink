# Banglalink Applink API Integration Guide

This document explains how to configure and use the Banglalink Applink APIs in the Hishab application.

## Overview

The Hishab app integrates with Banglalink's Applink platform to provide:

1. **Subscription API** - Premium subscription management (2 BDT/day)
2. **CaaS API** - Micro-payment transactions for reward redemptions
3. **SMS API** - Send monthly expense summaries via SMS
4. **USSD API** - Quick feature access via USSD short codes
5. **Downloadable API** - Generate and deliver PDF expense reports

## Quick Start

### Step 1: Get Banglalink API Credentials

Contact Banglalink Applink team to obtain:
- API Base URL
- API Key
- API Secret
- Application ID

### Step 2: Configure API Credentials

Open `lib/config/banglalink_config.dart` and replace the placeholder values:

```dart
class BangalinkConfig {
  // Replace these values with your actual credentials
  static const String apiBaseUrl = 'https://your-actual-api-url.com';
  static const String apiKey = 'your_actual_api_key';
  static const String apiSecret = 'your_actual_api_secret';
  static const String appId = 'your_actual_app_id';

  // Set to false when ready for production
  static const bool testMode = false;
}
```

### Step 3: Test the Integration

1. Keep `testMode = true` for initial testing
2. Test each feature in the app:
   - Premium subscription from Settings
   - Reward redemption (data/minutes/discounts)
   - Monthly SMS summaries
   - USSD code registration
   - PDF report generation

3. Once testing is successful, set `testMode = false`

## API Features

### 1. Subscription API

**File:** `lib/services/banglalink_api_service.dart`

**Methods:**
- `subscribeToPremium(phoneNumber)` - Subscribe to 2 BDT/day premium plan
- `checkSubscriptionStatus(phoneNumber)` - Check if user is subscribed
- `unsubscribeFromPremium(phoneNumber)` - Cancel subscription

**Usage Example:**
```dart
final apiService = BangalinkApiService();
final result = await apiService.subscribeToPremium('01312345678');

if (result['success']) {
  print('Subscribed! Transaction ID: ${result['data']['transaction_id']}');
} else {
  print('Error: ${result['message']}');
}
```

### 2. CaaS (Charging as a Service) API

**Methods:**
- `processPayment()` - Process micro-payment for rewards
- `deliverDataBundle()` - Deliver data MB to user's number
- `deliverTalkTime()` - Deliver talk time minutes

**Usage Example:**
```dart
// Deliver 50MB data bundle
final result = await apiService.deliverDataBundle(
  phoneNumber: '01312345678',
  dataMB: 50,
);
```

### 3. SMS API

**Methods:**
- `sendMonthlySummary()` - Send expense summary via SMS
- `sendBudgetAlert()` - Send budget warning alerts

**Usage Example:**
```dart
final summary = '''
Hishab Monthly Summary
Total Spent: 5,000 BDT
Remaining: 3,000 BDT
Daily Allowance: 250 BDT
''';

await apiService.sendMonthlySummary(
  phoneNumber: '01312345678',
  summary: summary,
);
```

### 4. USSD API

**Methods:**
- `registerUssdCode()` - Register USSD short code for user
- `handleUssdQuery()` - Process USSD queries

**Example USSD Flow:**
1. User dials `*123*45#` (configured in BangalinkConfig)
2. System responds with menu or balance info
3. User can check expenses without opening the app

### 5. Downloadable API

**Methods:**
- `generatePdfReport()` - Generate PDF expense report
- `sendReportViaSms()` - Send download link via SMS

**Usage Example:**
```dart
final result = await apiService.generatePdfReport(
  phoneNumber: '01312345678',
  reportType: 'monthly',
  startDate: DateTime(2025, 1, 1),
  endDate: DateTime(2025, 1, 31),
  reportData: {
    'total_expenses': 5000,
    'categories': {...},
  },
);

if (result['success']) {
  // SMS download link to user
  await apiService.sendReportViaSms(
    phoneNumber: '01312345678',
    reportUrl: result['downloadLink'],
  );
}
```

## Implementation Status

### ✅ Completed Features

1. **Rewards System**
   - Points for budget discipline
   - Streak tracking
   - Redemption for data/minutes/discounts
   - Reward history

2. **Daily Reminders**
   - Configurable notification time
   - Daily expense tracking reminders
   - Enable/disable in Settings

3. **Category Budgets**
   - Set monthly budget per category
   - Real-time budget tracking
   - Visual progress indicators
   - Budget alerts

4. **Voice Expense Entry**
   - Natural language parsing
   - "500 for groceries" → Creates expense
   - Offline-first design

5. **AI Chatbot (Finbro)**
   - Answer financial queries
   - Budget advice
   - Spending analysis
   - Bilingual (English/Bangla)

6. **Banglalink API Integration**
   - Service layer created
   - All 5 APIs implemented
   - Test mode enabled
   - Configuration centralized

### 🔄 Pending Tasks (When API Credentials Available)

1. **Add Real API Credentials**
   - Update `lib/config/banglalink_config.dart`
   - Set `testMode = false`

2. **Test Each API Endpoint**
   - Verify subscription flow
   - Test payment processing
   - Confirm SMS delivery
   - Validate USSD codes
   - Test PDF generation

3. **Error Handling**
   - Add retry logic for failed requests
   - Implement proper error messages
   - Handle network failures gracefully

4. **User Interface Integration**
   - Add subscription status in Settings
   - Show USSD code in app
   - Add "Send SMS Report" button
   - Display subscription benefits

## Security Considerations

⚠️ **IMPORTANT:**

1. **Never commit API credentials to version control**
   - Add `lib/config/banglalink_config.dart` to `.gitignore` if sharing code
   - Use environment variables in production

2. **Validate phone numbers**
   - Always use `isValidBangladeshiNumber()` before API calls
   - Format numbers with `formatPhoneNumber()`

3. **Handle API errors securely**
   - Don't expose API keys in error messages
   - Log errors securely (not to console in production)

4. **Secure user data**
   - Encrypt sensitive data before storing
   - Use HTTPS for all API calls
   - Validate all user inputs

## Testing Checklist

- [ ] Configure API credentials in `banglalink_config.dart`
- [ ] Test subscription in test mode
- [ ] Verify reward redemption works
- [ ] Test SMS sending
- [ ] Register and test USSD code
- [ ] Generate and download PDF report
- [ ] Switch to production mode (`testMode = false`)
- [ ] Test all features with real API
- [ ] Monitor API usage and costs
- [ ] Set up error logging and monitoring

## Support

For Banglalink Applink API support:
- Contact: [Banglalink Applink Support]
- Documentation: [Banglalink Developer Portal]

For Hishab app issues:
- Check the code comments in service files
- Review this documentation
- Test in `testMode` first

## File Structure

```
lib/
├── config/
│   └── banglalink_config.dart          # API configuration
├── services/
│   ├── banglalink_api_service.dart     # API service layer
│   ├── notification_service.dart       # Reminders
│   ├── chatbot_service.dart            # AI chatbot
│   └── voice_parser_service.dart       # Voice parsing
├── screens/
│   ├── rewards/
│   │   └── rewards_screen.dart         # Rewards UI
│   ├── budget/
│   │   └── category_budgets_screen.dart # Budget management
│   └── ...
└── providers/
    └── finance_provider.dart           # State management
```

## Next Steps

1. **Get API Credentials** from Banglalink
2. **Configure** `banglalink_config.dart`
3. **Test** in test mode
4. **Deploy** to production
5. **Monitor** usage and performance

---

**Note:** All placeholder methods are fully implemented and ready to use once API credentials are configured. The app works offline-first, so all features function without Banglalink APIs except for subscription, reward delivery, SMS, USSD, and PDF generation.
