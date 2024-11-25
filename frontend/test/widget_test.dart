import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:livraison/main.dart';
import 'testpage-signup.dart';



void main() {
  // Exécute tous les tests dans 'testaffichage-home.dart'
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Lancer le widget MyApp
    await tester.pumpWidget(const MyApp());

    // Vérifiez que le compteur commence à 0
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tapez sur l'icône '+' et déclencher un frame
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Vérifiez que le compteur a été incrémenté
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });

  // Cela exécutera tous les tests dans testaffichage-home.dart
}
