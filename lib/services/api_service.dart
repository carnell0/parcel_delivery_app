import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/utilisateur.dart';
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
  Utilisateur? _utilisateur;
  bool get isAuthenticated => _accessToken != null && _utilisateur != null;
  String? _accessToken;
  String? _refreshToken;
  late Dio _dio;
  bool _isConnected = true;

  // Clés pour le stockage local
  static const String _tokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';

  Utilisateur? get utilisateur => _utilisateur;
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
      if (_accessToken != null) {
        final response = await _dio.get(
          ApiConfig.utilisateurProfileEndpoint,
          options: Options(headers: {'Authorization': 'Bearer $_accessToken'}),
        );
        if (response.statusCode == 200) {
          _utilisateur = Utilisateur.fromJson(response.data);
          notifyListeners();
        } else if (response.statusCode == 401) {
          await _clearTokens();
        }
      }
    } catch (e) {
      print('Error initializing utilisateur session: $e');
      await _clearTokens();
    }
  }
  Future<void> initialize() async {
    await _init();
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
      await _checkConnectivity();
      if (!_isConnected) {
        return {
          'success': false,
          'message': 'Pas de connexion Internet. Veuillez vérifier votre connexion et réessayer.',
          'error': 'no_internet',
        };
      }
  
      final response = await _dio.post(
        ApiConfig.loginEndpoint,
        data: {
          'email': email.trim(),
          'password': password,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          sendTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
          validateStatus: (status) => status != null && status < 500, // Gère 400/401 sans exception
        ),
      );
  
      if (response.statusCode == 200) {
        _accessToken = response.data['access'] as String;
        _refreshToken = response.data['refresh'] as String;
  
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', _accessToken!);
        await prefs.setString('refresh_token', _refreshToken!);
  
        if (response.data['user'] != null) {
          _utilisateur = Utilisateur.fromJson(response.data['user']);
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
          errorMessage = errorData['detail']?.toString() ??
              errorData['message']?.toString() ??
              errorData['error']?.toString() ??
              errorMessage;
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
    } on DioException catch (e) {
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
      }
      return {
        'success': false,
        'message': 'Une erreur est survenue lors de la connexion. Veuillez réessayer.',
        'error': 'dio_error',
      };
    } catch (e) {
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
  required String natureColis,
  required String dimensions,
  required double poids,
  String? photoColis,
  required String modeLivraison,
  required double latitudeDepart,
  required double longitudeDepart,
  required double latitudeArrivee,
  required double longitudeArrivee,
  int? numeroDepart,
  int? numeroArrivee,
  }) async {
    try {
      final response = await _dio.post(
        ApiConfig.createDeliveryEndpoint,
        options: Options(headers: {'Authorization': 'Bearer $_accessToken'}),
        data: {
          // Partie Demande (infos colis)
          'utilisateur_id': utilisateurId,
          'nature_colis': natureColis,
          'dimensions': dimensions,
          'poids': poids,
          'photo_colis': photoColis,
          'mode_livraison': modeLivraison,
          // Partie Livraison (localisation)
          'latitude_depart': latitudeDepart,
          'longitude_depart': longitudeDepart,
          'latitude_arrivee': latitudeArrivee,
          'longitude_arrivee': longitudeArrivee,
          if (numeroDepart != null) 'numero_depart': numeroDepart,
          if (numeroArrivee != null) 'numero_arrivee': numeroArrivee,
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
        _utilisateur = Utilisateur.fromJson(responseData);
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
      _utilisateur = null;
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

  Future<Utilisateur?> getUtilisateurProfile() async {
    try {
      final response = await _dio.get(
        '${_baseUrl}${ApiConfig.utilisateurProfileEndpoint}',
        options: Options(
          headers: {
            'Authorization': 'Bearer $_accessToken',
          },
        ),
      );
      final data = response.data;
      _utilisateur = Utilisateur.fromJson(data);
      return _utilisateur;
    } catch (e) {
      print('Error getting utilisateur profile: $e');
      return null;
    }
  }

  Future<Livraison> getDeliveryDetails(int deliveryId) async {
    try {
      final response = await _dio.get(
        '${_baseUrl}${ApiConfig.deliveryDetailsEndpoint}/$deliveryId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $_accessToken',
          },
        ),
      );
      return Livraison.fromJson(response.data);
    } catch (e) {
      print('Get delivery details error: ${e.toString()}');
      rethrow;
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

  Stream<Livraison> trackDelivery(int deliveryId) async* {
    try {
      while (true) {
        final livraison = await getDeliveryDetails(deliveryId);
        yield livraison;
        await Future.delayed(const Duration(seconds: 5));
      }
    } catch (e) {
      print('Track delivery error: ${e.toString()}');
      rethrow;
    }
  }

  Future<List<Livraison>> getActiveDeliveries() async {
    try {
      final response = await _dio.get(
        '${_baseUrl}${ApiConfig.activeDeliveriesEndpoint}',
        options: Options(
          headers: {
            'Authorization': 'Bearer $_accessToken',
          },
        ),
      );
      final List<dynamic> data = response.data;
      return data.map((json) => Livraison.fromJson(json)).toList();
    } catch (e) {
      print('Get active deliveries error: ${e.toString()}');
      rethrow;
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

  Future<Map<String, dynamic>> getCurrentUtilisateur() async {
    try {
      print('Access Token: $_accessToken'); // Debug log
      print('Request URL: ${_baseUrl}${ApiConfig.currentUtilisateurEndpoint}'); // Debug log
      final response = await _dio.get(
        '${_baseUrl}${ApiConfig.currentUtilisateurEndpoint}',
        options: Options(
          headers: {
            'Authorization': 'Bearer $_accessToken',
          },
        ),
      );
      print('API Response: ${response.data}'); // Debug log
      return response.data;
    } catch (e) {
      print('Get current utilisateur error: ${e.toString()}');
      rethrow;
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
    _utilisateur = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
    notifyListeners();
  }
  Future<List<Livraison>> getDriverPendingDeliveries() async {
    // TODO: Replace with actual API call logic
    // Example implementation:
    // final response = await http.get(Uri.parse('YOUR_API_ENDPOINT'));
    // if (response.statusCode == 200) {
    //   // Parse response and return list of Livraison
    // }
    // throw Exception('Failed to load pending deliveries');
    return []; // Temporary placeholder
  }
}