import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:AuthtentiChain/MainViews/HomeView.dart';
import 'package:AuthtentiChain/login/registrazione_produttore.dart';
import 'package:AuthtentiChain/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:textfield_tags/textfield_tags.dart';
import 'package:animate_do/animate_do.dart';
import '../firebase_options.dart';
import '../utils/Constants.dart';
import '../utils/Usertype.dart';


class RegistrazioneIntelligente extends StatefulWidget {
  final String tipo; // Optional field

  RegistrazioneIntelligente({required this.tipo}); // Constructor with optio
  @override
  State<RegistrazioneIntelligente> createState() => _SpeechSampleAppState();
}

/// An example that demonstrates the basic functionality of the
/// SpeechToText plugin for using the speech recognition capability
/// of the underlying platform.
class _SpeechSampleAppState extends State<RegistrazioneIntelligente> {
  bool _hasSpeech = false;
  bool _logEvents = false;
  bool _onDevice = false;
  final TextEditingController _pauseForController =
  TextEditingController(text: '3');
  final TextEditingController _listenForController =
  TextEditingController(text: '30');
  double level = 0.0;
  double minSoundLevel = 50000;
  double maxSoundLevel = -50000;
  String lastWords = '';
  String lastError = '';
  String lastStatus = '';
  String _currentLocaleId = '';
  List<LocaleName> _localeNames = [];
  final SpeechToText speech = SpeechToText();
  final _formKey = GlobalKey<FormState>();
  final _imagePicker = ImagePicker();
  final _cittaController = TextEditingController();
  final _bioController = TextEditingController();
  final _materie = <String>[];
  late double _distanceToField;
  late DynamicTagController<DynamicTagData<ButtonData>> _dynamicTagController;
  final random = Random();
  late final database;
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController categoriesController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController surnameController = TextEditingController();
  bool isVisible = true;
  bool isVisible2 = true;

  UserData userData = UserData(acquisti: "",tipo: "",prodotti: "", email: "",id: "",image: "", nomeCognome: "", citta: "", categoria: "");
  String image = "";

  @override
  void initState() {
    print("entro qua");
    initSpeechState();


    initFirebase();


    _dynamicTagController = DynamicTagController<DynamicTagData<ButtonData>>();
    super.initState();
  }



