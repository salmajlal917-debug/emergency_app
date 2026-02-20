import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static const String _phoneKey = 'user_phone';
  
  // Save phone locally
  static Future<void> saveUserPhone(String phone) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_phoneKey, phone);
      print('✅ Phone saved: $phone');
    } catch (e) {
      print('❌ Error saving phone: $e');
    }
  }
  
  // Get phone
  static Future<String?> getCurrentUserPhone() async {
    try {
      // Try local storage first
      final prefs = await SharedPreferences.getInstance();
      final localPhone = prefs.getString(_phoneKey);
      if (localPhone != null && localPhone.isNotEmpty) {
        return localPhone;
      }

      // Try to get from Firebase Auth
      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        final phoneNumber = currentUser.phoneNumber;
        if (phoneNumber != null && phoneNumber.isNotEmpty) {
          await saveUserPhone(phoneNumber);
          return phoneNumber;
        }
      }

      return null;
    } catch (e) {
      print('❌ Error getting phone: $e');
      return null;
    }
  }
  
  // Get current user from Firebase Auth
  static User? getCurrentUser() {
    return _auth.currentUser;
  }
  
  // Logout
  static Future<void> logout() async {
    try {
      await _auth.signOut();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_phoneKey);
      print('✅ User logged out');
    } catch (e) {
      print('❌ Error during logout: $e');
    }
  }
  
  // Save profile to Firestore
  static Future<void> saveUserProfile({
    required String phone,
    required String name,
    required String email,
    required String bloodType,
    required String gender,
    String? emergencyNotes,
    DateTime? dateOfBirth,
  }) async {
    try {
      // Clean phone for document ID
      final cleanPhone = phone.replaceAll(RegExp(r'\s+'), '');
      
      final userData = {
        'name': name,
        'phone': phone,
        'email': email,
        'bloodType': bloodType,
        'gender': gender,
        'emergencyNotes': emergencyNotes ?? '',
        'updatedAt': FieldValue.serverTimestamp(),
      };
      
      if (dateOfBirth != null) {
        userData['dateOfBirth'] = Timestamp.fromDate(dateOfBirth);
      }
      
      await _firestore
          .collection('users')
          .doc(cleanPhone)
          .set(userData, SetOptions(merge: true));
          
      print('✅ Profile saved to Firestore for: $phone');
    } catch (e) {
      print('❌ Error saving profile to Firestore: $e');
      rethrow;
    }
  }
  
  // Get profile from Firestore
  static Future<Map<String, dynamic>?> getUserProfile(String phone) async {
    try {
      final cleanPhone = phone.replaceAll(RegExp(r'\s+'), '');
      
      final doc = await _firestore
          .collection('users')
          .doc(cleanPhone)
          .get();
          
      if (doc.exists) {
        print('✅ Profile found in Firestore for: $phone');
        return doc.data();
      }
      
      print('ℹ️ No profile found for: $phone');
      return null;
    } catch (e) {
      print('❌ Error getting profile from Firestore: $e');
      return null;
    }
  }
  
  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    return _auth.currentUser != null;
  }
}