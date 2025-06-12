class Livreur {
  final int id;
  final int utilisateurId;
  final String typeVehicule;
  final String? numeroImmatriculation;
  final String? photoMoto;
  final String? photoLivreur;
  final bool disponibilite;
  final int nombreLivraisons;
  final String statut;
  final DateTime dateCreation;

  Livreur({
    required this.id,
    required this.utilisateurId,
    required this.typeVehicule,
    this.numeroImmatriculation,
    this.photoMoto,
    this.photoLivreur,
    required this.disponibilite,
    required this.nombreLivraisons,
    required this.statut,
    required this.dateCreation,
  });

  factory Livreur.fromJson(Map<String, dynamic> json) {
    return Livreur(
      id: json['id'] as int,
      utilisateurId: json['utilisateur_id'] as int,
      typeVehicule: json['type_vehicule'] as String,
      numeroImmatriculation: json['numero_immatriculation'] as String?,
      photoMoto: json['photo_moto'] as String?,
      photoLivreur: json['photo_livreur'] as String?,
      disponibilite: json['disponibilite'] as bool,
      nombreLivraisons: json['nombre_livraisons'] as int,
      statut: json['statut'] as String,
      dateCreation: DateTime.parse(json['date_creation'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'utilisateur_id': utilisateurId,
      'type_vehicule': typeVehicule,
      'numero_immatriculation': numeroImmatriculation,
      'photo_moto': photoMoto,
      'photo_livreur': photoLivreur,
      'disponibilite': disponibilite,
      'nombre_livraisons': nombreLivraisons,
      'statut': statut,
      'date_creation': dateCreation.toIso8601String(),
    };
  }
}