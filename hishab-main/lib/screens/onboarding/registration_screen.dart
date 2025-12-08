import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/user_registration_service.dart';
import '../../services/otp_service.dart';
import 'income_setup_screen.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _isLoading = false;
  bool _showOtpField = false;
  bool _showPasswordFields = false;
  bool _showPassword = false;
  bool _showConfirmPassword = false;
  int _otpRemainingSeconds = 0;
  String? _errorMessage;
  String? _successMessage;

  final _registrationService = UserRegistrationService();
  final _otpService = OTPService();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _requestOtp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final result = await _otpService.sendOtp(
        phoneNumber: _phoneController.text.trim(),
        appUserId: 'temp_${_phoneController.text.trim()}',
      );

      if (!mounted) return;

      if (result['success'] == true) {
        setState(() {
          _showOtpField = true;
          _otpRemainingSeconds = result['expiresIn'] ?? 300;
          _successMessage = '✅ OTP sent to ${_phoneController.text.trim()}';
          _errorMessage = null;
        });
        print('📱 DEMO OTP: ${result['otp']}');
        _startOtpTimer();
      } else {
        setState(() {
          _errorMessage = result['message'] ?? 'Failed to send OTP';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _startOtpTimer() {
    Future.delayed(const Duration(seconds: 1)).then((_) {
      if (mounted && _otpRemainingSeconds > 0) {
        setState(() {
          _otpRemainingSeconds--;
        });
        if (_otpRemainingSeconds > 0) {
          _startOtpTimer();
        }
      }
    });
  }

  Future<void> _verifyOtp() async {
    if (_otpController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Please enter OTP';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final otpResult = await _otpService.verifyOtp(
        enteredOtp: _otpController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
      );

      if (!mounted) return;

      if (otpResult['success'] == true) {
        setState(() {
          _showPasswordFields = true;
          _successMessage = '✅ OTP verified! Now set your password.';
          _errorMessage = null;
        });
      } else {
        setState(() {
          _errorMessage = otpResult['message'] ?? 'OTP verification failed';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _registerUser() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _errorMessage = 'Passwords do not match';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final registerResult = await _registrationService.registerUser(
        name: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;

      if (registerResult['success'] == true) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('user_registered', true);

        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const IncomeSetupScreen()),
        );
      } else {
        setState(() {
          _errorMessage = registerResult['message'] ?? 'Registration failed';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _resendOtp() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _otpService.resendOtp(
        phoneNumber: _phoneController.text.trim(),
        appUserId: 'temp_${_phoneController.text.trim()}',
      );

      if (!mounted) return;

      if (result['success'] == true) {
        _otpController.clear();
        setState(() {
          _otpRemainingSeconds = result['expiresIn'] ?? 300;
          _successMessage = '✅ New OTP sent';
          _errorMessage = null;
        });
        print('📱 DEMO OTP: ${result['otp']}');
        _startOtpTimer();
      } else {
        setState(() {
          _errorMessage = result['message'] ?? 'Failed to resend OTP';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          colorScheme.primary.withValues(alpha: 0.2),
                          colorScheme.primary.withValues(alpha: 0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.primary.withValues(alpha: 0.15),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.person_add_alt_1,
                      size: 64,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Text(
                  'Create Your Account',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'We need a few details to get you started.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 40),

                if (_errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      border: Border.all(color: Colors.red.withValues(alpha: 0.5)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(color: Colors.red, fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (_errorMessage != null) const SizedBox(height: 20),

                if (_successMessage != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      border: Border.all(color: Colors.green.withValues(alpha: 0.5)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.check_circle_outline, color: Colors.green, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _successMessage!,
                            style: TextStyle(color: Colors.green[700], fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (_successMessage != null) const SizedBox(height: 20),

                if (!_showPasswordFields) ...[
                  Text('Full Name *', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _nameController,
                    enabled: !_isLoading && !_showOtpField,
                    decoration: InputDecoration(
                      hintText: 'e.g., Mohammad Rahman',
                      prefixIcon: Icon(Icons.person_outline, color: colorScheme.primary),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: colorScheme.primary, width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) return 'Please enter your name';
                      if (value.trim().length < 2) return 'Name must be at least 2 characters';
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  Text('Phone Number *', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _phoneController,
                    enabled: !_isLoading && !_showOtpField,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      hintText: '01xxxxxxxxx',
                      prefixIcon: Icon(Icons.phone_outlined, color: colorScheme.primary),
                      prefixText: '+880 ',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: colorScheme.primary, width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) return 'Please enter phone';
                      final cleanNumber = value.replaceAll(RegExp(r'\D'), '');
                      if (cleanNumber.length < 10) return 'Phone must be at least 10 digits';
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  if (_showOtpField) ...[
                    Text('Enter OTP *', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _otpController,
                      enabled: !_isLoading,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 8),
                      decoration: InputDecoration(
                        hintText: '000000',
                        counterText: '',
                        prefixIcon: Icon(Icons.security, color: colorScheme.primary),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: colorScheme.primary, width: 2),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _otpRemainingSeconds > 0 ? 'Expires in ${_otpRemainingSeconds}s' : 'OTP Expired',
                          style: TextStyle(fontSize: 12, color: _otpRemainingSeconds > 0 ? Colors.orange : Colors.red),
                        ),
                        TextButton(
                          onPressed: _otpRemainingSeconds <= 0 && !_isLoading ? _resendOtp : null,
                          child: Text(
                            _otpRemainingSeconds <= 0 ? 'Resend OTP' : 'Resend',
                            style: TextStyle(color: _otpRemainingSeconds <= 0 ? colorScheme.primary : Colors.grey),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ],

                if (_showPasswordFields) ...[
                  Text('Password *', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _passwordController,
                    enabled: !_isLoading,
                    obscureText: !_showPassword,
                    decoration: InputDecoration(
                      hintText: 'Min 8 characters',
                      prefixIcon: Icon(Icons.lock_outline, color: colorScheme.primary),
                      suffixIcon: IconButton(
                        icon: Icon(_showPassword ? Icons.visibility : Icons.visibility_off),
                        onPressed: () => setState(() => _showPassword = !_showPassword),
                      ),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: colorScheme.primary, width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Please enter password';
                      if (value.length < 8) return 'Min 8 characters required';
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  Text('Confirm Password *', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _confirmPasswordController,
                    enabled: !_isLoading,
                    obscureText: !_showConfirmPassword,
                    decoration: InputDecoration(
                      hintText: 'Re-enter password',
                      prefixIcon: Icon(Icons.lock_outline, color: colorScheme.primary),
                      suffixIcon: IconButton(
                        icon: Icon(_showConfirmPassword ? Icons.visibility : Icons.visibility_off),
                        onPressed: () => setState(() => _showConfirmPassword = !_showConfirmPassword),
                      ),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: colorScheme.primary, width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Please confirm password';
                      if (value != _passwordController.text) return 'Passwords do not match';
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                ],

                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.05),
                    border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue[600], size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Your information is securely stored.',
                          style: TextStyle(fontSize: 13, color: Colors.blue[700]),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : (_showPasswordFields
                            ? _registerUser
                            : (_showOtpField ? _verifyOtp : _requestOtp)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      disabledBackgroundColor: Colors.grey[300],
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isLoading
                        ? SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            _showPasswordFields
                                ? 'Create Account'
                                : (_showOtpField ? 'Verify OTP' : 'Send OTP'),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 20),

                Text(
                  'By registering, you agree to our Terms of Service.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
