import 'dart:ffi';
import 'dart:io';
import 'dart:math';

import 'package:cargo_app/auth/about.dart';
import 'package:cargo_app/auth/account.dart';
import 'package:cargo_app/auth/driver_info.dart';
import 'package:cargo_app/auth/history.dart';
import 'package:cargo_app/auth/location_search.dart';
import 'package:cargo_app/models/driver.dart';
import 'package:cargo_app/nonAuth/login.dart';
import 'package:cargo_app/services/firebase_services.dart';
import 'package:cargo_app/services/provider.dart';
import 'package:cargo_app/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/services.dart' show PlatformException, rootBundle;
// import 'package:location/location.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:async';

import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
// import 'package:google_place/google_place.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late String _mapStyle;
  bool isDrawerOpen = false;
  late GoogleMapController _mapController;
  final _destinationController = TextEditingController();
  final _currentLocationController = TextEditingController();
  bool isPackageDetailsFilled = false;
  int _selectedIndex = 0;
  String? _selectedOption = "1 - 0.9";
  bool isPhotoTaken = false;
  bool isLoading = false;
  String? _destination;
  LatLng? _selectedLocation;
  late Position _currentPosition;
  LatLng? _currentLatLng;
  static const maxSeconds = 60;
  int currentSeconds = maxSeconds;
  Timer? _timer;

  final CollectionReference driversCollection =
      FirebaseFirestore.instance.collection('Drivers');
  final geo = GeoFlutterFire();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirestoreService _firestoreService = FirestoreService();
  List<Marker> _markers = [];
  List<String> _driverIds = [];
  final double estimatedPrice = 5000.0;

  String requestdocId = "";

  List<String> packageTypeList = [
    "Clothes",
    "Glass",
    "Funicture",
    "Electronics",
    "Other"
  ];

  _selectPackageType(index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  File? image;
  Future pickImage() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.camera);
      if (image == null) return;
      final imageTemp = File(image.path);
      setState(() => this.image = imageTemp);
    } on PlatformException catch (e) {
      print('Failed to pick image: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _determinePosition();
    rootBundle.loadString('assets/map_style.txt').then((string) {
      _mapStyle = string;
    });
    // startTimer();
    if (_currentLatLng != null) {
      _loadData(_currentLatLng!);
    }
    _loadDriverIds();
  }

  Future<void> _getLatLngFromAddress(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        setState(() {
          _selectedLocation =
              LatLng(locations[0].latitude, locations[0].longitude);
        });
      }
    } catch (e) {
      print('Error occurred while converting address to LatLng: $e');
    }
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

    // Geolocator.getPositionStream(
    //   locationSettings: const LocationSettings(
    //     accuracy: LocationAccuracy.high,
    //     distanceFilter: 10,
    //   ),
    // ).listen((Position position) async {
    //   if (position.accuracy <= 20) {
    //     // Filtering out positions with low accuracy
    //     setState(() {
    //       _currentPosition = position;
    //       _currentLatLng = LatLng(position.latitude, position.longitude);
    //     });
    //     _mapController.animateCamera(
    //       CameraUpdate.newCameraPosition(
    //         CameraPosition(
    //           target: _currentLatLng!,
    //           zoom: 15.0,
    //         ),
    //       ),
    //     );
    //   }
    // });
  }

  // Future<void> _getNearbyDrivers(LatLng currentLatLng) async {
  //   GeoFirePoint center = geo.point(
  //       latitude: currentLatLng.latitude, longitude: currentLatLng.longitude);
  //   var collectionReference = _firestore.collection('Drivers');

  //   String field = 'currentLocation';
  //   double radius = 50; // Adjust the radius as needed

  //   Stream<List<DocumentSnapshot>> stream = geo
  //       .collection(collectionRef: collectionReference)
  //       .within(center: center, radius: radius, field: field);

  //   List<DocumentSnapshot> drivers = await stream.first;

  //   setState(() {
  //     _markers = drivers.map((driver) {
  //       GeoPoint geoPoint = driver['currentLocation'];
  //       return Marker(
  //         markerId: MarkerId(driver.id),
  //         position: LatLng(geoPoint.latitude, geoPoint.longitude),
  //         infoWindow: InfoWindow(title: 'Driver', snippet: driver['username']),
  //       );
  //     }).toList();
  //   });
  // }

  void toggleDrawer() {
    setState(() {
      isDrawerOpen = !isDrawerOpen;
    });
  }

  Future<DocumentSnapshot> getDocument() async {
    var firebaseUser = await FirebaseAuth.instance.currentUser!;
    return FirebaseFirestore.instance
        .collection("clients")
        .doc(firebaseUser.uid)
        .get();
  }

  Future<void> sendRequest(
      BuildContext context,
      String userId,
      String packageType,
      String packageSize,
      String pictureUrl,
      LatLng currentLocation,
      String destination,
      List<String> drivers,
      double price) async {
    try {
      setState(() {
        isLoading = true;
      });
      // final Geoflutterfire _geo = Geoflutterfire();
      await FirebaseFirestore.instance.collection('Requests').add({
        'userId': userId,
        'packageType': packageType,
        'packageSize': packageSize,
        'pictureUrl': pictureUrl,
        'currentLocation': {
          'latitude': currentLocation.latitude,
          'longitude': currentLocation.longitude,
        },
        'destination': destination, // Empty for now
        'driverId': drivers,
        'estimatedPrice': price,
        'isPickedUp': false,
        'requestTime': Timestamp.now(),
      }).then((value) => {requestdocId = value.id});
      setState(() {
        isPackageDetailsFilled = true;
        isLoading = false;
      });
    } catch (e) {
      print("Error saving pickup request: $e");
    }
  }

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (currentSeconds > 0) {
          currentSeconds--;
        } else {
          _timer?.cancel();
        }
      });
    });
  }

