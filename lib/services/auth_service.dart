import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:projec/services/user_service.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static String normalizePhone(String rawPhone) {
    final digitsOnly = rawPhone.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly.isEmpty) {
      return '';
    }
    return '+$digitsOnly';
  }

  static String phoneToAuthEmail(String phone) {
    final normalized = normalizePhone(phone);
    final compactPhone = normalized.replaceAll('+', '');
    return 'u$compactPhone@phone.emergencyapp.local';
  }

  static Future<void> signInWithPhoneAndPassword({
    required String phone,
    required String password,
  }) async {
    final normalizedPhone = normalizePhone(phone);
    final authEmail = phoneToAuthEmail(normalizedPhone);

    await _auth.signInWithEmailAndPassword(
      email: authEmail,
      password: password,
    );

    await UserService.saveUserPhone(normalizedPhone);
    await _safeEnsureUserDocument(normalizedPhone);
  }

  static Future<void> signUpWithPhoneAndPassword({
    required String fullName,
    required String phone,
    required String password,
  }) async {
    final normalizedPhone = normalizePhone(phone);
    final authEmail = phoneToAuthEmail(normalizedPhone);

    final credential = await _auth.createUserWithEmailAndPassword(
      email: authEmail,
      password: password,
    );

    if (credential.user != null) {
      await credential.user!.updateDisplayName(fullName.trim());
    }

    try {
      await _firestore.collection('users').doc(normalizedPhone).set({
        'name': fullName.trim(),
        'phone': normalizedPhone,
        'email': authEmail,
        'authUid': credential.user?.uid,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } on FirebaseException catch (error) {
      if (!_isFirestoreUnavailable(error)) {
        rethrow;
      }
    }

    await UserService.saveUserPhone(normalizedPhone);
  }

  static Future<void> _safeEnsureUserDocument(String normalizedPhone) async {
    try {
      await _ensureUserDocument(normalizedPhone);
    } on FirebaseException catch (error) {
      if (!_isFirestoreUnavailable(error)) {
        rethrow;
      }
    }
  }

  static Future<void> _ensureUserDocument(String normalizedPhone) async {
    final docRef = _firestore.collection('users').doc(normalizedPhone);
    final snapshot = await docRef.get();
    if (snapshot.exists) {
      return;
    }

    final currentUser = _auth.currentUser;
    await docRef.set({
      'name': currentUser?.displayName ?? '',
      'phone': normalizedPhone,
      'email': currentUser?.email ?? '',
      'authUid': currentUser?.uid,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  static bool _isFirestoreUnavailable(FirebaseException error) {
    final message = (error.message ?? '').toLowerCase();
    return error.code == 'failed-precondition' ||
        error.code == 'unavailable' ||
        error.code == 'permission-denied' ||
        message.contains('cloud firestore api has not been used') ||
        message.contains('firestore api is not available') ||
        message.contains('database does not exist') ||
        message.contains('permission denied');
  }

  static String mapFirebaseAuthError(FirebaseAuthException error) {
    final message = error.message ?? '';
    if (message.contains('CONFIGURATION_NOT_FOUND')) {
      return 'Firebase Auth is not fully configured. Enable Email/Password in Firebase Console > Authentication > Sign-in method.';
    }

    switch (error.code) {
      case 'invalid-credential':
      case 'wrong-password':
      case 'user-not-found':
        return 'Invalid phone number or password.';
      case 'operation-not-allowed':
        return 'Email/Password sign-in is disabled in Firebase Console.';
      case 'email-already-in-use':
        return 'This phone number is already registered.';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'network-request-failed':
        return 'No internet connection. Try again.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      default:
        return error.message ?? 'Authentication failed. Please try again.';
    }
  }
}
