import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:projec/services/user_service.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Normalize phone number (remove spaces, ensure +)
  static String normalizePhone(String rawPhone) {
    String cleaned = rawPhone.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    if (!cleaned.startsWith('+')) {
      cleaned = '+$cleaned';
    }
    return cleaned;
  }

  // Send OTP to phone number (works with test mode)
  static Future<void> sendOTP({
    required String phone,
    required Function(String verificationId) onCodeSent,
    required Function(String error) onError,
  }) async {
    try {
      final normalizedPhone = normalizePhone(phone);
      print('📞 Sending OTP to: $normalizedPhone');
      
      await _auth.verifyPhoneNumber(
        phoneNumber: normalizedPhone,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          // This runs automatically for test numbers
          print('✅ Auto-verification completed');
          await _signInWithCredential(credential, normalizedPhone);
        },
        verificationFailed: (FirebaseAuthException e) {
          String error = 'Verification failed: ${e.message}';
          print('❌ $error');
          onError(error);
        },
        codeSent: (String verificationId, int? resendToken) {
          print('✅ OTP sent/code generated for: $normalizedPhone');
          print('🔑 Verification ID: $verificationId');
          onCodeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          print('⏱️ Auto-retrieval timeout');
        },
      );
    } catch (e) {
      print('❌ Error sending OTP: $e');
      onError('Failed to send OTP. Please try again.');
    }
  }

  // Verify OTP and sign in
  static Future<void> verifyOTPAndSignIn({
    required String verificationId,
    required String smsCode,
    required String phone,
    String? password,
    required Function() onSuccess,
    required Function(String error) onError,
  }) async {
    try {
      print('🔐 Verifying OTP');
      print('   Phone: $phone');
      print('   SMS Code entered: $smsCode');
      print('   SMS Code length: ${smsCode.length}');
      print('   Verification ID: $verificationId');
      
      final normalizedPhone = normalizePhone(phone);
      print('   Normalized phone: $normalizedPhone');
      
      // Create credential
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      // Try to sign in with Firebase Phone Auth
      try {
        final userCredential = await _auth.signInWithCredential(credential);
        
        if (userCredential.user != null) {
          print('✅ Phone verified successfully for: $normalizedPhone');
          
          // Save phone locally
          await UserService.saveUserPhone(normalizedPhone);
          
          // Check if user exists in Firestore
          final userDoc = await _firestore.collection('users').doc(normalizedPhone).get();
          
          if (userDoc.exists) {
            // User exists - verify password if provided
            if (password != null && password.isNotEmpty) {
              final storedPassword = userDoc.data()?['password'];
              if (storedPassword != password) {
                // Password mismatch - sign out
                await _auth.signOut();
                onError('Incorrect password');
                return;
              }
            }
            print('✅ Existing user signed in: $normalizedPhone');
          } else {
            print('📝 New user phone verified: $normalizedPhone');
          }
          
          onSuccess();
          return;
        }
      } catch (e) {
        // If signInWithCredential fails, check if user is already authenticated
        print('⚠️ SignIn error caught: $e');
        await Future.delayed(Duration(milliseconds: 500));
      }
      
      // Check if user is authenticated despite the error
      if (_auth.currentUser != null) {
        print('✅ User authenticated after error recovery for: $normalizedPhone');
        
        // Save phone locally
        await UserService.saveUserPhone(normalizedPhone);
        
        // Check if user exists in Firestore
        final userDoc = await _firestore.collection('users').doc(normalizedPhone).get();
        
        if (userDoc.exists) {
          // User exists - verify password if provided
          if (password != null && password.isNotEmpty) {
            final storedPassword = userDoc.data()?['password'];
            if (storedPassword != password) {
              // Password mismatch - sign out
              await _auth.signOut();
              onError('Incorrect password');
              return;
            }
          }
          print('✅ Existing user signed in: $normalizedPhone');
        } else {
          print('📝 New user phone verified: $normalizedPhone');
        }
        
        onSuccess();
      } else {
        onError('Sign in failed. Please try again.');
      }
    } catch (e) {
      print('❌ OTP verification error: $e');
      onError('Invalid verification code. Please try again.');
    }
  }

  // Internal method to handle credential sign-in
  static Future<void> _signInWithCredential(
    PhoneAuthCredential credential, 
    String phone,
  ) async {
    try {
      await _auth.signInWithCredential(credential);
      print('✅ Auto sign-in successful for: $phone');
    } catch (e) {
      print('❌ Auto sign-in error: $e');
    }
  }

  // Sign up new user (after phone verification)
  static Future<void> signUpWithPhone({
    required String fullName,
    required String phone,
    required String password,
    required Function() onSuccess,
    required Function(String error) onError,
  }) async {
    try {
      final normalizedPhone = normalizePhone(phone);
      final currentUser = _auth.currentUser;
      
      if (currentUser == null) {
        onError('Please verify your phone number first');
        return;
      }

      print('📝 Creating Firestore document for: $normalizedPhone');

      // Try to update display name (may fail due to SDK issue, but that's okay)
      try {
        await currentUser.updateDisplayName(fullName.trim());
        await currentUser.reload();
      } catch (e) {
        print('⚠️ Could not update display name: $e');
        // Continue anyway, the important data will be saved to Firestore
      }

      // Save to Firestore with password
      await _firestore.collection('users').doc(normalizedPhone).set({
        'name': fullName.trim(),
        'phone': normalizedPhone,
        'password': password,
        'authUid': currentUser.uid,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'bloodType': '',
        'gender': '',
        'emergencyNotes': '',
      }, SetOptions(merge: true));

      print('✅ New user created in Firestore: $normalizedPhone');
      onSuccess();
    } catch (e) {
      print('❌ Sign up error: $e');
      onError('Failed to create account. Please try again.');
    }
  }

  // Sign in with phone + password (after OTP verification)
  static Future<void> signInWithPhoneAndPassword({
    required String phone,
    required String password,
    required Function() onSuccess,
    required Function(String error) onError,
  }) async {
    try {
      final normalizedPhone = normalizePhone(phone);
      final currentUser = _auth.currentUser;
      
      if (currentUser == null) {
        onError('Please verify your phone number first');
        return;
      }

      // Check password in Firestore
      final userDoc = await _firestore.collection('users').doc(normalizedPhone).get();
      
      if (!userDoc.exists) {
        onError('Account not found. Please sign up first.');
        await _auth.signOut();
        return;
      }

      final storedPassword = userDoc.data()?['password'];
      if (storedPassword != password) {
        onError('Incorrect password');
        return;
      }

      // Password correct - proceed
      await UserService.saveUserPhone(normalizedPhone);
      print('✅ Password verified for: $normalizedPhone');
      onSuccess();
    } catch (e) {
      print('❌ Sign in error: $e');
      onError('Sign in failed. Please try again.');
    }
  }

  // Resend OTP
  static Future<void> resendOTP({
    required String phone,
    required Function(String verificationId) onCodeSent,
    required Function(String error) onError,
  }) async {
    await sendOTP(phone: phone, onCodeSent: onCodeSent, onError: onError);
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

  // Check if user is logged in
  static bool isLoggedIn() {
    return _auth.currentUser != null;
  }

  // FOR TESTING: Get expected test code
  static String getTestCodeForPhone(String phone) {
    // In test mode, you return the code you set in Firebase Console
    // For +9647510620019, we set 123456
    if (phone.contains('7510620019')) {
      return '123456';
    }
    return '123456'; // Default test code
  }
}