//////////////////////////////////////////////////////

  Future<void> _loadDriverIds() async {
    List<String> driverIds = await fetchAllDriverIds();
    setState(() {
      _driverIds = driverIds;
    });
  }

  Future<List<String>> fetchAllDriverIds() async {
    List<String> driverIds = [];
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('Drivers').get();

    for (var document in snapshot.docs) {
      driverIds.add(document.id);
    }

    return driverIds;
  }

  void _loadData(LatLng currentLatLng) async {
    List<DocumentSnapshot> drivers = await _getNearbyDrivers(currentLatLng);

    setState(() {
      _markers = drivers.map((driver) {
        GeoPoint geoPoint = driver['currentLocation'];
        return Marker(
          markerId: MarkerId(driver.id),
          position: LatLng(geoPoint.latitude, geoPoint.longitude),
          infoWindow: InfoWindow(title: 'Driver', snippet: driver['username']),
        );
      }).toList();
    });
  }

// final geo = GeoFlutterFire();

  Future<List<DocumentSnapshot>> _getNearbyDrivers(LatLng currentLatLng) async {
    GeoFirePoint center = geo.point(
        latitude: currentLatLng.latitude, longitude: currentLatLng.longitude);
    var collectionReference = _firestore.collection('Drivers');

    String field = 'currentLocation';
    double radius = 0.5; // Radius in kilometers

    Stream<List<DocumentSnapshot>> stream = geo
        .collection(collectionRef: collectionReference)
        .within(center: center, radius: radius, field: field);

    List<DocumentSnapshot> drivers = await stream.first;
    return drivers;
  }

