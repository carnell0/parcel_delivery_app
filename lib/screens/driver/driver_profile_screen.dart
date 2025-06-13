// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:parcel_delivery/services/api_service.dart';
// import 'package:parcel_delivery/models/livreur.dart';

// class DriverProfileScreen extends StatefulWidget {
//   const DriverProfileScreen({Key? key}) : super(key: key);

//   @override
//   State<DriverProfileScreen> createState() => _DriverProfileScreenState();
// }

// class _DriverProfileScreenState extends State<DriverProfileScreen> {
//   Livreur? _driver;
//   bool _isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _loadDriverProfile();
//   }

//   Future<void> _loadDriverProfile() async {
//     try {
//       final apiService = Provider.of<ApiService>(context, listen: false);
//       final driver = await apiService.getDriverProfile();
//       setState(() {
//         _driver = driver;
//         _isLoading = false;
//       });
//     } catch (e) {
//       setState(() => _isLoading = false);
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Erreur lors du chargement du profil: $e'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     }
//   }

//   Future<void> _handleLogout() async {
//     final bool? confirm = await showDialog<bool>(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Déconnexion'),
//           content: const Text('Voulez-vous vraiment vous déconnecter ?'),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(false),
//               child: const Text('Annuler'),
//             ),
//             ElevatedButton(
//               onPressed: () => Navigator.of(context).pop(true),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFFF28C38),
//               ),
//               child: const Text('Déconnexion'),
//             ),
//           ],
//         );
//       },
//     );

//     if (confirm == true && mounted) {
//       try {
//         final apiService = Provider.of<ApiService>(context, listen: false);
//         await apiService.logout();
//         if (mounted) {
//           Navigator.of(context).pushReplacementNamed('/login');
//         }
//       } catch (e) {
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text('Erreur lors de la déconnexion: $e'),
//               backgroundColor: Colors.red,
//             ),
//           );
//         }
//       }
//     }
//   }

//   void _editProfile() {
//     // TODO: Implémenter la navigation vers l'écran de modification du profil
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(
//         content: Text('Fonctionnalité à venir'),
//         backgroundColor: Colors.orange,
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Mon Profil'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.logout),
//             onPressed: _handleLogout,
//           ),
//         ],
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : _driver == null
//               ? const Center(child: Text('Impossible de charger le profil'))
//               : SingleChildScrollView(
//                   padding: const EdgeInsets.all(16),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // Photo de profil
//                       Center(
//                         child: CircleAvatar(
//                           radius: 50,
//                           backgroundImage: _driver!.photo_livreur != null
//                               ? NetworkImage(_driver!.photo_livreur!)
//                               : null,
//                           child: _driver!.photo_livreur == null
//                               ? const Icon(Icons.person, size: 50)
//                               : null,
//                         ),
//                       ),
//                       const SizedBox(height: 24),

//                       // Informations personnelles
//                       const Text(
//                         'Informations personnelles',
//                         style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       const SizedBox(height: 16),
//                       Column(
//                         children: [
//                           _buildInfoCard(
//                             title: 'Nom',
//                             value: '${_driver!.prenom} ${_driver!.nom}',
//                             icon: Icons.person,
//                           ),
//                           const SizedBox(height: 8),
//                           _buildInfoCard(
//                             title: 'Email',
//                             value: _driver!.email,
//                             icon: Icons.email,
//                           ),
//                           const SizedBox(height: 8),
//                           _buildInfoCard(
//                             title: 'Téléphone',
//                             value: _driver!.telephone,
//                             icon: Icons.phone,
//                           ),
//                           const SizedBox(height: 8),
//                           _buildInfoCard(
//                             title: 'Type de véhicule',
//                             value: _driver!.typeVehicule,
//                             icon: Icons.motorcycle,
//                           ),
//                           const SizedBox(height: 8),
//                           _buildInfoCard(
//                             title: 'Statut',
//                             value: _driver!.statut_livreur,
//                             icon: Icons.work,
//                           ),
//                           const SizedBox(height: 8),
//                           _buildInfoCard(
//                             title: 'Immatriculation',
//                             value: _driver!.immatriculation_moto,
//                             icon: Icons.confirmation_number,
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 24),
//                       ElevatedButton(
//                         onPressed: _editProfile,
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Theme.of(context).primaryColor,
//                           minimumSize: const Size(double.infinity, 50),
//                         ),
//                         child: const Text(
//                           'Modifier le profil',
//                           style: TextStyle(
//                             fontSize: 16,
//                             color: Colors.white,
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 24),

//                       // Véhicule
//                       const Text(
//                         'Véhicule',
//                         style: TextStyle(
//                           fontSize: 20,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       const SizedBox(height: 16),
//                     ],
//                   ),
//                 ),
//     );
//   }

//   Widget _buildInfoCard({
//     required String title,
//     required String value,
//     required IconData icon,
//   }) {
//     return Card(
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Row(
//           children: [
//             Icon(icon, color: const Color(0xFFF28C38)),
//             const SizedBox(width: 16),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     title,
//                     style: const TextStyle(
//                       color: Colors.grey,
//                       fontSize: 12,
//                     ),
//                   ),
//                   Text(
//                     value,
//                     style: const TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildStatCard({
//     required String title,
//     required String value,
//     required IconData icon,
//   }) {
//     return Card(
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             Icon(icon, color: const Color(0xFFF28C38), size: 32),
//             const SizedBox(height: 8),
//             Text(
//               value,
//               style: const TextStyle(
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 4),
//             Text(
//               title,
//               style: const TextStyle(
//                 color: Colors.grey,
//                 fontSize: 12,
//               ),
//               textAlign: TextAlign.center,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// } 