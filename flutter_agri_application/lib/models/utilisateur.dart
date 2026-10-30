class Utilisateur {
  final String id;
  final String nom;
  final String telephone;
  final String type;

  Utilisateur({
    required this.id,
    required this.nom,
    required this.telephone,
    required this.type,
  });

  factory Utilisateur.fromJson(Map<String, dynamic> json) {
    return Utilisateur(
      id: json['id'] ?? json['_id'],
      nom: json['nom'],
      telephone: json['telephone'],
      type: json['type'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nom': nom,
        'telephone': telephone,
        'type': type,
      };
}