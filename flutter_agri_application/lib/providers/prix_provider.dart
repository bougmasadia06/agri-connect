import 'package:flutter/foundation.dart';
import '../models/prix_marche.dart';
import '../services/prix_api.dart';

class PrixProvider with ChangeNotifier {
  final PrixApi _prixApi = PrixApi();

  PrixMarche? _prixActuel;
  List<PrixMarche> _historique = [];
  bool _chargement = false;

  PrixMarche? get prixActuel => _prixActuel;
  List<PrixMarche> get historique => _historique;
  bool get chargement => _chargement;

  Future<void> chargerPrix(String produitId, String regionId) async {
    _chargement = true;
    notifyListeners();

    try {
      _prixActuel = await _prixApi.getDernierPrix(produitId, regionId);
      _historique = await _prixApi.getHistorique(produitId, regionId);
    } finally {
      _chargement = false;
      notifyListeners();
    }
  }
}