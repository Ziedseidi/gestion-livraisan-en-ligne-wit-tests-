import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:livraison/pages/loginpage.dart';
import 'package:livraison/pages/welcome_page.dart';

void main() {
  group('WelcomePage Tests', () {
    testWidgets('Displays welcome text and button', (WidgetTester tester) async {
      // Charger la page WelcomePage
      await tester.pumpWidget(
        const MaterialApp(home: WelcomePage()),
      );

      // Vérifier si le texte de bienvenue est affiché
      expect(find.text('Bienvenue chez nous'), findsOneWidget);

      // Vérifier si le bouton "Visiter notre site" est bien affiché
      expect(find.text('Visiter notre site'), findsOneWidget);
    });

    testWidgets('Background image is displayed', (WidgetTester tester) async {
      // Charger la page WelcomePage
      await tester.pumpWidget(
        const MaterialApp(home: WelcomePage()),
      );

      // Vérifier si l'image d'arrière-plan est affichée
      final imageFinder = find.byType(Image);
      expect(imageFinder, findsOneWidget);

      // Vérifier les propriétés de l'image
      final imageWidget = tester.widget<Image>(imageFinder);
      expect(
        (imageWidget.image as AssetImage).assetName,
        'assets/images/food-unique-decoration-restaurant-wall-260nw-1492036772.webp',
      );
    });

    testWidgets('Navigates to LoginPage when button is pressed', (WidgetTester tester) async {
      // Charger la page WelcomePage
      await tester.pumpWidget(
        const MaterialApp(home: WelcomePage()),
      );

      // Vérifier si le bouton "Visiter notre site" est présent
      final buttonFinder = find.text('Visiter notre site');
      expect(buttonFinder, findsOneWidget);

      // Simuler le clic sur le bouton
      await tester.tap(buttonFinder);
      await tester.pumpAndSettle();

      // Vérifier si la page LoginPage est affichée
      expect(find.byType(LoginPage), findsOneWidget);
    });
  });
}