/////////////////////////////////////////////////////

  @override
  void dispose() {
    _timer?.cancel();
    _mapController.dispose();
    _determinePosition();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String userId = Provider.of<UserProvider>(context, listen: false).userId;
    String distination =
        Provider.of<DestinationProvider>(context, listen: false).destination;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        actions: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Icon(Icons.notifications),
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: Colors.white,
        child: SafeArea(
          child: Column(
            children: <Widget>[
              Container(
                height: 100.0,
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                decoration: const BoxDecoration(
                  color: Colors.white,
                ),
                child: FutureBuilder(
                  future: getDocument(),
                  builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const CircleAvatar(
                            radius: 26,
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(snapshot.data!['username']),
                                Text("+255" + snapshot.data?['phone'])
                              ],
                            ),
                          ),
                        ],
                      );
                    } else if (snapshot.connectionState ==
                        ConnectionState.none) {
                      return const Text("No data");
                    }
                    return const Center(child: CircularProgressIndicator());
                  },
                ),
              ),
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('My Account'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AccountPage(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.lock_clock),
                title: const Text('My Rides'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RidesHistoryPage(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.info),
                title: const Text('About'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AboutPage(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          _currentLatLng == null
              ? const Center(child: CircularProgressIndicator())
              : GoogleMap(
                  mapType: MapType.normal,

                  onMapCreated: (GoogleMapController controller) {
                    _mapController = controller;
                    controller.setMapStyle(_mapStyle);
                    _mapController.animateCamera(
                        CameraUpdate.newCameraPosition(CameraPosition(
                      target: _currentLatLng ?? const LatLng(0, 0),
                      zoom: 16.0,
                    )));
                  },
                  initialCameraPosition: CameraPosition(
                    target: _currentLatLng ?? const LatLng(0, 0),
                    zoom: 16.0,
                  ),
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  markers: Set<Marker>.of(_markers),
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
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 18.0),
            child: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  //   crossAxisAlignment: CrossAxisAlignment.start,
                  //   children: [
                  //     // MenuButton(
                  //     //   icon: Icons.menu,
                  //     //   ontap: () {
                  //     //     toggleDrawer();
                  //     //   },
                  //     // ),
                  //     (isPackageDetailsFilled)
                  //         ? Column(
                  //             children: [
                  //               // LocationInputField(
                  //               //   controller: _currentLocationController,
                  //               //   title: "Pickup location",
                  //               // ),
                  //               Container(
                  //                 width:
                  //                     MediaQuery.of(context).size.width / 1.2,
                  //                 height: 50.0,
                  //                 padding: const EdgeInsets.symmetric(
                  //                     horizontal: 10),
                  //                 decoration: BoxDecoration(
                  //                   color: Colors.white,
                  //                   border: Border.all(
                  //                     width: 1,
                  //                     color: const Color.fromARGB(
                  //                         255, 170, 170, 170),
                  //                   ),
                  //                   borderRadius: const BorderRadius.all(
                  //                       Radius.circular(4)),
                  //                 ),
                  //                 child: const Row(
                  //                   children: [
                  //                     Icon(Icons.navigation),
                  //                     Padding(
                  //                       padding: EdgeInsets.symmetric(
                  //                           horizontal: 10.0),
                  //                       child: Text("Current location"),
                  //                     )
                  //                   ],
                  //                 ),
                  //               ),
                  //               const SizedBox(
                  //                 height: 7.0,
                  //               ),
                  //               LocationInputField(
                  //                 controller: _destinationController,
                  //                 title: _destination ?? "Destination",
                  //                 ontap: () async {
                  //                   final result = await Navigator.push(
                  //                     context,
                  //                     MaterialPageRoute(
                  //                         builder: (context) => SearchPage()),
                  //                   );

                  //                   if (result != null && result is String) {
                  //                     _getLatLngFromAddress(result);
                  //                     setState(() {
                  //                       _destination = result;
                  //                     });
                  //                   }
                  //                 },
                  //               ),
                  //               // GestureDetector(
                  //               //   onTap: () {
                  //               // Navigator.push(
                  //               //   context,
                  //               //   MaterialPageRoute(
                  //               //     builder: (context) => SearchPage(),
                  //               //   ),
                  //               // );
                  //               //   },
                  //               //   child: Container(
                  //               //     width:
                  //               //         MediaQuery.of(context).size.width / 1.2,
                  //               //     height: 50.0,
                  //               //     padding: const EdgeInsets.symmetric(
                  //               //         horizontal: 10),
                  //               //     decoration: BoxDecoration(
                  //               //       color: Colors.white,
                  //               //       border: Border.all(
                  //               //         width: 1,
                  //               //         color: const Color.fromARGB(
                  //               //             255, 170, 170, 170),
                  //               //       ),
                  //               //       borderRadius: const BorderRadius.all(
                  //               //           Radius.circular(4)),
                  //               //     ),
                  //               //     child: const Row(
                  //               //       children: [
                  //               //         Icon(Icons.navigation),
                  //               //         Padding(
                  //               //           padding: EdgeInsets.symmetric(
                  //               //               horizontal: 10.0),
                  //               //           child: Text("Destination"),
                  //               //         )
                  //               //       ],
                  //               //     ),
                  //               //   ),
                  //               // ),
                  //               const SizedBox(
                  //                 height: 7.0,
                  //               ),
                  //             ],
                  //           )
                  //         : Container(),
                  //   ],
                  // ),

                  (isPackageDetailsFilled)
                      ? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(8.0),
                            height: 160,
                            decoration:
                                const BoxDecoration(color: Colors.white),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text("Request is sent please wait..."),
                                SizedBox(
                                  width: 50,
                                  height: 50,
                                  child: CircularProgressIndicator(
                                    value: (maxSeconds - currentSeconds) /
                                        maxSeconds,
                                    strokeWidth: 6,
                                  ),
                                ),
                                MaterialButton(
                                    elevation: 0,
                                    minWidth: double.infinity,
                                    height: 45,
                                    child: const Text("Cancel Initial Request"),
                                    color: Colors.blue,
                                    textColor: Colors.white,
                                    onPressed: () {
                                      setState(() {
                                        isPackageDetailsFilled = false;
                                      });
                                    }),
                              ],
                            ),
                          ),
                        )
                      : const Center(),
