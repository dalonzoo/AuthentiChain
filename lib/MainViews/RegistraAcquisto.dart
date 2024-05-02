import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:AuthtentiChain/utils/Constants.dart';
import 'package:camera/camera.dart'; // Import camera package
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';

import '../utils/Usertype.dart'; // Import image_picker package

class RegistraAcquisto extends StatefulWidget {
  @override
  _RegistraAcquistoState createState() => _RegistraAcquistoState();
}

class _RegistraAcquistoState extends State<RegistraAcquisto> {
  late CameraController _cameraController;
  final _picker = ImagePicker();
  final _formKey = GlobalKey<FormState>();
  XFile? _image; // Store captured image
  String productId = "ErKx1xAjEbqqJ1R";
  @override
  void initState() {
    super.initState();
    _availableCameras().then((cameras) {
      _cameraController = CameraController(cameras[0], ResolutionPreset.medium);
      _cameraController.initialize().then((_) {
        if (!mounted) return;
        setState(() {});
      });
    });
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  Future<List<CameraDescription>> _availableCameras() async {
    final cameras = await availableCameras();
    return cameras;
  }

  Future<void> _captureImage() async {
    try {
      final image = await _cameraController.takePicture();
      setState(() {
        _image = image;
      });
    } on CameraException catch (e) {
      print(e);
    }
  }

  Future<void> _pickImageFromGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = pickedFile;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registra Acquisto'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.0),
        child: Center(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Space before product ID or image
                SizedBox(height: 20.0),
                  TextField(
                    onTap: _scanQRCode,
                    readOnly: true, // Make the field read-only
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: productId == "" ? 'Codice Prodotto' : productId,
                    ),
                  ),

                // Space between product ID and image/capture button
                SizedBox(height: 20.0),

                // Image preview or capture button
                if (_image != null)
                  Image.file(File(_image!.path))
                else
                  Stack(
                    alignment: Alignment.center, // Center stack content
                    children: [
                      // Camera preview (uncomment if using camera)
                      // _cameraController.value.isInitialized
                      //     ? CameraPreview(_cameraController)
                      //     : Container(),
                      IconButton(
                        icon: Icon(Icons.camera_alt_outlined),
                        onPressed: () => _pickImageFromGallery(), // Use gallery for now
                        iconSize: 100.0,
                      ),
                    ],
                  ),

                // Space between image and button
                SizedBox(height: 20.0),

                // Register button with full width
                ElevatedButton.icon(
                  onPressed: () async {
                    if (_image == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Seleziona un\'immagine del prodotto'),
                        ),
                      );
                      return;
                    }
                    // Send image data to ECMII database (replace with your logic)
                    final bytes = await File(_image!.path).readAsBytes();
                    final imageBase64 = base64Encode(bytes);
                    // TODO: Implement your ECMII database interaction logic here
                    // ... send imageBase64 data to ECMII ...
                    print('Sending image data to ECMII...');
                    var database = FirebaseDatabase.instance;
                    DatabaseReference reference = database.ref('purchases'); // Replace 'products' with your actual database path

                    DateTime now = DateTime.now();
                    String userId = FirebaseAuth.instance.currentUser!.uid;
                    String location = "";
                    String time = now.toString().replaceAll('-', "_").replaceAll('.', "_").replaceAll(':', "_");
                    location = await _getLocation();

                    Map<String, dynamic> productData = {
                      'image': imageBase64,
                      'data': time,
                      'location': location,
                      'idUser': userId,
                      'idProduct' : productId
                    };

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Registro prodotto'),
                      ),
                    );

                    final userRef = FirebaseDatabase.instance.ref('users/$userId');
                    final event = await userRef.once();


                    final data = event.snapshot.value as Map<dynamic, dynamic>;
                    UserData user = UserData.fromMap(data);
                    user.acquisti = productId + time;



                    await userRef.set(user.toJson()).onError((error, stackTrace) {
                      print("tentativo fallito");
                      print(error);
                    },).whenComplete((){

                    });
                    //salvataggio purcheses
                    reference.child(productId + time).set(productData).then((value) {


                      // Replace with the actual product ID
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => PurchaseConfirmationPage()), // Replace with your destination page
                      );
                      print('Product saved successfully with ID: $productId');
                    }).catchError((error) {
                      print('Failed to save product: ${error.toString()}');
                    });
                  },
                  icon: Icon(Icons.send),
                  label: Text('Registra Acquisto'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50.0),
                    foregroundColor: Colors.white,
                    backgroundColor: colorePrimario,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  void _scanQRCode() async {


    try {
      final String barcode = await FlutterBarcodeScanner.scanBarcode(
          '#007BFF', // Scan button color (your primary color)
          'Cancel', // Cancel button text
          true, // Use the camera on device
          ScanMode.QR); // Scan QR code only

      setState(() {

        productId = barcode;

      });
    } catch (e) {

      // Handle errors (e.g., camera permission denied)
    }
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
}

class PurchaseConfirmationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[100],
      appBar: AppBar(
        title: Text('Acquisto Registrato'),
        centerTitle: true,
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle,
              size: 100,
              color: Colors.green,
            ),
            SizedBox(height: 20),
            Text(
              'Acquisto registrato correttamente!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,

              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            Text(
              'Il tuo acquisto è stato inserito con successo nel database ECMII.',
              style: TextStyle(
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




