# Authentication System Guide

## Overview
This app now uses phone-based JWT authentication instead of password-based authentication.

## API Endpoints
- **Backend URL**: `https://hishab-backend.onrender.com`
- **Registration**: `POST /dev/register`
- **Login**: `POST /dev/login`
- **PDF Generation**: `POST /api/pdf/generate` (requires JWT token)

## Authentication Flow

### Registration Flow
1. User enters phone number
2. OTP is sent to phone number
3. User verifies OTP
4. Backend registration is called with phone number only
5. JWT token is stored in SharedPreferences
6. User is redirected to Income Setup Screen

### Login Flow
1. User enters phone number (11 digits starting with "01")
2. Backend login is called with phone number only
3. JWT token is received and stored
4. User is redirected to Home Screen

### Guest Mode
- Users can skip login and continue as guest
- Premium features (like PDF reports) require authentication

## AuthService Methods

### `registerUser(String phoneNumber)`
- Registers a new user with phone number
- Stores JWT token, user ID, and phone number
- Returns: `Map<String, dynamic>` with success, data, and message

### `loginUser(String phoneNumber)`
- Authenticates user with phone number
- Stores JWT token, user ID, and phone number
- Returns: `Map<String, dynamic>` with success, data, and message

### `getToken()`
- Retrieves stored JWT token
- Returns: `Future<String?>` - null if not authenticated

### `isAuthenticated()`
- Checks if user is currently authenticated
- Returns: `Future<bool>`

### `getCurrentUser()`
- Retrieves current user data
- Returns: `Future<Map<String, dynamic>?>` with userId, phone, and token

### `logout()`
- Clears all authentication data
- Returns: `Future<void>`

## Storage Keys
The following keys are used in SharedPreferences:
- `jwt_token` - The JWT authentication token
- `user_id` - The user's ID from backend
- `user_phone` - The user's phone number
- `is_authenticated` - Boolean flag for authentication status

## API Request Format

### Registration Request
```json
{
  "phoneNumber": "01712345678"
}
```

### Registration Response
```json
{
  "success": true,
  "data": {
    "jwt_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "user_id": 123,
    "user_phone": "01712345678"
  },
  "message": "User registered successfully"
}
```

### Login Request
```json
{
  "phoneNumber": "01712345678"
}
```

### Login Response
```json
{
  "success": true,
  "data": {
    "jwt_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "user_id": 123,
    "user_phone": "01712345678"
  },
  "message": "Login successful"
}
```

## PDF Report Generation
- Requires user to be authenticated
- Automatically retrieves JWT token from AuthService
- If token is missing/invalid, redirects to login screen
- Token is sent in Authorization header: `Bearer {token}`

## Important Notes

1. **No Password Required**: Users login and register using only their phone number
2. **OTP Verification**: OTP is used during registration for phone verification
3. **Token Persistence**: JWT token is stored in SharedPreferences and persists across app restarts
4. **Automatic Login**: If a valid token exists, user can skip login
5. **Guest Mode**: Users can continue without authentication, but premium features require login

## Error Handling

### Common Errors
- **401 Unauthorized**: Invalid or expired JWT token → Redirect to login
- **Network Error**: Check internet connection
- **Invalid Phone**: Must be 11 digits starting with "01"

### Error Messages
All API errors are displayed to users via SnackBar with the backend message.

## Testing

### Test Registration
1. Open app → Skip onboarding
2. Navigate to Login Screen
3. Click "Register"
4. Enter phone number (e.g., 01712345678)
5. Click "Send OTP"
6. Enter OTP received (check console for demo OTP)
7. Click "Verify & Register"
8. Should receive success message and navigate to Income Setup

### Test Login
1. Open Login Screen
2. Enter registered phone number
3. Click "Login"
4. Should receive success message and navigate to Home

### Test PDF Generation
1. Login first
2. Navigate to Premium Features → PDF Reports
3. Click "Generate Report"
4. Should download PDF successfully with JWT token

## Migration Notes

### Files Modified
1. `lib/services/auth_service.dart` (NEW) - Centralized authentication service
2. `lib/screens/auth/login_screen.dart` - Removed password field, added phone-only login
3. `lib/screens/onboarding/registration_screen.dart` - Removed password fields, OTP then register
4. `lib/screens/premium/pdf_report_generation_screen.dart` - Uses real JWT token from AuthService

### Deprecated Services
- `UserRegistrationService` - Can be removed or updated to use phone/JWT flow
- Password-based authentication - No longer used

## Security Considerations

1. **JWT Storage**: Tokens are stored in SharedPreferences (not encrypted by default)
2. **Token Expiration**: Backend should implement token expiration and refresh
3. **HTTPS Only**: All API calls use HTTPS to encrypt data in transit
4. **Phone Validation**: Client-side validation for Bangladeshi phone numbers (01XXXXXXXXX)

## Future Enhancements

1. Add token refresh mechanism
2. Implement biometric authentication (fingerprint/face ID)
3. Add "Remember Me" option
4. Implement social login (Google, Facebook)
5. Add multi-device token management
6. Encrypt sensitive data in SharedPreferences
