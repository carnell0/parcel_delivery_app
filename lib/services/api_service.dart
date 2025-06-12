import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/user.dart';
import '../models/demande.dart';
import '../models/livraison.dart';
import '../models/otp.dart';
import '../models/reclamation.dart';
import '../models/retour.dart';
import '../models/notification.dart' as app_notification;
import '../models/delivery.dart';
import 'api_config.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;

class ApiService with ChangeNotifier {
  final String _baseUrl = ApiConfig.baseUrl;
  User? _user;
  String? _accessToken;
  String? _refreshToken;
  late Dio _dio;
  bool _isConnected = true;

  // Clés pour le stockage local
  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';

  User? get user => _user;
  bool get isConnected => _isConnected;

  ApiService() {
    _init();
    _checkConnectivity();
  }

  Future<void> _init() async {
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
    ));

    // Charger le token au démarrage
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString('access_token');
    _refreshToken = prefs.getString('refresh_token');

    if (_accessToken != null) {
      _dio.options.headers['Authorization'] = 'Bearer $_accessToken';
    }

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        if (_accessToken != null) {
          options.headers['Authorization'] = 'Bearer $_accessToken';
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) async {
        if (e.response?.statusCode == 401) {
          // Token expiré, essayer de le rafraîchir
          if (await _refreshAccessToken()) {
            // Réessayer la requête avec le nouveau token
            e.requestOptions.headers['Authorization'] = 'Bearer $_accessToken';
            return handler.resolve(await _dio.fetch(e.requestOptions));
          }
        }
        return handler.next(e);
      },
    ));

    try {
      final response = await http.get(
        Uri.parse('${_baseUrl}${ApiConfig.loginEndpoint}'),
        headers: {
          'Content-Type': 'application/json',
          if (_accessToken != null) 'Authorization': 'Bearer $_accessToken',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['user'] != null) {
          _user = User.fromJson(data['user']);
          notifyListeners();
        }
      } else if (response.statusCode == 401) {
        await _clearTokens();
      }
    } catch (e) {
      print('Error initializing user session: $e');
      await _clearTokens();
    }
  }

  Future<void> _checkConnectivity() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      _isConnected = connectivityResult != ConnectivityResult.none;
      notifyListeners();
    } catch (e) {
      _isConnected = false;
      notifyListeners();
    }
  }

  Future<bool> _isServerReachable() async {
    try {
      final result = await InternetAddress.lookup('delivery-app-api-srb5.onrender.com');
      if (result.isEmpty || result[0].rawAddress.isEmpty) {
        print('Server lookup failed: No IP address found');
        return false;
      }
      print('Server IP: ${result[0].address}');
      return true;
    } on SocketException catch (e) {
      print('Server lookup failed: ${e.message}');
      return false;
    } catch (e) {
      print('Server lookup failed: $e');
      return false;
    }
  }

  Future<bool> _refreshAccessToken() async {
    if (_refreshToken == null) return false;

    try {
      final response = await _dio.post(
        ApiConfig.refreshTokenEndpoint,
        data: {'refresh': _refreshToken},
      );

      if (response.statusCode == 200) {
        _accessToken = response.data['access'] as String;
        _refreshToken = response.data['refresh'] as String;

        // Sauvegarder les nouveaux tokens
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', _accessToken!);
        await prefs.setString('refresh_token', _refreshToken!);

        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      // Vérifier la connectivité
      await _checkConnectivity();
      if (!_isConnected) {
        return {
          'success': false,
          'message': 'Pas de connexion Internet. Veuillez vérifier votre connexion et réessayer.',
          'error': 'no_internet',
        };
      }

      // Vérifier si le serveur est accessible
      final isServerReachable = await _isServerReachable();
      if (!isServerReachable) {
        return {
          'success': false,
          'message': 'Le serveur n\'est pas accessible. Veuillez réessayer dans quelques minutes.',
          'error': 'server_unreachable',
        };
      }

      print('Tentative de connexion à: ${_baseUrl}${ApiConfig.loginEndpoint}');
      
      final response = await _dio.post(
        ApiConfig.loginEndpoint,
        data: {
          'email': email.trim(),
          'password': password,
        },
        options: Options(
          validateStatus: (status) => status! < 500,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException('La connexion au serveur a pris trop de temps');
        },
      );

      print('Réponse de connexion - Status: ${response.statusCode}');
      print('Réponse de connexion - Body: ${response.data}');

      if (response.statusCode == 200) {
        _accessToken = response.data['access'] as String;
        _refreshToken = response.data['refresh'] as String;

        // Sauvegarder les tokens
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', _accessToken!);
        await prefs.setString('refresh_token', _refreshToken!);

        if (response.data['user'] != null) {
          _user = User.fromJson(response.data['user']);
          notifyListeners();
        }

        return {
          'success': true,
          'message': 'Connexion réussie',
        };
      } else if (response.statusCode == 401) {
        return {
          'success': false,
          'message': 'Email ou mot de passe incorrect',
          'error': 'invalid_credentials',
        };
      } else if (response.statusCode == 400) {
        final errorData = response.data;
        String errorMessage = 'Veuillez remplir tous les champs correctement';
        
        if (errorData is Map<String, dynamic>) {
          if (errorData['detail'] != null) {
            errorMessage = errorData['detail'].toString();
          } else if (errorData['message'] != null) {
            errorMessage = errorData['message'].toString();
          } else if (errorData['error'] != null) {
            errorMessage = errorData['error'].toString();
          }
        }
        
        return {
          'success': false,
          'message': errorMessage,
          'error': 'invalid_input',
        };
      }
      
      return {
        'success': false,
        'message': 'Une erreur est survenue lors de la connexion',
        'error': 'unknown',
      };
    } on TimeoutException {
      return {
        'success': false,
        'message': 'Le serveur met trop de temps à répondre. Veuillez réessayer plus tard.',
        'error': 'timeout',
      };
    } on DioException catch (e) {
      print('Erreur de connexion Dio: ${e.message}');
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        return {
          'success': false,
          'message': 'Le serveur met trop de temps à répondre. Veuillez réessayer plus tard.',
          'error': 'timeout',
        };
      } else if (e.type == DioExceptionType.connectionError) {
        return {
          'success': false,
          'message': 'Impossible de se connecter au serveur. Veuillez vérifier votre connexion Internet.',
          'error': 'connection_error',
        };
      } else if (e.response?.statusCode == 400) {
        final errorData = e.response?.data;
        String errorMessage = 'Veuillez remplir tous les champs correctement';
        
        if (errorData is Map<String, dynamic>) {
          if (errorData['detail'] != null) {
            errorMessage = errorData['detail'].toString();
          } else if (errorData['message'] != null) {
            errorMessage = errorData['message'].toString();
          } else if (errorData['error'] != null) {
            errorMessage = errorData['error'].toString();
          }
        }
        
        return {
          'success': false,
          'message': errorMessage,
          'error': 'invalid_input',
        };
      }
      return {
        'success': false,
        'message': 'Une erreur est survenue lors de la connexion. Veuillez réessayer.',
        'error': 'dio_error',
      };
    } catch (e) {
      print('Erreur de connexion inattendue: $e');
      return {
        'success': false,
        'message': 'Une erreur inattendue est survenue. Veuillez réessayer.',
        'error': 'unknown',
      };
    }
  }

  Future<OTPResponse> register({
    required String nom,
    required String prenom,
    required String email,
    required String telephone,
    required String motDePasse,
    required String role,
    String? typeVehicule,
    String? numeroImmatriculation,
    String? photoLivreur,
  }) async {
    try {
      final Map<String, dynamic> data = {
        'first_name': prenom,
        'last_name': nom,
        'email': email,
        'telephone': telephone,
        'password': motDePasse,
      };

      if (role == 'livreur') {
        data.addAll({
          'typeVehicule': typeVehicule,
          'numeroImmatriculation': numeroImmatriculation,
          'photoLivreur': photoLivreur,
        });
      }

      print('Sending registration request to: ${_baseUrl}${ApiConfig.registerEndpoint}');
      print('Request data: $data');

      final response = await http.post(
        Uri.parse('${_baseUrl}${ApiConfig.registerEndpoint}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final responseData = jsonDecode(response.body);
        return OTPResponse(
          success: true,
          message: responseData['message'] ?? 'Compte créé avec succès',
          email: email,
        );
      } else {
        final errorData = jsonDecode(response.body);
        return OTPResponse(
          success: false,
          message: errorData['message'] ?? 'Erreur lors de l\'inscription',
        );
      }
    } catch (e) {
      print('Registration error: $e');
      return OTPResponse(
        success: false,
        message: 'Erreur de connexion au serveur: ${e.toString()}',
      );
    }
  }

  Future<OTPResponse> verifyOTP({
    required String email,
    required String otp,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${_baseUrl}${ApiConfig.verifyOTPEndpoint}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'otp': otp,
        }),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return OTPResponse(
          success: true,
          message: 'Compte activé avec succès. Veuillez vous connecter.',
          email: email,
        );
      } else {
        return OTPResponse(
          success: false,
          message: data['message'] ?? 'Erreur lors de la vérification',
        );
      }
    } catch (e) {
      return OTPResponse(
        success: false,
        message: 'Erreur de connexion au serveur',
      );
    }
  }

  Future<OTPResponse> resendOTP({required String email}) async {
    try {
      final response = await http.post(
        Uri.parse('${_baseUrl}${ApiConfig.refreshOTPEndpoint}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      final data = jsonDecode(response.body);
      return OTPResponse.fromJson(data);
    } catch (e) {
      return OTPResponse(
        success: false,
        message: 'Erreur de connexion au serveur',
      );
    }
  }

  Future<bool> createDelivery({
    required int utilisateurId,
    String? natureColis,
    String? dimensions,
    double? poids,
    String? photoColis,
    required String adresseDepart,
    required String adresseDestination,
    required String modeLivraison,
  }) async {
    try {
      final response = await _dio.post(
        ApiConfig.createDeliveryEndpoint,
        options: Options(headers: {'Authorization': 'Bearer $_accessToken'}),
        data: {
          'utilisateur_id': utilisateurId,
          'nature_colis': natureColis,
          'dimensions': dimensions,
          'poids': poids,
          'photo_colis': photoColis,
          'adresse_depart': adresseDepart,
          'adresse_destination': adresseDestination,
          'mode_livraison': modeLivraison,
        },
      );

      if (response.statusCode == 201) {
        return true;
      }
      print('Create delivery failed: ${response.data}');
      return false;
    } on DioException catch (e) {
      print('Create delivery error: ${e.message}');
      return false;
    }
  }

  Future<List<Demande>> getClientDemandes() async {
    try {
      final response = await _dio.get(
        ApiConfig.clientDeliveriesEndpoint,
        options: Options(
          headers: {'Authorization': 'Bearer $_accessToken'},
          validateStatus: (status) => status! < 500,
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Demande.fromJson(json)).toList();
      } else if (response.statusCode == 404) {
        print('Endpoint non trouvé: ${ApiConfig.clientDeliveriesEndpoint}');
        return [];
      }
      print('Get client deliveries failed: ${response.data}');
      return [];
    } on DioException catch (e) {
      print('Get client deliveries error: ${e.message}');
      if (e.response?.statusCode == 404) {
        print('Endpoint non trouvé: ${ApiConfig.clientDeliveriesEndpoint}');
        return [];
      }
      return [];
    } catch (e) {
      print('Unexpected error in getClientDemandes: $e');
      return [];
    }
  }

  Future<List<Livraison>> getDriverDeliveries() async {
    try {
      final response = await _dio.get(
        ApiConfig.driverDeliveriesEndpoint,
        options: Options(
          headers: {'Authorization': 'Bearer $_accessToken'},
          validateStatus: (status) => status! < 500,
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Livraison.fromJson(json)).toList();
      } else if (response.statusCode == 404) {
        print('Endpoint non trouvé: ${ApiConfig.driverDeliveriesEndpoint}');
        return [];
      }
      print('Get driver deliveries failed: ${response.data}');
      return [];
    } on DioException catch (e) {
      print('Get driver deliveries error: ${e.message}');
      if (e.response?.statusCode == 404) {
        print('Endpoint non trouvé: ${ApiConfig.driverDeliveriesEndpoint}');
        return [];
      }
      return [];
    } catch (e) {
      print('Unexpected error in getDriverDeliveries: $e');
      return [];
    }
  }

  Future<bool> acceptDelivery(String deliveryId) async {
    try {
      final response = await _dio.post(
        ApiConfig.getAcceptDeliveryEndpoint(deliveryId),
        options: Options(headers: {'Authorization': 'Bearer $_accessToken'}),
      );

      if (response.statusCode == 200) {
        return true;
      }
      print('Accept delivery failed: ${response.data}');
      return false;
    } on DioException catch (e) {
      print('Accept delivery error: ${e.message}');
      return false;
    }
  }

  Future<bool> rejectDelivery(String deliveryId) async {
    try {
      final response = await _dio.post(
        ApiConfig.getRejectDeliveryEndpoint(deliveryId),
        options: Options(headers: {'Authorization': 'Bearer $_accessToken'}),
      );

      if (response.statusCode == 200) {
        return true;
      }
      print('Reject delivery failed: ${response.data}');
      return false;
    } on DioException catch (e) {
      print('Reject delivery error: ${e.message}');
      return false;
    }
  }

  Future<bool> completeDelivery(String deliveryId) async {
    try {
      final response = await _dio.post(
        ApiConfig.getCompleteDeliveryEndpoint(deliveryId),
        options: Options(headers: {'Authorization': 'Bearer $_accessToken'}),
      );

      if (response.statusCode == 200) {
        return true;
      }
      print('Complete delivery failed: ${response.data}');
      return false;
    } on DioException catch (e) {
      print('Complete delivery error: ${e.message}');
      return false;
    }
  }

  Future<List<app_notification.Notification>> getNotifications() async {
    try {
      final response = await _dio.get(
        ApiConfig.notificationsEndpoint,
        options: Options(headers: {'Authorization': 'Bearer $_accessToken'}),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => app_notification.Notification.fromJson(json)).toList();
      }
      print('Get notifications failed: ${response.data}');
    } on DioException catch (e) {
      print('Get notifications error: ${e.message}');
    }

    return [];
  }

  Future<bool> markNotificationAsRead(String notificationId) async {
    try {
      final response = await _dio.post(
        ApiConfig.getMarkNotificationReadEndpoint(notificationId),
        options: Options(headers: {'Authorization': 'Bearer $_accessToken'}),
      );

      if (response.statusCode == 200) {
        return true;
      }
      print('Mark notification as read failed: ${response.data}');
      return false;
    } on DioException catch (e) {
      print('Mark notification as read error: ${e.message}');
      return false;
    }
  }

  Future<bool> deleteNotification(String notificationId) async {
    try {
      final response = await _dio.delete(
        ApiConfig.getDeleteNotificationEndpoint(notificationId),
        options: Options(headers: {'Authorization': 'Bearer $_accessToken'}),
      );

      if (response.statusCode == 200) {
        return true;
      }
      print('Delete notification failed: ${response.data}');
      return false;
    } on DioException catch (e) {
      print('Delete notification error: ${e.message}');
      return false;
    }
  }

  Future<bool> updateProfile({
    required String nom,
    required String prenom,
    required String email,
    required String telephone,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('${_baseUrl}${ApiConfig.updateProfileEndpoint}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_accessToken',
        },
        body: jsonEncode({
          'first_name': prenom,
          'last_name': nom,
          'email': email,
          'telephone': telephone,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        _user = User.fromJson(responseData);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${_baseUrl}${ApiConfig.changePasswordEndpoint}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_accessToken',
        },
        body: jsonEncode({
          'old_password': oldPassword,
          'new_password': newPassword,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> logout() async {
    try {
      if (_accessToken != null) {
        await _dio.post(ApiConfig.logoutEndpoint);
      }

      // Supprimer les tokens
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('access_token');
      await prefs.remove('refresh_token');

      _accessToken = null;
      _refreshToken = null;
      _user = null;
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<Livraison>> getLivreurLivraisons() async {
    try {
      final response = await _dio.get(
        ApiConfig.driverDeliveriesEndpoint,
        options: Options(headers: {'Authorization': 'Bearer $_accessToken'}),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Livraison.fromJson(json)).toList();
      }
      print('Get driver deliveries failed: ${response.data}');
      return [];
    } on DioException catch (e) {
      print('Get driver deliveries error: ${e.message}');
      return [];
    }
  }

  Future<bool> createOrder({
    required int utilisateurId,
    String? natureColis,
    String? dimensions,
    double? poids,
    String? photoColis,
    required String adresseDepart,
    required String adresseDestination,
    required String modeLivraison,
  }) async {
    try {
      final response = await _dio.post(
        ApiConfig.createDeliveryEndpoint,
        options: Options(headers: {'Authorization': 'Bearer $_accessToken'}),
        data: {
          'utilisateur_id': utilisateurId,
          'nature_colis': natureColis,
          'dimensions': dimensions,
          'poids': poids,
          'photo_colis': photoColis,
          'adresse_depart': adresseDepart,
          'adresse_destination': adresseDestination,
          'mode_livraison': modeLivraison,
        },
      );

      if (response.statusCode == 201) {
        return true;
      }
      print('Create order failed: ${response.data}');
      return false;
    } on DioException catch (e) {
      print('Create order error: ${e.message}');
      return false;
    }
  }

  Future<User?> getUserProfile() async {
    try {
      final response = await http.get(
        Uri.parse('${_baseUrl}${ApiConfig.userProfileEndpoint}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_accessToken',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _user = User.fromJson(data);
        notifyListeners();
        return _user;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<Delivery> getDeliveryDetails(int deliveryId) async {
    try {
      final response = await _dio.get(
        '${_baseUrl}/deliveries/$deliveryId/',
        options: Options(
          headers: {'Authorization': 'Bearer $_accessToken'},
        ),
      );

      if (response.statusCode == 200) {
        return Delivery.fromJson(response.data);
      } else {
        throw Exception('Failed to load delivery details');
      }
    } catch (e) {
      print('Error getting delivery details: $e');
      throw Exception('Failed to load delivery details: $e');
    }
  }

  Future<void> updateDeliveryLocation(int deliveryId, double latitude, double longitude) async {
    try {
      final response = await _dio.patch(
        '${_baseUrl}/deliveries/$deliveryId/update-location/',
        data: {
          'latitude': latitude,
          'longitude': longitude,
        },
        options: Options(
          headers: {'Authorization': 'Bearer $_accessToken'},
        ),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update delivery location');
      }
    } catch (e) {
      print('Error updating delivery location: $e');
      throw Exception('Failed to update delivery location: $e');
    }
  }

  Stream<Delivery> trackDelivery(int deliveryId) async* {
    while (true) {
      try {
        final delivery = await getDeliveryDetails(deliveryId);
        yield delivery;
        await Future.delayed(const Duration(seconds: 30)); // Update every 30 seconds
      } catch (e) {
        print('Error tracking delivery: $e');
        await Future.delayed(const Duration(seconds: 5)); // Wait 5 seconds before retrying
      }
    }
  }

  Future<List<Delivery>> getActiveDeliveries() async {
    try {
      final response = await _dio.get(
        '${_baseUrl}/driver/active-deliveries/',
        options: Options(
          headers: {'Authorization': 'Bearer $_accessToken'},
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Delivery.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load active deliveries');
      }
    } catch (e) {
      print('Error getting active deliveries: $e');
      throw Exception('Failed to load active deliveries: $e');
    }
  }

  Future<void> updateDeliveryStatus(int deliveryId, String status) async {
    try {
      final response = await _dio.patch(
        '${_baseUrl}/deliveries/$deliveryId/update-status/',
        data: {'status': status},
        options: Options(
          headers: {'Authorization': 'Bearer $_accessToken'},
        ),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update delivery status');
      }
    } catch (e) {
      print('Error updating delivery status: $e');
      throw Exception('Failed to update delivery status: $e');
    }
  }

  Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      final response = await _dio.get(
        ApiConfig.currentUserEndpoint,
        options: Options(headers: {'Authorization': 'Bearer $_accessToken'}),
      );

      if (response.statusCode == 200) {
        return response.data;
      }
      throw Exception('Failed to load user data');
    } on DioException catch (e) {
      print('Get current user error: ${e.message}');
      throw Exception('Failed to load user data');
    }
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString(_tokenKey);
    _refreshToken = prefs.getString(_refreshTokenKey);
    notifyListeners();
  }

  Future<void> _saveToken(String token, String refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_refreshTokenKey, refreshToken);
    _accessToken = token;
    _refreshToken = refreshToken;
    notifyListeners();
  }

  Future<void> _clearTokens() async {
    _accessToken = null;
    _refreshToken = null;
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
    notifyListeners();
  }
}