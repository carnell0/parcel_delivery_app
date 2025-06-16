import 'package:flutter/material.dart';
import 'package:parcel_delivery/services/api_service.dart';
import 'package:parcel_delivery/models/livraison.dart';
import 'package:provider/provider.dart';

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
                    leading: const Icon(Icons.location_on),
                    title: const Text('Point de départ'),
                    subtitle: Text(
                      '${delivery.numeroDepart ?? ''} (${delivery.latitudeDepart}, ${delivery.longitudeDepart})',
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.flag),
                    title: const Text('Point d\'arrivée'),
                    subtitle: Text(
                      '${delivery.numeroArrivee ?? ''} (${delivery.latitudeArrivee}, ${delivery.longitudeArrivee})',
                    ),
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

  Future<void> _loadPendingDeliveries() async {
    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final deliveries = await apiService.getDriverDeliveries(); //  méthode correcte
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
