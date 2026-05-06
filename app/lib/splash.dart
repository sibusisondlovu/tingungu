import 'dart:async';
import 'package:flutter/material.dart';

import 'screens/home_screen.dart';


class Splash extends StatefulWidget {
  const Splash({super.key});
  static const String id = "splash";

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Or your branding color
      body: Center(
        child: Image.asset(
          'lib/assets/image/logo.png',
          width: 180,
          height: 180,
        ),
      ),
    );
  }
}
