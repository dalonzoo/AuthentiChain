import 'package:AuthtentiChain/login/registrazione_produttore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../utils/Constants.dart';
import 'RegistrazioneIntelligente.dart';


class Tipologiaregistrazione extends StatefulWidget {
  String tipo;
  Tipologiaregistrazione({required this.tipo});
  @override
  State<Tipologiaregistrazione> createState() => _RegistrazioneInsegnanteState();
}

class _RegistrazioneInsegnanteState extends State<Tipologiaregistrazione> {

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Scegli come',
          style: GoogleFonts.montserrat( // Or any Google Font you like
            color: Colors.black,
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 0),
            InkWell(
              onTap: () =>
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => RegistrazioneInsegnante()),
                  ),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                elevation: 4,
                child: Container(
                  width: MediaQuery
                      .of(context)
                      .size
                      .width - 80, // Adjust width as needed
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.edit,
                        // Replace with an icon for manual registration
                        size: 40,
                        color: colorePrimario,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Registrazione Manuale',
                        style: GoogleFonts
                            .montserrat( // Or any Google Font you like
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Inserisci i tuoi dati manualmente',
                        style: GoogleFonts
                            .montserrat( // Or any Google Font you like
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            InkWell(
              onTap: () =>
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => RegistrazioneIntelligente(tipo: widget.tipo)),
                  ),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                elevation: 4,
                child: Container(
                  width: MediaQuery
                      .of(context)
                      .size
                      .width - 80,
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.flash_on,
                        // Replace with an icon for intelligent registration
                        size: 40,
                        color: colorePrimario,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Registrazione Intelligente',
                        style: GoogleFonts
                            .montserrat( // Or any Google Font you like
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Usa la voce per registrarti in pochi secondi!',
                        style: GoogleFonts
                            .montserrat( // Or any Google Font you like
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}