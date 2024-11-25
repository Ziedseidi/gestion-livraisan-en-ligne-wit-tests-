import 'package:flutter/material.dart';

class AdvertisementPage extends StatelessWidget {
  const AdvertisementPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Publicité',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurpleAccent,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Arrière-plan lumineux
          Positioned.fill(
            child: Opacity(
              opacity: 0.3,
              child: Image.asset(
                'assets/images/arriere-plan-lumineux-technologie-ecran-projection-led-arriere-plan-affichage-scene-vectorielle-led-bleue-lueur_726113-233.avif',
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                const Text(
                  'Nos Dernières Publicités',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),

                // Exemple de publicité 1
                _buildAdCard(
                  title: 'Promo Spéciale 50% OFF',
                  description: 'Obtenez 50% de réduction sur votre première commande !',
                  imagePath: 'assets/images/promo1.jpg',
                ),
                const SizedBox(height: 20),

                // Exemple de publicité 2
                _buildAdCard(
                  title: 'Livraison Gratuite',
                  description: 'Livraison gratuite ce week-end pour toutes les commandes !',
                  imagePath: 'assets/images/promo2.jpg',
                ),
                const SizedBox(height: 20),

                // Exemple de publicité 3
                _buildAdCard(
                  title: 'Nouveaux Plats Disponibles',
                  description: 'Découvrez nos nouveaux plats délicieux ajoutés au menu !',
                  imagePath: 'assets/images/promo3.jpg',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdCard({
    required String title,
    required String description,
    required String imagePath,
  }) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
                height: 150,
                width: double.infinity,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurpleAccent,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
