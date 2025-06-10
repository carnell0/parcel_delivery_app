class Retour {
  final int id;
  final int demandeId;
  final String motif;
  final String statut;
  final DateTime dateRetour;

  Retour({
    required this.id,
    required this.demandeId,
    required this.motif,
    required this.statut,
    required this.dateRetour,
  });

  factory Retour.fromJson(Map<String, dynamic> json) {
    return Retour(
      id: json['id'] as int,
      demandeId: json['demande_id'] as int,
      motif: json['motif'] as String,
      statut: json['statut'] as String,
      dateRetour: DateTime.parse(json['date_retour'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'demande_id': demandeId,
      'motif': motif,
      'statut': statut,
      'date_retour': dateRetour.toIso8601String(),
    };
  }
} 