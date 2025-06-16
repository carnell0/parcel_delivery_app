import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:provider/provider.dart';
import 'package:parcel_delivery/services/api_service.dart';
import 'package:parcel_delivery/theme/app_theme.dart';
import 'package:geolocator/geolocator.dart';

class DeliveryFormScreen extends StatefulWidget {
  const DeliveryFormScreen({super.key});

  @override
  State<DeliveryFormScreen> createState() => _DeliveryFormScreenState();
}

class _DeliveryFormScreenState extends State<DeliveryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dimensionController = TextEditingController();
  final _natureController = TextEditingController();
  final _poidsController = TextEditingController();
  final _latitudeDepartController = TextEditingController();
  final _longitudeDepartController = TextEditingController();
  final _latitudeArriveeController = TextEditingController();
  final _longitudeArriveeController = TextEditingController();
  final _numeroDepartController = TextEditingController();
  final _numeroArriveeController = TextEditingController();

  String _selectedMode = 'standard'; // Valeur par défaut en minuscules
  File? _photoColis;
  bool _isLoading = false;
  LatLng? _departCoord;
  LatLng? _arriveeCoord;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _photoColis = File(image.path);
      });
    }
  }

  Future<void> _selectOnMap({
    required bool isDepart,
    required LatLng initialPosition,
  }) async {
    final picked = await Navigator.push<LatLng>(
      context,
      MaterialPageRoute(
        builder: (_) => MapPickerScreen(initialPosition: initialPosition),
      ),
    );
    if (picked != null) {
      setState(() {
        if (isDepart) {
          _departCoord = picked;
          _latitudeDepartController.text = picked.latitude.toString();
          _longitudeDepartController.text = picked.longitude.toString();
        } else {
          _arriveeCoord = picked;
          _latitudeArriveeController.text = picked.latitude.toString();
          _longitudeArriveeController.text = picked.longitude.toString();
        }
      });
    }
  }

  Future<void> _setCurrentPosition({required bool isDepart}) async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Permission de localisation refusée')),
          );
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permission de localisation refusée définitivement')),
        );
        return;
      }

      final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      setState(() {
        if (isDepart) {
          _departCoord = LatLng(pos.latitude, pos.longitude);
          _latitudeDepartController.text = pos.latitude.toString();
          _longitudeDepartController.text = pos.longitude.toString();
        } else {
          _arriveeCoord = LatLng(pos.latitude, pos.longitude);
          _latitudeArriveeController.text = pos.latitude.toString();
          _longitudeArriveeController.text = pos.longitude.toString();
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur de localisation : $e')),
      );
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final apiService = Provider.of<ApiService>(context, listen: false);

      // Récupérer l'utilisateur connecté
      final utilisateur = apiService.utilisateur;
      if (utilisateur == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Utilisateur non connecté')),
        );
        setState(() => _isLoading = false);
        return;
      }

      // Création de la demande (infos colis)
      final success = await apiService.createDelivery(
        natureColis: _natureController.text,
        dimensions: _dimensionController.text,
        poids: double.tryParse(_poidsController.text) ?? 0,
        photoColis: _photoColis?.path,
        modeLivraison: _selectedMode, // Toujours en minuscules
        latitudeDepart: double.tryParse(_latitudeDepartController.text) ?? 0,
        longitudeDepart: double.tryParse(_longitudeDepartController.text) ?? 0,
        latitudeArrivee: double.tryParse(_latitudeArriveeController.text) ?? 0,
        longitudeArrivee: double.tryParse(_longitudeArriveeController.text) ?? 0,
        numeroDepart: int.tryParse(_numeroDepartController.text),
        numeroArrivee: int.tryParse(_numeroArriveeController.text),
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Livraison créée avec succès')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors de la création de la livraison')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _dimensionController.dispose();
    _natureController.dispose();
    _poidsController.dispose();
    _latitudeDepartController.dispose();
    _longitudeDepartController.dispose();
    _latitudeArriveeController.dispose();
    _longitudeArriveeController.dispose();
    _numeroDepartController.dispose();
    _numeroArriveeController.dispose();
    super.dispose();
  }

  Widget _buildMiniMap({
    required String label,
    required LatLng? marker,
    required Function(LatLng) onTap,
    required double initialLat,
    required double initialLng,
    required VoidCallback onFullMap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTheme.headlineStyle.copyWith(fontSize: 16)),
        const SizedBox(height: 8),
        SizedBox(
          height: 220,
          child: FlutterMap(
            options: MapOptions(
              initialCenter: marker ?? LatLng(initialLat, initialLng),
              initialZoom: 13,
              onTap: (tapPosition, point) {
                onTap(point);
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.parcel_delivery',
              ),
              if (marker != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: marker,
                      width: 40,
                      height: 40,
                      child: const Icon(Icons.location_on, color: Colors.red, size: 40),
                    ),
                  ],
                ),
            ],
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            icon: const Icon(Icons.map),
            label: const Text('Sélectionner sur une grande carte'),
            onPressed: onFullMap,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nouvelle livraison'),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _dimensionController,
                decoration: AppTheme.textFieldDecoration(
                  label: 'Dimensions du colis (L x l x h)',
                  prefixIcon: Icons.straighten,
                  hint: 'Ex: 40 x 30 x 20 cm',
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Veuillez entrer les dimensions' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _natureController,
                decoration: AppTheme.textFieldDecoration(
                  label: 'Nature du colis',
                  prefixIcon: Icons.category,
                  hint: 'Ex: Documents, vêtements...',
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Veuillez entrer la nature du colis' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _poidsController,
                decoration: AppTheme.textFieldDecoration(
                  label: 'Poids (kg)',
                  prefixIcon: Icons.scale,
                  hint: 'Ex: 2.5',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Veuillez entrer le poids';
                  if (double.tryParse(value) == null) return 'Veuillez entrer un nombre valide';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedMode,
                decoration: AppTheme.textFieldDecoration(
                  label: 'Mode de livraison',
                  prefixIcon: Icons.local_shipping,
                ),
                items: const [
                  DropdownMenuItem(value: 'standard', child: Text('Standard')),
                  DropdownMenuItem(value: 'express', child: Text('Express')),
                  DropdownMenuItem(value: 'economique', child: Text('Economique')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedMode = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.photo_camera),
                label: const Text('Ajouter une photo du colis'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
              if (_photoColis != null) ...[
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.file(
                    _photoColis!,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
              const SizedBox(height: 24),
              Text(
                'Localisation de départ',
                style: AppTheme.headlineStyle.copyWith(fontSize: 18),
              ),
              const SizedBox(height: 8),
              _buildMiniMap(
                label: "Choisir sur la carte",
                marker: _departCoord,
                onTap: (point) {
                  setState(() {
                    _departCoord = point;
                    _latitudeDepartController.text = point.latitude.toString();
                    _longitudeDepartController.text = point.longitude.toString();
                  });
                },
                initialLat: 6.3703, // Cotonou
                initialLng: 2.3912,
                onFullMap: () => _selectOnMap(
                  isDepart: true,
                  initialPosition: _departCoord ?? LatLng(6.3703, 2.3912),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _latitudeDepartController,
                      decoration: AppTheme.textFieldDecoration(
                        label: 'Latitude',
                        prefixIcon: Icons.location_on,
                        hint: 'Ex: 6.3703',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Latitude requise';
                        final lat = double.tryParse(value);
                        if (lat == null || lat < -90 || lat > 90) return 'Latitude invalide';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _longitudeDepartController,
                      decoration: AppTheme.textFieldDecoration(
                        label: 'Longitude',
                        prefixIcon: Icons.location_on,
                        hint: 'Ex: 2.3912',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Longitude requise';
                        final lng = double.tryParse(value);
                        if (lng == null || lng < -180 || lng > 180) return 'Longitude invalide';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Localisation d\'arrivée',
                style: AppTheme.headlineStyle.copyWith(fontSize: 18),
              ),
              const SizedBox(height: 8),
              _buildMiniMap(
                label: "Choisir sur la carte",
                marker: _arriveeCoord,
                onTap: (point) {
                  setState(() {
                    _arriveeCoord = point;
                    _latitudeArriveeController.text = point.latitude.toString();
                    _longitudeArriveeController.text = point.longitude.toString();
                  });
                },
                initialLat: 6.3703, // Cotonou
                initialLng: 2.3912,
                onFullMap: () => _selectOnMap(
                  isDepart: false,
                  initialPosition: _arriveeCoord ?? LatLng(6.3703, 2.3912),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _latitudeArriveeController,
                      decoration: AppTheme.textFieldDecoration(
                        label: 'Latitude',
                        prefixIcon: Icons.flag,
                        hint: 'Ex: 6.3703',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Latitude requise';
                        final lat = double.tryParse(value);
                        if (lat == null || lat < -90 || lat > 90) return 'Latitude invalide';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _longitudeArriveeController,
                      decoration: AppTheme.textFieldDecoration(
                        label: 'Longitude',
                        prefixIcon: Icons.flag,
                        hint: 'Ex: 2.3912',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Longitude requise';
                        final lng = double.tryParse(value);
                        if (lng == null || lng < -180 || lng > 180) return 'Longitude invalide';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Numéro de départ et d\'arrivée',
                style: AppTheme.headlineStyle.copyWith(fontSize: 18),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _numeroDepartController,
                      decoration: AppTheme.textFieldDecoration(
                        label: 'Numéro départ',
                        prefixIcon: Icons.confirmation_number,
                        hint: 'Ex: 12',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value != null && value.isNotEmpty && int.tryParse(value) == null) {
                          return 'Numéro invalide';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _numeroArriveeController,
                      decoration: AppTheme.textFieldDecoration(
                        label: 'Numéro arrivée',
                        prefixIcon: Icons.confirmation_number,
                        hint: 'Ex: 34',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value != null && value.isNotEmpty && int.tryParse(value) == null) {
                          return 'Numéro invalide';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Lancer la demande de livraison'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Widget pour la sélection plein écran sur la carte
class MapPickerScreen extends StatefulWidget {
  final LatLng initialPosition;
  const MapPickerScreen({super.key, required this.initialPosition});

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  LatLng? _picked;

  Future<void> _setCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Permission de localisation refusée')),
          );
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permission de localisation refusée définitivement')),
        );
        return;
      }

      final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _picked = LatLng(pos.latitude, pos.longitude);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur de localisation : $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sélectionner un lieu')),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: _picked ?? widget.initialPosition,
          initialZoom: 14,
          onTap: (tapPosition, point) {
            setState(() => _picked = point);
          },
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.parcel_delivery',
          ),
          if (_picked != null)
            MarkerLayer(
              markers: [
                Marker(
                  point: _picked!,
                  width: 40,
                  height: 40,
                  child: const Icon(Icons.location_on, color: Colors.red, size: 40),
                ),
              ],
            ),
        ],
      ),
      floatingActionButton: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            FloatingActionButton.extended(
              heroTag: 'currentLoc',
              onPressed: _setCurrentLocation,
              label: const Text('Ma position'),
              icon: const Icon(Icons.my_location),
            ),
            const SizedBox(height: 12),
            if (_picked != null)
              FloatingActionButton.extended(
                heroTag: 'validateLoc',
                onPressed: () => Navigator.pop(context, _picked),
                label: const Text('Valider ce lieu'),
                icon: const Icon(Icons.check),
              ),
          ],
        ),
      ),
    );
  }
}