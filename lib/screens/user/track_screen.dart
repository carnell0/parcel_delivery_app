import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../services/api_service.dart';
import '../../models/delivery.dart';

class TrackScreen extends StatefulWidget {
  const TrackScreen({super.key});

  @override
  State<TrackScreen> createState() => _TrackScreenState();
}

class _TrackScreenState extends State<TrackScreen> {
  final MapController _mapController = MapController();
  Delivery? _delivery;
  bool _isLoading = true;
  StreamSubscription<Delivery>? _trackingSubscription;
  double _currentZoom = 13.0;

  @override
  void initState() {
    super.initState();
    _loadDeliveryData();
  }

  @override
  void dispose() {
    _trackingSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadDeliveryData() async {
    final int? colisId = ModalRoute.of(context)?.settings.arguments as int?;
    if (colisId != null) {
      final apiService = Provider.of<ApiService>(context, listen: false);
      try {
        // Start real-time tracking
        _trackingSubscription = apiService.trackDelivery(colisId).listen(
          (delivery) {
            setState(() {
              _delivery = delivery;
              _isLoading = false;
            });
            // Center map on delivery location
            _mapController.move(
              delivery.currentLocation,
              _currentZoom,
            );
          },
          onError: (error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Erreur de suivi: $error')),
            );
          },
        );
      } catch (e) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Suivi Colis #${_delivery?.id ?? ""}'),
        backgroundColor: const Color(0xFF1C2526),
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1C2526), Color(0xFF2E3B3E)],
          ),
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Expanded(
                    child: Stack(
                      children: [
                        FlutterMap(
                          mapController: _mapController,
                          options: MapOptions(
                            initialCenter: _delivery?.currentLocation ??
                                const LatLng(48.8566, 2.3522),
                            initialZoom: _currentZoom,
                            onMapReady: () {
                              if (_delivery != null) {
                                _mapController.move(
                                  _delivery!.currentLocation,
                                  _currentZoom,
                                );
                              }
                            },
                          ),
                          children: [
                            TileLayer(
                              urlTemplate:
                                  'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              userAgentPackageName: 'com.example.parcel_delivery',
                            ),
                            if (_delivery != null) ...[
                              MarkerLayer(
                                markers: [
                                  Marker(
                                    point: _delivery!.currentLocation,
                                    width: 80,
                                    height: 80,
                                    child: const Icon(
                                      Icons.location_on,
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
                                      _delivery!.currentLocation,
                                      LatLng(
                                        _delivery!.currentLocation.latitude + 0.01,
                                        _delivery!.currentLocation.longitude + 0.01,
                                      ),
                                    ],
                                    color: Colors.blue,
                                    strokeWidth: 3,
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                        Positioned(
                          right: 16,
                          bottom: 16,
                          child: FloatingActionButton(
                            onPressed: () {
                              if (_delivery != null) {
                                _mapController.move(
                                  _delivery!.currentLocation,
                                  _currentZoom,
                                );
                              }
                            },
                            backgroundColor: Colors.white,
                            child: const Icon(Icons.my_location),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Statut: ${_delivery?.status ?? "Inconnu"}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (_delivery?.driverName != null) ...[
                          Text(
                            'Livreur: ${_delivery!.driverName}',
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 4),
                        ],
                        if (_delivery?.estimatedArrival != null) ...[
                          Text(
                            'Arrivée estimée: ${_delivery!.estimatedArrival}',
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 4),
                        ],
                        Text(
                          'Dernière mise à jour: ${_delivery?.lastUpdate ?? "N/A"}',
                          style: const TextStyle(fontSize: 14),
          ),
                      ],
                    ),
                  ),
                ],
        ),
      ),
    );
  }
}