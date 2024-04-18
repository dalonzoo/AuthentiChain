import 'dart:async';

import 'package:flutter/material.dart';
import 'package:learn_link/MainViews/HomeView.dart';
import 'package:learn_link/login/login_view.dart';
import 'package:learn_link/icons/my_flutter_app_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'OnBoardingPage.dart';



class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();

  }

  Future<void> _checkLoginStatus() async {

    _isLoggedIn = false;
    await Future.delayed(const Duration(seconds: 1));
    if (_isLoggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeView()),
      );
    } else {

      final prefs = await SharedPreferences.getInstance();
      bool seenOnboarding = prefs.getBool('seenOnboarding') ?? false;

      if (seenOnboarding) {
        print("apro on barding");

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => OnboardingPage()),
        );

        prefs.setBool('seenOnboarding', true);

      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginView()),
        );

      }

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.webhook_rounded,
              size: 150,
              color: Colors.blue,
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
