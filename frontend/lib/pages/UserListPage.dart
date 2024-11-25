import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UserListPage extends StatefulWidget {
  final List<dynamic> users;
  final List<dynamic> availableRoles;
  final String token; // Ajoute le token ici

  UserListPage({required this.users, required this.availableRoles, required this.token});

  @override
  _UserListPageState createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  late List<dynamic> users;

  @override
  void initState() {
    super.initState();
    users = List.from(widget.users);
  }

  void _assignRoleDialog(BuildContext context, dynamic user) {
    String? selectedRoleName;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Assigner un rôle à ${user['firstName']} ${user['lastName']}'),
          content: DropdownButton<String>(
            hint: Text('Choisissez un rôle'),
            value: selectedRoleName,
            items: widget.availableRoles.map((role) {
              return DropdownMenuItem<String>(
                value: role['name'],
                child: Text(role['name']),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedRoleName = value;
              });
            },
          ),
          actions: [
            TextButton(
              child: Text('Annuler'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text('Assigner'),
              onPressed: () {
                if (selectedRoleName != null) {
                  _assignRoleToUser(user['_id'], selectedRoleName!);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _assignRoleToUser(String userId, String roleName) async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.1.4:3500/roles/assign-role'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.token}',
        },
        body: jsonEncode({
          'userId': userId,
          'roleName': roleName,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Rôle assigné avec succès')),
        );

        setState(() {
          users = users.map((user) {
            if (user['_id'] == userId) {
              List<dynamic> updatedRoles = List.from(user['roles'] ?? []);
              updatedRoles.add({'name': roleName});
              user['roles'] = updatedRoles;
            }
            return user;
          }).toList();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de l\'assignation du rôle')),
        );
      }
    } catch (e) {
      print('Erreur: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Une erreur est survenue')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Liste des utilisateurs'),
        backgroundColor: Colors.deepPurple,
      ),
      body: users.isEmpty
          ? Center(child: Text('Aucun utilisateur trouvé.'))
          : Padding(
              padding: const EdgeInsets.all(10.0),
              child: ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];

                  String fullName = '${user['firstName']} ${user['lastName']}';
                  String phone = user['phone'] ?? 'Numéro non disponible';
                  String address = user['deliveryAddress'] ?? 'Adresse non disponible';
                  List<dynamic> roles = user['roles'] ?? [];
                  String roleNames = roles.isNotEmpty
                      ? roles.map((role) => role['name']).join(', ')
                      : 'Rôle non assigné';

                  return Card(
                    elevation: 8,
                    margin: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.deepPurple,
                            radius: 30,
                            child: Icon(Icons.person, color: Colors.white),
                          ),
                          SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  fullName,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    color: Colors.deepPurple[800],
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Téléphone : $phone',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Adresse : $address',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Rôles : $roleNames',
                                  style: TextStyle(color: Colors.deepPurple[700], fontStyle: FontStyle.italic),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.deepPurple),
                            onPressed: () {
                              // Remplacer par une action de modification
                              _assignRoleDialog(context, user);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
