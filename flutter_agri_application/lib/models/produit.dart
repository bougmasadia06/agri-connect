class Produit {
  final String id;
  final String nom;
  final String unite;

  Produit({required this.id, required this.nom, required this.unite});

  factory Produit.fromJson(Map<String, dynamic> json) {
    return Produit(
      id: json['id'] ?? json['_id'],
      nom: json['nom'],
      unite: json['unite'],
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'nom': nom, 'unite': unite};
}