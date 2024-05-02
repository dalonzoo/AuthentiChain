import 'package:AuthtentiChain/MainViews/MyProducts.dart';
import 'package:AuthtentiChain/MainViews/MyProductsConsumer.dart';
import 'package:AuthtentiChain/MainViews/ProductLookUp.dart';
import 'package:AuthtentiChain/MainViews/ProductRegistration.dart';
import 'package:AuthtentiChain/MainViews/ProfilePage.dart';
import 'package:AuthtentiChain/MainViews/RegistraAcquisto.dart';
import 'package:AuthtentiChain/MainViews/TheftReportPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../utils/PurchaseData.dart';
import '../utils/Usertype.dart';

class HomeViewConsumer extends StatefulWidget {
  const HomeViewConsumer({Key? key}) : super(key: key);

  @override
  State<HomeViewConsumer> createState() => _HomeViewConsumerState();


}



class _HomeViewConsumerState extends State<HomeViewConsumer> {

  int _selectedIndex = 0;
  String productId = "";
  final List<Widget> _pages = [
    const Page1(productid: ""),
    const Page2(),
    const Page3(),
  ];

  final List<String> _categories = ['Categoria 1', 'Categoria 2', 'Categoria 3'];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

  }



  void signOut() async{
    final FirebaseAuth auth = FirebaseAuth.instance;
    await auth.signOut();
  }
  @override
  Widget build(BuildContext context) {
    return
    Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0.0, // Rimuove l'ombra sotto la barra
        title: Text(
          'Authentichain',
          style: GoogleFonts.openSans(),
        ),
        centerTitle: true, // Centra il testo
      ),

        body:
        Container(
          margin: EdgeInsets.all(15.0),
          child:  _pages[_selectedIndex],
        ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Cerca'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Impostazioni'),
        ],
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      )
    );

  }
}

class Page1 extends StatefulWidget {
  final String productid;
  const Page1({required this.productid});

  @override
  State<Page1> createState() => _Page1State();
}

class _Page1State extends State<Page1> {
  String productId = "";
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getProduct();
  }


  void getProduct() async{
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
  @override
  Widget build(BuildContext context) {

    return Center(
      child: GridView.count(
        crossAxisCount: 2, // Two cards per row
        mainAxisSpacing: 20.0, // Spacing between rows
        crossAxisSpacing: 20.0, // Spacing between cards
        children: [
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            elevation: 4.0,
            child: InkWell(
              onTap: () async{
                final userRef = FirebaseDatabase.instance.ref('users/' + FirebaseAuth.instance.currentUser!.uid);
                final event = await userRef.once();


                final data = event.snapshot.value as Map<dynamic, dynamic>;
                UserData user = UserData.fromMap(data);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => MyproductsConsumer()),
                );
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.shopping_basket, size: 40.0), // Larger icon
                  const SizedBox(height: 10.0),
                  Text('I Tuoi Prodotti', style: GoogleFonts.openSans()),
                ],
              ),
            ),
          ),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            elevation: 4.0,
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => RegistraAcquisto()),
                );
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.app_registration, size: 40.0), // Larger icon
                  const SizedBox(height: 10.0),
                  Text('Registra acquisto', style: GoogleFonts.openSans(),),
                ],
              ),
            ),
          ),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            elevation: 4.0,
            child: InkWell(
              onTap: () async{
                final userRef = FirebaseDatabase.instance.ref('users/' + FirebaseAuth.instance.currentUser!.uid);
                final event = await userRef.once();


                final data = event.snapshot.value as Map<dynamic, dynamic>;
                UserData user = UserData.fromMap(data);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ProductLookup()),
                );
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.document_scanner, size: 40.0), // Larger icon
                  const SizedBox(height: 10.0),
                  Text('Scansiona', style: GoogleFonts.openSans()),
                ],
              ),
            ),
          ),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            elevation: 4.0,
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => TheftReportPage(productId:productId)),
                );
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.crisis_alert_outlined, size: 40.0), // Larger icon
                  const SizedBox(height: 10.0),
                  Text('Segnala furto', style: GoogleFonts.openSans(),),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Page2 extends StatelessWidget {
  const Page2({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Pagina 2'),
    );
  }
}

class Page3 extends StatelessWidget {
  const Page3({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ProfilePage();
  }
}
