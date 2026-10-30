import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/utilisateur.dart';

class AuthApi {
  static const String baseUrl = 'http://localhost:5000/api';

  Future<Map<String, dynamic>> login(String telephone, String motDePasse) async {
    final reponse = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'telephone': telephone, 'mot_de_passe': motDePasse}),
    );

    if (reponse.statusCode == 200) {
      final donnees = jsonDecode(reponse.body);
      return {
        'token': donnees['token'],
        'utilisateur': Utilisateur.fromJson(donnees['utilisateur']),
      };
    } else {
      throw Exception('Identifiants incorrects');
    }
  }

  Future<Map<String, dynamic>> register(Map<String, dynamic> donneesInscription) async {
    final reponse = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(donneesInscription),
    );

    if (reponse.statusCode == 201) {
      final donnees = jsonDecode(reponse.body);
      return {
        'token': donnees['token'],
        'utilisateur': Utilisateur.fromJson(donnees['utilisateur']),
      };
    } else {
      final erreur = jsonDecode(reponse.body);
      throw Exception(erreur['error'] ?? 'Erreur lors de l\'inscription');
    }
  }
}