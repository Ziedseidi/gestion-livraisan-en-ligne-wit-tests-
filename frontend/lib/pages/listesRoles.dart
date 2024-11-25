import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // Assure-toi d'importer jsonEncode

class RoleListPage extends StatefulWidget {
  final List<dynamic> initialRoles; // Liste des rôles passée en paramètre
  final String token; // Token d'autorisation

  RoleListPage({required this.initialRoles, required this.token});

  @override
  _RoleListPageState createState() => _RoleListPageState();
}

class _RoleListPageState extends State<RoleListPage> {
  late List<dynamic> roles; // Liste des rôles

  @override
  void initState() {
    super.initState();
    roles = widget.initialRoles; // Initialiser les rôles avec ceux passés
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Liste des rôles'),
        backgroundColor: Colors.teal,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/R.jpg'), // Chemin vers l'image dans assets
            fit: BoxFit.cover, // L'image couvre tout l'arrière-plan
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: roles.isEmpty
              ? Center(child: Text('Aucun rôle trouvé'))
              : ListView.builder(
                  itemCount: roles.length,
                  itemBuilder: (context, index) {
                    final role = roles[index];

                    return Card(
                      child: ListTile(
                        title: Text(role['name']?.toString() ?? 'Nom non disponible'),
                        subtitle: Text(role['description']?.toString() ?? 'Description non disponible'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.blue),
                              onPressed: () {
                                _showEditDialog(context, role, index);
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                final roleId = role['_id'];
                                if (roleId != null) {
                                  _confirmDeleteRole(context, roleId, index);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('ID du rôle non disponible')),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, dynamic role, int index) {
    final TextEditingController nameController = TextEditingController(text: role['name']);
    final TextEditingController descriptionController = TextEditingController(text: role['description']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Modifier le rôle'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Nom'),
                ),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(labelText: 'Description'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Fermer le dialog
              },
              child: Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () async {
                // Effectuer la requête de mise à jour
                final response = await http.put(
                  Uri.parse('http://172.20.10.6:3500/roles/${role['_id']}'),
                  headers: {
                    'Authorization': 'Bearer ${widget.token}',
                    'Content-Type': 'application/json',
                  },
                  body: jsonEncode({ // Encode le corps en JSON
                    'name': nameController.text,
                    'description': descriptionController.text,
                  }),
                );

                if (response.statusCode == 200) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Rôle mis à jour avec succès')),
                  );

                  // Mettre à jour le rôle dans la liste locale
                  setState(() {
                    roles[index]['name'] = nameController.text; // Mettre à jour le nom
                    roles[index]['description'] = descriptionController.text; // Mettre à jour la description
                  });

                  Navigator.of(context).pop(); // Fermer le dialog
                } else {
                  print('Erreur : ${response.statusCode}');
                  print('Réponse : ${response.body}'); // Log pour déboguer
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erreur lors de la mise à jour du rôle')),
                  );
                }
              },
              child: Text('Enregistrer'),
            ),
          ],
        );
      },
    );
  }

  void _confirmDeleteRole(BuildContext context, String roleId, int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirmer la suppression'),
          content: Text('Êtes-vous sûr de vouloir supprimer ce rôle ?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Fermer le dialog
              },
              child: Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () async {
                // Effectuer la requête de suppression
                final response = await http.delete(
                  Uri.parse('http://172.20.10.6:3500/roles/$roleId'),
                  headers: {
                    'Authorization': 'Bearer ${widget.token}',
                  },
                );

                if (response.statusCode == 200) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Rôle supprimé avec succès')),
                  );

                  // Supprimer le rôle de la liste locale
                  setState(() {
                    roles.removeAt(index); // Retirer le rôle de la liste
                  });

                  Navigator.of(context).pop(); // Fermer le dialog
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erreur lors de la suppression du rôle')),
                  );
                }
              },
              child: Text('Supprimer'),
            ),
          ],
        );
      },
    );
  }
}
