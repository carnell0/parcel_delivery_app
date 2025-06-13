class Delivery {
  final int id;
  final String status;
  final String? currentLocation;
  final double? latitude;
  final double? longitude;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int utilisateurId;
  final int? livreurId;

  Delivery({
    required this.id,
    required this.status,
    this.currentLocation,
    this.latitude,
    this.longitude,
    required this.createdAt,
    this.updatedAt,
    required this.utilisateurId,
    this.livreurId,
  });

  factory Delivery.fromJson(Map<String, dynamic> json) {
    return Delivery(
      id: json['id'] as int,
      status: json['status'] as String,
      currentLocation: json['current_location'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      utilisateurId: json['utilisateur_id'] as int,
      livreurId: json['livreur_id'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status,
      'current_location': currentLocation,
      'latitude': latitude,
      'longitude': longitude,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'utilisateur_id': utilisateurId,
      'livreur_id': livreurId,
    };
  }
} 