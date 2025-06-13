class Utilisateur {
  final int id;
  final String nom;
  final String prenom;
  final String email;
  final String telephone;
  final String motDePasse;
  final String role;
  final DateTime dateCreation;
  final String? photoUrl;

  Utilisateur({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.email,
    required this.telephone,
    required this.motDePasse,
    required this.role,
    required this.dateCreation,
    this.photoUrl,
  });

  factory Utilisateur.fromJson(Map<String, dynamic> json) {
    return Utilisateur(
      id: json['id'] as int,
      nom: json['nom'] as String,
      prenom: json['prenom'] as String,
      email: json['email'] as String,
      telephone: json['telephone'] as String,
      motDePasse: json['mot_de_passe'] as String,
      role: json['role'] as String,
      dateCreation: DateTime.parse(json['date_creation'] as String),
      photoUrl: json['photo_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'prenom': prenom,
      'email': email,
      'telephone': telephone,
      'mot_de_passe': motDePasse,
      'role': role,
      'date_creation': dateCreation.toIso8601String(),
      'photo_url': photoUrl,
    };
  }
} 