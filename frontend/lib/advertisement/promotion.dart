import 'package:flutter/material.dart';

class PromotionPage extends StatelessWidget {
  const PromotionPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Promotions',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.teal,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const SizedBox(height: 20),
            const Text(
              'Découvrez nos Offres Spéciales',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),

            // Carte de Promotion 1
            _buildPromotionCard(
              context: context,
              title: '50% de réduction',
              description: 'Profitez de 50% de réduction sur tous nos produits ce mois-ci !',
              imagePath: 'assets/images/promo1.jpg',
              buttonText: 'Voir l\'offre',
              onTap: () {
                _showPromotionDetails(context, '50% de réduction', 'Tous nos produits sont en promotion avec 50% de réduction jusqu\'à la fin du mois !');
              },
            ),
            const SizedBox(height: 20),

            // Carte de Promotion 2
            _buildPromotionCard(
              context: context,
              title: 'Livraison Gratuite',
              description: 'Bénéficiez de la livraison gratuite pour toute commande supérieure à 50€.',
              imagePath: 'assets/images/promo2.jpg',
              buttonText: 'Commander maintenant',
              onTap: () {
                _showPromotionDetails(context, 'Livraison Gratuite', 'Livraison offerte sur toutes les commandes au-delà de 50€.');
              },
            ),
            const SizedBox(height: 20),

            // Carte de Promotion 3
            _buildPromotionCard(
              context: context,
              title: 'Nouveau Produit',
              description: 'Découvrez notre tout dernier produit avec une remise de 30% pour les premiers clients.',
              imagePath: 'assets/images/promo3.jpg',
              buttonText: 'Acheter maintenant',
              onTap: () {
                _showPromotionDetails(context, 'Nouveau Produit', 'Profitez d\'une réduction de 30% sur notre tout dernier produit.');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPromotionCard({
    required BuildContext context,
    required String title,
    required String description,
    required String imagePath,
    required String buttonText,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16.0)),
            child: Image.asset(
              imagePath,
              height: 150,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: onTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: Text(buttonText),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showPromotionDetails(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Fermer',
                style: TextStyle(color: Colors.teal),
              ),
            ),
          ],
        );
      },
    );
  }
}
