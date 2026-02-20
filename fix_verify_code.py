#!/usr/bin/env python3
import re

with open('lib/screens/verify_code_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# Check lines with old methods
lines = content.split('\n')
for i, line in enumerate(lines):
    if 'verifyOTPAndSignIn' in line or 'signUpWithPhone' in line:
        print(f"Line {i+1}: {line}")

print("\n" + "="*50 + "\n")

# Replace the entire if-else block
# Find from "if (widget.isSignUp)" to the matching "}"
new_code = '''    if (widget.isSignUp) {
  // Get the full name from shared preferences
  final prefs = await SharedPreferences.getInstance();
  final fullName = prefs.getString('temp_full_name') ?? '';

  // SIGN UP FLOW
  await AuthService.verifyOTPAndCreateAccount(
    verificationId: widget.verificationId,
    smsCode: enteredOtp,
    phone: widget.phoneNumber,
    password: widget.password,
    fullName: fullName,
    onSuccess: () {
      // Clear temp data
      final prefs = SharedPreferences.getInstance();
      prefs.then((p) => p.remove('temp_full_name'));
      _showSuccessAndNavigate();
    },
    onError: (error) {
      setState(() => _isLoading = false);
      _showErrorSnackbar(error);
    },
  );
} else {
      // SIGN IN FLOW - Verify OTP and sign in
      try {
        final credential = PhoneAuthProvider.credential(
          verificationId: widget.verificationId,
          smsCode: enteredOtp,
        );
        
        await FirebaseAuth.instance.signInWithCredential(credential);
        print('✅ Sign in successful via OTP');
        _showSuccessAndNavigate();
      } on FirebaseAuthException catch (e) {
        setState(() => _isLoading = false);
        if (e.code == 'invalid-verification-code') {
          _showErrorSnackbar('Invalid verification code. Please try again.');
        } else if (e.code == 'session-expired') {
          _showErrorSnackbar('Code expired. Please request a new one.');
        } else {
          _showErrorSnackbar('Sign in failed. Please try again.');
        }
      } catch (e) {
        setState(() => _isLoading = false);
        _showErrorSnackbar('Sign in failed. Please try again.');
      }
    }'''

# Use a broad regex pattern to match the entire if-else block
# This pattern looks for: if (widget.isSignUp) { ... } else { ... }
pattern = r'    if \(widget\.isSignUp\) \{[^}]*(?:\{[^}]*\}[^}]*)*\} else \{[^}]*(?:\{[^}]*\}[^}]*)*\n    \}'

# Try a simpler approach - replace specific problematic method calls
updated = False

# Replace verifyOTPAndSignIn in the first occurrence (sign-up flow)
old_signup_call = '''  // SIGN UP FLOW
  await AuthService.verifyOTPAndSignIn(
    verificationId: widget.verificationId,
    smsCode: enteredOtp,
    phone: widget.phoneNumber,
    password: widget.password,
    onSuccess: () {
      // Now create the account in Firestore
      AuthService.signUpWithPhone(
        fullName: fullName,
        phone: widget.phoneNumber,
        password: widget.password,
        onSuccess: () {
          // Clear temp data
          prefs.remove('temp_full_name');
          _showSuccessAndNavigate();
        },
        onError: (error) {
          setState(() => _isLoading = false);
          _showErrorSnackbar(error);
        },
      );
    },
    onError: (error) {
      setState(() => _isLoading = false);
      _showErrorSnackbar(error);
    },
  );'''

new_signup_call = '''  // SIGN UP FLOW
  await AuthService.verifyOTPAndCreateAccount(
    verificationId: widget.verificationId,
    smsCode: enteredOtp,
    phone: widget.phoneNumber,
    password: widget.password,
    fullName: fullName,
    onSuccess: () {
      // Clear temp data
      final prefs = SharedPreferences.getInstance();
      prefs.then((p) => p.remove('temp_full_name'));
      _showSuccessAndNavigate();
    },
    onError: (error) {
      setState(() => _isLoading = false);
      _showErrorSnackbar(error);
    },
  );'''

if old_signup_call in content:
    content = content.replace(old_signup_call, new_signup_call)
    updated = True
    print("✓ Replaced sign-up flow")

# Replace the sign-in flow
old_signin = '''      // SIGN IN FLOW
      await AuthService.verifyOTPAndSignIn(
        verificationId: widget.verificationId,
        smsCode: enteredOtp,
        phone: widget.phoneNumber,
        password: widget.password,
        onSuccess: () {
          _showSuccessAndNavigate();
        },
        onError: (error) {
          setState(() => _isLoading = false);
          _showErrorSnackbar(error);
        },
      );'''

new_signin = '''      // SIGN IN FLOW - Verify OTP and sign in
      try {
        final credential = PhoneAuthProvider.credential(
          verificationId: widget.verificationId,
          smsCode: enteredOtp,
        );
        
        await FirebaseAuth.instance.signInWithCredential(credential);
        print('✅ Sign in successful via OTP');
        _showSuccessAndNavigate();
      } on FirebaseAuthException catch (e) {
        setState(() => _isLoading = false);
        if (e.code == 'invalid-verification-code') {
          _showErrorSnackbar('Invalid verification code. Please try again.');
        } else if (e.code == 'session-expired') {
          _showErrorSnackbar('Code expired. Please request a new one.');
        } else {
          _showErrorSnackbar('Sign in failed. Please try again.');
        }
      } catch (e) {
        setState(() => _isLoading = false);
        _showErrorSnackbar('Sign in failed. Please try again.');
      }'''

if old_signin in content:
    content = content.replace(old_signin, new_signin)
    updated = True
    print("✓ Replaced sign-in flow")

if updated:
    with open('lib/screens/verify_code_screen.dart', 'w', encoding='utf-8') as f:
        f.write(content)
    print("\n✅ SUCCESS: File updated")
else:
    print("\n❌ FAILED: Could not find matching text blocks")
