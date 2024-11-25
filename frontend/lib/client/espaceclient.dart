import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:livraison/advertisement/advertisement.dart';
import 'package:livraison/advertisement/promotion.dart';
import 'package:livraison/dish/addDish.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:livraison/dish/dishListPage.dart';
import 'package:livraison/pages/loginpage.dart';
import 'package:livraison/delivery/deliveryListPage.dart';

class EspaceClient extends StatefulWidget {
  final String firstName;
  final String lastName;

  const EspaceClient({required this.firstName, required this.lastName, Key? key}) : super(key: key);

  @override
  _EspaceClientState createState() => _EspaceClientState();
}

class _EspaceClientState extends State<EspaceClient> {
  List<dynamic> dishes = [];
  String token = '';
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    setState(() {
      isLoading = true;
    });

    try {
      token = await _getToken();
      if (token.isNotEmpty) {
        dishes = await _fetchDishes();
      } else {
        print('Token non disponible');
      }
    } catch (error) {
      print('Erreur: $error');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<List<dynamic>> _fetchDishes() async {
    if (token.isEmpty) {
      throw Exception('Token non disponible');
    }

    final response = await http.get(
      Uri.parse('http://192.168.1.4:3500/dishs/allDishs'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else if (response.statusCode == 401) {
      throw Exception('Erreur 401: Non autorisé');
    } else {
      throw Exception('Échec de la récupération des plats');
    }
  }

  Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') ?? '';
  }

  Future<void> _logoutUser() async {
    final response = await http.post(
      Uri.parse('http://192.168.1.4:3500/users/logout'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      print('Déconnexion réussie');
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
    } else {
      print('Erreur lors de la déconnexion: ${response.statusCode}');
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Déconnexion'),
          content: const Text('Voulez-vous vraiment vous déconnecter ?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () async {
                await _logoutUser();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
              child: const Text('Déconnexion'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Espace Client', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.deepPurpleAccent,
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Text(
                  '${widget.firstName} ${widget.lastName}',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.logout, color: Colors.white),
                  onPressed: _showLogoutDialog,
                ),
              ],
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Image de fond avec opacité
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: const AssetImage(
                  'assets/images/OIP.jpg',
                ),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.3), // Appliquer une opacité de 0.3
                  BlendMode.darken,
                ),
              ),
            ),
          ),
          // Contenu principal
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const SizedBox(height: 30),
                        // Bouton Suivi de Livraison (carré)
                        _buildSquareButton(
                          context,
                          '',
                          Icons.motorcycle,
                          const Color.fromARGB(255, 23, 8, 26),
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => DeliveryListPage(token: token)),
                          ),
                        ),
                        const SizedBox(height: 30),
                        // Message de bienvenue
                        Text(
                          'Bienvenue, ${widget.firstName} ${widget.lastName} !',
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 30),
                        // Autres boutons
                        _buildButton(
                          context,
                          'Ajouter Plat',
                          Icons.fastfood,
                          Colors.orangeAccent,
                          () => Navigator.push(context, MaterialPageRoute(builder: (context) => AddDishPage())),
                        ),
                        const SizedBox(height: 20),
                        _buildButton(
                          context,
                          'Procédure de livraison',
                          Icons.delivery_dining,
                          Colors.greenAccent,
                          () => Navigator.push(context, MaterialPageRoute(builder: (context) => DishListPage(initialDishes: dishes, token: token))),
                        ),
                        const SizedBox(height: 20),
                        _buildButton(
                          context,
                          'Publicité',
                          Icons.campaign,
                          Colors.blueAccent,
                          () => Navigator.push(context, MaterialPageRoute(builder: (context) => AdvertisementPage())),
                        ),
                        const SizedBox(height: 20),
                        _buildButton(
                          context,
                          'Promotion',
                          Icons.local_offer,
                          Colors.redAccent,
                          () => Navigator.push(context, MaterialPageRoute(builder: (context) => PromotionPage())),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  // Bouton carré
  Widget _buildSquareButton(BuildContext context, String title, IconData icon, Color color, VoidCallback onPressed) {
    return SizedBox(
      width: 100, // Taille fixe pour un carré
      height: 100, // Taille fixe pour un carré
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 28, color: Colors.white),
        label: Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          backgroundColor: color,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)), // Pas de rayon pour un carré
        ),
      ),
    );
  }

  // Bouton standard arrondi
  Widget _buildButton(BuildContext context, String title, IconData icon, Color color, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 28, color: Colors.white),
        label: Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          backgroundColor: color,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)), // Arrondi
        ),
      ),
    );
  }
}
