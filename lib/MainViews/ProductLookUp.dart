import 'dart:convert';

import 'package:AuthtentiChain/utils/Constants.dart';
import 'package:AuthtentiChain/utils/ProductData.dart';
import 'package:device_info/device_info.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';

import '../utils/ProductScan.dart';
import 'TheftReportPage.dart'; // Add this package

class ProductLookup extends StatefulWidget {
  const ProductLookup({Key? key}) : super(key: key);

  @override
  State<ProductLookup> createState() => _ProductLookupState();
}

class _ProductLookupState extends State<ProductLookup> {
  String _productId = '';
  String categoria = "";
  String localita = "";
  String materiali = "";
  String _productName = '';
  String producer = "";
  String particolari = '';
  String _productImage = ''; // Placeholder for product image
  bool _isManualEntry = false;
  bool _isScanning = false;
  bool _isProductFound = false;
  ProductData prodotto = ProductData(nomeProdotto: "", nomeProduttore:
  "", dataProduzione: "", localitaProduzione: "", categoria: "", materiali: "", particolariTipici: "", linkProdotto: "", immagini: "");
  String id = "";
  String location = "";
  String date = "";
  String device = "";

  void _scanQRCode() async {
    setState(() {
      _isScanning = true;
    });

    try {
      final String barcode = await FlutterBarcodeScanner.scanBarcode(
          '#007BFF', // Scan button color (your primary color)
          'Cancel', // Cancel button text
          true, // Use the camera on device
          ScanMode.QR); // Scan QR code only

      setState(() {
        _isScanning = false;
        _productId = barcode;
        _getProductDetails(); // Fetch product details based on barcode

      });
    } catch (e) {
      setState(() {
        _isScanning = false;
      });
      // Handle errors (e.g., camera permission denied)
    }
  }

  Future<void> fetchData() async {
    // Ottieni la posizione
    setState(() async{
      location = await _getLocation();

      // Ottieni la data corrente
      date = await _getCurrentDate();

      // Ottieni le informazioni sul dispositivo
      Map<String, String> deviceInfo = await _getDeviceInfo();

      // Estrai i dati relativi al dispositivo
      device = deviceInfo['model'] ?? 'Unknown Device';

    });

    print('Location: $location');
    print('Date: $date');
    print('Device: $device');
  }

