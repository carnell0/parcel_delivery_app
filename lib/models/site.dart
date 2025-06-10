class Site {
  final int id;
  final String nom;
  final String? typeSite;
  final String? latitude;
  final String? longitude;
  final String email;
  final String telephone;
  final DateTime dateCreation;

  Site({
    required this.id,
    required this.nom,
    this.typeSite,
    this.latitude,
    this.longitude,
    required this.email,
    required this.telephone,
    required this.dateCreation,
  });

  factory Site.fromJson(Map<String, dynamic> json) {
    return Site(
      id: json['id'] as int,
      nom: json['nom'] as String,
      typeSite: json['type_site'] as String?,
      latitude: json['latitude'] as String?,
      longitude: json['longitude'] as String?,
      email: json['email'] as String,
      telephone: json['telephone'] as String,
      dateCreation: DateTime.parse(json['date_creation'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'type_site': typeSite,
      'latitude': latitude,
      'longitude': longitude,
      'email': email,
      'telephone': telephone,
      'date_creation': dateCreation.toIso8601String(),
    };
  }
} 