  /// This initializes SpeechToText. That only has to be done
  /// once per application, though calling it again is harmless
  /// it also does nothing. The UX of the sample app ensures that
  /// it can only be called once.
  Future<void> initSpeechState() async {
    _logEvent('Initialize');
    try {
      var hasSpeech = await speech.initialize(
        onError: errorListener,
        onStatus: statusListener,
        debugLogging: _logEvents,
      );
      if (hasSpeech) {
        // Get the list of languages installed on the supporting platform so they
        // can be displayed in the UI for selection by the user.
        _localeNames = await speech.locales();

        var systemLocale = await speech.systemLocale();
        _currentLocaleId = systemLocale?.localeId ?? '';
      }
      if (!mounted) return;

      setState(() {
        _hasSpeech = hasSpeech;
      });
    } catch (e) {
      setState(() {
        lastError = 'Speech recognition failed: ${e.toString()}';
        _hasSpeech = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Registrazione produttore',
          style: GoogleFonts.openSans( // Or any Google Font you like
            color: Colors.black,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildImagePicker(),
                SizedBox(height: 20,),
                Row( // Row for Name and Surname TextFields
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: nameController,// Name TextField
                        decoration: InputDecoration(
                          labelText: 'Nome e cognome',
                          labelStyle: GoogleFonts.montserrat( // Same font as other elements
                            fontSize: 16.0,
                            color: Colors.black,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(color: colorePrimario), // Same color as border
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Inserisci il tuo nome e cognome';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),// Assuming this builds an image picker widget
                const SizedBox(height: 20),
                _buildMateriaPicker(), // Assuming this builds a material picker widget
                const SizedBox(height: 20),
                const SizedBox(height: 20),
                _buildCittaTextField(), // Assuming this builds a city text field widget
                const SizedBox(height: 200),
                AnimatedOpacity(
                    opacity: isVisible ? 1.0 : 0.0, // Controllo dell'opacità
                    duration: Duration(milliseconds: 0), // Durata dell'animazione
                    child: Visibility(
                      visible: isVisible, // Controllo della visibilità
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                  decoration: BoxDecoration(
                    color: speech.isListening ? colorePrimario : Colors.grey[300],
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: InkWell(
                    onTap: () async {
                      if(speech.isListening){
                        stopListening();
                      }else{
                        startListening();
                      }

                    },
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Icon(
                        speech.isListening
                            ? Icons.mic_off
                            : Icons.mic,
                        size: 50,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ), // Il widget da mostrare/nascondere
                    ),
                ),
                AnimatedOpacity(
                  opacity: isVisible ? 0.0 : 1.0, // Control opacity
                  duration: const Duration(milliseconds: 500), // Animation duration
                  child: Visibility(
                    visible: !isVisible, // Control visibility
                    child: SlideInUp(
                      duration: const Duration(milliseconds: 500),
                      child: Center(
                        child: MaterialButton(
                          onPressed: (){
                            userData.nomeCognome = nameController.text;
                            userData.citta = _cittaController.text;
                            userData.categoria = categoriesController.text;

                            Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => ProducerRegistrationPage(image: image,userData: userData,tipo: widget.tipo)), // SecondPage è la pagina di destinazione
                          );

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
                            "Avanti", // Customizable text
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
          )
        ),
      ),
    );
  }

  String imageToBase64(File imageFile) {
    String base64Image;
    try {
      List<int> imageBytes = imageFile.readAsBytesSync();
      base64Image = base64Encode(imageBytes);
    } catch (e) {
      print('Error converting image to Base64: $e');
      base64Image = ''; // Handle the error appropriately
    }
    return base64Image;
  }

  Future<String> saveImageToFirebase(XFile image) async {
    final storageRef = FirebaseStorage.instance.ref();
    final filename = FirebaseAuth.instance.currentUser!.uid + '.jpg';
    final imageRef = storageRef.child('images/$filename');

    try {
      final uploadTask = imageRef.putData(await image.readAsBytes());
      final snapshot = await uploadTask.whenComplete(() => null);
      final url = await snapshot.ref.getDownloadURL();
      return url;
    } on FirebaseException catch (e) {
      // Handle error
      print(e);
      return '';
    }
  }
  Widget _buildImagePicker() {
    return GestureDetector(
        onTap: () async {
          final file = await _imagePicker.pickImage(source: ImageSource.gallery);





            var imageFile = File(file!.path);
            final imageBytes = await imageFile.readAsBytes();
            setState(() {
              image = base64Encode(imageBytes);


            userData = UserData(acquisti : "",tipo: widget.tipo,prodotti:  "", email: "",id: "",image: image, nomeCognome: nameController.text, citta: _cittaController.text, categoria: categoriesController.text);

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

      },
      child: CircleAvatar(
        radius: 50,
        backgroundImage: image.isEmpty ? null : Image.memory(base64Decode(image)).image,
        child: image.isEmpty ? const Icon(Icons.person) : null,
      ),
    );
  }


  Widget _buildMateriaPicker() {
    return  TextFieldTags<DynamicTagData<ButtonData>>(
      textfieldTagsController: _dynamicTagController,
      initialTags: [],

      textSeparators: const [' ', ','],
      letterCase: LetterCase.normal,
      validator: (DynamicTagData<ButtonData> tag) {

      },
      inputFieldBuilder: (context, inputFieldValues) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0),
          child: TextField(
            onTap: () {
              _showDropdown(context); // Call function to show dropdown on tap
            },
            controller: categoriesController,
            focusNode: inputFieldValues.focusNode,
            decoration: InputDecoration(
              labelText: 'Produco...',
              floatingLabelBehavior: FloatingLabelBehavior.always,
              border: const OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.blue,
                ),
              ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.blue,
                  width: 3.0,
                ),
              ),
              hintText: inputFieldValues.tags.isNotEmpty
                  ? ''
                  : "",
              errorText: inputFieldValues.error,
              suffixIconConstraints: BoxConstraints(maxWidth: 1.0),
              prefixIcon: inputFieldValues.tags.isNotEmpty
                  ? SingleChildScrollView(
                controller: inputFieldValues.tagScrollController,
                scrollDirection: Axis.vertical,
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: 8,
                    bottom: 8,
                    left: 8,
                  ),
                  child: Wrap(
                      runSpacing: 4.0,
                      spacing: 4.0,
                      children: inputFieldValues.tags
                          .map((DynamicTagData<ButtonData> tag) {
                        return Container(
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.all(
                              Radius.circular(20.0),
                            ),
                            color: tag.data.buttonColor,
                          ),
                          margin: const EdgeInsets.symmetric(
                              horizontal: 5.0),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10.0, vertical: 5.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              InkWell(
                                child: Text(
                                  '${tag.data.emoji} ${tag.tag}',
                                  style: const TextStyle(
                                      color: Color.fromARGB(
                                          255, 0, 0, 0)),
                                ),
                                onTap: () {
                                  // print("${tag.tag} selected");
                                },
                              ),
                              const SizedBox(width: 4.0),
                              InkWell(
                                child: const Icon(
                                  Icons.cancel,
                                  size: 14.0,
                                  color: Color.fromARGB(
                                      255, 0, 0, 0),
                                ),
                                onTap: () {
                                  inputFieldValues.onTagRemoved(tag);
                                },
                              )
                            ],
                          ),
                        );
                      }).toList()),
                ),
              )
                  : null,
            ),
            onChanged: (value) {
              // Handle text changes if needed
            },
            onSubmitted: (value) {
              // Handle text submission if needed
            },
          ),

        );
      },
    );
  }

