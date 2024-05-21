import 'dart:io';

import 'package:cargo_app/auth/about.dart';
import 'package:cargo_app/auth/account.dart';
import 'package:cargo_app/auth/driver_info.dart';
import 'package:cargo_app/auth/history.dart';
import 'package:cargo_app/auth/location_search.dart';
import 'package:cargo_app/models/driver.dart';
import 'package:cargo_app/nonAuth/login.dart';
import 'package:cargo_app/services/provider.dart';
import 'package:cargo_app/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:geocoding/geocoding.dart';
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
  // late Location _location;
  // LatLng? _currentPosition;
  // late LatLng _destination;
  LatLng? _selectedLocation;
  late Position _currentPosition;
  LatLng? _currentLatLng;

  final CollectionReference driversCollection =
      FirebaseFirestore.instance.collection('Drivers');

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
    // _location = Location();
    // _initializeLocation();
    _determinePosition();
    rootBundle.loadString('assets/map_style.txt').then((string) {
      _mapStyle = string;
    });
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
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

  Future<void> saveInitPickupRequest(
    BuildContext context,
    String userId,
    String packageType,
    String packageSize,
    String pictureUrl,
    LatLng currentLocation,
  ) async {
    try {
      setState(() {
        isLoading = true;
      });

      await FirebaseFirestore.instance.collection('Requests').add({
        'userId': userId,
        'packageType': packageType,
        'packageSize': packageSize,
        'pictureUrl': pictureUrl,
        'currentLocation': null, // Empty for now
        'destination': null, // Empty for now
        'driverId': null, // Empty for now
        'isPickedUp': false,
        'requestTime': Timestamp.now(),
      });
      setState(() {
        isPackageDetailsFilled = true;
        isLoading = false;
      });
    } catch (e) {
      print("Error saving pickup request: $e");
    }
  }

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
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 15),
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
                          CircleAvatar(
                            radius: 26,
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8.0),
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
                    return Center(child: const CircularProgressIndicator());
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
              ? Center(child: const CircularProgressIndicator())
              : GoogleMap(
                  mapType: MapType.normal,

                  onMapCreated: (GoogleMapController controller) {
                    _mapController = controller;
                    controller.setMapStyle(_mapStyle);
                    _mapController!.animateCamera(
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
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 18.0),
            child: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // MenuButton(
                      //   icon: Icons.menu,
                      //   ontap: () {
                      //     toggleDrawer();
                      //   },
                      // ),
                      (isPackageDetailsFilled)
                          ? Column(
                              children: [
                                // LocationInputField(
                                //   controller: _currentLocationController,
                                //   title: "Pickup location",
                                // ),
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width / 1.2,
                                  height: 50.0,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(
                                      width: 1,
                                      color: const Color.fromARGB(
                                          255, 170, 170, 170),
                                    ),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(4)),
                                  ),
                                  child: const Row(
                                    children: [
                                      Icon(Icons.navigation),
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 10.0),
                                        child: Text("Current location"),
                                      )
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 7.0,
                                ),
                                LocationInputField(
                                  controller: _destinationController,
                                  title: _destination ?? "Destination",
                                  ontap: () async {
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
                                ),
                                // GestureDetector(
                                //   onTap: () {
                                // Navigator.push(
                                //   context,
                                //   MaterialPageRoute(
                                //     builder: (context) => SearchPage(),
                                //   ),
                                // );
                                //   },
                                //   child: Container(
                                //     width:
                                //         MediaQuery.of(context).size.width / 1.2,
                                //     height: 50.0,
                                //     padding: const EdgeInsets.symmetric(
                                //         horizontal: 10),
                                //     decoration: BoxDecoration(
                                //       color: Colors.white,
                                //       border: Border.all(
                                //         width: 1,
                                //         color: const Color.fromARGB(
                                //             255, 170, 170, 170),
                                //       ),
                                //       borderRadius: const BorderRadius.all(
                                //           Radius.circular(4)),
                                //     ),
                                //     child: const Row(
                                //       children: [
                                //         Icon(Icons.navigation),
                                //         Padding(
                                //           padding: EdgeInsets.symmetric(
                                //               horizontal: 10.0),
                                //           child: Text("Destination"),
                                //         )
                                //       ],
                                //     ),
                                //   ),
                                // ),
                                const SizedBox(
                                  height: 7.0,
                                ),
                              ],
                            )
                          : Container(),
                    ],
                  ),

//****************************************************************
                  (isPackageDetailsFilled && _destination != "")
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
                                      estimatedPrice: 6000,
                                      truckType: drivers[index].truckType,
                                      onpress: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                DriverInfoPage(
                                              id: drivers[index].driverId,
                                            ),
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
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                          const Text('1 - 999 Kg'),
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
                                          const Text('1 - 3 Ton'),
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
                                          const Text('4 - 7 Ton'),
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
                                            ? Text("Take package picture")
                                            : Text("Retake package picture")
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
                                        : Text('No image selected.'),
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
                                                  final uploadTask =
                                                      imagesRef.putFile(image!);
                                                  await uploadTask
                                                      .whenComplete(() async {
                                                    imgUrl = await imagesRef
                                                        .getDownloadURL();
                                                  });
                                                  if (imgUrl != "") {
                                                    saveInitPickupRequest(
                                                      context,
                                                      userId,
                                                      packageTypeList[
                                                          _selectedIndex],
                                                      _selectedOption!,
                                                      imgUrl,
                                                      _currentLatLng!,
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