  Future<String> _getLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      return 'Lat: ${position.latitude}, Lng: ${position.longitude}';
    } catch (e) {
      return 'Unable to fetch location';
    }
  }

  Future<void> checkAndRequestLocationPermission() async {
    var status = await Permission.locationWhenInUse.status;

    if (status.isGranted) {
      // I permessi sono già stati concessi
      print('Permessi GPS già concessi');
    } else if (status.isDenied) {
      // I permessi sono stati negati in precedenza, richiedi all'utente di concederli nuovamente
      var result = await Permission.locationWhenInUse.request();

      if (result.isGranted) {
        print('Permessi GPS concessi');
      }
    } else if (status.isPermanentlyDenied) {
      // I permessi sono stati permanentemente negati, mostra un messaggio all'utente per abilitarli manualmente dalle impostazioni del dispositivo
      print('Permessi GPS permanentemente negati');
    }
  }
  Future<String> _getCurrentDate() async {
    String timeZone = await FlutterTimezone.getLocalTimezone();
    DateTime now = DateTime.now();
    now.toString().replaceAll(':', "_");
    return now.toString().replaceAll('-', "_").replaceAll('.', "_");
  }

  Future<Map<String, String>> _getDeviceInfo() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Theme.of(context).platform == TargetPlatform.android) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      return {
        'model': androidInfo.model,
        'version': androidInfo.version.release,
        'brand': androidInfo.brand,
      };
    } else {
      // Implementa il recupero delle informazioni del dispositivo per altre piattaforme (es. iOS)
      return {'model': 'Unknown', 'version': 'Unknown', 'brand': 'Unknown'};
    }
  }

  void saveData() async{
    var database = FirebaseDatabase.instance;
    DatabaseReference ref = database.ref('reports' + _productId + '/' + date.replaceAll(':', "_"));
    ProductScan productScan = ProductScan(location: location, data: date, device: device, status: showTheftBanner ? 'rubato' : 'buone');
    SnackBar(
      content: Text('Invio segnalazione'),
      duration: Duration(seconds: 3), // Durata del messaggio
    );

    await ref.set(productScan.toJson()).onError((error, stackTrace) {
      print("tentativo fallito");
      print(error);
    },).whenComplete((){
      print("cmpletato");
    });
  }

  void _getProductDetails() async {
    // Implement logic to fetch product details from API or database
    // based on _productId

    final database = FirebaseDatabase.instance; // Initialize Firebase Database
    final reference = database.ref('products/$_productId'); // Reference based on product ID
    checkScans();
    final event = await reference.once(); // Get product data once
    setState(() {
      final data = event.snapshot.value as Map<dynamic, dynamic>;
      prodotto = ProductData.fromMap(data); // Convert data to Product object
      _productName = prodotto.nomeProdotto;
      producer = prodotto.nomeProduttore;
      categoria = prodotto.categoria;
      localita = prodotto.localitaProduzione;
      materiali = prodotto.materiali;
      particolari = prodotto.particolariTipici;
      _productImage = prodotto.immagini;
      _isProductFound = true;
    });
    saveData();
  }


  void checkScans() async {
    final DatabaseReference reportsProductIdRef = FirebaseDatabase.instance.ref(
        'reports' + _productId);

// Function to iterate through report IDs

    final snapshot = await reportsProductIdRef.once();

    if (snapshot.snapshot.value != null) {
      // Access the data as a Map (assuming a list of keys or a Map structure)
      Map<dynamic,dynamic> data = snapshot.snapshot.value as Map<dynamic,dynamic>;


      data.forEach((key, value) {
        // Assuming value is a Map containing product data
        final productData = ProductScan.fromMap(value);
        print("stato :" + productData.status);
        if(productData.status == "rubato"){
          print("entro stato :" + productData.status);
          setState(() {
            showTheftBanner = true;
          });
        }

        // Perform other operations on product data
      });

      saveData();
  }
    }


  void _searchProduct() {
    setState(() {
      _getProductDetails(); // Fetch product details based on _productId
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchData();
  }

  bool showTheftBanner = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Remove default back button
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.arrow_back,color: Colors.white,),
            onPressed: () {
              // Your custom back action here (e.g., Navigator.pop(context))
              Navigator.pop(context);
            },
          ),
        ),
        title: const Text('Ricerca Prodotto'
          ,style: TextStyle(
          color: Colors.white,
        )),
        backgroundColor: colorePrimario, // Primary color
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Inserisci ID Prodotto:',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10.0),
            TextField(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Inserisci ID Prodotto',
              ),
              onChanged: (value) {
                setState(() {
                  _productId = value;
                });
              },
            ),
            const SizedBox(height: 20.0),
            Visibility(
              visible: showTheftBanner, // Flag to control banner visibility
              child: ProductTheftAlertBanner(), // Display the banner
            ),
            const SizedBox(height: 20.0),
            Text(
              'Oppure scansiona il QR Code:',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10.0),
            SizedBox(
              height: 150.0,
              child: _isScanning
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                onPressed: _scanQRCode,
                child: const Text('Scansiona QR Code'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor: colorePrimario, // Text color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
            ),
            if (_isProductFound)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(), // Separator
                  Text(
                    'Dettagli del Prodotto:',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  Text(
                    'Nome: $_productName',
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 5.0),
                  Text(
                    'Categoria: $categoria',
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 5.0),
                  Text(
                    'Località: $localita',
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 5.0),
                  Text(
                    'Materiali: $materiali',
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 5.0),
                  Text(
                    'Produttore: $producer',
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 5.0),
                  Text(
                    'Particolari: $particolari',
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  Container(
                    width: double.infinity,
                    height: 200.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      image: DecorationImage(
                        image: MemoryImage(
                          base64Decode(_productImage),
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );

  }
}

class TheftReportConfirmationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Sfondo bianco
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        title: Text(
          'Scansione avvenuta',
          style: GoogleFonts.openSans(), // Font Google
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle,
              size: 100,
              color: Colors.blue, // Colore primario azzurro
            ),
            SizedBox(height: 20),

            Text(
              'Segnalazione di Furto Avvenuta',
              style: GoogleFonts.openSans(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            Text(
              'La scansione e la registrazione database ECMII.',
              style: GoogleFonts.openSans(
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}


class ProductTheftAlertBanner extends StatefulWidget {
  const ProductTheftAlertBanner({Key? key}) : super(key: key);

  @override
  State<ProductTheftAlertBanner> createState() => _ProductTheftAlertBannerState();
}

class _ProductTheftAlertBannerState extends State<ProductTheftAlertBanner> {
  bool _isVisible = true; // Flag to control banner visibility

  void showBanner() {
    setState(() {
      _isVisible = true; // Show the banner
    });
  }

  void hideBanner() {
    setState(() {
      _isVisible = false; // Hide the banner
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: Duration(milliseconds: 300), // Adjust animation duration
      opacity: _isVisible ? 1.0 : 0.0, // Control banner opacity
      child: Visibility(
        visible: _isVisible,
        child: Container(
          margin: EdgeInsets.all(20), // Add spacing around the banner
          padding: EdgeInsets.all(15), // Add padding within the banner
          decoration: BoxDecoration(
            color: Colors.red[200], // Use a red background for warning
            borderRadius: BorderRadius.circular(10), // Add rounded corners
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Wrap content vertically
            crossAxisAlignment: CrossAxisAlignment.center, // Center content
            children: [
              Icon(Icons.warning, size: 40, color: Colors.white), // Warning icon
              SizedBox(height: 10),
              Text(
                'Attenzione!', // Alert message
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 5),
              Text(
                'Sospetta provenienza illecita di questo articolo.', // Warning text
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: hideBanner, // Hide the banner on button press
                child: Text('Chiudi'), // Button label
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.red[200], backgroundColor: Colors.white, // Red button text color
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


