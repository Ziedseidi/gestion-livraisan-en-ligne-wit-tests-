import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DishListPage extends StatefulWidget {
  final List<dynamic> initialDishes;
  final String token;

  DishListPage({required this.initialDishes, required this.token});

  @override
  _DishListPageState createState() => _DishListPageState();
}

class _DishListPageState extends State<DishListPage> {
  late List<dynamic> dishes;

  @override
  void initState() {
    super.initState();
    dishes = widget.initialDishes;
  }

  // Fonction pour afficher le formulaire de livraison avec le champ téléphone
  Future<void> _showDeliveryForm(String dishId) async {
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    String deliveryAddress = '';
    String phoneNumber = '';

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Détails de la Livraison'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  onChanged: (value) {
                    phoneNumber = value;
                  },
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Numéro de Téléphone',
                    hintText: 'Entrez le numéro de téléphone',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Le numéro de téléphone est requis';
                    }
                    if (value.length < 8) {
                      return 'Numéro invalide';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  onChanged: (value) {
                    deliveryAddress = value;
                  },
                  decoration: const InputDecoration(
                    labelText: 'Adresse de Livraison',
                    hintText: 'Entrez l\'adresse de livraison',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'L\'adresse est requise';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Annuler', style: TextStyle(color: Colors.red)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  Navigator.of(context).pop();
                  await _deliverDish(dishId, phoneNumber, deliveryAddress);
                }
              },
              child: const Text('Confirmer'),
            ),
          ],
        );
      },
    );
  }

  // Fonction pour gérer la livraison d'un plat
  Future<void> _deliverDish(String dishId, String phoneNumber, String deliveryAddress) async {
    if (deliveryAddress.isEmpty || phoneNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez entrer un numéro de téléphone et une adresse.')),
      );
      return;
    }

    if (widget.token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Jeton invalide. Veuillez vous reconnecter.')),
      );
      return;
    }

    final url = 'http://192.168.1.4:3500/deliverys/addDelivery';
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${widget.token}', // Envoi du token ici
    };
    final body = jsonEncode({
      'orderedDishes': [dishId],
      'phone': phoneNumber,
      'deliveryAddress': deliveryAddress,
    });

    try {
      print('Envoi de la requête avec le token : ${widget.token}');
      final response = await http.post(Uri.parse(url), headers: headers, body: body);

      // Vérifier si la réponse est valide et peut être convertie en JSON
      if (response.statusCode == 201) {
        // Afficher un message centré avec un Dialog
        _showSuccessDialog();
      } else {
        // Si la réponse n'est pas un succès, afficher le message d'erreur
        try {
          final errorResponse = jsonDecode(response.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur: ${errorResponse['message']}')),
          );
        } catch (e) {
          // Si la réponse ne peut pas être décodée en JSON, afficher l'erreur brute
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur de réponse: ${response.body}')),
          );
        }
      }
    } catch (error) {
      // Afficher l'erreur si la requête échoue
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur de connexion: $error')),
      );
    }
  }

  // Fonction pour afficher un message centré avec un emoji
  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 80),
              const SizedBox(height: 16.0),
              const Text(
                '😊 Livraison passée avec succès !\nAttendez la confirmation au maximum 5 minutes.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Fermer', style: TextStyle(color: Colors.green)),
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
        title: const Text('Liste des Plats'),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: dishes.isEmpty
            ? const Center(child: Text('Aucun plat trouvé'))
            : GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16.0,
                  mainAxisSpacing: 16.0,
                  childAspectRatio: 0.7,
                ),
                itemCount: dishes.length,
                itemBuilder: (context, index) {
                  final dish = dishes[index];

                  return Card(
                    elevation: 5.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(15.0),
                                topRight: Radius.circular(15.0)),
                            child: dish['image'] != null && dish['image'].isNotEmpty
                                ? Image.network(
                                    dish['image'],
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  )
                                : const Icon(
                                    Icons.fastfood,
                                    size: 80,
                                    color: Colors.grey,
                                  ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                dish['name'] ?? 'Nom non disponible',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                'Prix: ${dish['price']?.toString() ?? 'Non spécifié'} \$',
                                style: const TextStyle(
                                    fontSize: 14.0, fontWeight: FontWeight.bold, color: Colors.orange),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            _showDeliveryForm(dish['_id']);
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                          child: const Text('Livrer'),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}
