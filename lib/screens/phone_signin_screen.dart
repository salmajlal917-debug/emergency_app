import 'package:flutter/material.dart';
import 'verify_code_screen.dart';
import 'package:projec/services/user_service.dart'; // Add this import
import 'package:projec/services/otp_service.dart'; // Add this import

class PhoneSignInScreen extends StatefulWidget {
  @override
  _PhoneSignInScreenState createState() => _PhoneSignInScreenState();
}

class _PhoneSignInScreenState extends State<PhoneSignInScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String _selectedCountryCode = '+964'; // Default to Iraq
  bool _isCountryPickerOpen = false;
  
  // Store generated OTPs for verification (phone -> OTP)
  // Moved to OtpService

  // Country codes with flags and names
  final List<Map<String, String>> _countries = [
    {'code': '+964', 'flag': '🇮🇶', 'name': 'Iraq'},
    {'code': '+1', 'flag': '🇺🇸', 'name': 'United States'},
    {'code': '+44', 'flag': '🇬🇧', 'name': 'United Kingdom'},
    {'code': '+49', 'flag': '🇩🇪', 'name': 'Germany'},
    {'code': '+33', 'flag': '🇫🇷', 'name': 'France'},
    {'code': '+39', 'flag': '🇮🇹', 'name': 'Italy'},
    {'code': '+34', 'flag': '🇪🇸', 'name': 'Spain'},
    {'code': '+971', 'flag': '🇦🇪', 'name': 'UAE'},
    {'code': '+966', 'flag': '🇸🇦', 'name': 'Saudi Arabia'},
    {'code': '+20', 'flag': '🇪🇬', 'name': 'Egypt'},
    {'code': '+90', 'flag': '🇹🇷', 'name': 'Turkey'},
    {'code': '+98', 'flag': '🇮🇷', 'name': 'Iran'},
    {'code': '+962', 'flag': '🇯🇴', 'name': 'Jordan'},
    {'code': '+963', 'flag': '🇸🇾', 'name': 'Syria'},
    {'code': '+961', 'flag': '🇱🇧', 'name': 'Lebanon'},
  ];

  // Generate a 6-digit random OTP
  String _generateOtp() {
    final random = DateTime.now().millisecondsSinceEpoch.toString();
    final otp = (int.parse(random.substring(random.length - 6)) % 900000 + 100000).toString();
    return otp;
  }

  void _submitPhoneNumber() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Generate OTP
      final phoneNumber = _selectedCountryCode + _phoneController.text;
      final otp = _generateOtp();
      
      // Store OTP for verification
      OtpService.storeOtp(phoneNumber, otp);
      
      print('Generated OTP for $phoneNumber: $otp'); // For debugging

      // Simulate API call
      Future.delayed(Duration(seconds: 1), () {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          
          // Show OTP in dialog
          _showOtpDialog(phoneNumber, otp);
        }
      });
    }
  }

  void _showOtpDialog(String phoneNumber, String otp) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Theme(
        data: ThemeData.dark(),
        child: AlertDialog(
          backgroundColor: Color(0xFF1A1A1A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.lock_rounded, color: Colors.red, size: 24),
              ),
              SizedBox(width: 12),
              Text(
                'Mock OTP Generated',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'For testing purposes, use this OTP:',
                style: TextStyle(color: Colors.grey[400]),
              ),
              SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red),
                ),
                child: Center(
                  child: Text(
                    otp,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 5,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 8),
              Text(
                'This is a mock OTP for testing only.',
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('CLOSE', style: TextStyle(color: Colors.grey[400])),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // Save phone number before navigating
                UserService.saveUserPhone(phoneNumber);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VerifyCodeScreen(
                      phoneNumber: phoneNumber,
                      generatedOtp: otp,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: Text('CONTINUE'),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleCountryPicker() {
    setState(() {
      _isCountryPickerOpen = !_isCountryPickerOpen;
    });
  }

  void _selectCountry(String code) {
    setState(() {
      _selectedCountryCode = code;
      _isCountryPickerOpen = false;
    });
  }

  String get _selectedCountryFlag {
    return _countries.firstWhere(
      (country) => country['code'] == _selectedCountryCode,
      orElse: () => {'flag': '🇺🇸', 'name': ''},
    )['flag']!;
  }

  String get _selectedCountryName {
    return _countries.firstWhere(
      (country) => country['code'] == _selectedCountryCode,
      orElse: () => {'name': 'Unknown'},
    )['name']!;
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
                  // Responsive Back button
                  Container(
                    width: isSmallScreen ? 36 : 40,
                    height: isSmallScreen ? 36 : 40,
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey[800]!),
                    ),
                    child: IconButton(
                      onPressed: () => Navigator.maybePop(context),
                      icon: Icon(
                        Icons.arrow_back_ios_rounded,
                        color: Colors.white,
                        size: isSmallScreen ? 14 : 16,
                      ),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 24 : 40),

                  // Responsive Header
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome to SafeGuard',
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
                      SizedBox(height: isSmallScreen ? 6 : 8),
                      Text(
                        'Enter your phone number to secure your account',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 14 : 16,
                          color: Colors.grey[400],
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isSmallScreen ? 40 : 60),

                  // Phone input form
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Country Code Selector
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[900],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[800]!),
                          ),
                          child: Column(
                            children: [
                              // Country selector header
                              ListTile(
                                onTap: _toggleCountryPicker,
                                leading: Container(
                                  width: isSmallScreen ? 28 : 32,
                                  height: isSmallScreen ? 28 : 32,
                                  decoration: BoxDecoration(
                                    color: Colors.red.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Center(
                                    child: Text(
                                      _selectedCountryFlag,
                                      style: TextStyle(
                                        fontSize: isSmallScreen ? 14 : 16,
                                      ),
                                    ),
                                  ),
                                ),
                                title: Text(
                                  _selectedCountryName,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: isSmallScreen ? 14 : 16,
                                  ),
                                ),
                                subtitle: Text(
                                  _selectedCountryCode,
                                  style: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: isSmallScreen ? 12 : 14,
                                  ),
                                ),
                                trailing: Icon(
                                  _isCountryPickerOpen
                                      ? Icons.keyboard_arrow_up_rounded
                                      : Icons.keyboard_arrow_down_rounded,
                                  color: Colors.red,
                                  size: isSmallScreen ? 18 : 20,
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: isSmallScreen ? 12 : 16,
                                  vertical: isSmallScreen ? 8 : 12,
                                ),
                                minLeadingWidth: isSmallScreen ? 32 : 40,
                              ),

                              // Country list - SMALLER CONTAINER
                              if (_isCountryPickerOpen)
                                Container(
                                  height: isSmallScreen
                                      ? 120
                                      : 150, // Reduced height
                                  decoration: BoxDecoration(
                                    color: Colors.grey[850],
                                    borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(12),
                                      bottomRight: Radius.circular(12),
                                    ),
                                  ),
                                  child: ListView.builder(
                                    padding: EdgeInsets.zero,
                                    itemCount: _countries.length,
                                    itemBuilder: (context, index) {
                                      final country = _countries[index];
                                      return ListTile(
                                        onTap: () =>
                                            _selectCountry(country['code']!),
                                        leading: Container(
                                          width: isSmallScreen
                                              ? 24
                                              : 28, // Smaller
                                          height: isSmallScreen
                                              ? 24
                                              : 28, // Smaller
                                          decoration: BoxDecoration(
                                            color: Colors.red.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(
                                              6, // Smaller radius
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              country['flag']!,
                                              style: TextStyle(
                                                fontSize: isSmallScreen
                                                    ? 12
                                                    : 14, // Smaller font
                                              ),
                                            ),
                                          ),
                                        ),
                                        title: Text(
                                          country['name']!,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: isSmallScreen
                                                ? 12
                                                : 13, // Smaller font
                                          ),
                                        ),
                                        trailing: Text(
                                          country['code']!,
                                          style: TextStyle(
                                            color: Colors.grey[400],
                                            fontSize: isSmallScreen
                                                ? 11
                                                : 12, // Smaller font
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: isSmallScreen
                                              ? 10
                                              : 14, // Reduced padding
                                          vertical: isSmallScreen
                                              ? 6
                                              : 8, // Reduced padding
                                        ),
                                        minLeadingWidth: isSmallScreen
                                            ? 28
                                            : 32, // Reduced width
                                        minVerticalPadding:
                                            8, // Reduced padding
                                      );
                                    },
                                  ),
                                ),
                            ],
                          ),
                        ),
                        SizedBox(height: isSmallScreen ? 12 : 16),

                        // Phone number input
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[900],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[800]!),
                          ),
                          child: TextFormField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isSmallScreen ? 14 : 16,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Enter your phone number',
                              hintStyle: TextStyle(
                                color: Colors.grey[500],
                                fontSize: isSmallScreen ? 14 : 16,
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: isSmallScreen ? 12 : 16,
                                vertical: isSmallScreen ? 14 : 18,
                              ),
                              prefix: Padding(
                                padding: EdgeInsets.only(right: 8),
                                child: Text(
                                  '$_selectedCountryCode',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.w600,
                                    fontSize: isSmallScreen ? 14 : 16,
                                  ),
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your phone number';
                              }
                              if (value.length < 8) {
                                return 'Please enter a valid phone number';
                              }
                              return null;
                            },
                          ),
                        ),
                        SizedBox(height: isSmallScreen ? 20 : 24),

                        // Terms text
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: isSmallScreen ? 8 : 0,
                          ),
                          child: Text(
                            'By continuing, you agree to our Terms of Service and Privacy Policy',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: isSmallScreen ? 11 : 12,
                              height: 1.4,
                            ),
                          ),
                        ),
                        SizedBox(height: isSmallScreen ? 30 : 40),

                        // Continue button
                        SizedBox(
                          width: double.infinity,
                          height: isSmallScreen ? 50 : 56,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _submitPhoneNumber,
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
                                    height: 20,
                                    width: 20,
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
                                        'Continue',
                                        style: TextStyle(
                                          fontSize: isSmallScreen ? 15 : 16,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Icon(
                                        Icons.arrow_forward_rounded,
                                        size: isSmallScreen ? 18 : 20,
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Spacer(),

                  // Emergency notice removed from here
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
    _phoneController.dispose();
    super.dispose();
  }
}