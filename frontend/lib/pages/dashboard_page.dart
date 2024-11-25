import 'package:flutter/material.dart';
import '../components/navbar.dart';
import '../components/sidebar.dart';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String _selectedItem = "Aucun";

  void _onItemSelected(String item) {
    setState(() {
      _selectedItem = item; // Met à jour l'élément sélectionné
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Navbar(), 
      body: Row(
        children: [
          Sidebar(onItemSelected: _onItemSelected), // Passe la fonction de sélection
          Expanded(
            child: Center(
              child: Text(
                'Élément sélectionné : $_selectedItem', // Affiche l'élément sélectionné
                style: TextStyle(fontSize: 24),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
