import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../services/api_service.dart';
import '../../models/livraison.dart';

class TrackScreen extends StatefulWidget {
  final int deliveryId;

  const TrackScreen({Key? key, required this.deliveryId}) : super(key: key);

  @override
  State<TrackScreen> createState() => _TrackScreenState();
}

class _TrackScreenState extends State<TrackScreen> {
  final MapController _mapController = MapController();
  Livraison? _livraison;
  bool _isLoading = true;
  String? _error;
  StreamSubscription<Livraison>? _trackingSubscription;
  double _currentZoom = 13.0;

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
        });
        // Center map on delivery departure location if available
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
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Text('Erreur: $_error'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Suivi Colis #${_livraison?.id ?? ""}'),
        backgroundColor: const Color(0xFF1C2526),
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _livraison?.latitudeDepart != null && _livraison?.longitudeDepart != null
                  ? LatLng(_livraison!.latitudeDepart!, _livraison!.longitudeDepart!)
                  : const LatLng(48.8566, 2.3522),
              initialZoom: _currentZoom,
              onMapReady: () {
                if (_livraison?.latitudeDepart != null && _livraison?.longitudeDepart != null) {
                  _mapController.move(
                    LatLng(_livraison!.latitudeDepart!, _livraison!.longitudeDepart!),
                    _currentZoom,
                  );
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.parcel_delivery',
              ),
              if (_livraison?.latitudeDepart != null && _livraison?.longitudeDepart != null) ...[
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
              ],
              if (_livraison?.latitudeArrivee != null && _livraison?.longitudeArrivee != null) ...[
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
                        if (_livraison?.latitudeDepart != null && _livraison?.longitudeDepart != null)
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
          Positioned(
            right: 16,
            bottom: 16,
            child: Column(
              children: [
                FloatingActionButton(
                  onPressed: () {
                    if (_livraison?.latitudeArrivee != null && _livraison?.longitudeArrivee != null) {
                      _mapController.move(
                        LatLng(_livraison!.latitudeArrivee!, _livraison!.longitudeArrivee!),
                        _currentZoom,
                      );
                    }
                  },
                  child: const Icon(Icons.my_location),
                ),
                const SizedBox(height: 16),
                FloatingActionButton(
                  onPressed: () {
                    setState(() {
                      _currentZoom = (_currentZoom + 1).clamp(5, 18);
                    });
                  },
                  child: const Icon(Icons.add),
                ),
                const SizedBox(height: 8),
                FloatingActionButton(
                  onPressed: () {
                    setState(() {
                      _currentZoom = (_currentZoom - 1).clamp(5, 18);
                    });
                  },
                  child: const Icon(Icons.remove),
                ),
              ],
            ),
          ),
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