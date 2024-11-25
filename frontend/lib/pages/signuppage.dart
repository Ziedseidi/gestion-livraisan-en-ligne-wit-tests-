import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;
  String errorMessage = '';
  String? selectedService;

  Future<void> signupUser() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    const String apiUrl = "http://192.168.1.4:3500/users/signup";

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "firstName": firstNameController.text,
          "lastName": lastNameController.text,
          "email": emailController.text,
          "phone": phoneController.text,
          "address": addressController.text,
          "password": passwordController.text,
          "service": selectedService,
        }),
      );

      print("Statut: ${response.statusCode}");
      print("Réponse: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        print("Inscription réussie: ${data['message']}");
        Navigator.pop(context);
      } else {
        setState(() {
          errorMessage = "Erreur lors de l'inscription. Vérifiez les données.";
        });
      }
    } catch (error) {
      setState(() {
        errorMessage = "Erreur de connexion au serveur.";
      });
      print("Erreur: $error");
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
            fit: BoxFit.cover,
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
          ),
          SingleChildScrollView(
            child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.only(top: 50, left: 16, right: 16),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.85,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text(
                        'Signup',
                        style: TextStyle(fontSize: 30, color: Color.fromARGB(255, 36, 33, 33)),
                      ),
                      const SizedBox(height: 24),
                      _buildTextField('First Name', firstNameController),
                      const SizedBox(height: 20),
                      _buildTextField('Last Name', lastNameController),
                      const SizedBox(height: 20),
                      _buildTextField('Email', emailController),
                      const SizedBox(height: 20),
                      _buildTextField('Phone', phoneController),
                      const SizedBox(height: 20),
                      _buildTextField('Address', addressController),
                      const SizedBox(height: 20),
                      _buildTextField('Password', passwordController, obscureText: true),
                      const SizedBox(height: 20),
                      _buildDropdown(),
                      const SizedBox(height: 20),
                      isLoading
                          ? const CircularProgressIndicator()
                          : ElevatedButton(
                              onPressed: signupUser,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                                backgroundColor: const Color(0xFF28a745),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                elevation: 5,
                              ),
                              child: const Text(
                                'S\'inscrire',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                      if (errorMessage.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        Text(
                          errorMessage,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool obscureText = false}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white),
      ),
      style: const TextStyle(color: Colors.white),
      obscureText: obscureText,
    );
  }

  Widget _buildDropdown() {
    return DropdownButtonFormField<String>(
      value: selectedService,
      decoration: const InputDecoration(
        labelText: 'Service',
        labelStyle: TextStyle(color: Colors.white),
      ),
      dropdownColor: Colors.grey[800],
      items: const [
        DropdownMenuItem(
          value: 'producteur',
          child: Text('Producteur', style: TextStyle(color: Colors.white)),
        ),
        DropdownMenuItem(
          value: 'consommateur',
          child: Text('Consommateur', style: TextStyle(color: Colors.white)),
        ),
      ],
      onChanged: (value) {
        setState(() {
          selectedService = value;
        });
      },
    );
  }
}