  void _showDropdown(BuildContext context) {
    // Replace with your actual list of options
    final List<String> options = ['Borse', 'Giacche', 'Pantaloni su misura','Borse', 'Giacche', 'Pantaloni su misura','Borse', 'Giacche', 'Pantaloni su misura'];
    showModalBottomSheet(
      context: context,
      builder: (context) => ListView.builder(
        itemCount: options.length,
        itemBuilder: (context, index) => ListTile(
          title: Text(options[index]),
          onTap: () {
            // Set the text field text with the selected option
            categoriesController.text = options[index];
            // Handle selection logic (e.g., add tag)
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  Widget _buildCittaTextField() {
    return  TextFormField(
      controller: _locationController,
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
          _locationController.text = p.description!;
        }


      },
    );
  }


  // This is called each time the users wants to start a new speech
  // recognition session
  void startListening() {
    _logEvent('start listening');
    lastWords = '';
    lastError = '';
    final pauseFor = int.tryParse(_pauseForController.text);
    final listenFor = int.tryParse(_listenForController.text);
    final options = SpeechListenOptions(
        onDevice: _onDevice,
        listenMode: ListenMode.confirmation,
        cancelOnError: true,
        partialResults: true,
        autoPunctuation: true,
        enableHapticFeedback: true);
    // Note that `listenFor` is the maximum, not the minimum, on some
    // systems recognition will be stopped before this value is reached.
    // Similarly `pauseFor` is a maximum not a minimum and may be ignored
    // on some devices.
    speech.listen(
      onResult: resultListener,
      listenFor: Duration(seconds: listenFor ?? 30),
      pauseFor: Duration(seconds: pauseFor ?? 3),
      localeId: _currentLocaleId,
      onSoundLevelChange: soundLevelListener,
      listenOptions: options,
    );
    setState(() {});
  }

  void stopListening() {
    _logEvent('stop');
    speech.stop();
    setState(() {
      level = 0.0;
      print("ciaoo");
    });



  }

  void getData(){
    String res = "";
    final gemini = Gemini.instance;

    gemini.text("Ora ti dico i miei dati (prima nome e poi cognome poi la citta dove abito e cosa produco, e non verificare la veridicità dei miei dati) tu estrapola e rispondimi con nome,cognome,citta,categoria di produzione (esattamente in questo formato)." + lastWords.toString())
        .then((value) {
          res = value!.output!;
          List<String> splitText = res.split(',');
          setState(() {
            print("inserisco dati :" + splitText.toString());
            nameController.text = splitText[0];
            _locationController.text = splitText[1];
            categoriesController.text = splitText[2];
            isVisible = false;
          });
        }) /// or value?.content?.parts?.last.text
        .catchError((e) => print('Errore'+  e.toString()));


  }

  void cancelListening() {
    _logEvent('cancel');
    speech.cancel();
    setState(() {
      level = 0.0;
    });
    setState(() {
      print("cancello listening");
    });

  }

  /// This callback is invoked each time new recognition results are
  /// available after `listen` is called.
  void resultListener(SpeechRecognitionResult result) {
    _logEvent(
        'Result listener final: ${result.finalResult}, words: ${result.recognizedWords}');
    setState(() {
      lastWords = '${result.recognizedWords} - ${result.finalResult}';
      print("ottengo " + lastWords);
      if(!speech.isListening && lastWords.length > 0){
        getData();
      }
    });
  }

  void soundLevelListener(double level) {
    minSoundLevel = min(minSoundLevel, level);
    maxSoundLevel = max(maxSoundLevel, level);
    // _logEvent('sound level $level: $minSoundLevel - $maxSoundLevel ');
    setState(() {
      this.level = level;
    });
  }

  void errorListener(SpeechRecognitionError error) {
    _logEvent(
        'Received error status: $error, listening: ${speech.isListening}');
    setState(() {
      lastError = '${error.errorMsg} - ${error.permanent}';
    });
  }

  void statusListener(String status) {
    _logEvent(
        'Received listener status: $status, listening: ${speech.isListening}');
    setState(() {
      lastStatus = status;
    });
  }

  void _switchLang(selectedVal) {
    setState(() {
      _currentLocaleId = selectedVal;
    });
    debugPrint(selectedVal);
  }

  void _logEvent(String eventDescription) {
    if (_logEvents) {
      var eventTime = DateTime.now().toIso8601String();
      debugPrint('$eventTime $eventDescription');
    }
  }

  void _switchLogging(bool? val) {
    setState(() {
      _logEvents = val ?? false;
    });
  }

  void _switchOnDevice(bool? val) {
    setState(() {
      _onDevice = val ?? false;
    });
  }
}

/// Displays the most recently recognized words and the sound level.
class RecognitionResultsWidget extends StatelessWidget {
  const RecognitionResultsWidget({
    Key? key,
    required this.lastWords,
    required this.level,
  }) : super(key: key);

  final String lastWords;
  final double level;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        const Center(
          child: Text(
            'Recognized Words',
            style: TextStyle(fontSize: 22.0),
          ),
        ),
        Expanded(
          child: Stack(
            children: <Widget>[
              Container(
                color: Theme.of(context).secondaryHeaderColor,
                child: Center(
                  child: Text(
                    lastWords,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              Positioned.fill(
                bottom: 10,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                            blurRadius: .26,
                            spreadRadius: level * 1.5,
                            color: Colors.black.withOpacity(.05))
                      ],
                      color: Colors.white,
                      borderRadius: const BorderRadius.all(Radius.circular(50)),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.mic),
                      onPressed: () {},
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class HeaderWidget extends StatelessWidget {
  const HeaderWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Speech recognition available',
        style: TextStyle(fontSize: 22.0),
      ),
    );
  }
}

/// Display the current error status from the speech
/// recognizer
class ErrorWidget extends StatelessWidget {
  const ErrorWidget({
    Key? key,
    required this.lastError,
  }) : super(key: key);

  final String lastError;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        const Center(
          child: Text(
            'Error Status',
            style: TextStyle(fontSize: 22.0),
          ),
        ),
        Center(
          child: Text(lastError),
        ),
      ],
    );
  }
}

/// Controls to start and stop speech recognition
class SpeechControlWidget extends StatelessWidget {
  const SpeechControlWidget(this.hasSpeech, this.isListening,
      this.startListening, this.stopListening, this.cancelListening,
      {Key? key})
      : super(key: key);

  final bool hasSpeech;
  final bool isListening;
  final void Function() startListening;
  final void Function() stopListening;
  final void Function() cancelListening;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        TextButton(
          onPressed: !hasSpeech || isListening ? stopListening : startListening,
          child: const Text('Start'),
        ),
        TextButton(
          onPressed: isListening ? stopListening : null,
          child: const Text('Stop'),
        ),
        TextButton(
          onPressed: isListening ? cancelListening : null,
          child: const Text('Cancel'),
        )
      ],
    );
  }
}

