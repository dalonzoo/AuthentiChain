
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:AuthtentiChain/MainViews/MyProducts.dart';
import 'package:AuthtentiChain/utils/ProductData.dart';
import 'package:animate_do/animate_do.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';//add this
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../utils/Constants.dart';
import 'HomeView.dart';


class ProductRegistrationPage extends StatefulWidget {
  @override
  _ProductRegistrationPageState createState() => _ProductRegistrationPageState();
}

class _ProductRegistrationPageState extends State<ProductRegistrationPage> {
  final _formKey = GlobalKey<FormState>();

  // Product details
  String _categoria = '';
  String _materiali = '';
  String _particolariTipiciItaliani = '';
  String _linkProdottoOnline = '';
  List<Uint8List> _imageBytes = [];
  final categoriaController = TextEditingController();
  final materialiController = TextEditingController();
  final particolariController = TextEditingController();
  final localitaProduzioneController = TextEditingController();
  final nomeProdottoController = TextEditingController();
  final nomeProduttoreController = TextEditingController();
  final dataProduzioneController = TextEditingController();
  String image = "";
  ProductData product = ProductData(nomeProdotto: "", nomeProduttore: "", dataProduzione: "",
      localitaProduzione: "", categoria: "", materiali: "", particolariTipici: "", linkProdotto: "", immagini: "");
  // Colors for materials and Italian details
  Color _materialiColor = Colors.black;
  Color _particolariTipiciItalianiColor = Colors.black;
  String productId = "";
  // Image picker
  final _picker = ImagePicker();
  final _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  Random _rnd = Random();

  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
      length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
        'Registra prodotto',
        style: GoogleFonts.montserrat( // Or any Google Font you like
          color: Colors.black,
        ))),
        body: Form(
            key: _formKey,
            child: SingleChildScrollView(
                child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            controller: nomeProdottoController, // Add controller for product name
                            decoration: InputDecoration(
                              labelText: 'Nome prodotto',
                              labelStyle: TextStyle(color: colorePrimario),
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Inserisci il nome del prodotto';
                              }
                              return null;
                            },
                          ),
                          // Località di Produzione
                          const SizedBox(height: 20),
                          // Categoria
                          TextFormField(
                            controller: categoriaController,
                            decoration: InputDecoration(
                              labelText: 'Categoria',
                              labelStyle: TextStyle(color: colorePrimario),
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Inserisci la categoria del prodotto';
                              }
                              return null;
                            },
                            onSaved: (value) =>
                                setState(() => _categoria = value!),
                          ),
                          const SizedBox(height: 20),

                          // Materiali
                          TextFormField(
                            controller: materialiController,
                            decoration: InputDecoration(
                              labelText: 'Materiali',
                              labelStyle: TextStyle(color: colorePrimario),
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Inserisci i materiali del prodotto';
                              }
                              return null;
                            },
                            onSaved: (value) =>
                                setState(() => _materiali = value!),
                          ),
                          const SizedBox(height: 20),

                          // Particolari tipici italiani
                          TextFormField(
                            controller: particolariController,
                            decoration: InputDecoration(
                              labelText: 'Particolari tipici italiani',
                              labelStyle: TextStyle(color: colorePrimario),
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Inserisci i particolari tipici italiani del prodotto';
                              }
                              return null;
                            },
                            onSaved: (value) =>
                                setState(() =>
                                _particolariTipiciItaliani = value!),
                          ),
                          const SizedBox(height: 20),

                          // Link del prodotto online
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Link del prodotto online (opzionale)',
                              labelStyle: TextStyle(color: colorePrimario),
                              border: OutlineInputBorder(),
                            ),
                            onSaved: (value) =>
                                setState(() => _linkProdottoOnline = value!),
                          ),
                          const SizedBox(height: 20),

                          // Caricamento immagini
                          SizedBox(
                            height: 300, // Adjust height as needed (optional)
                            child:    Expanded(
                              child: GridView.builder(
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3, // Numero di colonne desiderato
                                  mainAxisSpacing: 10.0, // Spaziatura verticale tra le immagini
                                  crossAxisSpacing: 10.0, // Spaziatura orizzontale tra le immagini
                                ),
                                itemCount: _imageBytes.length + (_imageBytes.length < 10 ? 1 : 0),
                                itemBuilder: (context, index) {
                                  if (index < _imageBytes.length) {
                                    // Decode Uint8List to image
                                    final image = Image.memory(_imageBytes[index]);
                                    // Wrap image in a container for resizing
                                    return Stack(
                                      children: [
                                        AspectRatio(
                                          aspectRatio: 1.0, // Mantieni l'aspect ratio quadrato
                                          child: image,
                                        ),
                                        Positioned(
                                          top: 0,
                                          right: 0,
                                          child: IconButton(
                                            onPressed: () {
                                              setState(() {
                                                _imageBytes.removeAt(index);
                                              });
                                            },
                                            icon: Icon(
                                              Icons.close,
                                              color: Colors.red,
                                              size: 30.0,
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  } else {
                                    // Aggiungi il pulsante "Aggiungi immagine"
                                    return OutlinedButton(
                                      onPressed: () async {
                                        final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
                                        if (pickedFile != null) {
                                          // Leggi i byte dell'immagine e aggiungili alla lista
                                          final bytes = await pickedFile.readAsBytes();
                                          setState(() => _imageBytes.add(bytes));
                                          image = base64Encode(bytes);
                                          final gemini = Gemini.instance;
                                          String? res = "";
                                          String req = "Dimmi il nome del prodotto,la sua categoria,i materiali,poi tutti i particolari. Scrivimeli tutti separati da una virgola in unica frase nel formato nome prodotto,categoria del prodotto,materiali,particolari (devi essere quanto piu preciso e dettagliato possibile in Italiano ad esempio: Borsa unisex, borse di pelle, pelle, fibia in alluminio ).";

                                          if(categoriaController.text.length == 0) {
                                            gemini.textAndImage(
                                                text: req,
                                                /// text
                                                images: [bytes]

                                              /// list of images
                                            )
                                                .then((value) {
                                              res = value?.content?.parts?.last
                                                  .text;
                                              List<String>? splitText = res
                                                  ?.split(',');
                                              setState(() {
                                                print("inserisco dati :" +
                                                    splitText.toString());
                                                nomeProdottoController.text = splitText![0];
                                                categoriaController.text =
                                                splitText![1];
                                                materialiController.text =
                                                splitText![2];
                                                particolariController.text =
                                                splitText![3];
                                              });
                                            })
                                                .catchError((e) =>
                                                print('textAndImageInput' + e));
                                          }
                                        }
                                      },
                                      child: Icon(
                                        Icons.add,
                                        color: colorePrimario,
                                        size: 30.0,
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: colorePrimario, shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(100.0),
                                        ),
                                        padding: EdgeInsets.zero,
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),

                          ),
                          SlideInUp(
                            duration: const Duration(milliseconds: 500),
                            child: Center(
                              child: MaterialButton(
                                onPressed: () async{
                                  var database = FirebaseDatabase.instance;
                                  DatabaseReference reference = database.ref('products'); // Replace 'products' with your actual database path
                                  DatabaseReference newProductRef = reference.push(); // Create a reference with an auto-generated ID
                                  setState(() {
                                    productId = getRandomString(15);
                                  });

                                  Map<String, dynamic> productData = {
                                    'nomeProdotto': nomeProdottoController.text,
                                    'nomeProduttore': 'Mario Rossi',
                                    'dataProduzione': DateTime.now().toString(),
                                    'localitaProduzione': "Roma",
                                    'categoria': categoriaController.text,
                                    'materiali': materialiController.text,
                                    'particolariTipici': particolariController.text,
                                    'linkProdotto': _linkProdottoOnline,
                                    'immagini': image,
                                  };

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Registro prodotto'),
                                    ),
                                  );
                                  reference.child(productId).set(productData).then((value) {
                                    print('Product saved successfully with ID: $productId');
                                  }).catchError((error) {
                                    print('Failed to save product: ${error.toString()}');
                                  });
                                  reference.child(productId).set(productData).then((value) {
                                    DatabaseReference reference = FirebaseDatabase.instance.ref('users'); // Replace 'products' with your actual database path
                                    DatabaseReference productRef = reference.child(FirebaseAuth.instance.currentUser!.uid);

                                    productRef.update({'prodotti': productId}).then((value) {
                                      print('Field updated successfully');
                                    }).catchError((error) {
                                      print('Failed to update field: ${error.toString()}');
                                    });
                                    // Replace with the actual product ID
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => ProductRegistrationSuccessPage(id: productId)), // Replace with your destination page
                                    );
                                    print('Product saved successfully with ID: $productId');
                                  }).catchError((error) {
                                    print('Failed to save product: ${error.toString()}');
                                  });



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
                                  "Registra", // Customizable text
                                  style: GoogleFonts.montserrat(
                                    fontSize: 16.0,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),



                        ])))));
  }





}


