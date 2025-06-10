class Demande {
  final int id;
  final int utilisateurId;
  final String? natureColis;
  final String? dimensions;
  final double? poids;
  final String? photoColis;
  final String adresseDepart;
  final String adresseDestination;
  final String modeLivraison;
  final String statutDemande;
  final DateTime dateCreation;

  Demande({
    required this.id,
    required this.utilisateurId,
    this.natureColis,
    this.dimensions,
    this.poids,
    this.photoColis,
    required this.adresseDepart,
    required this.adresseDestination,
    required this.modeLivraison,
    required this.statutDemande,
    required this.dateCreation,
  });

  factory Demande.fromJson(Map<String, dynamic> json) {
    return Demande(
      id: json['id'] as int,
      utilisateurId: json['utilisateur_id'] as int,
      natureColis: json['nature_colis'] as String?,
      dimensions: json['dimensions'] as String?,
      poids: (json['poids'] as num?)?.toDouble(),
      photoColis: json['photo_colis'] as String?,
      adresseDepart: json['adresse_depart'] as String,
      adresseDestination: json['adresse_destination'] as String,
      modeLivraison: json['mode_livraison'] as String,
      statutDemande: json['statut_demande'] as String,
      dateCreation: DateTime.parse(json['date_creation'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'utilisateur_id': utilisateurId,
      'nature_colis': natureColis,
      'dimensions': dimensions,
      'poids': poids,
      'photo_colis': photoColis,
      'adresse_depart': adresseDepart,
      'adresse_destination': adresseDestination,
      'mode_livraison': modeLivraison,
      'statut_demande': statutDemande,
      'date_creation': dateCreation.toIso8601String(),
    };
  }
} 