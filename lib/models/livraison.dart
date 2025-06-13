import 'package:latlong2/latlong.dart';

class Livraison {
  final int id;
  final DateTime datePriseEnCharge;
  final double? longitudeDepart;
  final double? latitudeDepart;
  final double? longitudeArrivee;
  final double? latitudeArrivee;
  final int? numeroDepart;
  final int? numeroArrivee;
  final DateTime? dateLivraison;
  final String statut;
  final int utilisateurId;
  final int demandeId;
  final int livreurId;
  final String? nomLivreur;
  final DateTime? dateArriveeEstimee;
  final DateTime? derniereMiseAJour;

  Livraison({
    required this.id,
    required this.datePriseEnCharge,
    this.longitudeDepart,
    this.latitudeDepart,
    this.longitudeArrivee,
    this.latitudeArrivee,
    this.numeroDepart,
    this.numeroArrivee,
    this.dateLivraison,
    required this.statut,
    required this.utilisateurId,
    required this.demandeId,
    required this.livreurId,
    this.nomLivreur,
    this.dateArriveeEstimee,
    this.derniereMiseAJour,
  });

  factory Livraison.fromJson(Map<String, dynamic> json) {
    return Livraison(
      id: json['id'] as int,
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
      utilisateurId: json['utilisateur_id'] as int,
      demandeId: json['demande_id'] as int,
      livreurId: json['livreur_id'] as int,
      nomLivreur: json['nom_livreur'] as String?,
      dateArriveeEstimee: json['date_arrivee_estimee'] != null
          ? DateTime.parse(json['date_arrivee_estimee'] as String)
          : null,
      derniereMiseAJour: json['derniere_mise_a_jour'] != null
          ? DateTime.parse(json['derniere_mise_a_jour'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date_prise_en_charge': datePriseEnCharge.toIso8601String(),
      'longitude_depart': longitudeDepart,
      'latitude_depart': latitudeDepart,
      'longitude_arrivee': longitudeArrivee,
      'latitude_arrivee': latitudeArrivee,
      'numero_depart': numeroDepart,
      'numero_arrivee': numeroArrivee,
      'date_livraison': dateLivraison?.toIso8601String(),
      'statut': statut,
      'utilisateur_id': utilisateurId,
      'demande_id': demandeId,
      'livreur_id': livreurId,
      'nom_livreur': nomLivreur,
      'date_arrivee_estimee': dateArriveeEstimee?.toIso8601String(),
      'derniere_mise_a_jour': derniereMiseAJour?.toIso8601String(),
    };
  }

  // Getters pour la compatibilité avec l'ancien code
  LatLng get currentLocation => LatLng(
        latitudeArrivee ?? latitudeDepart ?? 0,
        longitudeArrivee ?? longitudeDepart ?? 0,
      );

  String get status => statut;
  String? get driverName => nomLivreur;
  DateTime? get estimatedArrival => dateArriveeEstimee;
  DateTime? get lastUpdate => derniereMiseAJour;
}