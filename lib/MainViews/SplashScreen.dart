import 'dart:async';

import 'package:AuthtentiChain/MainViews/HomeViewConsumer.dart';
import 'package:AuthtentiChain/MainViews/HomeViewFiliera.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../firebase_options.dart';
import '../login/login_view.dart';
import '../utils/Usertype.dart';
import 'HomeView.dart';
import 'OnBoardingPage.dart';



class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  bool _isLoggedIn = false;
  Image myImage = Image.asset('assets/icons/logo1.png');
  @override
  void initState() {
    super.initState();
    initFirebase();

  }

  void initFirebase() async{
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ).whenComplete(() async{
      checkLoginStatus();

    });

  }

  void checkLoginStatus() async {
    final User? user = FirebaseAuth.instance.currentUser;
    final prefs = await SharedPreferences.getInstance();
    bool seenOnboarding = prefs.getBool('seenOnboarding') ?? false;

    if (!seenOnboarding) {
      print("apro on barding");

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => OnboardingPage()),
      );
    } else {
      if (user != null) {

        print(user.email);
        getUserData(FirebaseAuth.instance.currentUser!.uid);
        // Navigate to the next page or perform other actions
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginView()),
        );
        print('User is not logged in');
        // Show the login page or perform other actions
      }
    }
  }

  void getUserData(String userId) async {
    final userRef = FirebaseDatabase.instance.ref('users/$userId');
    final event = await userRef.once();


    final data = event.snapshot.value as Map<dynamic, dynamic>;
    UserData user = UserData.fromMap(data);
    if(user.tipo == 'p'){
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeView()),
      );
    }else if(user.tipo == 'c'){
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeViewConsumer()),
      );
    }else{
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeViewFiliera()),
      );
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 150,
              width: 150,
              child: myImage,
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );

  }
}


