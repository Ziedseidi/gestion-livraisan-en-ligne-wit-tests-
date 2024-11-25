import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../pages/loginpage.dart';

class VerificationCodePage extends StatelessWidget {
  final String email; // Récupère l'email depuis la page précédente
  final TextEditingController codeController = TextEditingController();

  VerificationCodePage({Key? key, required this.email}) : super(key: key);

  Future<void> verifyCode(BuildContext context) async {
    final String apiUrl = 'http://192.168.1.4:3500/users/verify-confirmation';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'email': email,
          'confirmationCode': codeController.text,
        }),
      );

      if (response.statusCode == 200) {
        // Code de confirmation validé avec succès
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Votre compte a été activé avec succès !')),
        );

        // Attendre 7 secondes avant de revenir à la page précédente
        Future.delayed(Duration(seconds: 3), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginPage()),
          );
        });
      } else {
        // Code de confirmation incorrect
        final Map<String, dynamic> data = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Code incorrect.')),
        );
      }
    } catch (error) {
      // Gestion des erreurs
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur de connexion au serveur.')),
      );
      print('Erreur lors de la vérification : $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Vérification du Code'),
      ),
      body: Stack(
        children: [
          // Image d'arrière-plan
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    'assets/images/open-mail-9816558-7994449.webp'), // Assurez-vous que le chemin est correct
                fit: BoxFit.cover, // Pour couvrir tout l'écran
              ),
            ),
          ),
          // Contenu principal
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Saisissez votre code de vérification',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: codeController,
                    decoration: InputDecoration(
                      labelText: 'Code de vérification',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white.withOpacity(
                          0.8), // Couleur de fond du champ de texte
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      if (codeController.text.isEmpty) {
                        // Afficher un message d'erreur
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Veuillez saisir un code.')),
                        );
                      } else {
                        verifyCode(
                            context); // Appel à la fonction de vérification du code
                      }
                    },
                    child: Text('Vérifier le Code'),
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
