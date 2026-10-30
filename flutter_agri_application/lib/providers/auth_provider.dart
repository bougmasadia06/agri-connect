import 'package:flutter/foundation.dart';
import '../models/utilisateur.dart';
import '../services/auth_api.dart';

class AuthProvider with ChangeNotifier {
  final AuthApi _authApi = AuthApi();

  Utilisateur? _utilisateur;
  String? _token;
  bool _chargement = false;

  Utilisateur? get utilisateur => _utilisateur;
  String? get token => _token;
  bool get estConnecte => _token != null;
  bool get chargement => _chargement;

  Future<void> login(String telephone, String motDePasse) async {
    _chargement = true;
    notifyListeners();

    try {
      final resultat = await _authApi.login(telephone, motDePasse);
      _token = resultat['token'];
      _utilisateur = resultat['utilisateur'];
    } finally {
      _chargement = false;
      notifyListeners();
    }
  }

  Future<void> register(Map<String, dynamic> donnees) async {
    _chargement = true;
    notifyListeners();

    try {
      final resultat = await _authApi.register(donnees);
      _token = resultat['token'];
      _utilisateur = resultat['utilisateur'];
    } finally {
      _chargement = false;
      notifyListeners();
    }
  }

  void deconnexion() {
    _token = null;
    _utilisateur = null;
    notifyListeners();
  }
}