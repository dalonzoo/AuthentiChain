import 'dart:convert';
import 'dart:io';

import 'package:AuthtentiChain/MainViews/HomeViewConsumer.dart';
import 'package:AuthtentiChain/MainViews/HomeViewFiliera.dart';
import 'package:animate_do/animate_do.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:image_picker/image_picker.dart';

import '../MainViews/HomeView.dart';
import '../utils/Constants.dart';
import '../utils/Usertype.dart';


class RegistrazioneFiliera extends StatefulWidget {
  const RegistrazioneFiliera({Key? key}) : super(key: key);

  @override
  State<RegistrazioneFiliera> createState() => _RegistrazioneFilieraState();
}

class _RegistrazioneFilieraState extends State<RegistrazioneFiliera> {
  final _formKey = GlobalKey<FormState>();
  final _imagePicker = ImagePicker();
  final _cittaController = TextEditingController();
  final _materie = <String>[];
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  String image = "";
  final locationController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registrazione filiera', style: GoogleFonts.openSans()),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 30),

                _buildImagePicker(),
                const SizedBox(height: 20),


                // Name Text Field
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Nome e cognome',
                    labelStyle: GoogleFonts.montserrat(
                      fontSize: 16.0,
                      color: Colors.black,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(color: colorePrimario),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Inserisci il tuo nome e cognome';
                    }
                    return null;
                  },
                ),

                // Spacing between TextFields
                const SizedBox(height: 20),

                // Email Text Field

                _buildCittaTextField(),
                // Spacing between TextFields
                const SizedBox(height: 20),
                SizedBox(height: 20),
                TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: GoogleFonts.montserrat(
                      fontSize: 16.0,
                      color: Colors.black,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(color: colorePrimario),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Inserisci la tua email';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: GoogleFonts.montserrat(
                      fontSize: 16.0,
                      color: Colors.black,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(color: colorePrimario),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Inserisci la tua password';
                    }
                    return null;
                  },
                  obscureText: true, // Hide password characters
                ),
                SizedBox(height: 200),
                AnimatedOpacity(
                  opacity: 1.0, // Control opacity
                  duration: const Duration(milliseconds: 500), // Animation duration
                  child: Visibility(
                    visible: true, // Control visibility
                    child: SlideInUp(
                      duration: const Duration(milliseconds: 500),
                      child: Center(
                        child: MaterialButton(
                          onPressed: () => {
                            saveData(context)
                            // Implement your registration logic here (e.g., validate form, call an API)
                            // Navigator.push(...) can be used for navigation if successful
                          },
                          minWidth: double.infinity, // Occupy full available width
                          height: 60.0, // Customizable height
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero, // Squared border
                            side: BorderSide(color: Colors.black26, width: 1.0), // Thin black border
                          ),
                          color: colorePrimario,
                          elevation: 0.0, // Remove default shadow
                          splashColor: colorePrimario.withOpacity(0.5), // Temporary click color
                          highlightColor: Colors.transparent, // No highlight
                          child: Text(
                            "Registrati", // Customizable text
                            style: GoogleFonts.montserrat(
                              fontSize: 16.0,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

  }

  void saveData(context) async{
    try{

      UserCredential credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      User? user = credential.user;

      String? id = user?.uid;
      UserData userData2 = UserData(acquisti: "",tipo: 'f',prodotti: "",email: emailController.text,id: id!, image: image, nomeCognome: nameController.text, citta: locationController.text, categoria: "");
      // Save additional user data to Firebase Realtime Database or Firestore if needed
      // ...
      var database = FirebaseDatabase.instance;
      DatabaseReference ref = database.ref('users/$id');

      await ref.set(userData2.toJson()).onError((error, stackTrace) {
        print("tentativo fallito");
        print(error);
      },).whenComplete((){
        print("cmpletato");

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HomeViewFiliera()), // Replace with your destination page
        );
      });

      // Navigate to the next screen or perform other actions after successful registration

    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        print('The email address is already in use.');
      } else {
        print(e.message);
      }
    }

  }
  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: () async {
        final file = await _imagePicker.pickImage(source: ImageSource.gallery);
        if (image != null) {




          var imageFile = File(file!.path);
          final imageBytes = await imageFile.readAsBytes();
          setState(() {
            image = base64Encode(imageBytes);
          });



// Directly read bytes from the file and encode them to Base64


          //_inputImage = InputImage.fromFile(file);
          //identifyImage(_inputImage);

          // chat gpt and google vision try
/*
          try {
            var response = await http.post(
              Uri.parse('https://api.openai.com/v1/chat/completions'),
              headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer sk-proj-8XojeWnNVjzlnS0VjNRKT3BlbkFJTyadLcXg4NLfxmnus3pH', // Replace with your actual API Key
              },
              body: json.encode({
                'model': 'gpt-4', // Specify the model, replace with the actual model you want to use
                'messages': [
                  {'role': 'system', 'content': 'You are a helpful assistant, capable of identifying fish and sea creatures in images.'},
                  {'role': 'user',
                    "content": [
                      {
                        "type": "text",
                        // "text": "What fish can you detect in thailand and sharks?"

                        "text": "Quale vestito o capo di abbigliamento (potrebbe essere una borsa di pelle o un trench) riesci a individuare in questa immagine? Rispondi solo in json. Supponendo che il contenuto JSON inizi con '{' in modo da poterlo analizzare. Dovrebbe avere la chiave 'capo' che mostra e un dizionario di array contenente 'nome' per ciascun tipo di capo d'abbigliamento"
                      },
                      {
                        "type": "image_url",
                        "image_url": {
                          // "url": "https://cms.bbcearth.com/sites/default/files/2020-12/2fdhe0000001000.jpg",
                          "url": 'data:image/jpeg;base64,'+imageBytesBase64
                        }
                      }
                    ]
                  }
                ],
                'max_tokens': 1000 // Increase this value as needed

              }),
            );

            if (response.statusCode == 200) {
              setState(() {
                var data = json.decode(response.body);
                var contentString = data['choices']?.first['message']['content'] ?? '';

                // Find the start and end of the JSON content within the 'content' string
                int jsonStartIndex = contentString.indexOf('{');
                int jsonEndIndex = contentString.lastIndexOf('}');

                if (jsonStartIndex != -1 && jsonEndIndex != -1) {
                  var jsonString = contentString.substring(jsonStartIndex, jsonEndIndex + 1);
                  var contentData = json.decode(jsonString);

                  // Process the extracted JSON data
                  var responseText = contentData.toString(); // Or process as needed
                  List<dynamic> fishDetails = contentData['capo'] ?? [];
                  var risultato = fishDetails.map((f) => "nome: ${f['nome']}").toList();
                  print('risultato ' + responseText);
                  _bioController.text = risultato[0];
                } else {
                  print('No valid JSON content found');
                }
              });

            }  else {
              setState(() {
                print('risultato ${json.decode(response.body).toString()}');

              });
            }
          } catch (e) {
            setState(() {
              print('risultato ${e.toString()}');

            });
          }

          String projectId = "easy-lesson";
          String languageCode = "it";

          predictImage(projectId, imageBytesBase64, languageCode).then((response) {
            if (response.statusCode == 200) {
              // Parse the JSON response to get the predicted caption
              final jsonResponse = jsonDecode(response.body);
              // Access the caption data from the response
              print(jsonResponse);
            } else {
              print("Error: ${response.statusCode}");
            }
          });

*/
        }
      },
      child: CircleAvatar(
        radius: 50,
        backgroundImage: image != "" ? Image.memory(
          base64Decode(image),
        ).image : null,
        child:  image == "" ? const Icon(Icons.person) : null,
      ),
    );
  }


  Widget _buildMateriaPicker() {
    return DropdownButtonFormField<String>(
      hint: const Text('Scegli una materia'),
      items: _materie.map((materia) {
        return DropdownMenuItem<String>(
          value: materia,
          child: Text(materia),
        );
      }).toList(),
      onChanged: (materia) {
        setState(() {

        });
      },
    );
  }

  Widget _buildCittaTextField() {
    return  TextFormField(
      controller: locationController,
      decoration: InputDecoration(
        labelText: 'Inserisci la tua posizione',
        border: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.blue,
            )
        ),
      ),
      onTap: () async {
        // Launch Google Maps Places Autocomplete modal
        Prediction? p = await PlacesAutocomplete.show(
          context: context,
          radius: 100000000,
          types: [],
          strictbounds: false,
          mode: Mode.overlay,
          language: "it",
          decoration: InputDecoration(
            hintText: 'Search',
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(
                color: Colors.white,
              ),
            ),
          ),
          components: [Component(Component.country, "it")],
          apiKey: 'AIzaSyBGMVE-QILJSlLfbYQEcs05O6a66CSUops', // Replace with your API key
        );

        if (p != null) {
          locationController.text = p.description!;
        }


      },
    );
  }



}
