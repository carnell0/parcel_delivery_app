class OTP {
  final int id;
  final int utilisateurId;
  final String code;
  final DateTime createdAt;
  final bool isUsed;
  final DateTime expiresAt;

  OTP({
    required this.id,
    required this.utilisateurId,
    required this.code,
    required this.createdAt,
    required this.isUsed,
    required this.expiresAt,
  });

  factory OTP.fromJson(Map<String, dynamic> json) {
    return OTP(
      id: json['id'] as int,
      utilisateurId: json['utilisateur_id'] as int,
      code: json['code'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      isUsed: json['is_used'] as bool,
      expiresAt: DateTime.parse(json['expires_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'utilisateur_id': utilisateurId,
      'code': code,
      'created_at': createdAt.toIso8601String(),
      'is_used': isUsed,
      'expires_at': expiresAt.toIso8601String(),
    };
  }
}

class OTPResponse {
  final bool success;
  final String message;
  final String? email;

  OTPResponse({
    required this.success,
    required this.message,
    this.email,
  });

  factory OTPResponse.fromJson(Map<String, dynamic> json) {
    return OTPResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? 'Une erreur est survenue',
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'email': email,
    };
  }
} 