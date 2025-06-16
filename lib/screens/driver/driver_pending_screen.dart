import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:parcel_delivery/services/api_service.dart';
import 'package:parcel_delivery/models/livraison.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

// Fonction pour calculer la distance en km
double calculateDistance(double lat1, double lng1, double lat2, double lng2) {
  const earthRadius = 6371.0;
  final dLat = (lat2 - lat1) * (pi / 180.0);
  final dLng = (lng2 - lng1) * (pi / 180.0);
  final a = sin(dLat / 2) * sin(dLat / 2) +
      cos(lat1 * (pi / 180.0)) *
          cos(lat2 * (pi / 180.0)) *
          sin(dLng / 2) *
          sin(dLng / 2);
  final c = 2 * atan2(sqrt(a), sqrt(1 - a));
  return earthRadius * c;
}

// Fonction pour trouver le point milieu
LatLng getMiddlePoint(LatLng a, LatLng b) {
  return LatLng(
    (a.latitude + b.latitude) / 2,
    (a.longitude + b.longitude) / 2,
  );
}

class DriverPendingScreen extends StatefulWidget {
  const DriverPendingScreen({super.key});

  @override
  State<DriverPendingScreen> createState() => _DriverPendingScreenState();
}

class _DriverPendingScreenState extends State<DriverPendingScreen> {
  List<Livraison> pendingDeliveries = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPendingDeliveries();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Livraisons en attente'),
        backgroundColor: const Color(0xFFF28C38),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (pendingDeliveries.isEmpty) {
      return const Center(
        child: Text('Aucune livraison en attente'),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadPendingDeliveries,
      child: ListView.builder(
        itemCount: pendingDeliveries.length,
        itemBuilder: (context, index) {
          final delivery = pendingDeliveries[index];
          return Card(
            margin: const EdgeInsets.all(8.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Livraison #${delivery.id}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  ListTile(
                    leading: const Icon(Icons.phone, color: Colors.green),
                    title: const Text('Numéro de départ'),
                    subtitle: Text(
                      delivery.numeroDepart != null
                          ? '${delivery.numeroDepart}'
                          : 'Non renseigné',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    trailing: delivery.numeroDepart != null
                        ? IconButton(
                            icon: const Icon(Icons.call, color: Colors.blue),
                            onPressed: () {
                              launchUrl(Uri.parse('tel:${delivery.numeroDepart}'));
                            },
                          )
                        : null,
                  ),
                  ListTile(
                    leading: const Icon(Icons.phone, color: Colors.red),
                    title: const Text('Numéro d\'arrivée'),
                    subtitle: Text(
                      delivery.numeroArrivee != null
                          ? '${delivery.numeroArrivee}'
                          : 'Non renseigné',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    trailing: delivery.numeroArrivee != null
                        ? IconButton(
                            icon: const Icon(Icons.call, color: Colors.blue),
                            onPressed: () {
                              launchUrl(Uri.parse('tel:${delivery.numeroArrivee}'));
                            },
                          )
                        : null,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: buildDeliveryMap(delivery),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _acceptDelivery(delivery.id),
                      child: const Text('Accepter la livraison'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildDeliveryMap(Livraison delivery) {
    final depart = LatLng(delivery.latitudeDepart!, delivery.longitudeDepart!);
    final arrivee = LatLng(delivery.latitudeArrivee!, delivery.longitudeArrivee!);
    final middle = getMiddlePoint(depart, arrivee);
    final distance = calculateDistance(
      depart.latitude, depart.longitude, arrivee.latitude, arrivee.longitude,
    );

    return SizedBox(
      height: 250,
      child: FlutterMap(
        options: MapOptions(
          center: middle,
          zoom: 11,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.parcel_delivery',
          ),
          PolylineLayer(
            polylines: [
              Polyline(
                points: [depart, arrivee],
                color: Colors.blue,
                strokeWidth: 4,
              ),
            ],
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: depart,
                width: 40,
                height: 40,
                child: const Icon(Icons.location_on, color: Colors.green, size: 40),
              ),
              Marker(
                point: arrivee,
                width: 40,
                height: 40,
                child: const Icon(Icons.flag, color: Colors.red, size: 40),
              ),
              Marker(
                point: LatLng(middle.latitude + 0.01, middle.longitude), // Décalage pour lisibilité
                width: 120,
                height: 40,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blueAccent),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    '${distance.toStringAsFixed(1)} km',
                    style: const TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      shadows: [
                        Shadow(
                          color: Colors.white,
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _loadPendingDeliveries() async {
    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final deliveries = await apiService.getDriverDeliveries();
      if (mounted) {
        setState(() {
          pendingDeliveries = deliveries;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> _acceptDelivery(int deliveryId) async {
    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      // TODO: Implémenter cette méthode dans ApiService si ce n’est pas fait
      // await apiService.acceptDriverDelivery(deliveryId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Livraison acceptée avec succès'),
            backgroundColor: Colors.green,
          ),
        );
        _loadPendingDeliveries(); // Refresh list
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
