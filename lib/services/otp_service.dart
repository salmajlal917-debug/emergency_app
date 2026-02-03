class OtpService {
  static final Map<String, String> _generatedOtps = {};

  static void storeOtp(String phoneNumber, String otp) {
    _generatedOtps[phoneNumber] = otp;
  }

  static bool verifyOtp(String phoneNumber, String enteredOtp) {
    final storedOtp = _generatedOtps[phoneNumber];
    return storedOtp == enteredOtp;
  }
}