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

class ProductLookupFiliera extends StatefulWidget {
  const ProductLookupFiliera({Key? key}) : super(key: key);

  @override
  State<ProductLookupFiliera> createState() => _ProductLookupFilieraState();
}

class _ProductLookupFilieraState extends State<ProductLookupFiliera> {
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
  // Quality control answers
  Map<String, dynamic> _qualityControlAnswers = {}; // Dynamic values for answers

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

      location = await _getLocation();

      // Ottieni la data corrente
      date = await _getCurrentDate();

      // Ottieni le informazioni sul dispositivo
      Map<String, String> deviceInfo = await _getDeviceInfo();

      // Estrai i dati relativi al dispositivo
      device = deviceInfo['model'] ?? 'Unknown Device';


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
    ProductScan productScan = ProductScan(location: location, data: date, device: device, status: _qualityControlAnswers['productStatus']);
    SnackBar(
      content: Text('Invio segnalazione'),
      duration: Duration(seconds: 3), // Durata del messaggio
    );

    await ref.set(productScan.toJson()).onError((error, stackTrace) {
      print("tentativo fallito");
      print(error);
    },).whenComplete((){
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ScanConfirmationPage()),
      );
      print("cmpletato");
    });
  }

  void _getProductDetails() async {
    // Implement logic to fetch product details from API or database
    // based on _productId

    final database = FirebaseDatabase.instance; // Initialize Firebase Database
    final reference = database.ref('products/$_productId'); // Reference based on product ID

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
          ElevatedButton(
            onPressed: _searchProduct,
            child: const Text('Cerca'),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white, backgroundColor: colorePrimario, // Text color
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ),
          const SizedBox(height: 20.0),
          Center(child: Text(
            'Oppure scansiona il QR Code:',
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),)
          ,
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
      // Add quality control questions here
      const SizedBox(height: 40.0),
      Center(child: Text(
        'Controllo Qualità:',
        style: TextStyle(
          fontSize: 18.0,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
        ),
      const SizedBox(height: 10.0),
      // Example quality control question


      // Multi-select dropdown for product status
      DropdownButtonFormField<String>(
        value: _qualityControlAnswers['productStatus'],
        hint: const Text('Seleziona Stato Prodotto'),
        items: [
          'Ottime',
          'Sufficienti',
          'Rubato',
        ].map((String item) => DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        )).toList(),
        onChanged: (String? newValue) {
          setState(() => _qualityControlAnswers['productStatus'] = newValue);
        },
      ),

      // Add more quality control questions as needed
      const SizedBox(height: 20.0),
      ElevatedButton(
        onPressed: (){
              saveData();

        },
        child: const Text('Invia Controllo Qualità'),
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: colorePrimario, // Text color
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
      ),
    ],
  ),
    ])));

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


class ScanConfirmationPage extends StatelessWidget {
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
              'Scansione inviata con successo!',
              style: GoogleFonts.openSans(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            Text(
              'La scansione è stata salvata su database ECMII.',
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

