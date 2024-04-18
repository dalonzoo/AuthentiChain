import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../utils/Usertype.dart';


class RegistrazioneStudente extends StatefulWidget {
  const RegistrazioneStudente({Key? key}) : super(key: key);

  @override
  State<RegistrazioneStudente> createState() => _RegistrazioneStudenteState();
}

class _RegistrazioneStudenteState extends State<RegistrazioneStudente> {
  final _formKey = GlobalKey<FormState>();
  final _imagePicker = ImagePicker();
  final _cittaController = TextEditingController();
  final _materie = <String>[];

  User _user = User();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrazione Studente'),
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
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _saveUser();
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Registrati'),
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
    return DropdownButtonFormField<String>(
      value: _user.materia,
      hint: const Text('Scegli una materia'),
      items: _materie.map((materia) {
        return DropdownMenuItem<String>(
          value: materia,
          child: Text(materia),
        );
      }).toList(),
      onChanged: (materia) {
        setState(() {
          _user.materia = materia;
        });
      },
    );
  }

  Widget _buildCittaTextField() {
    return TextFormField(
      controller: _cittaController,
      validator: (value) {
        if (value!.isEmpty) {
          return 'Inserisci la tua città';
        }
        return null;
      },
      decoration: const InputDecoration(labelText: 'Città'),
      onSaved: (value) {
        _user.citta = value;
      },
    );
  }

  void _saveUser() async {

  }
}
