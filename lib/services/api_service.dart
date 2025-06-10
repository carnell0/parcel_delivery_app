import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../models/demande.dart';
import '../models/livraison.dart';
import '../models/otp.dart';
import '../models/reclamation.dart';
import '../models/retour.dart';
import '../models/notification.dart' as app_notification;
import 'api_config.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;

class ApiService with ChangeNotifier {
  User? _user;
  String? _accessToken;
  String? _refreshToken;
  late Dio _dio;

  User? get user => _user;

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ));
    _setupInterceptors();
    _init();
  }

  void _setupInterceptors() {
    _dio.interceptors.add(InterceptorsWrapper(
      onError: (DioException error, ErrorInterceptorHandler handler) async {
        if (error.response?.statusCode == 401 && _refreshToken != null) {
          try {
            final response = await _dio.post(
              ApiConfig.refreshTokenEndpoint,
              data: {'refresh': _refreshToken},
            );
            if (response.statusCode == 200) {
              _accessToken = response.data['access'] as String;
              _refreshToken = response.data['refresh'] as String;
              
              // Retry the original request
              final retryResponse = await _dio.request(
                error.requestOptions.path,
                data: error.requestOptions.data,
                queryParameters: error.requestOptions.queryParameters,
                options: Options(
                  method: error.requestOptions.method,
                  headers: {
                    ...error.requestOptions.headers,
                    'Authorization': 'Bearer $_accessToken',
                  },
                ),
              );
              return handler.resolve(retryResponse);
            }
          } catch (e) {
            print('Token refresh failed: $e');
            await logout();
          }
        }
        return handler.next(error);
      },
    ));
  }

  Future<void> _init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _accessToken = prefs.getString('access_token');
      _refreshToken = prefs.getString('refresh_token');
      
      if (_accessToken != null) {
        try {
          final userResponse = await _dio.get(
            ApiConfig.userProfileEndpoint,
            options: Options(
              headers: {'Authorization': 'Bearer $_accessToken'},
            ),
          );
          if (userResponse.statusCode == 200) {
            _user = User.fromJson(userResponse.data);
            notifyListeners();
          }
        } catch (e) {
          print('Error initializing user session: $e');
          await _clearTokens();
        }
      }
    } catch (e) {
      print('Error during initialization: $e');
      await _clearTokens();
    }
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

  Future<bool> login(String email, String password) async {
    try {
      final response = await _dio.post(
        ApiConfig.loginEndpoint,
        data: {'email': email, 'password': password},
      );

      if (response.statusCode == 200) {
        _accessToken = response.data['access'] as String;
        _refreshToken = response.data['refresh'] as String;

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', _accessToken!);
        await prefs.setString('refresh_token', _refreshToken!);

        final userResponse = await _dio.get(
          ApiConfig.userProfileEndpoint,
          options: Options(
            headers: {'Authorization': 'Bearer $_accessToken'},
          ),
        );

        if (userResponse.statusCode == 200) {
          _user = User.fromJson(userResponse.data);
          notifyListeners();
          return true;
        }
      }
      print('Login failed: ${response.statusCode} - ${response.data}');
      return false;
    } on DioException catch (e) {
      print('Login error: ${e.message}');
      if (e.response != null) {
        print('Error response: ${e.response?.data}');
      }
      return false;
    } catch (e) {
      print('Unexpected error during login: $e');
      return false;
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
        'nom': nom,
        'prenom': prenom,
        'email': email,
        'telephone': telephone,
        'motDePasse': motDePasse,
        'role': role,
      };

      if (role == 'livreur') {
        data.addAll({
          'typeVehicule': typeVehicule,
          'numeroImmatriculation': numeroImmatriculation,
          'photoLivreur': photoLivreur,
        });
      }

      print('Sending registration request to: ${ApiConfig.baseUrl}${ApiConfig.registerEndpoint}');
      print('Request data: $data');

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.registerEndpoint}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final responseData = jsonDecode(response.body);
        return OTPResponse.fromJson(responseData);
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
        Uri.parse(ApiConfig.baseUrl + '/auth/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'otp': otp,
        }),
      );

      final data = jsonDecode(response.body);
      if (data['success'] == true && data['token'] != null) {
        // TODO: Store token in secure storage
        _user = User.fromJson(data['user']);
      }
      return OTPResponse.fromJson(data);
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
        Uri.parse(ApiConfig.baseUrl + '/auth/resend-otp'),
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

  Future<List<Demande>> getClientDeliveries() async {
    try {
      final response = await _dio.get(
        ApiConfig.deliveriesEndpoint,
        options: Options(headers: {'Authorization': 'Bearer $_accessToken'}),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data
            .map((json) => Demande.fromJson(json))
            .where((demande) => demande.utilisateurId == _user?.id)
            .toList();
      }
      print('Get client deliveries failed: ${response.data}');
    } on DioException catch (e) {
      print('Get client deliveries error: ${e.message}');
    }

    // Fallback to mock data
    try {
      final String jsonString = await rootBundle.loadString('assets/mock_data/demandes.json');
      final List<dynamic> jsonData = jsonDecode(jsonString);
      return jsonData
          .map((json) => Demande.fromJson(json))
          .where((demande) => demande.utilisateurId == _user?.id)
          .toList();
    } catch (e) {
      print('Error loading mock deliveries: $e');
      return [];
    }
  }

  Future<List<Livraison>> getDriverDeliveries() async {
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
    } on DioException catch (e) {
      print('Get driver deliveries error: ${e.message}');
    }

    return [];
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
    required String firstName,
    required String lastName,
    required String phone,
    String? photo,
  }) async {
    try {
      final response = await _dio.put(
        ApiConfig.updateProfileEndpoint,
        options: Options(headers: {'Authorization': 'Bearer $_accessToken'}),
        data: {
          'first_name': firstName,
          'last_name': lastName,
          'phone': phone,
          if (photo != null) 'photo': photo,
        },
      );

      if (response.statusCode == 200) {
        _user = User.fromJson(response.data);
        notifyListeners();
        return true;
      }
      print('Update profile failed: ${response.data}');
      return false;
    } on DioException catch (e) {
      print('Update profile error: ${e.message}');
      return false;
    }
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final response = await _dio.post(
        ApiConfig.changePasswordEndpoint,
        options: Options(headers: {'Authorization': 'Bearer $_accessToken'}),
        data: {
          'current_password': currentPassword,
          'new_password': newPassword,
        },
      );

      if (response.statusCode == 200) {
        return true;
      }
      print('Change password failed: ${response.data}');
      return false;
    } on DioException catch (e) {
      print('Change password error: ${e.message}');
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await _dio.post(
        ApiConfig.logoutEndpoint,
        options: Options(headers: {'Authorization': 'Bearer $_accessToken'}),
      );
    } on DioException catch (e) {
      print('Logout error: ${e.message}');
    } finally {
      _user = null;
      _accessToken = null;
      _refreshToken = null;
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('access_token');
      await prefs.remove('refresh_token');
      notifyListeners();
    }
  }

  Future<List<Demande>> getClientDemandes() async {
    try {
      final response = await _dio.get(
        ApiConfig.deliveriesEndpoint,
        options: Options(headers: {'Authorization': 'Bearer $_accessToken'}),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Demande.fromJson(json)).toList();
      }
      print('Get client deliveries failed: ${response.data}');
      return [];
    } on DioException catch (e) {
      print('Get client deliveries error: ${e.message}');
      return [];
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
}