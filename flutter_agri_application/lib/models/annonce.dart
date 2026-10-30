import 'utilisateur.dart';
import 'produit.dart';
import 'region.dart';

class Annonce {
  final String id;
  final Utilisateur utilisateur;
  final Produit produit;
  final Region region;
  final double quantiteDisponible;
  final double prixPropose;
  final String statut;
  final DateTime datePublication;

  Annonce({
    required this.id,
    required this.utilisateur,
    required this.produit,
    required this.region,
    required this.quantiteDisponible,
    required this.prixPropose,
    required this.statut,
    required this.datePublication,
  });

  factory Annonce.fromJson(Map<String, dynamic> json) {
    return Annonce(
      id: json['_id'],
      utilisateur: Utilisateur(
        id: json['utilisateur']['id'],
        nom: json['utilisateur']['nom'],
        telephone: json['utilisateur']['telephone'],
        type: 'agriculteur',
      ),
      produit: Produit(
        id: json['produit']['id'],
        nom: json['produit']['nom'],
        unite: json['produit']['unite'],
      ),
      region: Region(
        id: json['region']['id'],
        nom: json['region']['nom'],
      ),
      quantiteDisponible: (json['quantite_disponible'] as num).toDouble(),
      prixPropose: (json['prix_propose'] as num).toDouble(),
      statut: json['statut'],
      datePublication: DateTime.parse(json['date_publication']),
    );
  }
}