class SessionOptionsWidget extends StatelessWidget {
  const SessionOptionsWidget(
      this.currentLocaleId,
      this.switchLang,
      this.localeNames,
      this.logEvents,
      this.switchLogging,
      this.pauseForController,
      this.listenForController,
      this.onDevice,
      this.switchOnDevice,
      {Key? key})
      : super(key: key);

  final String currentLocaleId;
  final void Function(String?) switchLang;
  final void Function(bool?) switchLogging;
  final void Function(bool?) switchOnDevice;
  final TextEditingController pauseForController;
  final TextEditingController listenForController;
  final List<LocaleName> localeNames;
  final bool logEvents;
  final bool onDevice;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            children: [
              const Text('Language: '),
              DropdownButton<String>(
                onChanged: (selectedVal) => switchLang(selectedVal),
                value: currentLocaleId,
                items: localeNames
                    .map(
                      (localeName) => DropdownMenuItem(
                    value: localeName.localeId,
                    child: Text(localeName.name),
                  ),
                )
                    .toList(),
              ),
            ],
          ),
          Row(
            children: [
              const Text('pauseFor: '),
              Container(
                  padding: const EdgeInsets.only(left: 8),
                  width: 80,
                  child: TextFormField(
                    controller: pauseForController,
                  )),
              Container(
                  padding: const EdgeInsets.only(left: 16),
                  child: const Text('listenFor: ')),
              Container(
                  padding: const EdgeInsets.only(left: 8),
                  width: 80,
                  child: TextFormField(
                    controller: listenForController,
                  )),
            ],
          ),
          Row(
            children: [
              const Text('On device: '),
              Checkbox(
                value: onDevice,
                onChanged: switchOnDevice,
              ),
              const Text('Log events: '),
              Checkbox(
                value: logEvents,
                onChanged: switchLogging,
              ),
            ],
          ),
        ],
      ),
    );
  }
}



