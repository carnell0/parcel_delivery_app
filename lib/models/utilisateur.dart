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
      id: json['id'] ?? 0,
      nom: json['nom'] ?? json['last_name'] ?? json['lastname'] ?? 'Inconnu',
      prenom: json['prenom'] ?? json['first_name'] ?? json['firstname'] ?? 'Inconnu',
      email: json['email'] ?? 'inconnu@example.com',
      telephone: json['telephone'] ?? '0000000000',
      motDePasse: json['mot_de_passe'] ?? json['password'] ?? '',
      role: json['role'] ?? 'client',
      dateCreation: json['date_creation'] != null
          ? DateTime.parse(json['date_creation'].toString())
          : DateTime.now(),
      photoUrl: json['photo_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'last_name': nom,
      'first_name': prenom,
      'email': email,
      'telephone': telephone,
      'password': motDePasse,
      'role': role,
      'date_creation': dateCreation.toIso8601String(),
      'photo_url': photoUrl,
    };
  }
}
