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
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      nom: json['nom'] ?? '',
      prenom: json['prenom'] ?? '',
      email: json['email'] as String,
      telephone: json['telephone'] ?? '',
      role: json['role'] as String,
      typeVehicule: json['typeVehicule'] as String?,
      numeroImmatriculation: json['numeroImmatriculation'] as String?,
      photoLivreur: json['photoLivreur'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'id': id,
      'nom': nom,
      'prenom': prenom,
      'email': email,
      'telephone': telephone,
      'role': role,
    };

    if (role == 'livreur') {
      data.addAll({
        'typeVehicule': typeVehicule,
        'numeroImmatriculation': numeroImmatriculation,
        'photoLivreur': photoLivreur,
      });
    }

    return data;
  }
}