import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'package:projec/services/otp_service.dart';


class VerifyCodeScreen extends StatefulWidget {
  final String phoneNumber;
  final String generatedOtp; // The OTP that was generated

  const VerifyCodeScreen({
    Key? key, 
    required this.phoneNumber,
    required this.generatedOtp,
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
  int _countdown = 30;
  bool _canResend = false;
  String? _currentEnteredOtp;

  @override
  void initState() {
    super.initState();
    _startCountdown();
    _setupFocusNodes();
    print('Expected OTP for ${widget.phoneNumber}: ${widget.generatedOtp}'); // Debug
  }

  void _setupFocusNodes() {
    for (int i = 0; i < _focusNodes.length; i++) {
      _focusNodes[i].addListener(() {
        setState(() {});
      });
    }
  }

  void _onDigitChanged(String value, int index) {
    if (value.length == 1 && index < 5) {
      FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
    } else if (value.isEmpty && index > 0) {
      FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
    }

    if (_isAllFieldsFilled()) {
      setState(() {
        _currentEnteredOtp = _getEnteredOtp();
      });
      // Auto-verify after a short delay
      Future.delayed(Duration(milliseconds: 500), () {
        _verifyCode();
      });
    }
    setState(() {});
  }

  bool _isAllFieldsFilled() {
    return _controllers.every((controller) => controller.text.isNotEmpty);
  }

  String _getEnteredOtp() {
    return _controllers.map((controller) => controller.text).join();
  }

  void _startCountdown() {
    Future.delayed(Duration(seconds: 1), () {
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

  void _verifyCode() {
    if (!_isAllFieldsFilled()) return;
    
    final enteredOtp = _getEnteredOtp();
    
    // Verify using static method from OtpService
    final isCorrect = OtpService.verifyOtp(widget.phoneNumber, enteredOtp);
    
    if (!isCorrect && widget.generatedOtp != enteredOtp) {
      // OTP is incorrect
      _showErrorSnackbar();
      return;
    }

    setState(() {
      _isLoading = true;
    });

    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        _isLoading = false;
      });

      _showSuccessSnackbar();
      
      Future.delayed(Duration(milliseconds: 1500), () {
        if (mounted) {
          // Mark user as logged in (you can use shared preferences or provider later)
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
            (route) => false,
          );
        }
      });
    });
  }

  void _showSuccessSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text('Verification successful!'),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showErrorSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_rounded, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text('Invalid OTP. Please try again.'),
          ],
        ),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: Duration(seconds: 2),
      ),
    );
    
    // Clear fields after showing error
    _clearAllFields();
  }

  void _resendCode() {
    if (_canResend) {
      setState(() {
        _canResend = false;
        _countdown = 30;
        _clearAllFields();
      });
      _startCountdown();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.send_rounded, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text('New OTP: ${widget.generatedOtp}'), // Show the OTP
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  void _clearAllFields() {
    for (var controller in _controllers) {
      controller.clear();
    }
    FocusScope.of(context).requestFocus(_focusNodes[0]);
    setState(() {
      _currentEnteredOtp = null;
    });
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
                  // Modern Back button
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

                  // Modern Header
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Verify Your Number',
                        style: TextStyle(
                          fontSize: isSmallScreen
                              ? 24
                              : isLargeScreen
                              ? 32
                              : 28,
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
                            TextSpan(text: 'Enter the 6-digit code sent to\n'),
                            TextSpan(
                              text: widget.phoneNumber,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 8),
                      // Debug hint for testing
                      Text(
                        'Test OTP: ${widget.generatedOtp}',
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isSmallScreen ? 40 : 60),

                  // Modern PIN input field
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 8 : 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(6, (index) {
                        final isFocused = _focusNodes[index].hasFocus;
                        final hasValue = _controllers[index].text.isNotEmpty;

                        return Container(
                          width: isSmallScreen ? 42 : 48,
                          height: isSmallScreen ? 52 : 56,
                          decoration: BoxDecoration(
                            color: Colors.grey[900],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isFocused
                                  ? Colors.red
                                  : hasValue
                                  ? Colors.red.withOpacity(0.7)
                                  : Colors.grey[800]!,
                              width: isFocused ? 2 : 1.5,
                            ),
                            boxShadow: [
                              if (isFocused)
                                BoxShadow(
                                  color: Colors.red.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                            ],
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
                            decoration: InputDecoration(
                              counterText: "",
                              contentPadding: EdgeInsets.zero,
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                            ),
                            onChanged: (value) => _onDigitChanged(value, index),
                          ),
                        );
                      }),
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 20 : 24),

                  // Show entered OTP for debugging
                  if (_currentEnteredOtp != null)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Entered: $_currentEnteredOtp',
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 12,
                        ),
                      ),
                    ),

                  // Auto verification notice
                  AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    height: _isAllFieldsFilled()
                        ? (isSmallScreen ? 40 : 44)
                        : 0,
                    child: AnimatedOpacity(
                      opacity: _isAllFieldsFilled() ? 1.0 : 0.0,
                      duration: Duration(milliseconds: 300),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isSmallScreen ? 12 : 16,
                          vertical: isSmallScreen ? 8 : 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.red.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.auto_awesome_motion_rounded,
                              color: Colors.red,
                              size: isSmallScreen ? 14 : 16,
                            ),
                            SizedBox(width: isSmallScreen ? 6 : 8),
                            Text(
                              'Auto-verifying...',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: isSmallScreen ? 12 : 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 30 : 40),

                  // Verify button
                  SizedBox(
                    width: double.infinity,
                    height: isSmallScreen ? 50 : 56,
                    child: ElevatedButton(
                      onPressed: _isAllFieldsFilled() && !_isLoading
                          ? _verifyCode
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        shadowColor: Colors.red.withOpacity(0.3),
                      ),
                      child: _isLoading
                          ? SizedBox(
                              height: isSmallScreen ? 18 : 20,
                              width: isSmallScreen ? 18 : 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Verify & Continue',
                                  style: TextStyle(
                                    fontSize: isSmallScreen ? 15 : 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                SizedBox(width: isSmallScreen ? 6 : 8),
                                Icon(
                                  Icons.arrow_forward_rounded,
                                  size: isSmallScreen ? 18 : 20,
                                ),
                              ],
                            ),
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 24 : 32),

                  // Resend code section
                  Column(
                    children: [
                      Text(
                        "Didn't receive the code?",
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: isSmallScreen ? 13 : 14,
                        ),
                      ),
                      SizedBox(height: isSmallScreen ? 10 : 12),
                      GestureDetector(
                        onTap: _canResend ? _resendCode : null,
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 200),
                          padding: EdgeInsets.symmetric(
                            horizontal: isSmallScreen ? 16 : 20,
                            vertical: isSmallScreen ? 10 : 12,
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
                                color: _canResend
                                    ? Colors.red
                                    : Colors.grey[600],
                                size: isSmallScreen ? 14 : 16,
                              ),
                              SizedBox(width: isSmallScreen ? 6 : 8),
                              Text(
                                _canResend
                                    ? 'Resend Code'
                                    : 'Resend in $_countdown',
                                style: TextStyle(
                                  color: _canResend
                                      ? Colors.red
                                      : Colors.grey[600],
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

                  Spacer(),

                  // Removed Account Security section
                  SizedBox(height: isSmallScreen ? 20 : 32),
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