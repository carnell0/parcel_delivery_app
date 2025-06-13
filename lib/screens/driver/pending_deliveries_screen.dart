// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:parcel_delivery/services/api_service.dart';
// import 'package:parcel_delivery/models/livraison.dart';

// class PendingDeliveriesScreen extends StatefulWidget {
//   const PendingDeliveriesScreen({Key? key}) : super(key: key);

//   @override
//   State<PendingDeliveriesScreen> createState() => _PendingDeliveriesScreenState();
// }

// class _PendingDeliveriesScreenState extends State<PendingDeliveriesScreen> {
//   List<Livraison> pendingDeliveries = [];
//   bool isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _loadPendingDeliveries();
//   }

//   Future<void> _loadPendingDeliveries() async {
//     try {
//       final apiService = Provider.of<ApiService>(context, listen: false);
//       final deliveries = await apiService.getDriverPendingDeliveries();
//       if (mounted) {
//         setState(() => pendingDeliveries = deliveries);
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(e.toString()),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     }
//   }

//   Future<void> _acceptDelivery(int deliveryId) async {
//     try {
//       final position = await Geolocator.getCurrentPosition();
//       final apiService = Provider.of<ApiService>(context, listen: false);
//       await apiService.acceptDriverDelivery(
//         deliveryId: deliveryId,
//         position: position,
//       );
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Livraison acceptée avec succès'),
//             backgroundColor: Colors.green,
//           ),
//         );
//         _loadPendingDeliveries();
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(e.toString()),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Livraisons en attente'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.refresh),
//             onPressed: _loadPendingDeliveries,
//           ),
//         ],
//       ),
//       body: isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : pendingDeliveries.isEmpty
//               ? const Center(child: Text('Aucune livraison en attente'))
//               : ListView.builder(
//                   padding: const EdgeInsets.all(16),
//                   itemCount: pendingDeliveries.length,
//                   itemBuilder: (context, index) {
//                     final delivery = pendingDeliveries[index];
//                     return Card(
//                       margin: const EdgeInsets.only(bottom: 16),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(15),
//                       ),
//                       child: Padding(
//                         padding: const EdgeInsets.all(16),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 Text(
//                                   'Livraison #${delivery.id}',
//                                   style: const TextStyle(
//                                     fontSize: 18,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                                 Container(
//                                   padding: const EdgeInsets.symmetric(
//                                     horizontal: 12,
//                                     vertical: 6,
//                                   ),
//                                   decoration: BoxDecoration(
//                                     color: const Color(0xFFF28C38).withOpacity(0.1),
//                                     borderRadius: BorderRadius.circular(20),
//                                   ),
//                                   child: const Text(
//                                     'En attente',
//                                     style: TextStyle(
//                                       color: Color(0xFFF28C38),
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             const SizedBox(height: 16),
//                             _buildInfoRow(
//                               icon: Icons.location_on,
//                               title: 'Point de départ',
//                               value: delivery.adresseDepart,
//                             ),
//                             const SizedBox(height: 8),
//                             _buildInfoRow(
//                               icon: Icons.location_on,
//                               title: 'Destination',
//                               value: delivery.adresseDestination,
//                             ),
//                             const SizedBox(height: 8),
//                             _buildInfoRow(
//                               icon: Icons.route,
//                               title: 'Distance estimée',
//                               value: '${delivery.distance} km',
//                             ),
//                             const SizedBox(height: 8),
//                             _buildInfoRow(
//                               icon: Icons.euro,
//                               title: 'Prix',
//                               value: '${delivery.prix} €',
//                             ),
//                             const SizedBox(height: 16),
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 TextButton.icon(
//                                   onPressed: () {
//                                     // TODO: Afficher la carte avec l'itinéraire
//                                   },
//                                   icon: const Icon(Icons.map),
//                                   label: const Text('Voir sur la carte'),
//                                 ),
//                                 ElevatedButton(
//                                   onPressed: () => _acceptDelivery(delivery.id),
//                                   style: ElevatedButton.styleFrom(
//                                     backgroundColor: const Color(0xFFF28C38),
//                                     padding: const EdgeInsets.symmetric(
//                                       horizontal: 24,
//                                       vertical: 12,
//                                     ),
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(30),
//                                     ),
//                                   ),
//                                   child: const Text('Accepter'),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//     );
//   }

//   Widget _buildInfoRow({
//     required IconData icon,
//     required String title,
//     required String value,
//   }) {
//     return Row(
//       children: [
//         Icon(icon, size: 20, color: Colors.grey),
//         const SizedBox(width: 8),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 title,
//                 style: const TextStyle(
//                   color: Colors.grey,
//                   fontSize: 12,
//                 ),
//               ),
//               Text(
//                 value,
//                 style: const TextStyle(
//                   fontSize: 14,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// } 