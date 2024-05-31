import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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
      currentLocation: data['currentLocation'] as GeoPoint,
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



// StreamBuilder<Object>(
//                               stream: driversCollection.snapshots(),
//                               builder: (context, snapshot) {
//                                 if (snapshot.hasError) {
//                                   return Center(
//                                       child: Text('Error: ${snapshot.error}'));
//                                 }
//                                 if (snapshot.connectionState ==
//                                     ConnectionState.waiting) {
//                                   return const Center(
//                                       child: CircularProgressIndicator());
//                                 }

//                                 if (!snapshot.hasData ||
//                                     snapshot.data == null) {
//                                   return const Center(
//                                       child: Text('No data available'));
//                                 }

//                                 // Explicitly cast snapshot.data to QuerySnapshot
//                                 final QuerySnapshot querySnapshot =
//                                     snapshot.data as QuerySnapshot;

//                                 final drivers = querySnapshot.docs.map((doc) {
//                                   return Driver.fromDocument(doc);
//                                 }).toList();
//                                 return ListView.builder(
//                                   scrollDirection: Axis.horizontal,
//                                   itemCount: drivers.length,
//                                   itemBuilder: (context, index) {
//                                     return DriverCard(
//                                       truckSize: drivers[index].truckSize,
//                                       estimatedPrice: estimatedPrice,
//                                       truckType: drivers[index].truckType,
//                                       isLoading: isLoading,
//                                       onpress: () {
//                                         Navigator.push(
//                                           context,
//                                           MaterialPageRoute(
//                                             builder: (context) =>
//                                                 DriverInfoPage(
//                                                     id: drivers[index]
//                                                         .driverId),
//                                           ),
//                                         );
//                                       },
//                                     );
//                                   },
//                                 );
//                               }),