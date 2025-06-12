class Reclamation {
  final int id;
  final int demandeId;
  final String description;
  final String statut;
  final DateTime dateReclamation;

  Reclamation({
    required this.id,
    required this.demandeId,
    required this.description,
    required this.statut,
    required this.dateReclamation,
  });

  factory Reclamation.fromJson(Map<String, dynamic> json) {
    return Reclamation(
      id: json['id'] as int,
      demandeId: json['demande_id'] as int,
      description: json['description'] as String,
      statut: json['statut'] as String,
      dateReclamation: DateTime.parse(json['date_reclamation'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'demande_id': demandeId,
      'description': description,
      'statut': statut,
      'date_reclamation': dateReclamation.toIso8601String(),
    };
  }
} 