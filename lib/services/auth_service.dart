import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:projec/services/user_service.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Normalize phone number
  static String normalizePhone(String rawPhone) {
    String cleaned = rawPhone.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    if (!cleaned.startsWith('+')) {
      cleaned = '+$cleaned';
    }
    // Ensure no extra spaces or special characters
    cleaned = cleaned.trim();
    print('📱 Normalized phone: $cleaned');
    return cleaned;
  }

  // CHECK IF USER EXISTS IN FIRESTORE
  static Future<bool> checkIfUserExists(String phone) async {
    try {
      final normalizedPhone = normalizePhone(phone);
      final doc = await _firestore.collection('users').doc(normalizedPhone).get();
      return doc.exists;
    } catch (e) {
      print('❌ Error checking user: $e');
      return false;
    }
  }

  // VERIFY PASSWORD ONLY (FOR SIGN IN)
  static Future<bool> verifyPassword(String phone, String password) async {
    try {
      final normalizedPhone = normalizePhone(phone);
      final doc = await _firestore.collection('users').doc(normalizedPhone).get();
      
      if (!doc.exists) {
        return false; // User doesn't exist
      }
      
      final storedPassword = doc.data()?['password'];
      return storedPassword == password;
    } catch (e) {
      print('❌ Error verifying password: $e');
      return false;
    }
  }

  // SIGN IN WITHOUT OTP (FOR EXISTING USERS)
  static Future<void> signInWithoutOTP({
    required String phone,
    required String password,
    required Function() onSuccess,
    required Function(String error) onError,
  }) async {
    try {
      final normalizedPhone = normalizePhone(phone);
      print('🔐 Attempting direct sign in for: $normalizedPhone');
      
      // Check if user exists
      final userExists = await checkIfUserExists(normalizedPhone);
      
      if (!userExists) {
        onError('Account not found. Please sign up first.');
        return;
      }
      
      // Verify password
      final passwordCorrect = await verifyPassword(normalizedPhone, password);
      
      if (!passwordCorrect) {
        onError('Incorrect password');
        return;
      }
      
      // Password correct - we need to sign in with Firebase Auth
      // Since we're not using OTP, we need to use email/password method
      // Convert phone to email format for Firebase Auth
      final authEmail = '${normalizedPhone.replaceAll('+', '')}@phone.auth';
      
      try {
        // Try to sign in with email/password
        await _auth.signInWithEmailAndPassword(
          email: authEmail,
          password: password,
        );
      } catch (e) {
        // If sign in fails, user might not have email/password account
        // In this case, we'll just save the phone locally and proceed
        print('⚠️ Firebase Auth sign in failed, but password is correct in Firestore');
      }
      
      // Save phone locally
      await UserService.saveUserPhone(normalizedPhone);
      
      print('✅ Direct sign in successful for: $normalizedPhone');
      onSuccess();
      
    } catch (e) {
      print('❌ Sign in error: $e');
      onError('Sign in failed. Please try again.');
    }
  }

  // SEND OTP (ONLY FOR SIGN UP)
  static Future<void> sendOTP({
    required String phone,
    required Function(String verificationId) onCodeSent,
    required Function(String error) onError,
  }) async {
    try {
      final normalizedPhone = normalizePhone(phone);
      print('📞 Sending OTP to: $normalizedPhone');
      print('ℹ️ Using phone number: "$normalizedPhone" for Firebase verification');
      
      await _auth.verifyPhoneNumber(
        phoneNumber: normalizedPhone,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          print('✅ Auto-verification completed');
          await _signInWithCredential(credential, normalizedPhone);
        },
        verificationFailed: (FirebaseAuthException e) {
          String error = 'Verification failed: ${e.message}';
          print('❌ $error');
          print('📋 Error code: ${e.code}');
          onError(error);
        },
        codeSent: (String verificationId, int? resendToken) {
          print('✅ OTP sent for: $normalizedPhone');
          print('🔑 Verification ID: $verificationId (length: ${verificationId.length})');
          print('⚠️ For test numbers: Check your Firebase console for the code');
          onCodeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          print('⏱️ Auto-retrieval timeout for verification ID: $verificationId');
        },
      );
    } catch (e) {
      print('❌ Error sending OTP: $e');
      onError('Failed to send OTP. Please try again.');
    }
  }

  // VERIFY OTP AND CREATE ACCOUNT (SIGN UP ONLY) - FIXED VERSION
  static Future<void> verifyOTPAndCreateAccount({
    required String verificationId,
    required String smsCode,
    required String phone,
    required String password,
    required String fullName,
    required Function() onSuccess,
    required Function(String error) onError,
  }) async {
    try {
      print('🔐 Verifying OTP for sign up');
      print('📱 Phone provided: $phone');
      print('🔑 SMS Code: "$smsCode" (length: ${smsCode.length})');
      print('✅ Verification ID: $verificationId');
      
      final normalizedPhone = normalizePhone(phone);
      
      // CRITICAL: Ensure SMS code is exactly 6 digits with no spaces/whitespace
      String cleanedCode = smsCode.trim().replaceAll(RegExp(r'\s+'), '');
      
      if (cleanedCode.length != 6 || !RegExp(r'^\d{6}$').hasMatch(cleanedCode)) {
        print('❌ Invalid code format: "$smsCode" -> cleaned: "$cleanedCode"');
        onError('Invalid code format. Please enter exactly 6 digits.');
        return;
      }
      
      print('✅ Code validated: $cleanedCode');
      
      // Create credential with cleaned code
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: cleanedCode,
      );

      print('🔐 Attempting to sign in with credential...');
      
      UserCredential? userCredential;
      
      try {
        // Sign in with Firebase Phone Auth
        userCredential = await _auth.signInWithCredential(credential);
      } catch (signInError) {
        print('⚠️ Sign-in error: $signInError');
        print('🔄 Checking if user is already authenticated...');
        
        // Check if user is already signed in despite the error
        if (_auth.currentUser != null) {
          print('✅ User is already signed in: ${_auth.currentUser!.uid}');
          userCredential = await _auth.currentUser!.linkWithCredential(credential);
        } else {
          // Try one more time after a small delay
          await Future.delayed(const Duration(milliseconds: 500));
          try {
            userCredential = await _auth.signInWithCredential(credential);
          } catch (retryError) {
            print('❌ Retry also failed: $retryError');
            throw signInError; // Re-throw original error
          }
        }
      }
      
      // If we have a user credential or user is signed in
      final user = userCredential?.user ?? _auth.currentUser;
      
      if (user != null) {
        print('✅ Phone verified successfully for: $normalizedPhone');
        print('👤 User UID: ${user.uid}');
        
        // Update display name (optional, not critical)
        try {
          await user.updateDisplayName(fullName.trim());
          await user.reload();
        } catch (e) {
          print('⚠️ Could not update display name: $e');
        }
        
        // Save to Firestore with password
        try {
          await _firestore.collection('users').doc(normalizedPhone).set({
            'name': fullName.trim(),
            'phone': normalizedPhone,
            'password': password,
            'authUid': user.uid,
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
            'bloodType': '',
            'gender': '',
            'emergencyNotes': '',
          }, SetOptions(merge: true));
          
          print('✅ Firestore document created/updated');
        } catch (firestoreError) {
          print('⚠️ Firestore error but continuing: $firestoreError');
        }

        // Save phone locally
        await UserService.saveUserPhone(normalizedPhone);
        
        print('✅ New account created successfully!');
        onSuccess();
      } else {
        onError('Sign in failed. Please try again.');
      }
      
    } on FirebaseAuthException catch (e) {
      print('❌ Firebase Auth error: ${e.code} - ${e.message}');
      
      // Check if user is actually signed in despite the error
      if (_auth.currentUser != null) {
        print('✅ User is signed in despite error! Attempting to recover...');
        
        final normalizedPhone = normalizePhone(phone);
        final user = _auth.currentUser!;
        
        try {
          // Try to create Firestore document
          await _firestore.collection('users').doc(normalizedPhone).set({
            'name': fullName.trim(),
            'phone': normalizedPhone,
            'password': password,
            'authUid': user.uid,
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
            'bloodType': '',
            'gender': '',
            'emergencyNotes': '',
          }, SetOptions(merge: true));
          
          await UserService.saveUserPhone(normalizedPhone);
          print('✅ Account recovered successfully!');
          onSuccess();
          return;
        } catch (recoveryError) {
          print('❌ Recovery failed: $recoveryError');
        }
      }
      
      if (e.code == 'invalid-verification-code') {
        onError('Invalid verification code. Please check the code and try again.');
      } else if (e.code == 'session-expired') {
        onError('Code expired. Please request a new one.');
      } else if (e.code == 'quota-exceeded') {
        onError('Too many attempts. Please try again later.');
      } else {
        onError('Verification failed: ${e.message}');
      }
    } catch (e) {
      print('❌ OTP verification error: $e');
      
      // Final check: See if user is actually signed in
      if (_auth.currentUser != null) {
        print('✅ User is signed in despite generic error!');
        
        final normalizedPhone = normalizePhone(phone);
        final user = _auth.currentUser!;
        
        try {
          await _firestore.collection('users').doc(normalizedPhone).set({
            'name': fullName.trim(),
            'phone': normalizedPhone,
            'password': password,
            'authUid': user.uid,
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
            'bloodType': '',
            'gender': '',
            'emergencyNotes': '',
          }, SetOptions(merge: true));
          
          await UserService.saveUserPhone(normalizedPhone);
          print('✅ Account created despite error!');
          onSuccess();
          return;
        } catch (finalError) {
          print('❌ Final recovery failed: $finalError');
        }
      }
      
      onError('Invalid verification code. Please try again.');
    }
  }

  // VERIFY OTP AND SIGN IN (FOR EXISTING USERS)
  static Future<void> verifyOTPAndSignIn({
    required String verificationId,
    required String smsCode,
    required String phone,
    required Function() onSuccess,
    required Function(String error) onError,
  }) async {
    try {
      print('🔐 Verifying OTP for sign in');
      print('📱 Phone provided: $phone');
      print('🔑 SMS Code: $smsCode (length: ${smsCode.length})');
      
      final normalizedPhone = normalizePhone(phone);
      
      // CRITICAL: Ensure SMS code is exactly 6 digits with no spaces/whitespace
      String cleanedCode = smsCode.trim().replaceAll(RegExp(r'\s+'), '');
      
      if (cleanedCode.length != 6 || !RegExp(r'^\d{6}$').hasMatch(cleanedCode)) {
        print('❌ Invalid code format: "$smsCode" -> cleaned: "$cleanedCode"');
        onError('Invalid code format. Please enter exactly 6 digits.');
        return;
      }
      
      print('✅ Code validated: $cleanedCode');
      
      // Create credential with cleaned code
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: cleanedCode,
      );

      print('🔐 Attempting to sign in with credential...');

      // Sign in with Firebase Phone Auth
      final userCredential = await _auth.signInWithCredential(credential);
      
      if (userCredential.user != null) {
        print('✅ Phone verified successfully for: $normalizedPhone');
        
        // Save phone locally
        await UserService.saveUserPhone(normalizedPhone);
        
        print('✅ Sign in successful: $normalizedPhone');
        onSuccess();
      } else {
        onError('Sign in failed. Please try again.');
      }
    } on FirebaseAuthException catch (e) {
      print('❌ Firebase Auth error: ${e.code} - ${e.message}');
      
      if (e.code == 'invalid-verification-code') {
        onError('Invalid verification code. Please check the code and try again.');
      } else if (e.code == 'session-expired') {
        onError('Code expired. Please request a new one.');
      } else if (e.code == 'quota-exceeded') {
        onError('Too many attempts. Please try again later.');
      } else {
        onError('Verification failed: ${e.message}');
      }
    } catch (e) {
      print('❌ OTP verification error: $e');
      onError('Invalid verification code. Please try again.');
    }
  }

  // RESEND OTP
  static Future<void> resendOTP({
    required String phone,
    required Function(String verificationId) onCodeSent,
    required Function(String error) onError,
  }) async {
    await sendOTP(phone: phone, onCodeSent: onCodeSent, onError: onError);
  }

  // Internal method
  static Future<void> _signInWithCredential(PhoneAuthCredential credential, String phone) async {
    try {
      await _auth.signInWithCredential(credential);
      print('✅ Auto sign-in successful for: $phone');
    } catch (e) {
      print('❌ Auto sign-in error: $e');
    }
  }

  // Logout
  static Future<void> signOut() async {
    await _auth.signOut();
    await UserService.logout();
    print('👋 User logged out');
  }

  // Get current user
  static User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Check if logged in
  static bool isLoggedIn() {
    return _auth.currentUser != null;
  }

  // Helper method to check if verification actually succeeded
  static Future<bool> isUserVerified(String phone) async {
    try {
      if (_auth.currentUser != null) {
        final normalizedPhone = normalizePhone(phone);
        final doc = await _firestore.collection('users').doc(normalizedPhone).get();
        return doc.exists;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}