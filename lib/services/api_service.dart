import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import 'package:parcel_delivery/models/colis.dart';
import 'api_config.dart';
import 'package:flutter/services.dart' show rootBundle;

class ApiService with ChangeNotifier {
  User? _user;
  String? _accessToken;
  String? _refreshToken;

  User? get user => _user;

  Future<bool> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.loginEndpoint}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _accessToken = data['access'] as String;
        _refreshToken = data['refresh'] as String;

        final userResponse = await http.get(
          Uri.parse('${ApiConfig.baseUrl}${ApiConfig.registerEndpoint}me/'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $_accessToken',
          },
        );

        if (userResponse.statusCode == 200) {
          _user = User.fromJson(jsonDecode(userResponse.body));
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('access_token', _accessToken!);
          notifyListeners();
          return true;
        }
      }
      print('Login failed: ${response.statusCode} - ${response.body}');
      return false;
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }

  Future<bool> register({
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
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.registerEndpoint}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nom': nom,
          'prenom': prenom,
          'email': email,
          'telephone': telephone,
          'password': motDePasse,
          'role': role,
          'type_vehicule': typeVehicule,
          'numero_immatriculation': numeroImmatriculation,
          'photo_livreur': photoLivreur,
        }),
      );

      if (response.statusCode == 201) {
        return true;
      }
      print('Register failed: ${response.statusCode} - ${response.body}');
      return false;
    } catch (e) {
      print('Register error: $e');
      return false;
    }
  }

  Future<bool> createOrder({
    required int senderId,
    required String receiverEmail,
    required String receiverName,
    required String receiverAddress,
    required double weight,
    required String description,
    required String deliveryType,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.parcelsEndpoint}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_accessToken',
        },
        body: jsonEncode({
          'sender_id': senderId,
          'receiver_email': receiverEmail,
          'receiver_name': receiverName,
          'receiver_address': receiverAddress,
          'weight': weight,
          'description': description,
          'delivery_type': deliveryType,
        }),
      );

      if (response.statusCode == 201) {
        return true;
      }
      print('Create order failed: ${response.body}');
      return false;
    } catch (e) {
      print('Create order error: $e');
      return false;
    }
  }

  Future<List<Colis>> getClientOrders() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.parcelsEndpoint}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_accessToken',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data
            .map((json) => Colis.fromJson(json))
            .where((colis) => colis.senderId == _user?.id)
            .toList();
      }
      print('Get client orders failed: ${response.body}');
    } catch (e) {
      print('Get client orders error: $e');
    }

    // Fallback to mock data
    try {
      final String jsonString = await rootBundle.loadString('assets/mock_data/deliveries.json');
      final List<dynamic> jsonData = jsonDecode(jsonString);
      return jsonData
          .map((json) => Colis.fromJson(json))
          .where((colis) => colis.senderId == _user?.id)
          .toList();
    } catch (e) {
      print('Error loading mock deliveries: $e');
      return [];
    }
  }

  Future<List<Colis>> getDriverOrders() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.parcelsEndpoint}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_accessToken',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        // TODO: Filtrer par livreur (nécessite un champ driver_id dans l'API)
        return data.map((json) => Colis.fromJson(json)).toList();
      }
      print('Get driver orders failed: ${response.body}');
    } catch (e) {
      print('Get driver orders error: $e');
    }

    // Fallback to mock data
    try {
      final String jsonString = await rootBundle.loadString('assets/mock_data/deliveries.json');
      final List<dynamic> jsonData = jsonDecode(jsonString);
      return jsonData.map((json) => Colis.fromJson(json)).toList();
    } catch (e) {
      print('Error loading mock deliveries: $e');
      return [];
    }
  }

  void logout() async {
    _user = null;
    _accessToken = null;
    _refreshToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    notifyListeners();
  }
}