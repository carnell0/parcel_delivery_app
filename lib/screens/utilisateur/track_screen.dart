import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../services/api_service.dart';
import '../../models/livraison.dart';

class TrackScreen extends StatefulWidget {
  final int deliveryId;

  const TrackScreen({super.key, required this.deliveryId});

  @override
  State<TrackScreen> createState() => _TrackScreenState();
}

class _TrackScreenState extends State<TrackScreen> {
  final MapController _mapController = MapController();
  Livraison? _livraison;
  bool _isLoading = true;
  String? _error;
  StreamSubscription<Livraison>? _trackingSubscription;
  final double _currentZoom = 13.0;

  // Position du livreur reçue dynamiquement (ex: via WebSocket ou API)
  double? _latitudeLivreur;
  double? _longitudeLivreur;

  @override
  void initState() {
    super.initState();
    _startTracking();
  }

  @override
  void dispose() {
    _trackingSubscription?.cancel();
    super.dispose();
  }

  void _startTracking() {
    final apiService = Provider.of<ApiService>(context, listen: false);
      _trackingSubscription = apiService.trackDelivery(widget.deliveryId).listen(
        (livraison) {
          setState(() {
            _livraison = livraison;
            _isLoading = false;
            _error = null;
          });
          if (livraison.latitudeDepart != null && livraison.longitudeDepart != null) {
            _mapController.move(
              LatLng(livraison.latitudeDepart!, livraison.longitudeDepart!),
              _currentZoom,
            );
          }
        },
        onError: (error) {
          setState(() {
            _error = error.toString();
            _isLoading = false;
            _livraison = null; // On efface la livraison pour éviter les marqueurs
          });
        },
      );
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _livraison?.latitudeDepart != null && _livraison?.longitudeDepart != null
                  ? LatLng(_livraison!.latitudeDepart!, _livraison!.longitudeDepart!)
                  : const LatLng(48.8566, 2.3522), // Paris par défaut
              initialZoom: _currentZoom,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.parcel_delivery',
              ),
              if (_livraison != null && _livraison!.latitudeDepart != null && _livraison!.longitudeDepart != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(_livraison!.latitudeDepart!, _livraison!.longitudeDepart!),
                      width: 80,
                      height: 80,
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.green,
                        size: 40,
                      ),
                    ),
                  ],
                ),
              if (_livraison != null && _livraison!.latitudeArrivee != null && _livraison!.longitudeArrivee != null)
                ...[
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: LatLng(_livraison!.latitudeArrivee!, _livraison!.longitudeArrivee!),
                        width: 80,
                        height: 80,
                        child: const Icon(
                          Icons.flag,
                          color: Colors.red,
                          size: 40,
                        ),
                      ),
                    ],
                  ),
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: [
                          if (_livraison!.latitudeDepart != null && _livraison!.longitudeDepart != null)
                            LatLng(_livraison!.latitudeDepart!, _livraison!.longitudeDepart!),
                          LatLng(_livraison!.latitudeArrivee!, _livraison!.longitudeArrivee!),
                        ],
                        color: Colors.blue,
                        strokeWidth: 4,
                      ),
                    ],
                  ),
                ],
            ],
          ),
          // Affiche la fiche d'infos seulement si la livraison existe
          if (_livraison != null)
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Statut: ${_livraison?.statut ?? "Inconnu"}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (_livraison?.dateLivraison != null) ...[
                        Text(
                          'Date de livraison: ${_livraison!.dateLivraison!.toString()}',
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                      ],
                      Text(
                        'Dernière mise à jour: ${_livraison?.datePriseEnCharge.toString() ?? "N/A"}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}