import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DeliveryListPage extends StatefulWidget {
  final String token;

  const DeliveryListPage({Key? key, required this.token}) : super(key: key);

  @override
  _DeliveryListPageState createState() => _DeliveryListPageState();
}

class _DeliveryListPageState extends State<DeliveryListPage> {
  List<dynamic> deliveries = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDeliveries();
  }

  Future<void> _fetchDeliveries() async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.1.4:3500/deliverys'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.token}',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          deliveries = json.decode(response.body);
          isLoading = false;
        });
      } else {
        print('Erreur lors de la récupération des livraisons: ${response.statusCode}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Erreur: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Liste des Livraisons', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
              itemCount: deliveries.length,
              itemBuilder: (context, index) {
                final delivery = deliveries[index];
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
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      subtitle: Text(
                        'Statut: ${delivery['status']}',
                        style: TextStyle(color: const Color.fromARGB(255, 200, 84, 6)),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.details_outlined, color: Colors.white),
                        onPressed: () {
                          _showDeliveryDetails(context, delivery);
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _showDeliveryDetails(BuildContext context, dynamic delivery) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Détails de la Livraison',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Text('Statut: ${delivery['status']}', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 10),
              Text('Adresse: ${delivery['deliveryAddress'] ?? 'Non disponible'}', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 10),
              Text('Téléphone: ${delivery['phone'] ?? 'Non disponible'}', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 20),
              Text('Prix Livraison est : 4,5 D') ,
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Fermer'),
              ),
            ],
          ),
        );
      },
    );
  }
}
