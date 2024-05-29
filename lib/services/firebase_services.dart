import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class FirestoreService {
  // final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // double _calculateDistance(LatLng start, LatLng end) {
  //   const R = 6371; // Radius of the Earth in km
  //   double dLat = (end.latitude - start.latitude) * (pi / 180);
  //   double dLon = (end.longitude - start.longitude) * (pi / 180);
  //   double a = sin(dLat / 2) * sin(dLat / 2) +
  //              cos(start.latitude * (pi / 180)) * cos(end.latitude * (pi / 180)) *
  //              sin(dLon / 2) * sin(dLon / 2);
  //   double c = 2 * atan2(sqrt(a), sqrt(1 - a));
  //   return R * c;
  // }

  // Future<List<DocumentSnapshot>> getNearbyDrivers(LatLng clientLocation, double radius) async {
  //   QuerySnapshot driversSnapshot = await _firestore.collection('Drivers').get();
  //   List<DocumentSnapshot> nearbyDrivers = [];

  //   for (var doc in driversSnapshot.docs) {
  //     Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
  //     GeoPoint pos = data['currentLocation'];
  //     LatLng driverLocation = LatLng(pos.latitude, pos.longitude);
  //     double distance = _calculateDistance(clientLocation, driverLocation);
  //     if (distance <= radius) {
  //       nearbyDrivers.add(doc);
  //     }
  //   }
  //   return nearbyDrivers;
  // }



final firestore = FirebaseFirestore.instance;
final geo = GeoFlutterFire();

Future<List<DocumentSnapshot>> _getNearbyDrivers(LatLng currentLatLng) async {
  GeoFirePoint center = geo.point(latitude: currentLatLng.latitude, longitude: currentLatLng.longitude);
  var collectionReference = firestore.collection('drivers');

  String field = 'currentLocation';
  double radius = 0.5; // Radius in kilometers

  Stream<List<DocumentSnapshot>> stream = geo
      .collection(collectionRef: collectionReference)
      .within(center: center, radius: radius, field: field);

  List<DocumentSnapshot> drivers = await stream.first;
  return drivers;

}
}


