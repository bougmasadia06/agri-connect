import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class UploadApi {
  // Adresse du serveur (sans /api), utilisée aussi pour afficher les photos
  static const String serveurUrl = 'http://localhost:5000';

  Future<String> envoyerImage(XFile fichier, String token) async {
    final requete = http.MultipartRequest('POST', Uri.parse('$serveurUrl/api/upload'));
    requete.headers['Authorization'] = 'Bearer $token';

    final octets = await fichier.readAsBytes();
    requete.files.add(
      http.MultipartFile.fromBytes('image', octets, filename: fichier.name),
    );

    final reponse = await http.Response.fromStream(await requete.send());
    if (reponse.statusCode != 201) {
      throw Exception('Erreur ${reponse.statusCode} : ${reponse.body}');
    }
    return jsonDecode(reponse.body)['url'];
  }
}