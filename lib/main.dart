
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tingungu_app/splash.dart';

import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
 await Firebase.initializeApp();

  final prefs = await SharedPreferences.getInstance();
  final isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;
  final user = FirebaseAuth.instance.currentUser;

  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF3b0d11),
        primary: const Color(0xFF3b0d11),
        secondary: const Color(0xFFFB8B24),
        brightness: Brightness.light,
      ),
      primaryColor: const Color(0xFF3b0d11),
      scaffoldBackgroundColor: Colors.white,
      fontFamily: 'Poppins',
      iconTheme: const IconThemeData(
        color: Color(0xFFFB8B24),
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Colors.black),
        bodyMedium: TextStyle(color: Colors.black),
        bodySmall: TextStyle(color: Colors.black),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFB8B24),
          foregroundColor: Colors.white,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFFFB8B24),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFFFB8B24),
          side: const BorderSide(color: Color(0xFFFB8B24)),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF3b0d11),
        foregroundColor: Colors.white,
      ),
    ),
    home: isFirstLaunch
        ? const OnboardingScreen()
        : (user != null ? const HomeScreen() : const HomeScreen()),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tingungu',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFff0000),
          brightness: Brightness.light,
        ),
        fontFamily: 'Poppins',
      ),
      debugShowCheckedModeBanner: false,
      home: const Splash(),

    );
  }
}
