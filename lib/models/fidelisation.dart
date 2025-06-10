class Fidelisation {
  final int id;
  final int utilisateurId;
  final int points;

  Fidelisation({
    required this.id,
    required this.utilisateurId,
    required this.points,
  });

  factory Fidelisation.fromJson(Map<String, dynamic> json) {
    return Fidelisation(
      id: json['id'] as int,
      utilisateurId: json['utilisateur_id'] as int,
      points: json['points'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'utilisateur_id': utilisateurId,
      'points': points,
    };
  }
}