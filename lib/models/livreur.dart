class Livreur {
  final int id;
  final String nom;
  final String prenom;
  final String email;
  final String telephone;
  final String photo_livreur;
  final String immatriculation_moto;
  final String photo_moto;
  final String statut_livreur;
  final String typeVehicule;

  Livreur({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.email,
    required this.telephone,
    required this.photo_livreur,
    required this.immatriculation_moto,
    required this.photo_moto,
    required this.statut_livreur,
    required this.typeVehicule,
  });

  factory Livreur.fromJson(Map<String, dynamic> json) {
    return Livreur(
      id: json['id'] as int,
      nom: json['nom'] as String,
      prenom: json['prenom'] as String,
      email: json['email'] as String,
      telephone: json['telephone'] as String,
      photo_livreur: json['photo_livreur'] as String,
      immatriculation_moto: json['immatriculation_moto'] as String,
      photo_moto: json['photo_moto'] as String,
      statut_livreur: json['statut_livreur'] as String,
      typeVehicule: json['type_vehicule'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'prenom': prenom,
      'email': email,
      'telephone': telephone,
      'photo_livreur': photo_livreur,
      'immatriculation_moto': immatriculation_moto,
      'photo_moto': photo_moto,
      'statut_livreur': statut_livreur,
      'type_vehicule': typeVehicule,
    };
  }
}