import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'MainViews/HomeView.dart';
import 'firebase_options.dart';
import 'utils/Constants.dart';
import 'MainViews/SplashScreen.dart';
import 'login/Tipologiautente.dart';
import 'login/registrazione_produttore.dart';
import 'login/registrazione_consumatore.dart';

void main() async{

  Gemini.init(apiKey: 'AIzaSyD7--lzWJ1qkRI4UedblJKyS_-3ZBpBy5o');
  runApp(MaterialApp(home: SplashScreen()));
}

void initFirebase() async{
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ).whenComplete(() async{
    print("firebase initialized");

  });

}


class MyApp extends StatelessWidget {
  const MyApp({key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Authentichain',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: colorePrimario),
        useMaterial3: true,
      ),
      home: const SplashScreen(),  routes: {
      '/registrazione': (context) => const TipologiaUtente(),
      '/registrazione_studente': (context) => const RegistrazioneConsumatore(),
      '/registrazione_insegnante': (context) => const RegistrazioneInsegnante(),
    },
    );
  }




}



