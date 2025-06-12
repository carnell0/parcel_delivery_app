import 'package:latlong2/latlong.dart';

class Delivery {
  final int id;
  final String status;
  final String lastUpdate;
  final LatLng currentLocation;
  final String? driverName;
  final String? driverPhone;
  final String? estimatedArrival;
  final String pickupAddress;
  final String deliveryAddress;

  Delivery({
    required this.id,
    required this.status,
    required this.lastUpdate,
    required this.currentLocation,
    this.driverName,
    this.driverPhone,
    this.estimatedArrival,
    required this.pickupAddress,
    required this.deliveryAddress,
  });

  factory Delivery.fromJson(Map<String, dynamic> json) {
    return Delivery(
      id: json['id'],
      status: json['status'],
      lastUpdate: json['last_update'],
      currentLocation: LatLng(
        json['current_location']['latitude'],
        json['current_location']['longitude'],
      ),
      driverName: json['driver_name'],
      driverPhone: json['driver_phone'],
      estimatedArrival: json['estimated_arrival'],
      pickupAddress: json['pickup_address'],
      deliveryAddress: json['delivery_address'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status,
      'last_update': lastUpdate,
      'current_location': {
        'latitude': currentLocation.latitude,
        'longitude': currentLocation.longitude,
      },
      'driver_name': driverName,
      'driver_phone': driverPhone,
      'estimated_arrival': estimatedArrival,
      'pickup_address': pickupAddress,
      'delivery_address': deliveryAddress,
    };
  }
}