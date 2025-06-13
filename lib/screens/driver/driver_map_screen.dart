// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:provider/provider.dart';
// import 'package:parcel_delivery/services/api_service.dart';
// import 'package:parcel_delivery/models/livraison.dart';

// class DriverMapScreen extends StatefulWidget {
//   const DriverMapScreen({Key? key}) : super(key: key);

//   @override
//   State<DriverMapScreen> createState() => _DriverMapScreenState();
// }

// class _DriverMapScreenState extends State<DriverMapScreen> {
//   GoogleMapController? _mapController;
//   Set<Marker> _markers = {};
//   Set<Polyline> _polylines = {};
//   Position? _currentPosition;
//   List<Livraison> _activeDeliveries = [];
//   bool _isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _initializeMap();
//   }

//   Future<void> _initializeMap() async {
//     try {
//       // Vérifier les permissions de localisation
//       LocationPermission permission = await Geolocator.checkPermission();
//       if (permission == LocationPermission.denied) {
//         permission = await Geolocator.requestPermission();
//         if (permission == LocationPermission.denied) {
//           if (!mounted) return;
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text('Les permissions de localisation sont nécessaires'),
//               backgroundColor: Colors.red,
//             ),
//           );
//           return;
//         }
//       }

//       // Obtenir la position actuelle
//       _currentPosition = await Geolocator.getCurrentPosition();
      
//       // Charger les livraisons actives
//       await _loadActiveDeliveries();

//       // Mettre à jour la carte
//       _updateMap();

//       if (mounted) {
//         setState(() => _isLoading = false);
//       }
//     } catch (e) {
//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Erreur lors de l\'initialisation: $e'),
//           backgroundColor: Colors.red,
//         ),
//       );
//       setState(() => _isLoading = false);
//     }
//   }

//   Future<void> _loadActiveDeliveries() async {
//     try {
//       final apiService = Provider.of<ApiService>(context, listen: false);
//       final deliveries = await apiService.getDriverActiveDeliveries();
//       if (mounted) {
//         setState(() => _activeDeliveries = deliveries);
//         _updateMap();
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

//   void _updateMap() {
//     if (_currentPosition == null) return;

//     // Ajouter le marqueur de position actuelle
//     _markers.add(
//       Marker(
//         markerId: const MarkerId('current_position'),
//         position: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
//         icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
//         infoWindow: const InfoWindow(title: 'Ma position'),
//       ),
//     );

//     // Ajouter les marqueurs pour chaque livraison
//     for (var delivery in _activeDeliveries) {
//       if (delivery.latitudeDepart != null && delivery.longitudeDepart != null) {
//         _markers.add(
//           Marker(
//             markerId: MarkerId('start_${delivery.id}'),
//             position: LatLng(delivery.latitudeDepart!, delivery.longitudeDepart!),
//             icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
//             infoWindow: InfoWindow(
//               title: 'Point de départ',
//               snippet: delivery.adresseDepart,
//             ),
//           ),
//         );
//       }

//       if (delivery.latitudeArrivee != null && delivery.longitudeArrivee != null) {
//         _markers.add(
//           Marker(
//             markerId: MarkerId('end_${delivery.id}'),
//             position: LatLng(delivery.latitudeArrivee!, delivery.longitudeArrivee!),
//             icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
//             infoWindow: InfoWindow(
//               title: 'Point d\'arrivée',
//               snippet: delivery.adresseDestination,
//             ),
//           ),
//         );
//       }
//     }

//     // Centrer la carte sur la position actuelle
//     _mapController?.animateCamera(
//       CameraUpdate.newCameraPosition(
//         CameraPosition(
//           target: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
//           zoom: 14,
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Carte des livraisons'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.refresh),
//             onPressed: () {
//               setState(() => _isLoading = true);
//               _initializeMap();
//             },
//           ),
//         ],
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : _currentPosition == null
//               ? const Center(
//                   child: Text(
//                     'Impossible d\'obtenir votre position',
//                     style: TextStyle(color: Colors.red),
//                   ),
//                 )
//               : Stack(
//                   children: [
//                     GoogleMap(
//                       initialCameraPosition: CameraPosition(
//                         target: LatLng(
//                           _currentPosition!.latitude,
//                           _currentPosition!.longitude,
//                         ),
//                         zoom: 14,
//                       ),
//                       onMapCreated: (controller) {
//                         _mapController = controller;
//                         _updateMap();
//                       },
//                       markers: _markers,
//                       polylines: _polylines,
//                       myLocationEnabled: true,
//                       myLocationButtonEnabled: true,
//                     ),
//                     if (_activeDeliveries.isNotEmpty)
//                       Positioned(
//                         bottom: 16,
//                         left: 16,
//                         right: 16,
//                         child: Card(
//                           child: Padding(
//                             padding: const EdgeInsets.all(8.0),
//                             child: Column(
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 const Text(
//                                   'Livraisons en cours',
//                                   style: TextStyle(
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                                 const SizedBox(height: 8),
//                                 ..._activeDeliveries.map((delivery) {
//                                   return ListTile(
//                                     title: Text('Livraison #${delivery.id}'),
//                                     subtitle: Text(delivery.adresseDestination),
//                                     trailing: IconButton(
//                                       icon: const Icon(Icons.directions),
//                                       onPressed: () {
//                                         // Ouvrir Google Maps avec l'itinéraire
//                                         // TODO: Implémenter l'ouverture de Google Maps
//                                       },
//                                     ),
//                                   );
//                                 }).toList(),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//                   ],
//                 ),
//     );
//   }

//   @override
//   void dispose() {
//     _mapController?.dispose();
//     super.dispose();
//   }
// } 