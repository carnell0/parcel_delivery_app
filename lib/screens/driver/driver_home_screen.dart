import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/api_service.dart';
import '../../widgets/custom_button.dart';
import '../../models/livraison.dart';
import '../../models/demande.dart';

class DriverHomeScreen extends StatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  DriverHomeScreenState createState() => DriverHomeScreenState();
}

class DriverHomeScreenState extends State<DriverHomeScreen> {
  int _currentIndex = 0;
  bool _isAvailable = true;

  @override
  Widget build(BuildContext context) {
    final apiService = Provider.of<ApiService>(context);
    final user = apiService.user;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1C2526), Color(0xFF2E3B3E)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bonjour, ${user?.prenom ?? "Livreur"}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Points de fidélité: 0',
                          style: const TextStyle(fontSize: 14, color: Colors.white70),
                        ),
                      ],
                    ),
                    CircleAvatar(
                      radius: 20,
                      child: const Icon(Icons.person, color: Color(0xFFF28C38)),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Disponible',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    Switch(
                      value: _isAvailable,
                      onChanged: (value) {
                        setState(() => _isAvailable = value);
                        // TODO: Appeler PATCH /api/livreurs/<id>/
                      },
                      activeColor: const Color(0xFFF28C38),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: IndexedStack(
                  index: _currentIndex,
                  children: [
                    FutureBuilder<List<Livraison>>(
                      future: apiService.getLivreurLivraisons(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator(color: Color(0xFFF28C38)));
                        }
                        final livraisons = snapshot.data ?? [];
                        return Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Livraisons assignées',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Expanded(
                                child: livraisons.isEmpty
                                    ? const Center(
                                        child: Text(
                                          'Aucune livraison assignée',
                                          style: TextStyle(color: Colors.white70),
                                        ),
                                      )
                                    : ListView.builder(
                                        itemCount: livraisons.length,
                                        itemBuilder: (context, index) {
                                          final livraison = livraisons[index];
                                          return Card(
                                            color: const Color(0xFFF5F6F5),
                                            margin: const EdgeInsets.only(bottom: 16),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: ListTile(
                                              contentPadding: const EdgeInsets.all(16),
                                              title: Text(
                                                'Livraison #${livraison.id}',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF1C2526),
                                                ),
                                              ),
                                              subtitle: Text(
                                                'Statut: ${livraison.statut}\n'
                                                'Date de prise en charge: ${livraison.datePriseEnCharge.toString().split('.')[0]}',
                                                style: const TextStyle(color: Color(0xFF616161)),
                                              ),
                                              trailing: IconButton(
                                                icon: const Icon(Icons.qr_code_scanner, color: Color(0xFFF28C38)),
                                                onPressed: () {
                                                  // TODO: Scanner QR
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    const SnackBar(content: Text('Scanner QR')),
                                                  );
                                                },
                                              ),
                                              onTap: () {
                                                Navigator.pushNamed(context, '/driver/livraison', arguments: livraison.id);
                                              },
                                            ),
                                          );
                                        },
                                      ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    Container(
                      color: Colors.white,
                      child: const Center(
                        child: Text(
                          'Carte (À intégrer avec flutter_map)',
                          style: TextStyle(fontSize: 18, color: Color(0xFF1C2526)),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Profil',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Card(
                            color: const Color(0xFFF5F6F5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              title: const Text(
                                'Mettre à jour la position',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1C2526),
                                ),
                              ),
                              trailing: const Icon(Icons.location_on, color: Color(0xFFF28C38)),
                              onTap: () {
                                // TODO: Appeler updateDriverLocation()
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Mettre à jour position')),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                          CustomButton(
                            text: 'Déconnexion',
                            onPressed: () {
                              apiService.logout();
                              Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                            },
                            backgroundColor: Colors.redAccent,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        backgroundColor: const Color(0xFFF5F6F5),
        selectedItemColor: const Color(0xFFF28C38),
        unselectedItemColor: const Color(0xFF616161),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.delivery_dining), label: 'Livraisons'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Carte'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}