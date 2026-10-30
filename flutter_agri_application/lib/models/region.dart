class Region {
  final String id;
  final String nom;

  Region({required this.id, required this.nom});

  factory Region.fromJson(Map<String, dynamic> json) {
    return Region(id: json['id'] ?? json['_id'], nom: json['nom']);
  }

  Map<String, dynamic> toJson() => {'id': id, 'nom': nom};
}