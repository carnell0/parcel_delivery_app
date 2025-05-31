// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../services/api_service.dart';
// import '../../widgets/custom_button.dart';
// import '../../widgets/custom_card.dart';
// import 'user/deliveries_screen.dart';
// import 'track_screen.dart';
// import '../messages_screen.dart';
// import '../profile_screen.dart';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   HomeScreenState createState() => HomeScreenState();
// }

// class HomeScreenState extends State<HomeScreen> {
//   int _currentIndex = 0;

//   final List<Widget> _screens = [
//     const HomeContent(),
//     DeliveriesScreen(),
//     const TrackScreen(),
//     MessagesScreen(),
//     const ProfileScreen(),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: _screens[_currentIndex],
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: _currentIndex,
//         onTap: (index) => setState(() => _currentIndex = index),
//         type: BottomNavigationBarType.fixed,
//         items: const [
//           BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
//           BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Orders'),
//           BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Track'),
//           BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Messages'),
//           BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
//         ],
//       ),
//     );
//   }
// }

// class HomeContent extends StatelessWidget {
//   const HomeContent({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final apiService = Provider.of<ApiService>(context);
//     final user = apiService.user;

//     return Container(
//       width: double.infinity,
//       height: double.infinity,
//       decoration: const BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topCenter,
//           end: Alignment.bottomCenter,
//           colors: [Color(0xFF1C2526), Color(0xFF2E3B3E)],
//         ),
//       ),
//       child: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 'Hello, ${user?.prenom ?? 'User'} ${user?.nom ?? ''}',
//                 style: const TextStyle(
//                   fontSize: 32,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white,
//                 ),
//               ),
//               const SizedBox(height: 8),
//               const Text(
//                 'Ready to send a parcel?',
//                 style: TextStyle(
//                   fontSize: 16,
//                   color: Colors.white70,
//                 ),
//               ),
//               const SizedBox(height: 24),
//               CustomButton(
//                 text: 'New Order',
//                 onPressed: () => Navigator.pushNamed(context, '/delivery-form'),
//               ),
//               const SizedBox(height: 24),
//               const Text(
//                 'Recent Orders',
//                 style: TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.w600,
//                   color: Colors.white,
//                 ),
//               ),
//               const SizedBox(height: 16),
//               CustomCard(
//                 title: 'Order #1',
//                 subtitle: 'Recipient: Jean Dupont\nStatus: In Transit',
//                 onTap: () => Navigator.pushNamed(context, '/track'),
//               ),
//               CustomCard(
//                 title: 'Order #2',
//                 subtitle: 'Recipient: Marie Koffi\nStatus: Delivered',
//                 onTap: () => Navigator.pushNamed(context, '/track'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }