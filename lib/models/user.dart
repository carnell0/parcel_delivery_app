class User {
  final String id;
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
      id: json['id'],
      nom: json['nom'],
      prenom: json['prenom'],
      email: json['email'],
      telephone: json['telephone'],
      role: json['role'],
      typeVehicule: json['typeVehicule'],
      numeroImmatriculation: json['numeroImmatriculation'],
      photoLivreur: json['photoLivreur'],
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