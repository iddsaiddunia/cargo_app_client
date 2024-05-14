import 'package:cargo_app/auth/about.dart';
import 'package:cargo_app/auth/account.dart';
import 'package:cargo_app/auth/driver_info.dart';
import 'package:cargo_app/auth/history.dart';
import 'package:cargo_app/auth/location_search.dart';
import 'package:cargo_app/services/provider.dart';
import 'package:cargo_app/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/services.dart' show rootBundle;
// import 'package:location/location.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:async';

import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late String _mapStyle;
  bool isDrawerOpen = false;
  late GoogleMapController _controller;
  final _destinationController = TextEditingController();
  final _currentLocationController = TextEditingController();
  bool isPackageDetailsFilled = false;
  int _selectedIndex = 0;
  String? _selectedOption = "1 - 0.9";
  bool isPhotoTaken = false;
  bool isLoading = false;
  // final Location _location = Location();
  // late LatLng _currentPosition;
  // late LatLng _destination;
  // File? _image;

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

  @override
  void initState() {
    super.initState();
    // _getCurrentLocation();
    rootBundle.loadString('assets/map_style.txt').then((string) {
      _mapStyle = string;
    });
  }

  // Future<void> _getCurrentLocation() async {
  //   try {
  //     var userLocation = await _location.getLocation();
  //     setState(() {
  //       _currentPosition =
  //           LatLng(userLocation.latitude!, userLocation.longitude!);
  //     });
  //   } catch (e) {
  //     print("Error getting user location: $e");
  //   }
  // }

  void toggleDrawer() {
    setState(() {
      isDrawerOpen = !isDrawerOpen;
    });
  }

  Future<void> saveInitPickupRequest(BuildContext context, String userId,
      String packageType, String packageSize, String pictureUrl) async {
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
      ),
      drawer: Drawer(
        backgroundColor: Colors.white,
        child: SafeArea(
          child: Column(
            children: <Widget>[
              Container(
                height: 80.0,
                decoration: const BoxDecoration(
                  color: Colors.white,
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 26,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [Text("John Doe"), Text("+255768906543")],
                      ),
                    ),
                  ],
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
          GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: const CameraPosition(
              target: LatLng(37.7749, -122.4194), // San Francisco coordinates
              zoom: 12.0,
            ),
            onMapCreated: (GoogleMapController controller) {
              _controller = controller;
              controller.setMapStyle(_mapStyle);
            },
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
                                LocationInputField(
                                  controller: _currentLocationController,
                                  title: "Pickup location",
                                ),
                                const SizedBox(
                                  height: 7.0,
                                ),
                                // LocationInputField(
                                //   controller: _destinationController,
                                //   title: "Destination",
                                // ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            LocationSearchPage(),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    width:
                                        MediaQuery.of(context).size.width / 1.2,
                                    height: 50.0,
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 10),
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
                                    child: Row(
                                      children: [
                                        Icon(Icons.navigation),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10.0),
                                          child: Text("Destination"),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 7.0,
                                ),
                              ],
                            )
                          : Container(),
                    ],
                  ),

//****************************************************************
                  SizedBox(
                    width: double.infinity,
                    height: 150,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 3,
                      itemBuilder: (context, index) {
                        return DriverCard(
                          onpress: () {
                            print("hello");
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DriverInfoPage(),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  )
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
                                    height: 10.0,
                                  ),
                                  InkWell(
                                    onTap: () async {
                                      //              final image = await ImagePicker().getImage(source: ImageSource.gallery);
                                      //  if (image != null) {
                                      //    _image = File(image.path);
                                      //  }
                                    },
                                    child: const Row(
                                      children: [
                                        Icon(Icons.camera),
                                        Text("Take package picture")
                                      ],
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 10.0,
                                  ),
                                  const Divider(),
                                  Align(
                                    alignment: Alignment.bottomCenter,
                                    child: (!isPhotoTaken)
                                        ? MaterialButton(
                                            minWidth: double.infinity,
                                            height: 50,
                                            elevation: 0,
                                            color: Colors.blue,
                                            onPressed: () {
                                              if (userId != "") {
                                                saveInitPickupRequest(
                                                    context,
                                                    userId,
                                                    packageTypeList[
                                                        _selectedIndex],
                                                    _selectedOption!,
                                                    "");
                                              } else {
                                                print('User not logged in');
                                              }
                                            },
                                            child: (!isLoading)
                                                ? const Text(
                                                    "Continue",
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  )
                                                : CircularProgressIndicator(
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
