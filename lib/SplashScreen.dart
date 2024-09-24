import 'package:flutter/material.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, '/home');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.bottomCenter, // Center of the gradient
            radius: 0.6, // Radius of the gradient
            colors: [
              Colors.red, // Inner color
              Colors.red.withOpacity(0.2), // Outer color with transparency
            ],
          ),
        ),
        child: Center(
          child: Container(
              decoration:BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.white, width: 2.0),
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Image.asset('assets/images/QuadB.png')
          ),
        ),
      ),
    );
  }
}
