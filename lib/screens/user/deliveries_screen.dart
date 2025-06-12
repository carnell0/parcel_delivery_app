import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/demande.dart';
import '../../services/api_service.dart';
import '../../widgets/custom_card.dart';

class DeliveriesScreen extends StatelessWidget {
  const DeliveriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final apiService = Provider.of<ApiService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes livraisons'),
        backgroundColor: const Color(0xFF1C2526),
        foregroundColor: Colors.white,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1C2526), Color(0xFF2E3B3E)],
          ),
        ),
        child: FutureBuilder<List<Demande>>(
          future: apiService.getClientDemandes(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Color(0xFFF28C38)));
            }
            final demandes = snapshot.data ?? [];

            if (demandes.isEmpty) {
              return const Center(
                child: Text(
                  'Aucune livraison',
                  style: TextStyle(color: Colors.white70),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              itemCount: demandes.length,
              itemBuilder: (context, index) {
                final demande = demandes[index];
                return CustomCard(
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Text(
                      'Livraison #${demande.id}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1C2526),
                      ),
                    ),
                    subtitle: Text(
                      'Adresse de départ: ${demande.adresseDepart}\n'
                      'Adresse de destination: ${demande.adresseDestination}\n'
                      'Mode de livraison: ${demande.modeLivraison}\n'
                      'Statut: ${demande.statutDemande}',
                      style: const TextStyle(color: Color(0xFF616161)),
                    ),
                    onTap: () => Navigator.pushNamed(
                      context,
                      '/track',
                      arguments: demande.id,
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}