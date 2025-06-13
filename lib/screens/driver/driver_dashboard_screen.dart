import 'package:flutter/material.dart';
import 'package:parcel_delivery/services/api_service.dart';
import 'package:parcel_delivery/models/livraison.dart';
import 'package:provider/provider.dart';

class DriverDashboardScreen extends StatefulWidget {
  const DriverDashboardScreen({super.key});

  @override
  State<DriverDashboardScreen> createState() => _DriverDashboardScreenState();
}

class _DriverDashboardScreenState extends State<DriverDashboardScreen> {
  List<Livraison> _activeDeliveries = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadActiveDeliveries();
  }

  Future<void> _loadActiveDeliveries() async {
    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final deliveries = await apiService.getDriverPendingDeliveries();
      if (mounted) {
        setState(() {
          _activeDeliveries = deliveries;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tableau de bord'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadActiveDeliveries,
          ),
        ],
      ),
      body: _activeDeliveries.isEmpty
          ? const Center(
              child: Text('Aucune livraison active'),
            )
          : ListView.builder(
              itemCount: _activeDeliveries.length,
              itemBuilder: (context, index) {
                final delivery = _activeDeliveries[index];
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    leading: const Icon(Icons.local_shipping),
                    title: Text('Livraison #${delivery.id}'),
                    subtitle: Text(delivery.statut),
                    trailing: IconButton(
                      icon: const Icon(Icons.map),
                      onPressed: () {
                        // TODO: Naviguer vers la carte avec l'itinéraire
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
} 