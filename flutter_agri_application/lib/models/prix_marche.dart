class PrixMarche {
  final double prixMoyen;
  final DateTime dateReleve;

  PrixMarche({required this.prixMoyen, required this.dateReleve});

  factory PrixMarche.fromJson(Map<String, dynamic> json) {
    return PrixMarche(
      prixMoyen: (json['prix_moyen'] as num).toDouble(),
      dateReleve: DateTime.parse(json['date_releve']),
    );
  }
}