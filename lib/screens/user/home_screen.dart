import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/demande.dart';
import '../../services/api_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_card.dart';
import 'deliveries_screen.dart';
import 'track_screen.dart';
import '../messages_screen.dart';
import '../profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeContent(),
    const DeliveriesScreen(),
    const TrackScreen(),
    const MessagesScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFFF5F6F5),
        selectedItemColor: const Color(0xFFF28C38),
        unselectedItemColor: const Color(0xFF616161),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Livraisons'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Suivi'),
          BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Messages'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    final apiService = Provider.of<ApiService>(context);
    final user = apiService.user;

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1C2526), Color(0xFF2E3B3E)],
        ),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bonjour, ${user?.prenom ?? 'Utilisateur'} ${user?.nom ?? ''}',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Prêt à envoyer un colis ?',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: 'Nouvelle livraison',
                onPressed: () => Navigator.pushNamed(context, '/delivery-form'),
              ),
              const SizedBox(height: 24),
              const Text(
                'Livraisons récentes',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              FutureBuilder<List<Demande>>(
                future: apiService.getClientDemandes(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: Color(0xFFF28C38)));
                  }
                  final demandes = snapshot.data ?? [];
                  if (demandes.isEmpty) {
                    return const Text(
                      'Aucune livraison récente',
                      style: TextStyle(color: Colors.white70),
                    );
                  }
                  return Column(
                    children: demandes.take(2).map((demande) {
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
                            'Adresse: ${demande.adresseDestination}\nStatut: ${demande.statutDemande}',
                            style: const TextStyle(color: Color(0xFF616161)),
                          ),
                          onTap: () => Navigator.pushNamed(
                            context,
                            '/track',
                            arguments: demande.id,
                          ),
                        ),
                      );
                    }).toList(),
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