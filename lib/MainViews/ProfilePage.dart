import 'dart:convert';

import 'package:AuthtentiChain/login/login_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Import Google Fonts
import 'package:firebase_database/firebase_database.dart';

import '../firebase_options.dart';
import '../utils/Usertype.dart'; // Import Firebase Realtime Database

class ProfilePage extends StatefulWidget {



  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  final database = FirebaseDatabase.instance;
  String nomeCognome = "";
  String email = "";
  String image = "";
  String citta = "";
  String categoria = "";

  @override
  void initState() {
    // TODO: implement initState

    super.initState();
    initFirebase();
  }

  void initFirebase() async{
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ).whenComplete(() async{
      final User? user = FirebaseAuth.instance.currentUser;

        getUserData(user!.uid);

    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profilo'),
        automaticallyImplyLeading: false, // Remove back button
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            children: [
              // Header with background image and profile picture
              Container(
                height: 200,
                child: Center(
                  child: ClipRRect( // Clip the child to a circle shape
                    borderRadius: BorderRadius.circular(50.0), // Set the circle radius
                    child: Container( // Inner container for image
                      height: 150.0, // Set a smaller height for the image
                      width: 150.0, // Set a smaller width for the image
                      color: Colors.white, // Set background color (optional)
                      child: image == ""
                          ? SizedBox(height: 50, width: 50,) // Placeholder for empty image
                          : Image.memory(
                        base64Decode(image),
                        fit: BoxFit.cover, // Cover the container area
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),

              // Profile Information section
              // Inside Profile Information section
              Card(
                elevation: 4.0,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nomeCognome,
                        style: GoogleFonts.montserrat(
                          fontSize: 22.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(width: 10.0),
                      CardInformation(title: 'Email',value: email ?? ''),
                      SizedBox(height: 10),
                      CardInformation(title: 'Città',value: citta ?? ''),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              // Handle edit profile button press
                              // You can navigate to an edit profile page here
                            },
                            icon: Icon(Icons.edit),
                            label: Text('Modifica'),
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.green,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // After the Profile Information card
              SizedBox(height: 20), // Add some spacing

              // Other sections or widgets on the profile page
              // (Optional, depending on your design)

              // Example: A section for displaying recent activities or posts

              // **New Quit Button**
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      // Handle logout logic here
                      // This could involve navigating to a login page or performing authentication tasks
                      FirebaseAuth.instance.signOut();
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginView()), // SecondPage è la pagina di destinazione
                      );
                    },
                    icon: Icon(
                      Icons.exit_to_app,
                      color: Colors.red,
                    ),
                    label: Text(
                      'Esci',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

  }

  // Read the user data once and return a Future
  void getUserData(String userId) async {
    final userRef = FirebaseDatabase.instance.ref('users/$userId');
    final event = await userRef.once();


    final data = event.snapshot.value as Map<dynamic, dynamic>;
    UserData user = UserData.fromMap(data);
    setState(() {
      email = user.email;
      nomeCognome = user.nomeCognome;
      citta = user.citta;
      categoria = user.categoria;
      image = user.image;
    });

  }
}

class CardInformation extends StatelessWidget {
  final String title;
  final String value;

  CardInformation({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title + ':',
          style: GoogleFonts.montserrat(
            fontSize: 16.0,
            color: Colors.black,
          ),
        ),
        SizedBox(width: 10),
        Text(
          value,
          style: GoogleFonts.montserrat(
            fontSize: 13.0,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ],
    );
  }






}


