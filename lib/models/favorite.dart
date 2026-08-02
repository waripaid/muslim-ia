class Favorite {
  final String id;
  final String sourate;
  final String verset;
  final String texteArabe;
  final String traduction;
  final String notes;
  final DateTime? createdAt;

  Favorite({
    required this.id,
    required this.sourate,
    required this.verset,
    this.texteArabe = '',
    this.traduction = '',
    this.notes = '',
    this.createdAt,
  });

  factory Favorite.fromJson(Map<String, dynamic> json) {
    return Favorite(
      id: json['id'] ?? '',
      sourate: json['sourate'] ?? '',
      verset: json['verset']?.toString() ?? '',
      texteArabe: json['texte_arabe'] ?? '',
      traduction: json['traduction'] ?? '',
      notes: json['notes'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'sourate': sourate,
        'verset': verset,
        'texte_arabe': texteArabe,
        'traduction': traduction,
        'notes': notes,
      };

  String get reference => '$sourate $verset';
}
