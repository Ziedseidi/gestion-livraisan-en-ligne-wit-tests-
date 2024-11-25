import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'dart:convert';
import 'mock_client.mocks.dart';  // Import du fichier généré

void main() {
  group('Signup API Tests', () {
    test('Signup should succeed and return success message', () async {
      final client = MockClient(); // Utilisation du mock généré
      const String apiUrl = "http://192.168.1.4:3500/users/signup";

      final responseData = json.encode({"message": "Inscription réussie"});

      when(client.post(
        Uri.parse(apiUrl),
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async {
        return http.Response(responseData, 200); // Retourne une réponse valide
      });

      final response = await client.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "firstName": "John",
          "lastName": "Doe",
          "email": "john.doe@example.com",
          "phone": "0123456789",
          "address": "123 Street",
          "password": "password123",
          "service": "producteur",
        }),
      );

      expect(response.statusCode, 200);
      final data = json.decode(response.body);
      expect(data['message'], 'Inscription réussie');
    });
  });
}
