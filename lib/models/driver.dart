import 'package:cloud_firestore/cloud_firestore.dart';

class Driver {
  final GeoPoint currentLocation;
  final String driverId;
  final bool isAvailable;
  final String phone;
  final int ratings;
  final String truckRegistration;
  final String truckModel;
  final double truckSize;
  final String truckType;
  final String username;

  Driver({
    required this.currentLocation,
    required this.driverId,
    required this.isAvailable,
    required this.phone,
    required this.ratings,
    required this.truckRegistration,
    required this.truckModel,
    required this.truckSize,
    required this.truckType,
    required this.username,
  });

  factory Driver.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Driver(
      currentLocation: data['currentLocation'],
      driverId: data['driverId'],
      isAvailable: data['isAvailable'],
      phone: data['phone'],
      ratings: data['ratings'],
      truckRegistration: data['truckRegistration'],
      truckModel: data['truckModel'],
      truckSize: data['truckSize'],
      truckType: data['truckType'],
      username: data['username'],
    );
  }
}
