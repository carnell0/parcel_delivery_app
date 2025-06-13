import 'package:flutter/material.dart';
import 'package:parcel_delivery/models/livraison.dart';
import 'package:parcel_delivery/services/api_service.dart';
import 'package:parcel_delivery/widgets/custom_button.dart';

class DriverDeliveryDetailsScreen extends StatefulWidget {
  final int deliveryId;

  const DriverDeliveryDetailsScreen({
    super.key,
    required this.deliveryId,
  });

  @override
  State<DriverDeliveryDetailsScreen> createState() => _DriverDeliveryDetailsScreenState();
}

class _DriverDeliveryDetailsScreenState extends State<DriverDeliveryDetailsScreen> {
  final ApiService _apiService = ApiService();
  Livraison? _delivery;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDeliveryDetails();
  }

  Future<void> _loadDeliveryDetails() async {
    try {
      final delivery = await _apiService.getDeliveryDetails(widget.deliveryId);
      if (mounted) {
        setState(() {
          _delivery = delivery;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du chargement des détails: $e'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
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

    if (_delivery == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Détails de la livraison'),
        ),
        body: const Center(
          child: Text('Aucun détail disponible'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails de la livraison'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard('Statut', _delivery!.statut),
            const SizedBox(height: 16),
            _buildInfoCard('Date de prise en charge', _delivery!.datePriseEnCharge.toString()),
            if (_delivery!.dateLivraison != null) ...[
              const SizedBox(height: 16),
              _buildInfoCard('Date de livraison', _delivery!.dateLivraison.toString()),
            ],
            if (_delivery!.dateArriveeEstimee != null) ...[
              const SizedBox(height: 16),
              _buildInfoCard('Date d\'arrivée estimée', _delivery!.dateArriveeEstimee.toString()),
            ],
            const SizedBox(height: 24),
            CustomButton(
              text: 'Accepter la livraison',
              onPressed: () async {
                try {
                  await _apiService.acceptDelivery(widget.deliveryId.toString());
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Livraison acceptée avec succès'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    Navigator.pop(context, true);
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Erreur lors de l\'acceptation: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String value) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
} 