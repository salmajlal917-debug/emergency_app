import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:projec/screens/phone_signin_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase with YOUR credentials
  try {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyBwnU3m0EZ-l6BnB7JvzY9-YcDuPFY_TGM",
        appId: "1:632363845938:android:21b5a8541073b8c8cf6f2b", 
        messagingSenderId: "632363845938",
        projectId: "emergencyappsj",
        storageBucket: "emergencyappsj.firebasestorage.app",
      ),
    );
    print('🎉 Firebase connected successfully!');
  } catch (e) {
    print('⚠️ Note: Firebase connection issue - $e');
    print('📱 App will continue in mock mode');
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SafeGuard Emergency',
      theme: ThemeData(
        primarySwatch: Colors.red,
        useMaterial3: true,
        fontFamily: 'Inter',
        scaffoldBackgroundColor: const Color.fromARGB(255, 14, 14, 14),
      ),
      home: PhoneSignInScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}