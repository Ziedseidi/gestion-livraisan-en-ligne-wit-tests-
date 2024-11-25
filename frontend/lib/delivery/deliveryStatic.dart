import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';

class DeliveryStatistics extends StatefulWidget {
  final String token;

  const DeliveryStatistics({Key? key, required this.token}) : super(key: key);

  @override
  _DeliveryStatisticsState createState() => _DeliveryStatisticsState();
}

class _DeliveryStatisticsState extends State<DeliveryStatistics> {
  // Initialiser les variables de statistiques de livraison
  int ongoingDeliveries = 0;
  int acceptedDeliveries = 0;
  int deliveredDeliveries = 0;
  int cancelledDeliveries = 0;
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
        const SnackBar(content: Text('Token manquant. Veuillez vous connecter.')),
      );
      return; // Arrêter la méthode si le token est manquant
    }

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse('http://192.168.1.4:3500/deliverys/DeliveryStatistics'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.token}', // Utiliser le token d'authentification
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body); // Convertir la réponse JSON
        if (responseData != null) {
          // Assigner les valeurs directement depuis la réponse de l'API
          setState(() {
            ongoingDeliveries = responseData['ongoingDeliveries'] ?? 0;
            acceptedDeliveries = responseData['acceptedDeliveries'] ?? 0;
            deliveredDeliveries = responseData['deliveredDeliveries'] ?? 0;
            cancelledDeliveries = responseData['cancelledDeliveries'] ?? 0;
          });
        } else {
          print('Réponse vide ou mal formée.');
          setState(() {
            ongoingDeliveries = 0;
            acceptedDeliveries = 0;
            deliveredDeliveries = 0;
            cancelledDeliveries = 0;
          });
        }
      } else {
        print('Erreur: ${response.statusCode}');
        setState(() {
          ongoingDeliveries = 0;
          acceptedDeliveries = 0;
          deliveredDeliveries = 0;
          cancelledDeliveries = 0;
        });
      }
    } catch (error) {
      print('Erreur lors de la récupération des livraisons: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur de connexion, veuillez réessayer plus tard.')),
      );
      setState(() {
        ongoingDeliveries = 0;
        acceptedDeliveries = 0;
        deliveredDeliveries = 0;
        cancelledDeliveries = 0;
      });
    } finally {
      setState(() {
        isLoading = false; // Arrêter le chargement
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistiques des Livraisons', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator()) // Afficher l'indicateur de chargement
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  // Affichage du graphique
                  AspectRatio(
                    aspectRatio: 1.3,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: 10, // Valeur maximale de l'axe Y, ajuster si nécessaire
                        barTouchData: BarTouchData(enabled: false),
                        titlesData: FlTitlesData(show: true),
                        borderData: FlBorderData(show: true),
                        gridData: FlGridData(show: true),
                        barGroups: [
                          // Barres pour chaque statut
                          BarChartGroupData(
                            x: 0,
                            barRods: [
                              BarChartRodData(
                                toY: ongoingDeliveries.toDouble(), // Utiliser toY au lieu de y
                                color: Colors.orange, // Utilisation de 'color' au lieu de 'rodColor'
                                width: 20,
                                borderRadius: BorderRadius.zero,
                              ),
                            ],
                          ),
                          BarChartGroupData(
                            x: 1,
                            barRods: [
                              BarChartRodData(
                                toY: acceptedDeliveries.toDouble(), // Utiliser toY au lieu de y
                                color: Colors.blue, // Utilisation de 'color' au lieu de 'rodColor'
                                width: 20,
                                borderRadius: BorderRadius.zero,
                              ),
                            ],
                          ),
                          BarChartGroupData(
                            x: 2,
                            barRods: [
                              BarChartRodData(
                                toY: deliveredDeliveries.toDouble(), // Utiliser toY au lieu de y
                                color: Colors.green, // Utilisation de 'color' au lieu de 'rodColor'
                                width: 20,
                                borderRadius: BorderRadius.zero,
                              ),
                            ],
                          ),
                          BarChartGroupData(
                            x: 3,
                            barRods: [
                              BarChartRodData(
                                toY: cancelledDeliveries.toDouble(), // Utiliser toY au lieu de y
                                color: Colors.red, // Utilisation de 'color' au lieu de 'rodColor'
                                width: 20,
                                borderRadius: BorderRadius.zero,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Texte pour les statistiques
                  Text(
                    'En cours: $ongoingDeliveries\n'
                    'Acceptées: $acceptedDeliveries\n'
                    'Livrées: $deliveredDeliveries\n'
                    'Annulées: $cancelledDeliveries',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
    );
  }
}
