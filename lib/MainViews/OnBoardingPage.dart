import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../login/login_view.dart';
import 'HomeView.dart';

class OnboardingPage extends StatefulWidget {
  @override
  _OnboardingPageState createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  int _currentPage = 0;
  late PageController controller;
  final List<Widget> _pages = [
    OnboardingScreen1(),
    OnboardingScreen2(),
    OnboardingScreen3(),
  ];
  String _buttonText = 'Avanti';
  bool _buttonEnabled = true;


  void _nextPage() {
    setState(() {
      _currentPage = (_currentPage + 1) % _pages.length;
    });
  }

  void _skipToLogin() async{
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('seenOnboarding', true);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LoginView()), // SecondPage è la pagina di destinazione
    );
  }
@override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller = PageController(initialPage: 0);

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Onboarding'),
        actions: [
          TextButton(
            onPressed: _skipToLogin,
            child: Text('Salta'),
          ),
        ],
      ),
      body: Stack(
        children: [
          PageView(
            controller: controller,
            children: _pages,
            onPageChanged: (page) {
              setState(() {
                _currentPage = page;
                _buttonText = page < _pages.length - 1 ? 'Avanti' : 'Fine';
                _buttonEnabled = page < _pages.length - 1;
              });
            },

          ),
          Positioned(
            child: Align(
              alignment: Alignment(0.5, 1), // Centro in basso
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (int i = 0; i < _pages.length; i++)
                    Padding(
                      padding: EdgeInsets.only(bottom: 30), // Aggiungi il margine inferiore
                      child: Indicator(
                        isActive: i == _currentPage,
                      ),
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
class Indicator extends StatelessWidget {
  final bool isActive;

  Indicator({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      width: 10,
      height: 10,
      margin: EdgeInsets.only(right: 5),
      decoration: BoxDecoration(
        color: isActive ? Colors.lightBlueAccent : Colors.grey, // Azzurro per attivo, grigio per inattivo
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }
}

// Sostituisci OnboardingScreen1, OnboardingScreen2 e OnboardingScreen3 con i tuoi widget per le schermate di onboarding
class OnboardingScreen1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Benvenuto!'),
          SizedBox(height: 20),
          Text('Scopri le funzionalità di questa fantastica app'),
        ],
      ),
    );
  }
}

class OnboardingScreen2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Personalizza la tua esperienza'),
          SizedBox(height: 20),
          Text('Scegli le impostazioni che preferisci per adattarle alle tue esigenze'),
        ],
      ),
    );
  }
}

class OnboardingScreen3 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Inizia il tuo viaggio!'),
          SizedBox(height: 20),
          Text('Sei pronto a esplorare tutte le possibilità che ti offre questa app?'),
        ],
      ),
    );
  }
}






