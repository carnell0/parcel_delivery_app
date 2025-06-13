class ApiConfig {
  static const String baseUrl = 'http://10.0.2.2:8000/api';
  
  // Auth endpoints
  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';
  static const String verifyOtpEndpoint = '/auth/verify-otp';
  static const String resendOtpEndpoint = '/auth/resend-otp';
  static const String refreshTokenEndpoint = '/auth/refresh-token';
  static const String logoutEndpoint = '/auth/logout';
  
  // User endpoints
  static const String userProfileEndpoint = '/user/profile';
  static const String updateProfileEndpoint = '/user/update-profile';
  static const String updateProfilePictureEndpoint = '/user/update-profile-picture';
  static const String currentUtilisateurEndpoint = '/user/current';
  static const String utilisateurProfileEndpoint = '/user/profile';
  static const String changePasswordEndpoint = '/user/change-password';
  
  // Delivery endpoints
  static const String createDeliveryEndpoint = '/deliveries/create';
  static const String userDeliveriesEndpoint = '/deliveries/user';
  static const String deliveryDetailsEndpoint = '/deliveries';
  static const String deliveryRouteEndpoint = '/deliveries/route';
  static const String clientDeliveriesEndpoint = '/deliveries/client';
  static const String driverDeliveriesEndpoint = '/deliveries/driver';
  static const String activeDeliveriesEndpoint = '/deliveries/active';
  
  // Driver endpoints
  static const String driverPendingDeliveriesEndpoint = '/driver/pending-deliveries';
  static const String acceptDeliveryEndpoint = '/driver/accept-delivery';
  static const String updateDriverLocationEndpoint = '/driver/update-location';
  
  // Notification endpoints
  static const String notificationsEndpoint = '/notifications';
  
  // Endpoints OTP
  static const String verifyOTPEndpoint = '/api/verify-otp';
  static const String refreshOTPEndpoint = '/api/resend-otp';
  
  // Helper methods for dynamic endpoints
  static String getAcceptDeliveryEndpoint(int deliveryId) => '/driver/accept-delivery/$deliveryId';
  static String getRejectDeliveryEndpoint(int deliveryId) => '/driver/reject-delivery/$deliveryId';
  static String getCompleteDeliveryEndpoint(int deliveryId) => '/driver/complete-delivery/$deliveryId';
  static String getMarkNotificationReadEndpoint(int notificationId) => '/notifications/$notificationId/read';
  static String getDeleteNotificationEndpoint(int notificationId) => '/notifications/$notificationId';
} 