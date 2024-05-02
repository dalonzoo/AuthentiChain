import 'dart:convert';

import 'package:AuthtentiChain/MainViews/HomeView.dart';
import 'package:AuthtentiChain/utils/ProductData.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../utils/Constants.dart'; // Import for Firebase Realtime Database

class Myproducts extends StatefulWidget {
  final String productId; // Pass the product ID as an argument

  const Myproducts({Key? key, required this.productId}) : super(key: key);

  @override
  State<Myproducts> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<Myproducts> {
  ProductData product = ProductData(nomeProdotto: "", nomeProduttore: "", dataProduzione: "",
      localitaProduzione: "", categoria: "", materiali: "", particolariTipici: "", linkProdotto: "", immagini: "");
  @override
  void initState() {
    super.initState();
    _getProductDetails(); // Fetch product details on initialization
  }

  Future<void> _getProductDetails() async {
    final database = FirebaseDatabase.instance; // Initialize Firebase Database
    final reference = database.ref('products/${widget.productId}'); // Reference based on product ID

    final event = await reference.once(); // Get product data once
    setState(() {
      final data = event.snapshot.value as Map<dynamic, dynamic>;
      product = ProductData.fromMap(data); // Convert data to Product object
    });

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
      body: product == null
          ? const Center(child: CircularProgressIndicator()) // Show progress indicator while loading
          : SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(15.0),
          child: ProductCard(product: product!, id: widget.productId), // Pass the retrieved product to ProductCard widget
        ),
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final ProductData product;
  final String id;

  const ProductCard({required this.id, required this.product});

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
          product.immagini.isEmpty
              ? Center(child: CircularProgressIndicator(color: colorePrimario,)) // Show progress indicator if image is empty
              : Center(
            child: ClipRRect(// Set rounded corners (optional)
              child: Image.memory(
                base64Decode(product.immagini),
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
            product.nomeProdotto,
            style: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold, // Make title bold
              color: Colors.black,
            ),
          ),
          // Add spacing between title and details
          // 3. Display product details
          Text(
            product.particolariTipici,
            style: TextStyle(
              fontSize: 14.0,
              color: Colors.grey[600], // Use a grey color for details
            ),
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

