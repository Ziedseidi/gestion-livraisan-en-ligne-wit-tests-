import 'package:flutter/material.dart';
import 'loginpage.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Image d'arrière-plan
          Positioned.fill(
            // Utilisation de Positioned.fill pour remplir l'écran
            child: Image.asset(
              'assets/images/food-unique-decoration-restaurant-wall-260nw-1492036772.webp',
              fit: BoxFit.fill, // Remplit complètement l'écran
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
            ),
          ),
          // Contenu au-dessus de l'image
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text(
                  'Bienvenue chez nous',
                  style: TextStyle(
                    fontSize: 28,
                    color: Color.fromARGB(255, 176, 17, 17), // Texte en blanc pour être lisible sur l'image
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginPage()),
                    );
                  },
                  child: const Text('Visiter notre site'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
