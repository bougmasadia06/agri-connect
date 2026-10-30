import 'package:flutter/foundation.dart';
import '../models/annonce.dart';
import '../services/annonce_api.dart';

class AnnonceProvider with ChangeNotifier {
  final AnnonceApi _annonceApi = AnnonceApi();

  List<Annonce> _annonces = [];
  bool _chargement = false;
  String? _filtreProduit;
  String? _filtreRegion;

  List<Annonce> get annonces => _annonces;
  bool get chargement => _chargement;
  String? get filtreProduit => _filtreProduit;
  String? get filtreRegion => _filtreRegion;

  Future<void> chargerAnnonces() async {
    _chargement = true;
    notifyListeners();

    try {
      _annonces = await _annonceApi.getAnnonces(
        produit: _filtreProduit,
        region: _filtreRegion,
      );
    } finally {
      _chargement = false;
      notifyListeners();
    }
  }

  void appliquerFiltres({String? produit, String? region}) {
    _filtreProduit = produit;
    _filtreRegion = region;
    chargerAnnonces();
  }

  Future<void> publier(Map<String, dynamic> donnees, String token) async {
    await _annonceApi.publierAnnonce(donnees, token);
    await chargerAnnonces();
  }

  Future<void> contacter(String annonceId, String token) async {
    await _annonceApi.contacterAnnonce(annonceId, token);
  }
}