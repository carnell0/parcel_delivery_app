import 'package:flutter/material.dart';
import 'package:parcel_delivery/screens/driver/driver_home_screen.dart';
import 'package:parcel_delivery/screens/driver/pending_deliveries_screen.dart';
import 'package:parcel_delivery/screens/driver/driver_map_screen.dart';
import 'package:parcel_delivery/screens/driver/driver_profile_screen.dart';

class DriverNavigation extends StatefulWidget {
  const DriverNavigation({Key? key}) : super(key: key);

  @override
  State<DriverNavigation> createState() => _DriverNavigationState();
}

class _DriverNavigationState extends State<DriverNavigation> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const DriverHomeScreen(),
    const PendingDeliveriesScreen(),
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