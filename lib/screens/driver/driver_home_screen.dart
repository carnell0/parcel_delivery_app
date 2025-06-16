import 'package:flutter/material.dart';
import 'package:parcel_delivery/models/livraison.dart';
import 'package:parcel_delivery/services/api_service.dart';
import 'package:provider/provider.dart';
import 'package:parcel_delivery/screens/driver/driver_pending_screen.dart';
import 'package:parcel_delivery/screens/driver/driver_map_screen.dart';
import 'package:parcel_delivery/screens/driver/driver_profile_screen.dart';

class DriverHomeScreen extends StatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  int _selectedIndex = 0;
  List<Livraison> pendingDeliveries = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPendingDeliveries();
  }

  Future<void> _loadPendingDeliveries() async {
    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final deliveries = await apiService.getDriverPendingDeliveries();
      if (mounted) {
        setState(() {
          pendingDeliveries = deliveries;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  List<Widget> get _screens => [
        _HomeTab(
          pendingDeliveries: pendingDeliveries,
          isLoading: isLoading,
        ),
        const DriverPendingScreen(),
        const DriverMapScreen(),
        const DriverProfileScreen(),
      ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: const Color(0xFFF28C38),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_shipping),
            label: 'En attente',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Carte',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  final List<Livraison> pendingDeliveries;
  final bool isLoading;

  const _HomeTab({
    required this.pendingDeliveries,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dcoliv'),
        backgroundColor: const Color(0xFFF28C38),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 32),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            child: Text(
              "Alors, on va où aujourd'hui ?",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 32),
          // Center(
          //   child: Image.network(
          //     'https://i.pinimg.com/736x/7a/e7/8c/7ae78c66fd31b4dcbb5f7781f444f268.jpg', // Mets ici l'URL de ton image
          //     height: 400,
          //     fit: BoxFit.contain,
          //   ),
          // ),
          Center(
            child: Image.asset(
              'assets/images/livreur.jpg', // Mets ton image dans assets
              height: 400,
              fit: BoxFit.contain,
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const DriverPendingScreen()),
                );
              },
              icon: const Icon(Icons.list_alt),
              label: const Text(
                'Voir les demandes en attente',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF28C38),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}