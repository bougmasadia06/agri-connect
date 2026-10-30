import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/annonce.dart';

class AnnonceApi {
  // Remplace par l'adresse de ton backend une fois déployé
  static const String baseUrl = 'http://localhost:5000/api';
  // localhost fonctionne sur Chrome. Sur un émulateur Android, utilise 10.0.2.2.

  Future<List<Annonce>> getAnnonces({String? produit, String? region}) async {
    final params = <String, String>{};
    if (produit != null) params['produit'] = produit;
    if (region != null) params['region'] = region;

    final uri = Uri.parse('$baseUrl/annonces').replace(queryParameters: params);
    final reponse = await http.get(uri);

    if (reponse.statusCode == 200) {
      final List donnees = jsonDecode(reponse.body);
      return donnees.map((json) => Annonce.fromJson(json)).toList();
    } else {
      throw Exception('Erreur lors du chargement des annonces');
    }
  }

  Future<Annonce> getAnnonceDetail(String id) async {
    final reponse = await http.get(Uri.parse('$baseUrl/annonces/$id'));

    if (reponse.statusCode == 200) {
      return Annonce.fromJson(jsonDecode(reponse.body));
    } else {
      throw Exception('Annonce introuvable');
    }
  }

  Future<void> publierAnnonce(Map<String, dynamic> donnees, String token) async {
    final reponse = await http.post(
      Uri.parse('$baseUrl/annonces'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(donnees),
    );

    if (reponse.statusCode != 201) {
      throw Exception('Erreur lors de la publication');
    }
  }

  Future<void> contacterAnnonce(String annonceId, String token) async {
    final reponse = await http.post(
      Uri.parse('$baseUrl/annonces/$annonceId/contacter'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (reponse.statusCode != 200) {
      throw Exception('Erreur lors du contact');
    }
  }
}