# OTP Registration Flow - Visual Guide

## Registration Flow Timeline

### Step 1: User Enters Details
```
┌─────────────────────────────────────────┐
│        Create Your Account              │
├─────────────────────────────────────────┤
│                                         │
│  Full Name *                            │
│  [Mohammad Rahman____________]          │
│                                         │
│  Phone Number *                         │
│  [+880 01812345678___________]          │
│  Example: 01812345678                   │
│                                         │
│         [Send OTP Button]               │
│                                         │
│  By registering, you agree to...        │
└─────────────────────────────────────────┘
```

### Step 2: OTP Sent - Demo OTP Shown
```
┌─────────────────────────────────────────┐
│        Create Your Account              │
├─────────────────────────────────────────┤
│                                         │
│  Full Name *                            │
│  [Mohammad Rahman____________]          │
│  (disabled - already entered)           │
│                                         │
│  Phone Number *                         │
│  [+880 01812345678___________]          │
│  (disabled - already entered)           │
│                                         │
│ ✅ OTP sent to 01812345678             │
│ 📱 Demo OTP: 456789                     │
│    (shown for testing only)             │
│                                         │
│  Enter OTP *                            │
│  [  4  5  6  7  8  9  ]                 │
│                                         │
│  Expires in 285s              Resend    │
│                                         │
│  [Verify & Create Account]              │
│                                         │
└─────────────────────────────────────────┘
```

### Step 3: OTP Verified - Account Created
```
User navigates to: Income Setup Screen
↓
Welcome to income setup (optional)
Enter monthly income or skip
↓
Navigate to Home Screen
✅ Registration Complete
```

## Demo OTP Display (Testing)

The demo OTP is shown in the success message for **testing purposes only**:

```
Green Success Box:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ OTP sent to 01812345678
📱 Demo OTP: 456789 (shown for testing only)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**NOTE:** In production, remove this message. Real SMS will deliver OTP.

## OTP Input Field Details

```
┌─────────────────────────────────┐
│ Enter OTP *                     │
│ ┌─────────────────────────────┐ │
│ │ 🔒  456789                  │ │
│ └─────────────────────────────┘ │
│ Expires in 45s        Resend    │
└─────────────────────────────────┘

Features:
- Large font (24pt) for easy reading
- 6-digit input limit
- Center aligned
- Visual separator (large letter spacing)
- Shows expiry countdown
- Resend button enables when OTP expires
```

## Error Messages

### Invalid OTP
```
Red Error Box:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
❌ Invalid OTP. Please try again.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Expired OTP
```
Red Error Box:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
❌ OTP has expired. Please request a new one.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
(Resend button now enabled)
```

### Network Error
```
Red Error Box:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
❌ Error sending OTP: [error details]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## Button States & Behavior

### Initial State
```
┌────────────────────────────┐
│     Send OTP (enabled)     │
└────────────────────────────┘
- Click to send OTP
```

### Sending State
```
┌────────────────────────────┐
│   ⏳ (loading spinner)     │
└────────────────────────────┘
- Button disabled
- Shows spinner
```

### OTP Field Visible
```
┌─────────────────────────────┐
│ Verify & Create Account     │
│        (enabled)            │
└─────────────────────────────┘
- Button text changes
- Ready for verification
```

### Verifying State
```
┌─────────────────────────────┐
│   ⏳ (loading spinner)      │
│       (disabled)            │
└─────────────────────────────┘
- Button disabled during API call
```

## User Interaction Flow

```
START
  │
  ├─ User fills Name & Phone
  │  │
  │  ├─ Validation passes? ✅
  │  │  └─ Enable "Send OTP"
  │  │
  │  └─ Validation fails? ❌
  │     └─ Show error, disable button
  │
  ├─ User clicks "Send OTP"
  │  │
  │  ├─ Success? ✅
  │  │  ├─ Show success message
  │  │  ├─ Show demo OTP (testing)
  │  │  ├─ Show OTP input field
  │  │  └─ Start countdown timer
  │  │
  │  └─ Failure? ❌
  │     └─ Show error message
  │
  ├─ User enters OTP
  │  │
  │  ├─ User clicks "Verify & Create Account"
  │  │  │
  │  │  ├─ OTP valid? ✅
  │  │  │  ├─ Create account
  │  │  │  └─ Navigate to Income Setup
  │  │  │
  │  │  └─ OTP invalid? ❌
  │  │     └─ Show error, allow retry
  │  │
  │  ├─ OTP expired?
  │  │  └─ Enable "Resend" button
  │  │
  │  └─ User clicks "Resend"
  │     └─ Generate new OTP, restart
  │
  └─ END
```

## Console Logs (Debug Output)

When testing, check console for these logs:

```
🔐 OTP Generated (DEMO): 456789 (Expires in 300 seconds)
✅ OTP sent via Banglalink SMS API
✅ User data sent to backend successfully
```

Or if API not connected:

```
🔐 OTP Generated (DEMO): 456789 (Expires in 300 seconds)
⚠️ Warning: Failed to send via Banglalink API: [error]
✅ OTP will work with local verification only
```

## Testing Checklist

- [ ] **Send OTP** - Click "Send OTP" with valid name & phone
  - [ ] Success message appears with demo OTP
  - [ ] OTP input field becomes visible
  - [ ] Countdown timer starts

- [ ] **Enter OTP** - Copy demo OTP from message, paste in field
  - [ ] OTP appears in input (masked display)
  - [ ] Button changes to "Verify & Create Account"

- [ ] **Verify OTP** - Click verification button
  - [ ] Loading spinner shows
  - [ ] Account created successfully
  - [ ] Redirected to Income Setup screen

- [ ] **Resend OTP** - Let OTP expire, click Resend
  - [ ] New OTP generated
  - [ ] New demo OTP shown
  - [ ] Timer resets to 300 seconds

- [ ] **Invalid OTP** - Enter wrong 6 digits
  - [ ] Error message: "Invalid OTP"
  - [ ] Can retry with correct OTP

- [ ] **Expired OTP** - Wait for timer to reach 0
  - [ ] Error message: "OTP has expired"
  - [ ] Resend button becomes enabled

## Demo OTP Format

```
Generated OTP: 456789

Range: 100000 - 999999
Length: 6 digits
Format: Numeric only (no letters)
Expiry: 300 seconds (5 minutes)
```

## Future - Production Setup

### To Remove Demo OTP Display:

1. Open `lib/screens/onboarding/registration_screen.dart`

2. In `_requestOtp()` method, change:
```dart
// From:
_successMessage = '✅ OTP sent to ${_phoneController.text.trim()}\n📱 Demo OTP: ${result['otp']} (shown for testing only)';

// To:
_successMessage = '✅ OTP sent successfully to ${_phoneController.text.trim()}';
```

3. In `_resendOtp()` method, change:
```dart
// From:
_successMessage = '✅ New OTP sent\n📱 Demo OTP: ${result['otp']}';

// To:
_successMessage = '✅ OTP resent successfully';
```

4. Ensure Banglalink SMS API is properly configured in `ApiConfig`

5. Test with real SMS delivery

---

**Demo Mode Status:** ✅ Active (for testing)
**Production Status:** 🔒 Ready (with above changes)
**Last Updated:** December 7, 2025
