class ApiConfig {
  // Base URL
  static const String baseUrl = 'https://delivery-app-api-srb5.onrender.com/api';
  
  // Auth endpoints
  static const String loginEndpoint = '/login/';
  /// Endpoint pour créer un utilisateur avec envoi d'OTP
  /// Méthode: POST
  /// Authentifié: Non
  /// Validation:
  /// {
  ///   "password": "motdepasse123",
  ///   "email": "redlekid@gmail.com",
  ///   "first_name": "Jean",
  ///   "last_name": "Dupont",
  ///   "telephone": "0159498601"
  /// }
  static const String registerEndpoint = '/utilisateurs/';
  static const String verifyOTPEndpoint = '/verify-otp/';
  static const String refreshOTPEndpoint = '/refresh-otp/';
  static const String logoutEndpoint = '/logout/';
  static const String refreshTokenEndpoint = '/refresh-token/';
  static const String currentUserEndpoint = '/me/'; // Endpoint pour récupérer l'utilisateur connecté
  
  // User endpoints
  static const String userProfileEndpoint = '/users/profile/';
  static const String updateProfileEndpoint = '/users/profile/update/';
  static const String changePasswordEndpoint = '/users/change-password/';
  
  // Delivery endpoints
  static const String deliveriesEndpoint = '/deliveries/';
  static const String createDeliveryEndpoint = '/deliveries/create/';
  static const String deliveryDetailsEndpoint = '/deliveries/{id}/';
  static const String updateDeliveryStatusEndpoint = '/deliveries/{id}/status/';
  static const String cancelDeliveryEndpoint = '/deliveries/{id}/cancel/';
  static const String clientDeliveriesEndpoint = '/deliveries/client/';
  
  // Driver endpoints
  static const String driverProfileEndpoint = '/drivers/profile/';
  static const String updateDriverProfileEndpoint = '/drivers/profile/update/';
  static const String driverDeliveriesEndpoint = '/drivers/deliveries/';
  static const String acceptDeliveryEndpoint = '/drivers/deliveries/{id}/accept/';
  static const String rejectDeliveryEndpoint = '/drivers/deliveries/{id}/reject/';
  static const String completeDeliveryEndpoint = '/drivers/deliveries/{id}/complete/';
  
  // Notification endpoints
  static const String notificationsEndpoint = '/notifications/';
  static const String markNotificationReadEndpoint = '/notifications/{id}/read/';
  static const String deleteNotificationEndpoint = '/notifications/{id}/delete/';
  
  // Rating endpoints
  static const String rateDeliveryEndpoint = '/ratings/delivery/{id}/';
  static const String rateDriverEndpoint = '/ratings/driver/{id}/';
  
  // Payment endpoints
  static const String paymentMethodsEndpoint = '/payments/methods/';
  static const String addPaymentMethodEndpoint = '/payments/methods/add/';
  static const String processPaymentEndpoint = '/payments/process/';
  static const String paymentHistoryEndpoint = '/payments/history/';
  
  // Helper methods for endpoints with parameters
  static String getDeliveryDetailsEndpoint(String id) => deliveryDetailsEndpoint.replaceAll('{id}', id);
  static String getUpdateDeliveryStatusEndpoint(String id) => updateDeliveryStatusEndpoint.replaceAll('{id}', id);
  static String getCancelDeliveryEndpoint(String id) => cancelDeliveryEndpoint.replaceAll('{id}', id);
  static String getAcceptDeliveryEndpoint(String id) => acceptDeliveryEndpoint.replaceAll('{id}', id);
  static String getRejectDeliveryEndpoint(String id) => rejectDeliveryEndpoint.replaceAll('{id}', id);
  static String getCompleteDeliveryEndpoint(String id) => completeDeliveryEndpoint.replaceAll('{id}', id);
  static String getMarkNotificationReadEndpoint(String id) => markNotificationReadEndpoint.replaceAll('{id}', id);
  static String getDeleteNotificationEndpoint(String id) => deleteNotificationEndpoint.replaceAll('{id}', id);
  static String getRateDeliveryEndpoint(String id) => rateDeliveryEndpoint.replaceAll('{id}', id);
  static String getRateDriverEndpoint(String id) => rateDriverEndpoint.replaceAll('{id}', id);
}