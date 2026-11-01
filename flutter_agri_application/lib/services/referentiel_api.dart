import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/produit.dart';
import '../models/region.dart';

class ReferentielApi {
  static const String baseUrl = 'http://localhost:5000/api';

  Future<List<Region>> getRegions() async {
    final reponse = await http.get(Uri.parse('$baseUrl/regions'));
    if (reponse.statusCode == 200) {
      final List donnees = jsonDecode(reponse.body);
      return donnees.map((json) => Region.fromJson(json)).toList();
    } else {
      throw Exception('Erreur lors du chargement des régions');
    }
  }

  Future<List<Produit>> getProduits() async {
    final reponse = await http.get(Uri.parse('$baseUrl/produits'));
    if (reponse.statusCode == 200) {
      final List donnees = jsonDecode(reponse.body);
      return donnees.map((json) => Produit.fromJson(json)).toList();
    } else {
      throw Exception('Erreur lors du chargement des produits');
    }
  }
}