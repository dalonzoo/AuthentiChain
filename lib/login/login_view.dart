import 'package:AuthtentiChain/MainViews/HomeViewConsumer.dart';
import 'package:AuthtentiChain/MainViews/HomeViewFiliera.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import '../MainViews/HomeView.dart';
import '../utils/Constants.dart';
import '../utils/Usertype.dart';
import 'Tipologiautente.dart';
class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  Image myImage = Image.asset('assets/icons/logo1.png');
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App logo
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween, // Space between text and icon
                    children: [
                      // Google Font text
                      Text(
                        'Difendi il Made in Italy.',
                        style: GoogleFonts.montserrat(
                          fontSize: 26.0,
                          color: colorePrimario,
                          fontWeight: FontWeight.bold,
                        ),
                        softWrap: true,
                      ),
                      // App log
                    ],
                  ),
                  const SizedBox(height: 40),
                  const SizedBox(height: 40),

                  // Email field
                  TextFormField(
                    controller: _emailController,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Inserisci la tua email';
                      } else if (!RegExp(r'^.+@[a-zA-Z]+\.[a-zA-Z]+$').hasMatch(value)) {
                        return 'Email non valida';
                      }
                      return null;
                    },
                    style: TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: TextStyle(color: colorePrimario),
                      filled: true,
                      fillColor: Colors.blue.withOpacity(0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(color: colorePrimario),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(color: colorePrimario),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(color: colorePrimario),
                      ),
                      prefixIcon: Icon(Icons.email, color: colorePrimario),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Password field
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Inserisci la tua password';
                      }
                      return null;
                    },
                    style: TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: TextStyle(color: colorePrimario),
                      filled: true,
                      fillColor: Colors.blue.withOpacity(0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(color: colorePrimario),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(color: colorePrimario),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(color: colorePrimario),
                      ),
                      prefixIcon: Icon(Icons.lock, color: colorePrimario),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Login button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_emailController.text != "" && _passwordController.text != "") {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Accesso in corso...'),
                            ),
                          );
                          _login(_emailController.text, _passwordController.text);

                          //validate credentials...
                        }
                      },
                      child: const Text('Accedi'),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white, backgroundColor: colorePrimario,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Forgot password and registration buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Email di reimpostazione password inviata'),
                            ),
                          );
                        },
                        child: const Text('Password dimenticata.'),
                        style: TextButton.styleFrom(foregroundColor: colorePrimario),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => TipologiaUtente()), // SecondPage è la pagina di destinazione
                          );
                        },
                        child: const Text('Non hai un account.'),
                        style: TextButton.styleFrom(foregroundColor: colorePrimario),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _login(String email, String password) async {
    try {
      final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      print('Logged in as: ${userCredential.user!.uid}');
      final userRef = FirebaseDatabase.instance.ref('users/' + userCredential.user!.uid);
      final event = await userRef.once();


      final data = event.snapshot.value as Map<dynamic, dynamic>;
      UserData user = UserData.fromMap(data);
      if(user.tipo == 'p'){
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HomeView()), // Replace with your destination page
        );
      }else if(user.tipo == 'c'){
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HomeViewConsumer()), // Replace with your destination page
        );
      }else{
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HomeViewFiliera()), // Replace with your destination page
        );
      }

      // Navigate to the next page or perform other actions
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found with that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided.');
      } else {
        print('Login failed due to: ${e.code}');
      }
    }
  }
}
