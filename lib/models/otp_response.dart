class OTPResponse {
  final bool success;
  final String? message;
  final String? email;

  OTPResponse({
    required this.success,
    this.message,
    this.email,
  });

  factory OTPResponse.fromJson(Map<String, dynamic> json) {
    return OTPResponse(
      success: json['success'] as bool,
      message: json['message'] as String?,
      email: json['email'] as String?,
    );
  }
} 