class ProductRegistrationSuccessPage extends StatelessWidget {
  String id;
  ProductRegistrationSuccessPage({required this.id});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[100],
      appBar: AppBar(
        backgroundColor: Colors.transparent, // renders AppBar transparent
        elevation: 0, // removes shadow
        leading: IconButton(
          icon: Icon(Icons.close), // using close icon
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Myproducts(productId: id)), // Replace with your destination page
            );
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.share), // Icon for "Condividi su marketplace"
            onPressed: () {
              // Action for "Condividi su marketplace"
              // Add your logic here
            },
          ),
        ],
      ),
      body: Center(
        child: Container(
          margin: EdgeInsets.all(20),
          padding: EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.grey,
                offset: Offset(0, 1),
                blurRadius: 8,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 10),
              Icon(
                Icons.check_circle,
                size: 100,
                color: Colors.green,
              ),
              SizedBox(height: 20),
              Text(
                'Prodotto inserito correttamente!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Abbiamo registrato sulla blockchain il prodotto, ora decidi tu come condividere l\'id univoco.',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 20),
              // Code representation
              Container(
                height: 60,
                padding: EdgeInsets.all(5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: LinearGradient(
                    colors: [Colors.green, Colors.white, Colors.red], // Green, white, red for Italian flag
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
                child:
                Text(
                  id,// Customizable text
                  style: GoogleFonts.montserrat(
                    fontSize: 26.0,
                    color: Colors.black26,
                    fontWeight: FontWeight.normal,
                  ),
              ),),

              SizedBox(height: 40),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // QR Code button
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => QRCodePage(id: id)), // Replace with your destination page
                      );
                    },
                    icon: Icon(Icons.qr_code),
                    label: Text('Genera QR Code'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  // NFC Tag button
                  ElevatedButton.icon(
                    onPressed: () {
                      // Implement NFC tag writing logic
                      writeNFCTag();
                    },
                    icon: Icon(Icons.nfc),
                    label: Text('Scrivi su Tag NFC'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              SizedBox(height: 50), // New text with highlighted "Clicca qui"
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Non sai come registrare il codice?',
                    style: TextStyle(
                      fontSize: 11,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // Add your action here (e.g., navigate to a help page)
                    },
                    child: Text(
                      'Clicca qui',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.green[200], // Highlight the text with blue color
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

  // Implement functions for QR Code generation, NFC tag writing
  void generateQRCode() {
    // TODO: Implement QR Code generation logic
    print('Generate QR Code');
  }

  void writeNFCTag() {
    // TODO: Implement NFC tag writing logic
    print('Write to NFC Tag');
  }
}


class QRCodePage extends StatelessWidget {
  // ... (qrCodeData and primaryColor properties)
  String id;

  QRCodePage({required this.id});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Generated QR Code', style: TextStyle(fontFamily: 'GoogleSans')),
        backgroundColor: Colors.white,
      ),
      body: Center(
        child: Neumorphic(
          style: NeumorphicStyle(
            depth: 4,
            lightSource: LightSource.topLeft,
            shape: NeumorphicShape.concave,
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                QrImageView(
                  backgroundColor: Colors.white,
                  foregroundColor: colorePrimario,
                  data: id, // The QR code data
                  padding: EdgeInsets.all(20), // Add padding around the QR code
                ),
                SizedBox(height: 20),
                Text(
                  'Scansiona per vedere il codice',
                  style: TextStyle(
                    fontFamily: 'GoogleSans',
                    fontSize: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