//****************************************************************
                  (_destination != "")
                      ? SizedBox(
                          width: double.infinity,
                          height: 150,
                          child: StreamBuilder<Object>(
                              stream: driversCollection.snapshots(),
                              builder: (context, snapshot) {
                                if (snapshot.hasError) {
                                  return Center(
                                      child: Text('Error: ${snapshot.error}'));
                                }
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                }

                                if (!snapshot.hasData ||
                                    snapshot.data == null) {
                                  return const Center(
                                      child: Text('No data available'));
                                }

                                // Explicitly cast snapshot.data to QuerySnapshot
                                final QuerySnapshot querySnapshot =
                                    snapshot.data as QuerySnapshot;

                                final drivers = querySnapshot.docs.map((doc) {
                                  return Driver.fromDocument(doc);
                                }).toList();
                                return ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: drivers.length,
                                  itemBuilder: (context, index) {
                                    return DriverCard(
                                      truckSize: drivers[index].truckSize,
                                      estimatedPrice: estimatedPrice,
                                      truckType: drivers[index].truckType,
                                      isLoading: isLoading,
                                      onpress: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                DriverInfoPage(
                                                    id: drivers[index]
                                                        .driverId),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                );
                              }),
                        )
                      : const SizedBox(),
                ],
              ),
            ),
          ),
          Expanded(
            child: (!isPackageDetailsFilled)
                ? DraggableScrollableSheet(
                    initialChildSize:
                        0.3, // Initial size of the sheet (30% of the screen)
                    minChildSize:
                        0.2, // Minimum size of the sheet (10% of the screen)
                    maxChildSize:
                        0.8, // Maximum size of the sheet (80% of the screen)
                    builder: (BuildContext context,
                        ScrollController scrollController) {
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(15),
                          ),
                        ),
                        child: SingleChildScrollView(
                          controller: scrollController,
                          child: Column(
                            children: [
                              Align(
                                child: Container(
                                  width: 100,
                                  height: 7,
                                  decoration: const BoxDecoration(
                                    color: Colors.grey,
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(10),
                                    ),
                                  ),
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(
                                    height: 16,
                                  ),
                                  GestureDetector(
                                    onTap: () async {
                                      final result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => SearchPage()),
                                      );

                                      if (result != null && result is String) {
                                        _getLatLngFromAddress(result);
                                        setState(() {
                                          _destination = result;
                                        });
                                      }
                                    },
                                    child: Container(
                                      width: double.infinity,
                                      height: 70,
                                      decoration: BoxDecoration(
                                        color: const Color.fromARGB(
                                            31, 204, 204, 204),
                                        borderRadius: const BorderRadius.all(
                                          Radius.circular(10),
                                        ),
                                        border: Border.all(
                                            width: 2,
                                            color: const Color.fromARGB(
                                                255, 205, 205, 206)),
                                      ),
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Row(
                                          children: [
                                            const Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child: Icon(
                                                Icons.search,
                                                size: 32,
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 3.0),
                                              child: Text(
                                                _destination ?? "Where to?",
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color.fromARGB(
                                                      255, 71, 71, 71),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 16,
                                  ),
                                  const Text(
                                    "Package type",
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(
                                    height: 16,
                                  ),
                                  Container(
                                    width: double.infinity,
                                    height: 48,
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: packageTypeList.length,
                                      itemBuilder: (context, index) {
                                        return PackageType(
                                          title: packageTypeList[index],
                                          ontap: () {
                                            _selectPackageType(index);
                                          },
                                          index: index,
                                          selectedIndex: _selectedIndex,
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 16,
                                  ),
                                  const Text(
                                    "Package Size",
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Radio<String>(
                                            value: '1 - 0.9',
                                            groupValue: _selectedOption,
                                            onChanged: (String? value) {
                                              setState(() {
                                                _selectedOption = value;
                                              });
                                            },
                                          ),
                                          const Row(
                                            children: [
                                              Text(
                                                "[Bajaj] ",
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              Text('1 - 999 Kg'),
                                            ],
                                          ),
                                        ],
                                      ),
                                      // Radio button for option B
                                      Row(
                                        children: [
                                          Radio<String>(
                                            value: '1 - 3',
                                            groupValue: _selectedOption,
                                            onChanged: (String? value) {
                                              setState(() {
                                                _selectedOption = value;
                                              });
                                            },
                                          ),
                                          const Row(
                                            children: [
                                              Text(
                                                '[Kirikuu] ',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              Text('1 - 3 Ton'),
                                            ],
                                          ),
                                        ],
                                      ),
                                      // Radio button for option C
                                      Row(
                                        children: [
                                          Radio<String>(
                                            value: '4 - 7',
                                            groupValue: _selectedOption,
                                            onChanged: (String? value) {
                                              setState(() {
                                                _selectedOption = value;
                                              });
                                            },
                                          ),
                                          const Row(
                                            children: [
                                              Text(
                                                '[Canter] ',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              Text('4 - 7 Ton'),
                                            ],
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Radio<String>(
                                            value: 'other',
                                            groupValue: _selectedOption,
                                            onChanged: (String? value) {
                                              setState(() {
                                                _selectedOption = value;
                                              });
                                            },
                                          ),
                                          const Text('other'),
                                        ],
                                      ),
                                      (_selectedOption == "other")
                                          ? const TextField(
                                              decoration: InputDecoration(
                                                  hintText: "specify size"),
                                            )
                                          : Container(),
                                    ],
                                  ),
                                  const Divider(),
                                  const SizedBox(
                                    height: 6.0,
                                  ),
                                  InkWell(
                                    onTap: () {
                                      pickImage();
                                    },
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          width: 90,
                                          height: 37,
                                          decoration: BoxDecoration(
                                              // color: Colors.blue,
                                              border: Border.all(
                                                  width: 2,
                                                  color: Colors.blue)),
                                          child: const Icon(Icons.camera),
                                        ),
                                        (image == null)
                                            ? const Text("Take package picture")
                                            : const Text(
                                                "Retake package picture")
                                      ],
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 5.0,
                                  ),
                                  SizedBox(
                                    width: double.infinity,
                                    // height: 200,
                                    child: image != null
                                        ? Image.file(image!)
                                        : const Text('No image selected.'),
                                  ),
                                  const Divider(),
                                  const SizedBox(
                                    height: 5.0,
                                  ),
                                  Align(
                                    alignment: Alignment.bottomCenter,
                                    child: (!isPhotoTaken)
                                        ? MaterialButton(
                                            minWidth: double.infinity,
                                            height: 50,
                                            elevation: 0,
                                            color: Colors.blue,
                                            onPressed: () async {
                                              if (userId != "") {
                                                if (_destination != null) {
                                                  if (image != null) {
                                                    setState(() {
                                                      isLoading = true;
                                                    });
                                                    var imgUrl = "";
                                                    final storageRef =
                                                        FirebaseStorage.instance
                                                            .ref();
                                                    final imagesRef =
                                                        storageRef.child(
                                                            "images/${DateTime.now().millisecondsSinceEpoch}.png");
                                                    final uploadTask = imagesRef
                                                        .putFile(image!);
                                                    await uploadTask
                                                        .whenComplete(() async {
                                                      imgUrl = await imagesRef
                                                          .getDownloadURL();
                                                    });

                                                    if (imgUrl != "") {
                                                      sendRequest(
                                                        context,
                                                        userId,
                                                        packageTypeList[
                                                            _selectedIndex],
                                                        _selectedOption!,
                                                        imgUrl,
                                                        _currentLatLng!,
                                                        _destination!,
                                                        _driverIds,
                                                        estimatedPrice,
                                                      );
                                                    } else {
                                                      _showToast(
                                                        context,
                                                        "retry to add package photo",
                                                      );
                                                    }
                                                  } else {
                                                    _showToast(
                                                      context,
                                                      "Add package photo to continue",
                                                    );
                                                  }
                                                } else {
                                                  _showToast(
                                                    context,
                                                    "Add destination please",
                                                  );
                                                }
                                              } else {
                                                auth.signOutUser();
                                              }
                                            },
                                            child: (!isLoading)
                                                ? const Text(
                                                    "Continue",
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  )
                                                : const CircularProgressIndicator(
                                                    color: Colors.white,
                                                  ),
                                          )
                                        : Container(),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  )
                : Container(),
          ),
        ],
      ),
    );
  }

  void _showToast(BuildContext context, String message) {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      SnackBar(
        content: Text(message),
        action: SnackBarAction(
            label: 'UNDO', onPressed: scaffold.hideCurrentSnackBar),
      ),
    );
  }
}

class PackageType extends StatelessWidget {
  final String title;
  final Function()? ontap;
  final int index;
  final int selectedIndex;
  const PackageType(
      {super.key,
      required this.title,
      required this.ontap,
      required this.index,
      required this.selectedIndex});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ontap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5),
        padding: const EdgeInsets.symmetric(horizontal: 15),
        // width: 130,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          border: (index == selectedIndex)
              ? Border.all(width: 2, color: Colors.blue)
              : Border.all(width: 1, color: Colors.black12),
          borderRadius: const BorderRadius.all(
            Radius.circular(10),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
