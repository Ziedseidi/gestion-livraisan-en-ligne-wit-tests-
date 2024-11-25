import 'dart:async';
import 'package:flutter/material.dart';
import 'package:livraison/delivery/AllDeliverys.dart';
import 'package:livraison/delivery/deliveryStatic.dart';
import 'package:livraison/pages/UserPage.dart';
import 'package:livraison/pages/rolePage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Sidebar extends StatelessWidget {
  final Function(String) onItemSelected;

  const Sidebar({Key? key, required this.onItemSelected}) : super(key: key);

  Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') ?? '';  // Récupère le token ou une chaîne vide si non trouvé
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _getToken(),  // Récupère le token
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());  // Affiche un loader pendant la récupération du token
        }

        if (snapshot.hasError) {
          return Center(child: Text('Erreur : ${snapshot.error}'));
        }

        final token = snapshot.data ?? '';  // Si le token est vide, on le traite comme une chaîne vide

        return SizedBox(
          width: 70,
          child: Drawer(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
            ),
            child: Container(
              color: const Color.fromARGB(255, 10, 143, 90),
              child: Column(
                children: [
                  Expanded(
                    child: ListView(
                      children: [
                        _buildDrawerItem(Icons.people, '', () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => UserPage()),
                          );
                        }),
                        _buildDrawerItem(Icons.assignment_ind, '', () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => AddRolePage()),
                          );
                        }),
                        _buildDrawerItem(Icons.delivery_dining, '', () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DeliverysList(token: token),
                            ),
                          );
                        }),
                        _buildDrawerItem(Icons.analytics, '', () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DeliveryStatistics(token: token),
                            ),
                          );
                        }),
                        _buildDrawerItem(Icons.search, '', () {
                          onItemSelected('Search');
                        }),
                        _buildDrawerItem(Icons.notifications, '', () {
                          onItemSelected('Notifications');
                        }),
                        _buildDrawerItem(Icons.settings, '', () {
                          onItemSelected('Settings');
                        }),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, Function onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      onTap: () => onTap(),
    );
  }
}
