class Colis {
  final int id;
  final int senderId;
  final String receiverEmail;
  final String receiverName;
  final String receiverAddress;
  final double weight;
  final String description;
  final String deliveryType;
  final double estimatedPrice;
  final String status;
  final Map<String, double>? position;

  Colis({
    required this.id,
    required this.senderId,
    required this.receiverEmail,
    required this.receiverName,
    required this.receiverAddress,
    required this.weight,
    required this.description,
    required this.deliveryType,
    required this.estimatedPrice,
    required this.status,
    this.position,
  });

  factory Colis.fromJson(Map<String, dynamic> json) {
    return Colis(
      id: json['id'] as int,
      senderId: json['sender_id'] as int,
      receiverEmail: json['receiver_email'] as String,
      receiverName: json['receiver_name'] as String,
      receiverAddress: json['receiver_address'] as String,
      weight: (json['weight'] as num).toDouble(),
      description: json['description'] as String,
      deliveryType: json['delivery_type'] as String,
      estimatedPrice: (json['estimated_price'] as num).toDouble(),
      status: json['status'] as String,
      position: json['position'] != null
          ? {
              'lat': (json['position']['lat'] as num).toDouble(),
              'lng': (json['position']['lng'] as num).toDouble(),
            }
          : null,
    );
  }
}