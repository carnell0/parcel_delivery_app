class Notification {
  final int id;
  final String titre;
  final String message;
  final String? type;
  final DateTime dateCreation;
  final bool estLu;

  Notification({
    required this.id,
    required this.titre,
    required this.message,
    this.type,
    required this.dateCreation,
    required this.estLu,
  });

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['id'] as int,
      titre: json['titre'] as String,
      message: json['message'] as String,
      type: json['type'] as String?,
      dateCreation: DateTime.parse(json['date_creation'] as String),
      estLu: json['est_lu'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titre': titre,
      'message': message,
      'type': type,
      'date_creation': dateCreation.toIso8601String(),
      'est_lu': estLu,
    };
  }
}

class NotificationUser {
  final int id;
  final int notificationId;
  final int utilisateurId;
  final bool estLu;

  NotificationUser({
    required this.id,
    required this.notificationId,
    required this.utilisateurId,
    required this.estLu,
  });

  factory NotificationUser.fromJson(Map<String, dynamic> json) {
    return NotificationUser(
      id: json['id'] as int,
      notificationId: json['notification_id'] as int,
      utilisateurId: json['utilisateur_id'] as int,
      estLu: json['est_lu'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'notification_id': notificationId,
      'utilisateur_id': utilisateurId,
      'est_lu': estLu,
    };
  }
}