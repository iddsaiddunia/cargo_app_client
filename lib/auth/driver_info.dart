import 'dart:convert';

import 'package:cargo_app/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class DriverInfoPage extends StatefulWidget {
  final String id;
  final String requestId;
  final LatLng destination;
  const DriverInfoPage({
    super.key,
    required this.id,
    required this.requestId,
    required this.destination,
  });

  @override
  State<DriverInfoPage> createState() => _DriverInfoPageState();
}

class _DriverInfoPageState extends State<DriverInfoPage> {
  late String _mapStyle;
  late GoogleMapController? _controller;
  late Position _currentPosition;
  LatLng? _currentLatLng;
  late GoogleMapController _mapController;
  bool _isPickedUp = false;
  final Set<Marker> _markers = {};
  final String apiKey =
      'AIzaSyAjsJbodhou5nNntMWPdhRsWqz2h1Tgzoc'; // Replace with your API key
  Set<Polyline> _polylines = {};
  final PolylinePoints _polylinePoints = PolylinePoints();

  @override
  void initState() {
    super.initState();
    _determinePosition();
    GoogleMapController _mapController;
    rootBundle.loadString('assets/map_style.txt').then((string) {
      _mapStyle = string;
    });
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    print("${widget.destination} -----<<<");
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      _currentPosition = position;
      _currentLatLng = LatLng(position.latitude, position.longitude);
    });

    Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((Position position) {
      if (position.accuracy <= 20) {
        // Filtering out positions with low accuracy
        setState(() {
          _currentPosition = position;
          _currentLatLng = LatLng(position.latitude, position.longitude);
        });
        _mapController
            .animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
          target: _currentLatLng!,
          zoom: 15.0,
        )));

        _drawRoute(_currentLatLng!, widget.destination);
      }
    });
  }

  Future<void> updateRequestPickupStatus(String requestId) async {
    try {
      // Reference to the specific request document
      DocumentReference requestDocRef =
          FirebaseFirestore.instance.collection('Requests').doc(requestId);

      // Update the isPickedUp field to true
      await requestDocRef.update({
        'isPickedUp': true,
      });

      print('Request updated successfully.');
    } catch (e) {
      print('Failed to update request: $e');
    }
  }

  Future<void> _drawRoute(LatLng start, LatLng end) async {
    final String url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${start.latitude},${start.longitude}&destination=${end.latitude},${end.longitude}&key=$apiKey';

    final response = await http.get(Uri.parse(url));
    final data = json.decode(response.body);

    if (data['status'] == 'OK') {
      final polylinePoints = data['routes'][0]['overview_polyline']['points'];

      List<PointLatLng> result = _polylinePoints.decodePolyline(polylinePoints);

      setState(() {
        _polylines.add(Polyline(
          polylineId: PolylineId('route'),
          points: result
              .map((point) => LatLng(point.latitude, point.longitude))
              .toList(),
          color: Colors.blue,
          width: 5,
        ));
      });
    } else {
      print('Failed to load directions');
    }
  }

  void _showPhonePopup(BuildContext context, String phoneNumber) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Phone Number'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(phoneNumber),
              SizedBox(height: 10),
              // ElevatedButton(
              //   onPressed: () {
              //     Clipboard.setData(ClipboardData(text: phoneNumber));
              //     ScaffoldMessenger.of(context).showSnackBar(
              //       SnackBar(
              //         content: Text('Phone number copied to clipboard'),
              //       ),
              //     );
              //   },
              //   child: Text('Copy Number'),
              // ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _mapController.dispose();
    _determinePosition();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        Column(
          children: [
            SizedBox(
              width: double.infinity,
              height: MediaQuery.of(context).size.height / 1.6,
              // color: Colors.red,
              child: _currentLatLng == null
                  ? Center(child: const CircularProgressIndicator())
                  : GoogleMap(
                      mapType: MapType.normal,

                      onMapCreated: (GoogleMapController controller) {
                        _mapController = controller;
                        controller.setMapStyle(_mapStyle);
                        _mapController.animateCamera(
                            CameraUpdate.newCameraPosition(CameraPosition(
                          target: _currentLatLng ?? LatLng(0, 0),
                          zoom: 16.0,
                        )));
                      },
                      initialCameraPosition: CameraPosition(
                        target: _currentLatLng ?? LatLng(0, 0),
                        zoom: 16.0,
                      ),
                      myLocationEnabled: true,
                      myLocationButtonEnabled: true,
                      polylines: _polylines,
                      markers: widget.destination != null
                          ? {
                              Marker(
                                  markerId: MarkerId('destination'),
                                  position: widget.destination,
                                  infoWindow: InfoWindow(title: "Destination")),
                            }
                          : {},
                      // polylines: _destination != null
                      //     ? {
                      //         Polyline(
                      //           polylineId: PolylineId('route'),
                      //           color: Colors.blue,
                      //           points: [
                      //             _currentPosition,
                      //             _destination,
                      //           ],
                      //         ),
                      //       }
                      //     : {},
                    ),
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                color: const Color.fromARGB(255, 245, 245, 245),
                padding: const EdgeInsets.all(20),
                child: StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('Drivers')
                        .doc(widget.id)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      if (!snapshot.hasData || !snapshot.data!.exists) {
                        return Center(
                          child: Text(widget.id),
                        );
                      }

                      var driverData =
                          snapshot.data!.data() as Map<String, dynamic>;
                      return Column(
                        children: [
                          const Text(
                            "Driver info",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 60,
                                    height: 55,
                                    padding: const EdgeInsets.all(9.0),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        width: 1,
                                        color: const Color.fromARGB(
                                            255, 150, 150, 150),
                                      ),
                                      borderRadius: const BorderRadius.all(
                                        Radius.circular(7.0),
                                      ),
                                    ),
                                    child: Image.asset(
                                      "assets/img/cargo-truck (1).png",
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 10.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(driverData["username"]),
                                        Icon(
                                          Icons.star,
                                          size: 18,
                                          color:
                                              Color.fromARGB(255, 231, 212, 42),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                              GestureDetector(
                                onTap: () {
                                  _showPhonePopup(context, driverData['phone']);
                                },
                                child: Container(
                                  width: 35,
                                  height: 35,
                                  decoration: const BoxDecoration(
                                    color: Colors.blue,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(35)),
                                  ),
                                  child: const Icon(
                                    Icons.phone,
                                    size: 18,
                                    color: Colors.white,
                                  ),
                                ),
                              )
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(driverData['truckModel']),
                                  Text(
                                    driverData['truckRegistration'],
                                    style:
                                        TextStyle(fontWeight: FontWeight.w600),
                                  )
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Arriving In"),
                                  Text(
                                    "05 Min",
                                    style:
                                        TextStyle(fontWeight: FontWeight.w600),
                                  )
                                ],
                              ),
                            ],
                          ),
                          (!_isPickedUp)
                              ? GestureDetector(
                                  onTap: () async {
                                    await updateRequestPickupStatus(
                                        widget.requestId);
                                    setState(() {
                                      _isPickedUp = true;
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            'Request pickup status updated successfully.'),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    width: 200.0,
                                    height: 45,
                                    margin:
                                        EdgeInsets.symmetric(vertical: 30.0),
                                    decoration: const BoxDecoration(
                                      color: Color.fromARGB(255, 82, 82, 82),
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(5)),
                                    ),
                                    child: const Center(
                                      child: Text(
                                        "Confirm Pickup",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                )
                              : GestureDetector(
                                  onTap: () {
                                    _showConfirmationDialog(context, true);
                                  },
                                  child: Container(
                                    width: 200.0,
                                    height: 45,
                                    margin:
                                        EdgeInsets.symmetric(vertical: 30.0),
                                    decoration: const BoxDecoration(
                                      color: Color.fromARGB(255, 82, 82, 82),
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(5)),
                                    ),
                                    child: const Center(
                                      child: Text(
                                        "Confirm Arrival",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                ),
                        ],
                      );
                    }),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 30.0, horizontal: 10),
          child: SafeArea(
            child: MenuButton(
              icon: Icons.arrow_back,
              ontap: () {
                Navigator.pop(context);
              },
            ),
          ),
        ),
      ]),
    );
  }

  Future<void> _showConfirmationDialog(
      BuildContext context, bool newStatus) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(newStatus ? 'Mark as Arrived?' : 'Mark as Not Arrived?'),
          content: Text(
            newStatus
                ? 'Are you sure you want to mark this request as arrived?'
                : 'Are you sure you want to mark this request as not arrived?',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await updateClientArrivalStatus(widget.requestId, newStatus);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      newStatus
                          ? 'Client arrival status updated to arrived.'
                          : 'Client arrival status updated to not arrived.',
                    ),
                  ),
                );
                Navigator.of(context).pop(); // Close the dialog
                Navigator.pop(context); // Navigate back after update
              },
              child: Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  Future<void> updateClientArrivalStatus(
      String requestId, bool newStatus) async {
    try {
      DocumentReference requestDocRef =
          FirebaseFirestore.instance.collection('Requests').doc(requestId);

      await requestDocRef.update({
        'clientArrivalStatus': newStatus,
      });

      print('Client arrival status updated successfully.');
    } catch (e) {
      print('Failed to update client arrival status: $e');
    }
  }
}
