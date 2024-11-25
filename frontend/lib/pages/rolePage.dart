import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:livraison/pages/listesRoles.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AddRolePage extends StatefulWidget {
  @override
  _AddRolePageState createState() => _AddRolePageState();
}

class _AddRolePageState extends State<AddRolePage> {
  String newRoleName = '';
  String newRoleDescription = '';
  String? token;
  List<dynamic> roles = []; // Pour stocker les rôles récupérés
  bool isLoading = false; // Pour afficher le chargement pendant la récupération des rôles

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  Future<void> _loadToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      token = prefs.getString('token');
    });

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Token non trouvé.')),
      );
    }
  }

  // Fonction pour ajouter un rôle
  Future<void> _addRole() async {
    final String apiUrl = "http://192.168.1.4:3500/roles/addrole"; // Remplacez par votre URL API

    if (newRoleName.isEmpty || newRoleDescription.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veuillez remplir tous les champs')),
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name': newRoleName,
          'description': newRoleDescription,
        }),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Rôle ajouté avec succès')),
        );
        // Vider les champs après l'ajout
        setState(() {
          newRoleName = '';
          newRoleDescription = '';
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de l\'ajout du rôle')),
        );
      }
    } catch (error) {
      print('Erreur lors de la requête API : $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la requête API')),
      );
    }
  }

  // Fonction pour récupérer la liste des rôles
  Future<void> _fetchRoles() async {
    final String apiUrl = "http://192.168.1.4:3500/roles/Allroles"; // Remplacez par votre URL API

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Token non disponible pour récupérer les rôles.')),
      );
      return; // Sortir si le token est null
    }

    setState(() {
      isLoading = true; // Début du chargement
    });

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          roles = jsonDecode(response.body); // Récupérer et stocker les rôles
          isLoading = false; // Fin du chargement
        });
        // Naviguer vers la page de la liste des rôles en passant les rôles récupérés et le token
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RoleListPage(initialRoles: roles, token: token!), // Utilisez "roles" et "token"
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la récupération des rôles')),
        );
        setState(() {
          isLoading = false; // Fin du chargement même en cas d'erreur
        });
      }
    } catch (error) {
      print('Erreur lors de la requête API : $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la requête API')),
      );
      setState(() {
        isLoading = false; // Fin du chargement même en cas d'erreur
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gestion des rôles'),
        backgroundColor: const Color.fromARGB(255, 27, 50, 47),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/R.jpg'), // Remplacez avec le chemin de votre image d'arrière-plan
            fit: BoxFit.cover, // Couvre tout l'écran
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Champ avec icône et design amélioré
              _buildIconTextField('Nom du rôle', Icons.person_add, (value) {
                setState(() {
                  newRoleName = value;
                });
              }),
              SizedBox(height: 16),
              _buildIconTextField('Description du rôle', Icons.description, (value) {
                setState(() {
                  newRoleDescription = value;
                });
              }),
              SizedBox(height: 32),
              // Bouton pour ajouter un rôle
              _buildGradientButton('Ajouter le rôle', _addRole, Colors.purple, Colors.blue),
              SizedBox(height: 16),
              // Bouton pour récupérer les rôles
              _buildGradientButton(
                isLoading ? 'Chargement...' : 'Liste des rôles',
                _fetchRoles,
                Colors.orange,
                Colors.red,
                showLoading: isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconTextField(String label, IconData icon, Function(String) onChanged) {
    return TextField(
      onChanged: onChanged,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.teal),
        labelText: label,
        labelStyle: TextStyle(color: Colors.black87),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.teal, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.teal, width: 2),
        ),
      ),
    );
  }

  Widget _buildGradientButton(String text, Function() onPressed, Color startColor, Color endColor, {bool showLoading = false}) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 16.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: LinearGradient(
            colors: [startColor, endColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: showLoading
            ? Center(child: CircularProgressIndicator(color: Colors.white))
            : Text(
                text,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}
