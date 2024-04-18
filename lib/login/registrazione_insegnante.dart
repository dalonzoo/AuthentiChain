import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:textfield_tags/textfield_tags.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import '../utils/Usertype.dart';


class RegistrazioneInsegnante extends StatefulWidget {
  const RegistrazioneInsegnante({Key? key}) : super(key: key);

  @override
  State<RegistrazioneInsegnante> createState() => _RegistrazioneInsegnanteState();
}

class _RegistrazioneInsegnanteState extends State<RegistrazioneInsegnante> {
  final _formKey = GlobalKey<FormState>();
  final _imagePicker = ImagePicker();
  final _cittaController = TextEditingController();
  final _bioController = TextEditingController();
  final _materie = <String>[];
  late double _distanceToField;
  late DynamicTagController<DynamicTagData<ButtonData>> _dynamicTagController;
  final random = Random();
  User _user = User();
  final TextEditingController _locationController = TextEditingController();

  final places = GoogleMapsPlaces(apiKey: 'AIzaSyBGMVE-QILJSlLfbYQEcs05O6a66CSUops'); // Replace with your API key

  static final List<DynamicTagData<ButtonData>> _initialTags = [
    DynamicTagData<ButtonData>(
      'Italiano',
      const ButtonData(
        Color.fromARGB(255, 200, 232, 255),
        "",
      ),
    ),
    DynamicTagData(
      'Storia',
      const ButtonData(
        Color.fromARGB(255, 255, 201, 243),
        '',
      ),
    ),
    DynamicTagData(
      'Inglese',
      const ButtonData(
        Color.fromARGB(255, 240, 255, 200),
        '',
      ),
    ),
  ];



  @override
  void initState() {
    super.initState();

    _dynamicTagController = DynamicTagController<DynamicTagData<ButtonData>>();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _distanceToField = MediaQuery.of(context).size.width;
  }

  @override
  void dispose() {
    super.dispose();
    _dynamicTagController.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrazione Insegnante'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildImagePicker(),
                const SizedBox(height: 20),
                _buildMateriaPicker(),
                const SizedBox(height: 20),
                _buildCittaTextField(),
                const SizedBox(height: 20),
                _buildBioTextField(),
                const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _saveUser();
                  Navigator.pop(context);
                }
              },
              child: const Text('Registrati'),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.white),
                foregroundColor: MaterialStateProperty.all(Colors.blue),
                elevation: MaterialStateProperty.all(0),
                shape: MaterialStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(color: Colors.blue),
                  ),
                ),
                padding: MaterialStateProperty.all(const EdgeInsets.symmetric(horizontal: 20, vertical: 10)),
                textStyle: MaterialStateProperty.all(
                  const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
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

  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: () async {
        final image = await _imagePicker.pickImage(source: ImageSource.gallery);
        if (image != null) {
          setState(() {
            _user.image = image.path;
          });
        }
      },
      child: CircleAvatar(
        radius: 50,
        backgroundImage: _user.image != null ? FileImage(File(_user.image!)) : null,
        child: _user.image == null ? const Icon(Icons.person) : null,
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
              _dynamicTagController.getFocusNode?.requestFocus();
            },
            controller: inputFieldValues.textEditingController,
            focusNode: inputFieldValues.focusNode,
            decoration: InputDecoration(
              labelText: 'Posso insegnare...',
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
                            mainAxisAlignment:
                            MainAxisAlignment.start,
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
                                  inputFieldValues
                                      .onTagRemoved(tag);
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
              final getColor = Color.fromARGB(
                  random.nextInt(256),
                  random.nextInt(256),
                  random.nextInt(256),
                  random.nextInt(256));
              final button = ButtonData(getColor, '');
              final tagData = DynamicTagData(value, button);
              inputFieldValues.onTagChanged(tagData);
            },
            onSubmitted: (value) {
              final getColor = Color.fromARGB(
                  random.nextInt(256),
                  random.nextInt(256),
                  random.nextInt(256),
                  random.nextInt(256));
              final button = ButtonData(getColor, '');
              final tagData = DynamicTagData(value, button);
              inputFieldValues.onTagSubmitted(tagData);
            },
          ),
        );
      },
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

        print(_locationController.text + "selected");
      },
    );
  }

  Widget _buildBioTextField() {
    return TextFormField(
      controller: _bioController,
      validator: (value) {
        if (value!.isEmpty) {
          return 'Inserisci una breve bio';
        }
        return null;
      },
      decoration: const InputDecoration(labelText: 'Bio',

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
      ),
      maxLines: 5,
      maxLength: 200,
      onSaved: (value) {
        _user.bio = value;
      },
    );
  }

  void _saveUser() async {
    // Salvataggio dei dati dell'utente nel tuo database
    // ...

    // Navigazione verso la pagina successiva
    Navigator.pop(context);
  }
}

class ButtonData {
  final Color buttonColor;
  final String emoji;
  const ButtonData(this.buttonColor, this.emoji);
}
