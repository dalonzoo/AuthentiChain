import 'package:AuthtentiChain/utils/Constants.dart';
import 'package:AuthtentiChain/utils/ProductScan.dart';
import 'package:device_info/device_info.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';

import '../utils/PurchaseData.dart';
import '../utils/Usertype.dart';


class TheftReportPage extends StatelessWidget {
  String productId;

  TheftReportPage({required this.productId});
  @override
  Widget build(BuildContext context) {
    return Container(
        child: TheftReportForm(), // Utilizza TheftReportForm per il contenuto della pagina
    );
  }
}

class TheftReportForm extends StatefulWidget {

  @override
  _TheftReportFormState createState() => _TheftReportFormState();
}

class _TheftReportFormState extends State<TheftReportForm> {
  final TextEditingController _idController = TextEditingController();
  String id = "";
  String location = "";
  String date = "";
  String device = "";
  String productId = "";
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkAndRequestLocationPermission();
    fetchData();
    function();
  }

  void function() async{
    final userRef = FirebaseDatabase.instance.ref('users/' + FirebaseAuth.instance.currentUser!.uid);
    final event = await userRef.once();


    final data = event.snapshot.value as Map<dynamic, dynamic>;
    UserData user = UserData.fromMap(data);


    print(user.acquisti);
    final database = FirebaseDatabase.instance; // Initialize Firebase Database
    final reference = database.ref('purchases/' + user.acquisti); // Reference based on product ID
    Purchasedata productPurchase = Purchasedata(image: "", data: "", location: "", userId: "", productId: "");
    final event2 = await reference.once(); // Get product data once
    setState(() {
      final data = event2.snapshot.value as Map<dynamic, dynamic>;
      productPurchase = Purchasedata.fromMap(data); // Convert data to Product object
    });




    setState(() {
      productId = productPurchase.productId;

    });
  }

  Future<void> fetchData() async {



    location = await _getLocation();

  // Ottieni la data corrente
  String data = await _getCurrentDate();

  // Ottieni le informazioni sul dispositivo
  Map<String, String> deviceInfo = await _getDeviceInfo();

  // Estrai i dati relativi al dispositivo
  String device1 = deviceInfo['model'] ?? 'Unknown Device';
    // Ottieni la posizione
    setState((){
      date = data;
      device = device1;

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
    DatabaseReference ref = database.ref('reports' +productId + '/' + date.replaceAll(':', "_"));
    ProductScan productScan = ProductScan(location: location, data: date, device: device, status: 'rubato');
    SnackBar(
      content: Text('Invio segnalazione'),
      duration: Duration(seconds: 3), // Durata del messaggio
    );

    await ref.set(productScan.toJson()).onError((error, stackTrace) {
      print("tentativo fallito");
      print(error);
    },).whenComplete((){
      print("cmpletato"); Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => TheftReportConfirmationPage()), // Replace with your destination page
      );
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Segnala Furto',
          style: TextStyle(
            color: Colors.white, // Assuming a light app theme
            fontSize: 20.0,
          ),
        ),
        backgroundColor: const Color(0xFF007BFF), // Primary color (consider brand guidelines)
      ),
      body: Center( // Center the entire body content
        child: SingleChildScrollView( // Wrap in SingleChildScrollView for scrollable content
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column( // Maintain column structure for layout
              mainAxisAlignment: MainAxisAlignment.center, // Center the column content
              crossAxisAlignment: CrossAxisAlignment.center, // Center the column content horizontally
              children: [
                Text(
                  'Inserisci l\'ID del prodotto rubato:',
                  style: TextStyle(
                    fontSize: 19.0,
                    color: Colors.black87, // Adjust based on app theme
                  ),
                ),
                const SizedBox(height: 10.0),
                DropdownButtonFormField<String>(
                  value: productId, // Pre-populate with initial value
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(color: Colors.grey.shade400),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(color: const Color(0xFF007BFF)), // Primary color
                    ),
                  ),
                  items: <String>[productId,] // Example options
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    // Update state or handle selection change
                  },
                ),
                const SizedBox(height: 20.0),
                ElevatedButton(
                  onPressed: () {
                    // Implement logic for submitting theft report
                    // ...
                    saveData();
                  },
                  child: Text(
                    'Invia Segnalazione',
                    style: TextStyle(color: Colors.white), // Assuming white text on primary button
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorePrimario, // Primary color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 15.0), // Adjust padding as needed
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _idController.dispose();
    super.dispose();
  }
}


void main() {
  runApp(MaterialApp(
    home: TheftReportConfirmationPage(),
  ));
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
          'Segnalazione Avvenuta',
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
              'La segnalazione del furto è stata inviata con successo alle forze dell\'ordine e al database ECMII.',
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

