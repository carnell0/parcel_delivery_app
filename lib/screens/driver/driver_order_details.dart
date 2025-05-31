import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/api_service.dart';
import '../../widgets/custom_button.dart';

class DriverOrderDetailsScreen extends StatelessWidget {
  const DriverOrderDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final int colisId = ModalRoute.of(context)!.settings.arguments as int;
    final apiService = Provider.of<ApiService>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Colis #$colisId'),
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
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                color: const Color(0xFFF5F6F5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Colis #$colisId',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1C2526),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Destinataire: John Doe\nAdresse: 123 Rue Cotonou\nPoids: 2.5 kg\nType: Express',
                        style: TextStyle(color: Color(0xFF616161)),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              CustomButton(
                text: 'Scanner QR',
                onPressed: () {
                  // TODO: Scanner QR, appeler confirmQrCode()
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Scanner QR')),
                  );
                },
              ),
              const SizedBox(height: 16),
              CustomButton(
                text: 'Mettre à jour position',
                onPressed: () {
                  // TODO: Appeler updateDriverLocation()
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Position mise à jour')),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}