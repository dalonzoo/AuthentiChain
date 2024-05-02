import 'dart:convert';

import 'package:AuthtentiChain/MainViews/HomeView.dart';
import 'package:AuthtentiChain/utils/Constants.dart';
import 'package:AuthtentiChain/utils/ProductData.dart';
import 'package:AuthtentiChain/utils/ProductScan.dart';
import 'package:AuthtentiChain/utils/PurchaseData.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../utils/Usertype.dart'; // Import for Firebase Realtime Database

class MyproductsConsumer extends StatefulWidget {

  const MyproductsConsumer({Key? key}) : super(key: key);

  @override
  State<MyproductsConsumer> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<MyproductsConsumer> with TickerProviderStateMixin{
  Purchasedata productPurchase = Purchasedata(productId: "",data: "", image: "",location: '', userId: '');
  List<String> dates = [];
  List<String> pos = [];
  List<String> devices = [];
  String productId = "";
  double devicesIndicator =0,locationIndicator = 0,datesIndicator = 0,overallIndicator = 0;
  @override
  void initState() {
    super.initState();
    _getProductDetails(); // Fetch product details on initialization
  }
  String productName = "";
  String image = "";
  Future<void> _getProductDetails() async {

    final userRef = FirebaseDatabase.instance.ref('users/' + FirebaseAuth.instance.currentUser!.uid);
    final event = await userRef.once();


    final data = event.snapshot.value as Map<dynamic, dynamic>;
    UserData user = UserData.fromMap(data);


    print(user.acquisti);
    final database = FirebaseDatabase.instance; // Initialize Firebase Database
    final reference = database.ref('purchases/' + user.acquisti); // Reference based on product ID

    final event2 = await reference.once(); // Get product data once
    setState(() {
      final data = event2.snapshot.value as Map<dynamic, dynamic>;
      productPurchase = Purchasedata.fromMap(data); // Convert data to Product object
    });



    final purchaseRef = database.ref('products/' + productPurchase.productId); // Reference based on product ID

    final event3 = await purchaseRef.once(); // Get product data once
    setState(() {
      productId = productPurchase.productId;
      final data = event3.snapshot.value as Map<dynamic, dynamic>;
      ProductData productData = ProductData.fromMap(data); // Convert data to Product object
      productName = productData.nomeProdotto;
      image = productData.immagini;
    });

    getProductReport(productPurchase.productId);


  }


  void getProductReport(String productId) async{
    final DatabaseReference reportsProductIdRef = FirebaseDatabase.instance.ref(
        'reports' + productId);

// Function to iterate through report IDs

    final snapshot = await reportsProductIdRef.once();

    if (snapshot.snapshot.value != null) {
      // Access the data as a Map (assuming a list of keys or a Map structure)
      Map<dynamic,dynamic> data = snapshot.snapshot.value as Map<dynamic,dynamic>;


        data.forEach((key, value) {
          // Assuming value is a Map containing product data
          final productData = ProductScan.fromMap(value);
          pos.add(productData.location);
          dates.add(productData.data);
          devices.add(productData.device);

          // Perform other operations on product data
        });

      final gemini = Gemini.instance;
      print("invio " + pos.toString() + "," + dates.toString() + "," + devices.toString());
      gemini.text("Ora ti mando una lista di scansioni fatti di un prodotto separate da posizioni (latidutine e longitudine), data di scansione e device di scansione. QUello che devi fare è"
          "darmi 3 parametri di sicurezza da un massimo di 100 fino a un minimo di 1 per la posizione se le scansioni sono troppo distanti tra loro in termini di posizioni, per i dispositivi se cambiano ogni scansione,per le date se queste sono troppo ravvicinate nel tempo.Calcola i parametri e inviameli, Rispondimi con i 3 parametri nell'ordine locations,dates,devices divisi da virgola (solo i numeri tipo 67,88,70). Ecco la lista :" +
      pos.toString() + "," + dates.toString() + "," + devices.toString())
          .then((value) {
        String res = value!.output!;

        print(res);
        List<String> splitText = res.split(',');
        setState(() {
          locationIndicator = double.parse(res.split(",")[0]);
          datesIndicator = double.parse(res.split(",")[1]);
          devicesIndicator = double.parse(res.split(",")[2]);

          overallIndicator = (locationIndicator + datesIndicator + devicesIndicator) / 3;
        });
      }) /// or value?.content?.parts?.last.text
          .catchError((e) => print('Errore'+  e.toString()));



    } else {
      print('No data found in reportsProductId');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            // Azione da eseguire al click del pulsante "back"
            // Puoi navigare indietro alla schermata precedente
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.transparent,
        elevation: 0.0, // Rimuove l'ombra sotto la barra
        title: Text(
          'I tuoi prodotti',
          style: GoogleFonts.openSans(),
        ),
        centerTitle: true, // Centra il testo
      ),
      body: productPurchase == null
          ? const Center(child: CircularProgressIndicator()) // Show progress indicator while loading
          : SingleChildScrollView(
        child: Container(
      margin: const EdgeInsets.all(10.0),
      child: Column(
        children: [ProductCard(product: productPurchase!, id: productId, image: image, productName: productName,),
          SizedBox(height: 30,),
          Container(
            padding: const EdgeInsets.all(15.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey,
                  offset: Offset(0.0, 2.0),
                  blurRadius: 5.0,
                  spreadRadius: 2.0,
                ),
              ],
            ),
            child: Column(
              children: [
                // Title
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Parametro sicurezza prodotti ECMII',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10.0),

                // Circular progress indicator for overall security
                Stack(
                  alignment: Alignment.center, // Center the stack content
                  children: [
                    SizedBox(
                      width: 150.0, // Set width
                      height: 150.0, // Set height
                      child:
                      CircularProgressIndicator(
                      value: overallIndicator,
                      strokeWidth: 5.0,
                      valueColor: getColorBasedOnPercentageAnimation(overallIndicator),
                    )),
                    Text(
                      '${overallIndicator}%', // Replace with calculation logic
                      style: TextStyle(
                        fontSize: 28.0,
                        fontWeight: FontWeight.bold,
                        color: colorePrimario, // Set color based on percentage
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10.0),

                // Horizontal indicators for sub-parameters
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox( // Wrap with SizedBox for fixed width
                  width: 100.0, // Adjust width as needed
                  child: _buildSubIndicator(
                    'Locations',
                    locationIndicator as double,
                    Colors.green, // Set color for Posizione
                  ),
                ),
                SizedBox(
                  width: 100.0, // Adjust width as needed
                  child: _buildSubIndicator(
                    'Dates',
                    datesIndicator as double,
                    Colors.amber, // Set color for Temporali
                  ),
                ),
                SizedBox(
                  width: 100.0, // Adjust width as needed
                  child: _buildSubIndicator(
                    'Devices',
                    devicesIndicator as double
                    ,
                    Colors.red, // Set color for Altro
                  ),
                ),
              ],
            ),
              ],
            ),
          ),
        ],
      ),
    )));
  }


  Color getColorBasedOnPercentage(double percentage) {
    if (percentage >= 80) {
      return Colors.green;
    } else if (percentage >= 60) {
      return Colors.amber;
    } else {
      return Colors.red;
    }
  }

