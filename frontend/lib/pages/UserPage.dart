import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'UserListPage.dart'; // Assurez-vous d'importer la page UserListPage

class UserPage extends StatefulWidget {
  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  List<dynamic> users = [];
  List<dynamic> availableRoles = []; // Déclarez la liste des rôles
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    final String apiUrl = "http://192.168.1.4:3500/users"; // Remplacez par l'URL de votre API
    final String rolesUrl = "http://192.168.1.4:3500/roles/Allroles"; // URL pour récupérer les rôles

    // Récupérer le token d'authentification
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token'); // Assurez-vous que le token est stocké avec cette clé

    if (token == null) {
      print('Le token est nul');
      setState(() {
        isLoading = false; // Mettre à jour l'état pour ne plus afficher le loading
      });
      return;
    }

    try {
      // Récupérer les utilisateurs
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token', // Ajouter le token au header de la requête
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> fetchedUsers = jsonDecode(response.body);
        print('Utilisateurs récupérés : $fetchedUsers'); // Pour déboguer
        setState(() {
          users = fetchedUsers; // Mettre à jour la liste des utilisateurs
        });
      } else {
        throw Exception('Erreur lors de la récupération des utilisateurs');
      }

      // Récupérer les rôles
      final rolesResponse = await http.get(
        Uri.parse(rolesUrl),
        headers: {
          'Authorization': 'Bearer $token', // Ajouter le token au header de la requête
        },
      );

      if (rolesResponse.statusCode == 200) {
        availableRoles = jsonDecode(rolesResponse.body); // Récupérer la liste des rôles
      } else {
        throw Exception('Erreur lors de la récupération des rôles');
      }

      // Navigation vers UserListPage après avoir récupéré les utilisateurs et les rôles
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => UserListPage(
            users: users,
            availableRoles: availableRoles,
            token: token, // Passer le token à UserListPage
          ),
        ),
      );

    } catch (error) {
      print('Erreur lors de la requête API : $error');
      setState(() {
        isLoading = false; // Mettre à jour l'état pour ne plus afficher le loading
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gestion des utilisateurs'),
        backgroundColor: Colors.teal,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator()) // Afficher un indicateur de chargement
          : users.isEmpty // Afficher un message si la liste est vide
              ? Center(child: Text('Aucun utilisateur trouvé.'))
              : Container(), // Vous pouvez personnaliser cela plus tard
    );
  }
}
