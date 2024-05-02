import 'package:AuthtentiChain/login/registrazione_filiera.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/login/registrazione_produttore.dart';
import '/login/registrazione_consumatore.dart';

import '../utils/Constants.dart';
import 'TipologiaRegistrazione.dart';

class TipologiaUtente extends StatelessWidget {
  const TipologiaUtente({Key? key}) : super(key: key);

  Widget build(BuildContext context) {
  return MaterialApp(
    theme: ThemeData(
      primaryColor: Colors.white,
      colorScheme: ColorScheme.fromSeed(seedColor: colorePrimario),
      textTheme: TextTheme(
        bodyText1: GoogleFonts.montserrat(), // Or any Google Font you like
      ),
      useMaterial3: true,
    ),
    home: Scaffold(
      appBar: AppBar(
        title:
        Center(
          child: Text(
            'Scegli il tuo ruolo',
            style: GoogleFonts.montserrat( // Or any Google Font you like
              color: Colors.black,
            ),
        )
        ,
        ),
      ),
      body: SingleChildScrollView( // Wrap the Column in SingleChildScrollView for scrollable content
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 70),
            Center(
              child: Wrap( // Use Wrap to arrange cards responsively
                spacing: 20.0, // Adjust spacing as needed
                runSpacing: 40.0, // Adjust spacing as needed
                children: [
                  InkWell(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Tipologiaregistrazione(tipo: 'p')),
                    ),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      elevation: 4,
                      child: Container(
                        width: MediaQuery.of(context).size.width / 0.5, // Half of screen width
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.factory,
                              size: 40,
                              color: colorePrimario,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Produttore',
                              style: GoogleFonts.montserrat( // Or any Google Font you like
                                fontSize: 18,
                                fontWeight: FontWeight.normal,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RegistrazioneConsumatore()),
                    ),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      elevation: 4,
                      child: Container(
                        width: MediaQuery.of(context).size.width / 0.5, // Half of screen width
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.shopping_basket,
                              size: 40,
                              color: colorePrimario,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Consumatore',
                              style: GoogleFonts.montserrat( // Or any Google Font you like
                                fontSize: 18,
                                fontWeight: FontWeight.normal,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RegistrazioneFiliera()),
                    ),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      elevation: 4,
                      child: Container(
                        width: MediaQuery.of(context).size.width / 0.5, // Half of screen width
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.align_horizontal_left_outlined, // Or choose a relevant icon for Filiera
                              size: 40,
                              color: colorePrimario,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Filiera',
                              style: GoogleFonts.montserrat( // Or any Google Font you like
                                fontSize: 18,
                                fontWeight: FontWeight.normal,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
            ,
          ],
        ),
      ),
    ),
  );
}
  Widget _buildChoiceCard({
    required BuildContext context,
    required String label,
    required IconData icon,
    required String routeName,
  }) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, routeName),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(icon, size: 30),
              const SizedBox(width: 10),
              Text(
                label,
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
