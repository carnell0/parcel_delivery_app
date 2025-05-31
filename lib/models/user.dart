class User {
  final int id;
  final String nom;
  final String prenom;
  final String email;
  final String telephone;
  final String role;
  final String? typeVehicule;
  final String? numeroImmatriculation;
  final String? photoLivreur;
  final int? nombreLivraisons;
  final bool? disponibilite;

  User({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.email,
    required this.telephone,
    required this.role,
    this.typeVehicule,
    this.numeroImmatriculation,
    this.photoLivreur,
    this.nombreLivraisons,
    this.disponibilite,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      nom: json['nom'] as String,
      prenom: json['prenom'] as String,
      email: json['email'] as String,
      telephone: json['telephone'] as String,
      role: json['role'] as String,
      typeVehicule: json['type_vehicule'] as String?,
      numeroImmatriculation: json['numero_immatriculation'] as String?,
      photoLivreur: json['photo_livreur'] as String?,
      nombreLivraisons: json['nombre_livraisons'] as int?,
      disponibilite: json['disponibilite'] as bool?,
    );
  }
}