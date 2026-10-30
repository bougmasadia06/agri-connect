import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/prix_marche.dart';

class PrixApi {
  static const String baseUrl = 'http://localhost:5000/api';

  Future<PrixMarche?> getDernierPrix(String produitId, String regionId) async {
    final uri = Uri.parse('$baseUrl/prix').replace(queryParameters: {
      'produit': produitId,
      'region': regionId,
    });
    final reponse = await http.get(uri);

    if (reponse.statusCode == 200) {
      final donnees = jsonDecode(reponse.body);
      if (donnees['prix_moyen'] == null) return null;
      return PrixMarche.fromJson(donnees);
    } else {
      throw Exception('Erreur lors du chargement du prix');
    }
  }

  Future<List<PrixMarche>> getHistorique(String produitId, String regionId) async {
    final uri = Uri.parse('$baseUrl/prix/historique').replace(queryParameters: {
      'produit': produitId,
      'region': regionId,
    });
    final reponse = await http.get(uri);

    if (reponse.statusCode == 200) {
      final List donnees = jsonDecode(reponse.body);
      return donnees.map((json) => PrixMarche.fromJson(json)).toList();
    } else {
      throw Exception('Erreur lors du chargement de l\'historique');
    }
  }
}