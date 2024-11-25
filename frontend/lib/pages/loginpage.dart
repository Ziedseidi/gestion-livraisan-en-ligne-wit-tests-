import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:livraison/client/espaceclient.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../components/verification_code.dart';
import 'dashboard_page.dart'; 
import 'signuppage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  String? errorMessage;

  Future<void> _login() async {
  setState(() {
    isLoading = true;
    errorMessage = null; // Réinitialiser le message d'erreur
  });

  final String apiUrl = "http://192.168.1.4:3500/users/login"; // Assurez-vous que l'URL est correcte

  try {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": emailController.text.trim(),
        "password": passwordController.text.trim(),
      }),
    );

    print('Statut de la réponse: ${response.statusCode}'); // Ajouté pour débogage

    if (response.statusCode == 200) {
  final Map<String, dynamic> data = jsonDecode(response.body);
  print('Réponse de l\'API : $data');

  final String? token = data['token'];
  final String? refreshToken = data['refreshToken'];
  final String? firstName = data['user']?['firstName']; // Ajoutez cela pour récupérer le prénom
  final String? lastName = data['user']?['lastName'];   // Ajoutez cela pour récupérer le nom de famille
  final List<dynamic> roles = data['user']?['roles'] ?? []; // Récupérez la liste des rôles

  // Vérifiez que roles n'est pas vide avant d'accéder à son contenu
  final String? role = roles.isNotEmpty ? roles[0] : null; // Récupérez le premier rôle

  if (token != null && refreshToken != null && role != null) {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    await prefs.setString('refreshToken', refreshToken);

    // Redirection basée sur le rôle
    if (role.toLowerCase() == 'admin') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => DashboardPage()),
      );
    } else if (role.toLowerCase() == 'client') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => EspaceClient(
            firstName: firstName ?? '', // Passer le prénom à EspaceClient
            lastName: lastName ?? '',     // Passer le nom de famille à EspaceClient
          ),
        ),
      );
    } else {
      setState(() {
        errorMessage = 'Rôle non reconnu.';
      });
    }
  } else {
    setState(() {
      errorMessage = 'Erreur : Données de connexion manquantes ou incomplètes.';
    });
  }
} 

     else {
      final Map<String, dynamic> data = jsonDecode(response.body);
      setState(() {
        errorMessage = data['message'] ?? 'Erreur d\'accès';
      });
      if (response.statusCode == 403 && data['needsActivation'] == true) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => VerificationCodePage(email: data['email'] ?? ''),
          ),
        );
      } else if (response.statusCode == 401) {
        errorMessage = 'Identifiants incorrects. Veuillez réessayer.';
      } else {
        errorMessage = 'Erreur de connexion. Code: ${response.statusCode}';
      }
    }
  } catch (error) {
    setState(() {
      errorMessage = 'Une erreur s\'est produite lors de la connexion : $error';
    });
    print('Erreur lors de la requête API : $error');
  } finally {
    setState(() {
      isLoading = false;
    });
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Image.asset(
            'assets/images/pngtree-food-fruit-and-vegetable-gourmet-background-border-image_2214752.jpg',
            fit: BoxFit.fill,
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
          ),
          Align(
            alignment: Alignment.topLeft,
            child: Container(
              margin: const EdgeInsets.only(top: 70, left: 16),
              width: 230,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: const Color.fromARGB(0, 246, 245, 245),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromARGB(255, 212, 210, 210).withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  const Text(
                    'Login',
                    style: TextStyle(fontSize: 30, color: Color.fromARGB(255, 154, 145, 145)),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      labelStyle: TextStyle(color: Colors.white),
                    ),
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      labelStyle: TextStyle(color: Colors.white),
                    ),
                    style: const TextStyle(color: Colors.white),
                    obscureText: true,
                  ),
                  const SizedBox(height: 20),
                  if (isLoading)
                    const CircularProgressIndicator()
                  else ...[
                    ElevatedButton(
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                        backgroundColor: const Color(0xFF28a745),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 5,
                      ),
                      child: const Text(
                        'Connecter',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SignupPage()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                        backgroundColor: const Color.fromARGB(255, 107, 53, 113),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 5,
                      ),
                      child: const Text(
                        'Créer un compte',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                  if (errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Text(
                        errorMessage!,
                        style: const TextStyle(color: Colors.red),
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