// Function to build a sub-indicator with text and horizontal progress bar
  Widget _buildSubIndicator(String title, double percentage, Color color) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14.0,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 5.0),
        LinearProgressIndicator(
          value: percentage / 100.0, // Convert percentage to value (0.0 - 1.0)
          backgroundColor: Colors.grey.shade200,
          valueColor: AlwaysStoppedAnimation(color), // Use a static color
        ),
      ],
    );
  }




  // Function to calculate overall security percentage (replace with your logic)
  double calculateOverallSecurityPercentage() {
    // Implement your logic to calculate the overall security percentage based on sub-parameters
    return 70.0; // Replace with actual calculation
  }

// Function to calculate sub-parameter security percentages (replace with your logic)
  double calculatePositionSecurityPercentage() {
    // Implement your logic to calculate the position security percentage
    return 80.0; // Replace with actual calculation
  }

  double calculateTemporalSecurityPercentage() {
    // Implement your logic to calculate the temporal security percentage
    return 60.0; // Replace with actual calculation
  }

  double calculateOtherSecurityPercentage() {
    // Implement your logic to calculate the other security percentage
    return 50.0; // Replace with actual calculation
  }

  Animation<Color?> getColorBasedOnPercentageAnimation(double percentage) {
    final ColorTween colorTween;

    if (percentage >= 80) {
      colorTween = ColorTween(begin: colorePrimario, end: colorePrimario);
    } else if (percentage >= 60) {
      colorTween = ColorTween(begin: colorePrimario, end: colorePrimario);
    } else {
      colorTween = ColorTween(begin: Colors.grey.shade200, end: Colors.red);
    }

    final AnimationController animationController = AnimationController(
      vsync: this, // Use the current TickerProvider (assuming in a StatefulWidget)
      duration: const Duration(milliseconds: 500), // Adjust duration as needed
    );

    final Animation<Color?> colorAnimation = colorTween.animate(animationController);
    return colorAnimation;
  }
}

class ProductCard extends StatelessWidget {
  final Purchasedata product;
  final String id;
  final String productName;
  final String image;
  const ProductCard({required this.image,required this.productName,required this.id, required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey,
            offset: Offset(0.0, 2.0),
            blurRadius: 5.0,
            spreadRadius: 2.0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Align text to the left
        children: [
          // Conditionally display image or progress indicator
          image.isEmpty
              ? Center(child: CircularProgressIndicator(color: colorePrimario,)) // Show progress indicator if image is empty
              : Center(
            child: ClipRRect(
              // Set rounded corners (optional)
              child: Image.memory(
                base64Decode(image),
                fit: BoxFit.cover, // Cover the container area
                height: 150.0, // Set image height
                width: 150.0, // Set image width
                errorBuilder: (context, error, stackTrace) =>
                const Center(child: Icon(Icons.error)), // Display error icon
              ),
            ),
          ),
          // Add spacing between image and text
          // 2. Display product title
          Text(
            productName,
            style: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold, // Make title bold
              color: Colors.black,
            ),
          ),
          // Add spacing between title and details
          // 3. Display product details with purchase date
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween, // Align content horizontally
            children: [
              // Check if product has a purchaseDate property
              if (product?.data != null)
                Text(
                  'Acquistato: ${product.data.split(" ")[0].replaceAll("_", " ")}', // Replace with your date formatting function
                  style: TextStyle(
                    fontSize: 12.0,
                    color: Colors.grey,
                  ),
                ),
            ],
          ),
          // 4. QR Code Button
          TextButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => QrCodePage(productId: id),
              ),
            ),
            child: Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(5.0),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center, // Center content
                children: const [
                  Icon(Icons.qr_code_scanner, color: Colors.white),
                  Text(
                    "Show QR Code",
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );




  }
}

class QrCodePage extends StatelessWidget {
  final String productId;

  const QrCodePage({Key? key, required this.productId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product QR Code'),
        centerTitle: true,
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.0),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                offset: const Offset(5, 5),
                blurRadius: 10.0,
              ),
            ],
          ),
          child: QrImageView(
            // Use the provided productId to generate QR data
            data: '$productId',
            size: 300.0, // Adjust size as needed
          ),
        ),
      ),
    );
  }
}

