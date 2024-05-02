import 'package:AuthtentiChain/MainViews/MyProducts.dart';
import 'package:AuthtentiChain/MainViews/ProductLookUpFiliera.dart';
import 'package:AuthtentiChain/MainViews/ProductRegistration.dart';
import 'package:AuthtentiChain/MainViews/ProfilePage.dart';
import 'package:AuthtentiChain/MainViews/TheftReportPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../utils/Usertype.dart';

class HomeViewFiliera extends StatefulWidget {
  const HomeViewFiliera({Key? key}) : super(key: key);

  @override
  State<HomeViewFiliera> createState() => _HomeViewFilieraState();


}



class _HomeViewFilieraState extends State<HomeViewFiliera> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const Page1(),
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

class Page1 extends StatelessWidget {
  const Page1({Key? key}) : super(key: key);

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
                      builder: (context) => ProductLookupFiliera()),
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
                      builder: (context) => TheftReportPage(productId: "")),
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
