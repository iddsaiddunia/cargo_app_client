import 'package:cargo_app/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DriverInfoPage extends StatefulWidget {
  final String id;
  const DriverInfoPage({super.key, required this.id});

  @override
  State<DriverInfoPage> createState() => _DriverInfoPageState();
}

class _DriverInfoPageState extends State<DriverInfoPage> {
  late String _mapStyle;
  late GoogleMapController? _controller;
  late Position _currentPosition;
  LatLng? _currentLatLng;
  late GoogleMapController _mapController;

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
      }
    });
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
                      // markers: _destination != null
                      //     ? {
                      //         Marker(
                      //           markerId: MarkerId('destination'),
                      //           position: _destination,
                      //         ),
                      //       }
                      //     : {},
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
                              Container(
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
                          Container(
                            width: 200.0,
                            height: 45,
                            margin: EdgeInsets.symmetric(vertical: 30.0),
                            decoration: const BoxDecoration(
                              color: Color.fromARGB(255, 82, 82, 82),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5)),
                            ),
                            child: const Center(
                              child: Text(
                                "Cancel Pickup",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
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
}
