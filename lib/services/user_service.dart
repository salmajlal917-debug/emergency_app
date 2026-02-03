import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
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
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_phoneKey);
    } catch (e) {
      print('❌ Error getting phone: $e');
      return null;
    }
  }
  
  // Logout
  static Future<void> logout() async {
    try {
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
      // Clean phone for document ID (remove spaces, keep + and numbers)
      final cleanPhone = phone.replaceAll(RegExp(r'\s+'), ''); // Just remove spaces
      
      final userData = {
        'phone': phone,
        'name': name,
        'email': email,
        'bloodType': bloodType,
        'gender': gender,
        'emergencyNotes': emergencyNotes ?? '',
        'updatedAt': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
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
      final cleanPhone = phone.replaceAll(RegExp(r'\s+'), ''); // Just remove spaces
      
      final doc = await _firestore
          .collection('users')
          .doc(cleanPhone)
          .get();
          
      if (doc.exists) {
        print('✅ Profile found in Firestore for: $phone');
        return doc.data();
      }
      print('ℹ️ No profile found in Firestore for: $phone');
      return null;
    } catch (e) {
      print('❌ Error getting profile from Firestore: $e');
      return null;
    }
  }
}