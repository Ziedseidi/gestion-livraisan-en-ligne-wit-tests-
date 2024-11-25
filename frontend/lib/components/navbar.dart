import 'package:flutter/material.dart';

class Navbar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        'Dashboard Admin', // Titre
        overflow: TextOverflow.ellipsis, // Ajout des points de suspension si le texte est trop long
        style: TextStyle(
          color: Colors.white, // Couleur du texte
        ),
      ),
      backgroundColor: const Color.fromARGB(255, 10, 145, 32), // Couleur de fond de la barre
      actions: [
        IconButton(
          icon: Icon(Icons.notifications),
          onPressed: () {
            // Action pour les notifications
          },
        ),
        PopupMenuButton<String>(
          onSelected: (String result) {
            // Action pour le menu popup
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            const PopupMenuItem<String>(
              value: 'Settings',
              child: Text('Settings'),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
