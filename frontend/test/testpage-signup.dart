import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:livraison/pages/signuppage.dart'; // Assurez-vous que ce chemin est correct

void main() {
  testWidgets('SignupPage displays UI elements correctly', (WidgetTester tester) async {
    // Initialiser l'application avec la page de signup
    await tester.pumpWidget(MaterialApp(home: SignupPage()));
    await tester.pumpAndSettle(); // Attendre que l'UI soit complètement rendue

    // Vérifier que le titre "Signup" est affiché
    expect(find.text('Signup'), findsOneWidget);

    // Vérifier que le formulaire de saisie est affiché
    expect(find.byType(TextField), findsNWidgets(6)); // Vérifie 6 champs de texte
    expect(find.byType(DropdownButtonFormField<String>), findsOneWidget); // Vérifier Dropdown
    expect(find.byType(ElevatedButton), findsOneWidget); // Vérifier le bouton

    // Vérifier que l'image de fond est affichée
    expect(find.byType(Image), findsOneWidget);

    // Attendre que le menu déroulant soit complètement affiché
    final dropdown = find.byType(DropdownButtonFormField<String>);
    await tester.ensureVisible(dropdown); // S'assurer que le Dropdown est visible
    await tester.tap(dropdown); // Ouvrir le dropdown
    await tester.pumpAndSettle(); // Attendre que le dropdown soit complètement rendu

    // Vérifier que les options "Producteur" et "Consommateur" sont présentes dans le dropdown
    expect(find.text('Producteur'), findsOneWidget);
    expect(find.text('Consommateur'), findsOneWidget);
  });

  testWidgets('SignupPage handles errors correctly', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: SignupPage()));
    await tester.pumpAndSettle(); // Attendre que l'UI soit complètement rendue

    // Simuler des données incorrectes (par exemple, remplir seulement certains champs)
    await tester.enterText(find.byType(TextField).at(0), 'aziz'); // Remplir le champ 'First Name'
    await tester.enterText(find.byType(TextField).at(1), 'jouini'); // Remplir le champ 'Last Name'
    await tester.enterText(find.byType(TextField).at(2), 'jouiniaziz@gmail.com'); // Remplir le champ 'Email'
    await tester.enterText(find.byType(TextField).at(3), '11444'); // Remplir le champ 'Phone'
    await tester.enterText(find.byType(TextField).at(4), '145263'); // Remplir le champ 'Address'
    await tester.enterText(find.byType(TextField).at(5), ''); // Laisser le champ 'Password' vide

    // Faire défiler le bouton si nécessaire et cliquer dessus
    await tester.ensureVisible(find.byType(ElevatedButton)); // Faire défiler pour rendre le bouton visible
    await tester.tap(find.byType(ElevatedButton)); // Cliquer sur le bouton "S'inscrire"
    await tester.pumpAndSettle(); // Attendre que l'UI se mette à jour

    // Vérifier que le message d'erreur est affiché
    expect(find.text("Erreur lors de l'inscription. Vérifiez les données."), findsOneWidget);
  });

  testWidgets('Dropdown selection works correctly', (WidgetTester tester) async {
    // Construire le widget SignupPage
    await tester.pumpWidget(MaterialApp(home: SignupPage()));

    // Trouver le widget DropdownButtonFormField et ouvrir le menu déroulant
    final dropdown = find.byType(DropdownButtonFormField<String>);
    
    // Faire défiler pour rendre le widget visible si nécessaire
    await tester.ensureVisible(dropdown);
    
    // Ouvrir le menu déroulant
    await tester.tap(dropdown);
    await tester.pumpAndSettle(); // Attendre que le dropdown se déploie complètement

    // Vérifier si l'option "Producteur" est disponible
    expect(find.text('Producteur'), findsOneWidget);
    
    // Vérifier si l'option "Consommateur" est disponible
    expect(find.text('Consommateur'), findsOneWidget);

    // Sélectionner "Producteur" et vérifier qu'il est sélectionné
    await tester.tap(find.text('Producteur').last); // "last" garantit qu'on clique sur la bonne option
    await tester.pumpAndSettle();

    // Vérifier si la sélection a bien eu lieu
    expect(find.text('Producteur'), findsOneWidget);  // Vérifier si l'option est toujours visible après sélection
  });
}
