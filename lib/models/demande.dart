class Demande {
  final int id;
  final int utilisateurId;
  final int siteId;
  final String statut;
  final DateTime dateDemande;
  final String? description;
  final String? adresse;
  final String? typeColis;
  final double? poids;
  final String? dimensions;
  final String? instructions;
  final String? photoUrl;

  Demande({
    required this.id,
    required this.utilisateurId,
    required this.siteId,
    required this.statut,
    required this.dateDemande,
    this.description,
    this.adresse,
    this.typeColis,
    this.poids,
    this.dimensions,
    this.instructions,
    this.photoUrl,
  });

  factory Demande.fromJson(Map<String, dynamic> json) {
    return Demande(
      id: json['id'] as int,
      utilisateurId: json['utilisateur_id'] as int,
      siteId: json['site_id'] as int,
      statut: json['statut'] as String,
      dateDemande: DateTime.parse(json['date_demande'] as String),
      description: json['description'] as String?,
      adresse: json['adresse'] as String?,
      typeColis: json['type_colis'] as String?,
      poids: json['poids'] as double?,
      dimensions: json['dimensions'] as String?,
      instructions: json['instructions'] as String?,
      photoUrl: json['photo_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'utilisateur_id': utilisateurId,
      'site_id': siteId,
      'statut': statut,
      'date_demande': dateDemande.toIso8601String(),
      'description': description,
      'adresse': adresse,
      'type_colis': typeColis,
      'poids': poids,
      'dimensions': dimensions,
      'instructions': instructions,
      'photo_url': photoUrl,
    };
  }
} 