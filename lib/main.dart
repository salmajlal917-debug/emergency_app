import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:projec/screens/phone_signin_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase from platform config (google-services.json on Android)
  try {
    await Firebase.initializeApp();
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
      home: const PhoneSignInScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
