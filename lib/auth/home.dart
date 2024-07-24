import 'dart:io';
import 'dart:math' as math;
import 'dart:math';
import 'package:cargo_app/auth/about.dart';
import 'package:cargo_app/auth/account.dart';
import 'package:cargo_app/auth/driver_info.dart';
import 'package:cargo_app/auth/history.dart';
import 'package:cargo_app/auth/location_search.dart';
import 'package:cargo_app/auth/notification.dart';
import 'package:cargo_app/models/driver.dart';
import 'package:cargo_app/nonAuth/login.dart';
import 'package:cargo_app/services/firebase_services.dart';
import 'package:cargo_app/services/provider.dart';
import 'package:cargo_app/widgets.dart';
import 'package:cargo_app/wrapper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
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
  // final _destinationController = TextEditingController();
  // final _currentLocationController = TextEditingController();
  bool isPackageDetailsFilled = false;
  int _selectedIndex = 0;
  String? _selectedOption = "bajaj";
  bool isPhotoTaken = false;
  bool isLoading = false;
  double _distance = 0.0;
  String? _destination;
  LatLng? _selectedLocation = LatLng(0, 0);
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
  double estimatedPrice = 0.0;
  Map<String, Map<String, dynamic>> requestedDrivers = {};
  // late Future<List<Map<String, dynamic>>> _fetchedDri;

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

  _calculateCost() {
    if (_selectedOption == "bajaj") {
      setState(() {
        estimatedPrice = 1000 * _distance;
      });
    } else if (_selectedOption == "kirikuu") {
      setState(() {
        estimatedPrice = 1500 * _distance;
      });
    } else if (_selectedOption == "canter") {
      setState(() {
        estimatedPrice = 2500 * _distance;
      });
    }
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

  double calculateDistance(LatLng start, LatLng end) {
    const double earthRadius = 6371; // Radius of the Earth in kilometers
    final double dLat = _toRadians(end.latitude - start.latitude);
    final double dLng = _toRadians(end.longitude - start.longitude);

    final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(start.latitude)) *
            math.cos(_toRadians(end.latitude)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);

    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadius * c;
  }

  double _toRadians(double degree) {
    return degree * math.pi / 180;
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
      GeoPoint currentLocation,
      String destination,
      Map<String, dynamic> drivers,
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
        'clientCurrentLocation': currentLocation,
        'destination': destination,
        'driverPickup': false,
        'driversRequested': drivers,
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

    for (var driverId in driverIds) {
      requestedDrivers[driverId] = {'bidPrice': 0, 'isSelected': false};
    }

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

  Future<List<Map<String, dynamic>>> _mapRequestDriverData() async {
    if (_currentLatLng == null) {
      return [];
    }

    // Fetch drivers from Drivers collection
    QuerySnapshot driverSnapshot =
        await FirebaseFirestore.instance.collection('Drivers').get();

    // Fetch the most recent request from Requests collection
    QuerySnapshot requestSnapshot = await FirebaseFirestore.instance
        .collection('Requests')
        .orderBy('requestTime', descending: true)
        .limit(1)
        .get();

    if (requestSnapshot.docs.isEmpty) {
      return [];
    }

    var requestDoc = requestSnapshot.docs.first;

    // Extract the driversRequested map from the most recent request document
    Map<String, dynamic> driversRequested = requestDoc['driversRequested'];

    // Create a map to store bidPrice for each driverId
    Map<String, double> driverBidPrices = {};

    // Filter driver data and combine with bid prices
    List<Map<String, dynamic>> combinedData = [];
    for (var driverDoc in driverSnapshot.docs) {
      Driver driver = Driver.fromDocument(driverDoc);
      double bidPrice = (driversRequested[driver.driverId]
                  as Map<String, dynamic>?)?['bidPrice']
              ?.toDouble() ??
          0.0;
      driverBidPrices[driver.driverId] = bidPrice;

      // Calculate the distance between the current location and the driver's location
      double distance = _calculateDistance(
        _currentLatLng!.latitude,
        _currentLatLng!.longitude,
        driver.currentLocation.latitude,
        driver.currentLocation.longitude,
      );

      // Check if the driver is within 500 meters
      // if (distance <= 0.1) {
      //   combinedData.add({
      //     'driver': driver.toJson(),
      //     'bidPrice': bidPrice,
      //     'request': requestDoc.data()
      //         as Map<String, dynamic>, // Add the whole request document data
      //     'requestId': requestDoc.id, // Add the request document ID
      //   });
      // }
      combinedData.add({
        'driver': driver.toJson(),
        'bidPrice': bidPrice,
        'request': requestDoc.data()
            as Map<String, dynamic>, // Add the whole request document data
        'requestId': requestDoc.id, // Add the request document ID
      });
    }

    print(combinedData);

    return combinedData;
  }

// Function to calculate the distance between two geographic points using the Haversine formula
  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const double R = 6371; // Radius of the Earth in kilometers
    double dLat = _degToRad(lat2 - lat1);
    double dLon = _degToRad(lon2 - lon1);
    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degToRad(lat1)) *
            cos(_degToRad(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    double distance = R * c; // Distance in kilometers

    return distance;
  }

// Function to convert degrees to radians
  double _degToRad(double deg) {
    return deg * (pi / 180);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _mapController.dispose();
    _determinePosition();
    _loadDriverIds();
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
        title: Text("Cargo App"),
        actions: [
          // Padding(
          //   padding: EdgeInsets.all(8.0),
          //   child: IconButton(
          //     onPressed: () {
          //       Navigator.push(
          //         context,
          //         MaterialPageRoute(
          //           builder: (context) => NotificationPage(),
          //         ),
          //       );
          //     },
          //     icon: Icon(Icons.notifications),
          //   ),
          // ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: Colors.white,
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Column(
                children: [
                  Container(
                    height: 100.0,
                    padding: const EdgeInsets.symmetric(
                        vertical: 20, horizontal: 15),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                    ),
                    child: FutureBuilder(
                      future: getDocument(),
                      builder:
                          (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
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
                  // ListTile(
                  //   leading: const Icon(Icons.info),
                  //   title: const Text('About'),
                  //   onTap: () {
                  //     Navigator.push(
                  //       context,
                  //       MaterialPageRoute(
                  //         builder: (context) => const AboutPage(),
                  //       ),
                  //     );
                  //   },
                  // ),
                ],
              ),
              MaterialButton(
                elevation: 0,
                color: Colors.blue,
                height: 55,
                child: Row(
                  children: [
                    Icon(
                      Icons.logout,
                      color: Colors.white,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18.0),
                      child: Text(
                        "LogOut",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                onPressed: () async {
                  auth.signOutUser();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Wrapper(isSignedIn: false),
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
                  zoomControlsEnabled: false,
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
                            height: 200,
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
                                MaterialButton(
                                    elevation: 0,
                                    minWidth: double.infinity,
                                    height: 45,
                                    child: const Text("Refresh Driver status"),
                                    // color: Colors.blue,
                                    textColor: Colors.black,
                                    onPressed: () {
                                      setState(() {
                                        _mapRequestDriverData();
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
                          child: FutureBuilder<List<Map<String, dynamic>>>(
                            future: _mapRequestDriverData(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Center(
                                  child: CircularProgressIndicator(),
                                );
                              } else if (snapshot.hasError) {
                                return Center(
                                    child: Text('Error: ${snapshot.error}'));
                              } else if (!snapshot.hasData ||
                                  snapshot.data!.isEmpty) {
                                return Center(
                                    child: Text('No NearBy drivers found'));
                              } else {
                                List<Map<String, dynamic>> data =
                                    snapshot.data!;
                                return ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: data.length,
                                  itemBuilder: (context, index) {
                                    var driverData = data[index]['driver'];
                                    var bidPrice = data[index]['bidPrice'];
                                    var request = data[index]['request'];
                                    var requestId = data[index]['requestId'];

                                    return DriverCard(
                                      truckSize: driverData['truckSize'],
                                      estimatedPrice: bidPrice,
                                      truckType: driverData['truckType'],
                                      isLoading: isLoading,
                                      bidPrice: bidPrice,
                                      onpress: () {
                                        if (bidPrice > 0) {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  DriverInfoPage(
                                                      id: driverData[
                                                          'driverId'],
                                                      requestId: requestId,
                                                      destination:
                                                          _selectedLocation!),
                                            ),
                                          );
                                        } else {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Waiting for Driver to bid',
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                    );
                                  },
                                );
                              }
                            },
                          ),
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
                                        await _getLatLngFromAddress(result);
                                        setState(() {
                                          _destination = result;
                                          _distance = calculateDistance(
                                              _currentLatLng!,
                                              _selectedLocation!);
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
                                  SizedBox(
                                      height: 40,
                                      child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text("Distance",
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            Text(
                                                "${_distance.toStringAsFixed(2)} Km"),
                                          ])),
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
                                            value: 'bajaj',
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
                                            value: 'kirikuu',
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
                                            value: 'canter',
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
                                      // Row(
                                      //   children: [
                                      //     Radio<String>(
                                      //       value: 'other',
                                      //       groupValue: _selectedOption,
                                      //       onChanged: (String? value) {
                                      //         setState(() {
                                      //           _selectedOption = value;
                                      //         });
                                      //       },
                                      //     ),
                                      //     const Text('other'),
                                      //   ],
                                      // ),
                                      // (_selectedOption == "other")
                                      //     ? const TextField(
                                      //         decoration: InputDecoration(
                                      //             hintText: "specify size"),
                                      //       )
                                      //     : Container(),
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
                                            ? const Text(
                                                "Take package picture",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              )
                                            : const Text(
                                                "Retake package picture",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              )
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
                                  SizedBox(
                                    height: 50.0,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                            "Total Price: ${estimatedPrice.toStringAsFixed(2)} Tsh"),
                                        MaterialButton(
                                          onPressed: () {
                                            _calculateCost();
                                          },
                                          child: Text(
                                            "Generate Price",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
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
                                              GeoPoint geoPoint = GeoPoint(
                                                  _currentLatLng!.latitude,
                                                  _currentLatLng!.longitude);
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
                                                        geoPoint,
                                                        _destination!,
                                                        requestedDrivers,
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
