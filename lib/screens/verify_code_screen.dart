import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:projec/services/auth_service.dart';
import 'package:projec/screens/home_screen.dart';

class VerifyCodeScreen extends StatefulWidget {
  final String phoneNumber;
  final String verificationId;
  final bool isSignUp;
  final String password;

  const VerifyCodeScreen({
    Key? key,
    required this.phoneNumber,
    required this.verificationId,
    required this.isSignUp,
    required this.password,
  }) : super(key: key);

  @override
  _VerifyCodeScreenState createState() => _VerifyCodeScreenState();
}

class _VerifyCodeScreenState extends State<VerifyCodeScreen> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  bool _isLoading = false;
  int _countdown = 60;
  bool _canResend = false;
  
  // Track if verification is already in progress
  bool _verificationInProgress = false;

  @override
  void initState() {
    super.initState();
    _startCountdown();
    
    // Add listeners to each controller for debugging
    for (int i = 0; i < _controllers.length; i++) {
      _controllers[i].addListener(() {
        // When all fields are filled, trigger verification
        if (_isAllFieldsFilled() && !_verificationInProgress) {
          _verifyCode();
        }
      });
    }
  }

  void _onDigitChanged(String value, int index) {
    if (value.length == 1 && index < 5) {
      FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
    } else if (value.isEmpty && index > 0) {
      FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
    }
    setState(() {});
  }

  bool _isAllFieldsFilled() {
    return _controllers.every((controller) => controller.text.isNotEmpty);
  }

  String _getEnteredOtp() {
    final otp = _controllers.map((controller) => controller.text).join();
    print('📝 Entered OTP: "$otp" (length: ${otp.length})');
    return otp;
  }

  void _startCountdown() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          if (_countdown > 0) {
            _countdown--;
            _startCountdown();
          } else {
            _canResend = true;
          }
        });
      }
    });
  }

  Future<void> _verifyCode() async {
    // Prevent multiple verification attempts
    if (_verificationInProgress) return;
    
    if (!_isAllFieldsFilled()) return;

    setState(() {
      _isLoading = true;
      _verificationInProgress = true;
    });

    final enteredOtp = _getEnteredOtp();
    
    // Debug: Print all details
    print('=' * 50);
    print('🔐 VERIFICATION ATTEMPT');
    print('📱 Phone: ${widget.phoneNumber}');
    print('🔑 Entered Code: "$enteredOtp"');
    print('🆔 Verification ID: ${widget.verificationId}');
    print('📝 Is Sign Up: ${widget.isSignUp}');
    print('=' * 50);

    if (widget.isSignUp) {
      final prefs = await SharedPreferences.getInstance();
      final fullName = prefs.getString('temp_full_name') ?? '';
      
      print('👤 Full Name from prefs: "$fullName"');

      await AuthService.verifyOTPAndCreateAccount(
        verificationId: widget.verificationId,
        smsCode: enteredOtp,
        phone: widget.phoneNumber,
        password: widget.password,
        fullName: fullName,
        onSuccess: () {
          print('✅ Verification successful!');
          prefs.remove('temp_full_name');
          prefs.remove('temp_password');
          if (mounted) {
            setState(() {
              _isLoading = false;
              _verificationInProgress = false;
            });
            _showSuccessAndNavigate();
          }
        },
        onError: (error) {
          print('❌ Verification error: $error');
          if (mounted) {
            setState(() {
              _isLoading = false;
              _verificationInProgress = false;
            });
            _showErrorSnackbar(error);
          }
        },
      );
    } else {
      // For sign in (if you ever need it)
      await AuthService.verifyOTPAndSignIn(
        verificationId: widget.verificationId,
        smsCode: enteredOtp,
        phone: widget.phoneNumber,
        onSuccess: () {
          print('✅ Sign in verification successful!');
          if (mounted) {
            setState(() {
              _isLoading = false;
              _verificationInProgress = false;
            });
            _showSuccessAndNavigate();
          }
        },
        onError: (error) {
          print('❌ Sign in verification error: $error');
          if (mounted) {
            setState(() {
              _isLoading = false;
              _verificationInProgress = false;
            });
            _showErrorSnackbar(error);
          }
        },
      );
    }
  }

  void _showSuccessAndNavigate() {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Verification successful!'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (route) => false,
        );
      }
    });
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
    _clearAllFields();
  }

  void _resendCode() {
    if (_canResend && !_verificationInProgress) {
      setState(() {
        _canResend = false;
        _countdown = 60;
        _clearAllFields();
        _isLoading = true;
        _verificationInProgress = true;
      });

      AuthService.resendOTP(
        phone: widget.phoneNumber,
        onCodeSent: (newVerificationId) {
          print('✅ New verification ID received: $newVerificationId');
          if (mounted) {
            setState(() {
              _isLoading = false;
              _verificationInProgress = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('OTP resent successfully'),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
            _startCountdown();
          }
        },
        onError: (error) {
          print('❌ Resend error: $error');
          if (mounted) {
            setState(() {
              _isLoading = false;
              _verificationInProgress = false;
            });
            _showErrorSnackbar(error);
          }
        },
      );
    }
  }

  void _clearAllFields() {
    for (var controller in _controllers) {
      controller.clear();
    }
    FocusScope.of(context).requestFocus(_focusNodes[0]);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 375;
    final isLargeScreen = size.width > 600;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: size.height - MediaQuery.of(context).padding.vertical,
            ),
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back button
                  Container(
                    width: isSmallScreen ? 36 : 40,
                    height: isSmallScreen ? 36 : 40,
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey[800]!),
                    ),
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.arrow_back_ios_rounded,
                        color: Colors.white,
                        size: isSmallScreen ? 14 : 16,
                      ),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 24 : 40),

                  // Header
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Verify Your Number',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 24 : isLargeScreen ? 32 : 28,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                      SizedBox(height: isSmallScreen ? 8 : 12),
                      RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: isSmallScreen ? 14 : 16,
                            color: Colors.grey[400],
                            height: 1.4,
                          ),
                          children: [
                            const TextSpan(text: 'Enter the 6-digit code sent to\n'),
                            TextSpan(
                              text: widget.phoneNumber,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Debug info - REMOVE AFTER TESTING
                      if (widget.phoneNumber.contains('756106290019'))
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.orange),
                            ),
                            child: const Text(
                              'Test Mode: Use code 123456',
                              style: TextStyle(color: Colors.orange, fontSize: 12),
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: isSmallScreen ? 40 : 60),

                  // PIN input
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 8 : 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(6, (index) {
                        return Container(
                          width: isSmallScreen ? 42 : 48,
                          height: isSmallScreen ? 52 : 56,
                          decoration: BoxDecoration(
                            color: Colors.grey[900],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _controllers[index].text.isNotEmpty
                                  ? Colors.red.withOpacity(0.7)
                                  : Colors.grey[800]!,
                            ),
                          ),
                          child: TextField(
                            controller: _controllers[index],
                            focusNode: _focusNodes[index],
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            maxLength: 1,
                            style: TextStyle(
                              fontSize: isSmallScreen ? 18 : 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                            decoration: const InputDecoration(
                              counterText: "",
                              border: InputBorder.none,
                            ),
                            onChanged: (value) => _onDigitChanged(value, index),
                          ),
                        );
                      }),
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 30 : 40),

                  // Verify button
                  SizedBox(
                    width: double.infinity,
                    height: isSmallScreen ? 50 : 56,
                    child: ElevatedButton(
                      onPressed: _isAllFieldsFilled() && !_isLoading ? _verifyCode : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Verify & Continue',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 24 : 32),

                  // Resend code
                  Center(
                    child: Column(
                      children: [
                        Text(
                          "Didn't receive the code?",
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: isSmallScreen ? 13 : 14,
                          ),
                        ),
                        const SizedBox(height: 10),
                        GestureDetector(
                          onTap: _canResend && !_isLoading ? _resendCode : null,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: _canResend
                                  ? Colors.red.withOpacity(0.1)
                                  : Colors.grey[900],
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: _canResend
                                    ? Colors.red.withOpacity(0.3)
                                    : Colors.grey[800]!,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.refresh_rounded,
                                  color: _canResend ? Colors.red : Colors.grey[600],
                                  size: isSmallScreen ? 14 : 16,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _canResend
                                      ? 'Resend Code'
                                      : 'Resend in $_countdown',
                                  style: TextStyle(
                                    color: _canResend ? Colors.red : Colors.grey[600],
                                    fontWeight: FontWeight.w600,
                                    fontSize: isSmallScreen ? 13 : 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }
}