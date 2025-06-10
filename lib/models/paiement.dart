class Paiement {
  final int id;
  final int utilisateurId;
  final int livraisonId;
  final double montant;
  final String modePaiement;
  final String statut;
  final DateTime datePaiement;

  Paiement({
    required this.id,
    required this.utilisateurId,
    required this.livraisonId,
    required this.montant,
    required this.modePaiement,
    required this.statut,
    required this.datePaiement,
  });

  factory Paiement.fromJson(Map<String, dynamic> json) {
    return Paiement(
      id: json['id'] as int,
      utilisateurId: json['utilisateur_id'] as int,
      livraisonId: json['livraison_id'] as int,
      montant: (json['montant'] as num).toDouble(),
      modePaiement: json['mode_paiement'] as String,
      statut: json['statut'] as String,
      datePaiement: DateTime.parse(json['date_paiement'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'utilisateur_id': utilisateurId,
      'livraison_id': livraisonId,
      'montant': montant,
      'mode_paiement': modePaiement,
      'statut': statut,
      'date_paiement': datePaiement.toIso8601String(),
    };
  }
}