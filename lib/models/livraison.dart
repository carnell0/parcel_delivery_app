class Livraison {
  final int id;
  final int demandeId;
  final int livreurId;
  final DateTime datePriseEnCharge;
  final double? longitudeDepart;
  final double? latitudeDepart;
  final double? longitudeArrivee;
  final double? latitudeArrivee;
  final int? numeroDepart;
  final int? numeroArrivee;
  final DateTime? dateLivraison;
  final String statut;

  Livraison({
    required this.id,
    required this.demandeId,
    required this.livreurId,
    required this.datePriseEnCharge,
    this.longitudeDepart,
    this.latitudeDepart,
    this.longitudeArrivee,
    this.latitudeArrivee,
    this.numeroDepart,
    this.numeroArrivee,
    this.dateLivraison,
    required this.statut,
  });

  factory Livraison.fromJson(Map<String, dynamic> json) {
    return Livraison(
      id: json['id'] as int,
      demandeId: json['demande_id'] as int,
      livreurId: json['livreur_id'] as int,
      datePriseEnCharge: DateTime.parse(json['date_prise_en_charge'] as String),
      longitudeDepart: (json['longitude_depart'] as num?)?.toDouble(),
      latitudeDepart: (json['latitude_depart'] as num?)?.toDouble(),
      longitudeArrivee: (json['longitude_arrivee'] as num?)?.toDouble(),
      latitudeArrivee: (json['latitude_arrivee'] as num?)?.toDouble(),
      numeroDepart: json['numero_depart'] as int?,
      numeroArrivee: json['numero_arrivee'] as int?,
      dateLivraison: json['date_livraison'] != null
          ? DateTime.parse(json['date_livraison'] as String)
          : null,
      statut: json['statut'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'demande_id': demandeId,
      'livreur_id': livreurId,
      'date_prise_en_charge': datePriseEnCharge.toIso8601String(),
      'longitude_depart': longitudeDepart,
      'latitude_depart': latitudeDepart,
      'longitude_arrivee': longitudeArrivee,
      'latitude_arrivee': latitudeArrivee,
      'numero_depart': numeroDepart,
      'numero_arrivee': numeroArrivee,
      'date_livraison': dateLivraison?.toIso8601String(),
      'statut': statut,
    };
  }
}