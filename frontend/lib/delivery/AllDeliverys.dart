import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DeliverysList extends StatefulWidget {
  final String token;

  const DeliverysList({Key? key, required this.token}) : super(key: key);

  @override
  _DeliverysListState createState() => _DeliverysListState();
}

class _DeliverysListState extends State<DeliverysList> {
  List<dynamic> deliveries = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchDeliveries(); // Appeler la méthode pour récupérer les livraisons
  }

  // Méthode pour récupérer les livraisons
  Future<void> _fetchDeliveries() async {
    if (widget.token.isEmpty) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Token manquant. Veuillez vous connecter.')),
      );
      return; // Arrêter la méthode si le token est manquant
    }

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse('http://192.168.1.4:3500/deliverys/AllDelivery'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization':
              'Bearer ${widget.token}', // Utiliser le token d'authentification
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          deliveries = json.decode(
              response.body); // Convertir la réponse JSON en une liste d'objets
        });
      } else if (response.statusCode == 401) {
        // Le token peut avoir expiré ou être invalide
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Token expiré ou invalide.')),
        );
      } else {
        print('Erreur: ${response.statusCode}');
      }
    } catch (error) {
      print('Erreur lors de la récupération des livraisons: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Erreur de connexion, veuillez réessayer plus tard.')),
      );
    } finally {
      setState(() {
        isLoading = false; // Arrêter le chargement
      });
    }
  }

  // Méthode pour changer le statut d'une livraison
  Future<void> _changeStatus(String deliveryId, String newStatus) async {
    final url =
        'http://172.20.10.6:3500/deliverys/$deliveryId'; // URL pour la mise à jour
    try {
      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.token}',
        },
        body: json.encode({'status': newStatus}),
      );

      if (response.statusCode == 200) {
        // Si la requête est réussie, mettre à jour le statut localement
        setState(() {
          final delivery = deliveries.firstWhere((d) => d['_id'] == deliveryId);
          delivery['status'] = newStatus;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Erreur lors de la mise à jour du statut.')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur de connexion.')),
      );
    }
  }

  // Fonction pour déterminer la couleur du statut
  Color _getStatusColor(String status) {
    switch (status) {
      case 'Acceptée':
        return const Color(0xFF4CAF50); // Vert pour "Livrée"
      case 'En cours':
        return Colors.orange; // Orange pour "En cours"
      case 'Refusée':
        return Colors.red; // Rouge pour "Annulée"
      case 'Livrée':
        return Colors.black;
      default:
        return const Color.fromARGB(255, 17, 216, 130); // Noir pour les autres statuts
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Liste des Livraisons',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(
              child:
                  CircularProgressIndicator()) // Afficher l'indicateur de chargement
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
              itemCount:
                  deliveries.length, // Le nombre d'éléments dans la liste
              itemBuilder: (context, index) {
                final delivery =
                    deliveries[index]; // Récupérer la livraison courante
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.deepPurple.withOpacity(0.6),
                          Colors.blue.withOpacity(0.6),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(15.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 10.0,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16.0),
                      leading: CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 30,
                        child: Icon(
                          Icons.local_shipping,
                          color: Colors.deepPurple[700],
                          size: 30.0,
                        ),
                      ),
                      title: Text(
                        'Livraison ${index + 1}',
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      subtitle: Text(
                        'Statut: ${delivery['status']}',
                        style: TextStyle(
                          color: _getStatusColor(delivery[
                              'status']), // Utiliser la couleur dynamique
                        ),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit,
                            color: Colors.white), // Bouton d'édition
                        onPressed: () {
                          _showStatusChangeDialog(context,
                              delivery); // Afficher le dialogue pour changer le statut
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  // Méthode pour afficher un dialogue afin de changer le statut
  void _showStatusChangeDialog(BuildContext context, dynamic delivery) {
    String selectedStatus = delivery['status'];
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Modifier le statut'),
          content: DropdownButton<String>(
            value: selectedStatus,
            items: <String>[
              'En cours',
              'Acceptée',
              'Refusée',
              'Livrée'
            ] // Ajouter "Livrée" si nécessaire
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  selectedStatus = newValue;
                });
              }
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                _changeStatus(
                    delivery['_id'], selectedStatus); // Mettre à jour le statut
                Navigator.of(context).pop();
              },
              child: const Text('Confirmer'),
            ),
          ],
        );
      },
    );
  }
}
