class Entreprise {
  final int id;
  final String nom;
  final String? domaineActivite;
  final String? localisation;
  final String email;
  final String telephone;
  final DateTime dateCreation;

  Entreprise({
    required this.id,
    required this.nom,
    this.domaineActivite,
    this.localisation,
    required this.email,
    required this.telephone,
    required this.dateCreation,
  });

  factory Entreprise.fromJson(Map<String, dynamic> json) {
    return Entreprise(
      id: json['id'] as int,
      nom: json['nom'] as String,
      domaineActivite: json['domaine_activite'] as String?,
      localisation: json['localisation'] as String?,
      email: json['email'] as String,
      telephone: json['telephone'] as String,
      dateCreation: DateTime.parse(json['date_creation'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'domaine_activite': domaineActivite,
      'localisation': localisation,
      'email': email,
      'telephone': telephone,
      'date_creation': dateCreation.toIso8601String(),
    };
  }
}