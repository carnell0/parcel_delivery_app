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
    final notifications = [
      "Nouvelle livraison disponible !",
      "Votre dernière livraison a été validée.",
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dcoliv'),
        backgroundColor: const Color(0xFFF28C38),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Notifications récentes",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            ...notifications.map((msg) => _buildNotification(msg)),
            const SizedBox(height: 24),
            Text(
              "Livraisons en attente",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else if (pendingDeliveries.isEmpty)
              const Text("Aucune livraison en attente.")
            else
              ...pendingDeliveries.map((liv) => _buildDeliveryCard(context, liv)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // Naviguer vers l'écran des livraisons en attente
                // Navigator.push(context, MaterialPageRoute(builder: (_) => const DriverPendingScreen()));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF28C38),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Voir toutes les livraisons en attente',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotification(String message) {
    return Card(
      color: Colors.orange[50],
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: const Icon(Icons.notifications, color: Color(0xFFF28C38)),
        title: Text(message),
      ),
    );
  }

  Widget _buildDeliveryCard(BuildContext context, Livraison livraison) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: const Icon(Icons.local_shipping, color: Color(0xFFF28C38)),
        title: Text("Livraison #${livraison.id}"),
        subtitle: Text("Statut : ${livraison.statut}"),
        trailing: ElevatedButton(
          onPressed: () {
            // Action : accepter ou voir la livraison
          },
          child: const Text("Voir"),
        ),
      ),
    );
  }
}