/// Display the current status of the listener
class SpeechStatusWidget extends StatelessWidget {
  const SpeechStatusWidget({
    Key? key,
    required this.speech,
  }) : super(key: key);

  final SpeechToText speech;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      color: Theme.of(context).colorScheme.background,
      child: Center(
        child: speech.isListening
            ? const Text(
          "I'm listening...",
          style: TextStyle(fontWeight: FontWeight.bold),
        )
            : const Text(
          'Not listening',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class ProducerRegistrationPage extends StatefulWidget {
  String tipo;
  final UserData userData;
  String image;

  ProducerRegistrationPage({required this.userData, required this.tipo, required this.image});

  @override
  State<ProducerRegistrationPage> createState() => _ProducerRegistrationPageState();
}

class _ProducerRegistrationPageState extends State<ProducerRegistrationPage> {
  final _formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();

  final passwordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
 // Initialize Firebase Auth
  bool isVisible = false;

  bool isVisible2 = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Registrazione produttore',
          style: GoogleFonts.openSans(
            color: Colors.black,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "Un ultimo passo...",
                    style: GoogleFonts.montserrat( // Same font as other elements
                      fontSize: 18.0,
                      color: Colors.black,
                    ),
                  ),
                ),// Placeholder for your image picker widget
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
                Visibility(child:SizedBox(height: 80),
                  visible: isVisible,
                ),
                Visibility(child:CircularProgressIndicator(color: colorePrimario,),
                  visible: isVisible,
                ),
                SizedBox(height: 200),
                Visibility(
                    visible: isVisible2,
                    child: CaricamentoWidget(colorePrimario: colorePrimario)),
                AnimatedOpacity(
                  opacity: isVisible ? 0.0 : 1.0, // Control opacity
                  duration: const Duration(milliseconds: 500), // Animation duration
                  child: Visibility(
                    visible: !isVisible, // Control visibility
                    child: SlideInUp(
                      duration: const Duration(milliseconds: 500),
                      child: Center(
                        child: MaterialButton(
                          onPressed: () async {
                            // Set isVisible and isVisible2 to true (optional, based on your logic)

                            setState(() {
                              isVisible = true;

                            });

                            // Implement your registration logic here (e.g., validate form, call an API)
                            saveData(context);


                            // Optional: Additional actions after successful registration
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
                    )
                    ,
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
      UserData userData2 = UserData(acquisti : "",tipo: widget.tipo,prodotti: "",email: emailController.text,id: id!, image: widget.image, nomeCognome: widget.userData.nomeCognome, citta: widget.userData.citta, categoria: widget.userData.categoria);
      // Save additional user data to Firebase Realtime Database or Firestore if needed
      // ...
      var database = FirebaseDatabase.instance;
      DatabaseReference ref = database.ref('users/$id');

      await ref.set(userData2.toJson()).onError((error, stackTrace) {
        print("tentativo fallito");
        print(error);
      },).whenComplete((){
        print("cmpletato"); Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HomeView()), // Replace with your destination page
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

  String imageToBase64(File imageFile) {
    String base64Image;
    try {
      List<int> imageBytes = imageFile.readAsBytesSync();
      base64Image = base64Encode(imageBytes);
    } catch (e) {
      print('Error converting image to Base64: $e');
      base64Image = ''; // Handle the error appropriately
    }
    return base64Image;
  }
}


class CaricamentoWidget extends StatefulWidget {
  final Color colorePrimario;
  final double dimensione;

  const CaricamentoWidget({
    Key? key,
    required this.colorePrimario,
    this.dimensione = 30,
  }) : super(key: key);

  @override
  State<CaricamentoWidget> createState() => _CaricamentoWidgetState();
}

class _CaricamentoWidgetState extends State<CaricamentoWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animazione;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _animazione = Tween<double>(begin: 0, end: 1).animate(_controller)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _controller.reverse();
        } else if (status == AnimationStatus.forward) {
          _controller.reset();
        }
      });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: _animazione,
        builder: (context, child) {
          return Transform.rotate(
            angle: _animazione.value * 2 * pi,
            child: SizedBox(
              height: widget.dimensione,
              width: widget.dimensione,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(widget.colorePrimario),
                strokeWidth: 4,
              ),
            ),
          );
        },
      ),
    );
  }
}



