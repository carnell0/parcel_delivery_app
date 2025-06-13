class Site {
  final int id;
  final String typeSite;
  final String longitude;
  final String latitude;
  final String email;
  final String telephone;
  final DateTime dateCreation;

  Site({
    required this.id,
    required this.typeSite,
    required this.longitude,
    required this.latitude,
    required this.email,
    required this.telephone,
    required this.dateCreation,
  });

  factory Site.fromJson(Map<String, dynamic> json) {
    return Site(
      id: json['id'] as int,
      typeSite: json['type_site'] as String,
      longitude: json['longitude'] as String,
      latitude: json['latitude'] as String,
      email: json['email'] as String,
      telephone: json['telephone'] as String,
      dateCreation: DateTime.parse(json['date_creation'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type_site': typeSite,
      'longitude': longitude,
      'latitude': latitude,
      'email': email,
      'telephone': telephone,
      'date_creation': dateCreation.toIso8601String(),
    };
  }
} 