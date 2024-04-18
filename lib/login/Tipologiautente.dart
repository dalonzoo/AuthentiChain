import 'package:flutter/material.dart';

class TipologiaUtente extends StatelessWidget {
  const TipologiaUtente({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrazione'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Scegli il tuo ruolo:'),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildChoiceButton(
                  context: context,
                  label: 'Studente',
                  routeName: '/registrazione_studente',
                ),
                _buildChoiceButton(
                  context: context,
                  label: 'Insegnante',
                  routeName: '/registrazione_insegnante',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChoiceButton({
    required BuildContext context,
    required String label,
    required String routeName,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, routeName);
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.blue),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(label),
      ),
    );
  }
}
