import 'package:cargo_app/auth/about.dart';
import 'package:cargo_app/auth/account.dart';
import 'package:cargo_app/auth/driver_info.dart';
import 'package:cargo_app/auth/history.dart';
import 'package:cargo_app/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/services.dart' show rootBundle;
// import 'package:location/location.dart';
import 'dart:async';

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
  String? _selectedOption;
  bool isPhotoTaken = false;
  // final Location _location = Location();
  // late LatLng _currentPosition;
  // late LatLng _destination;

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

  Widget build(BuildContext context) {
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
                decoration: BoxDecoration(
                  color: Colors.white,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CircleAvatar(
                      radius: 26,
                    ),
                    const Padding(
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
                      builder: (context) => AccountPage(),
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
            initialCameraPosition: CameraPosition(
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
                      (isPackageDetailsFilled)?Column(
                        children: [
                          LocationInputField(
                            controller: _currentLocationController,
                            title: "Pickup location",
                          ),
                          SizedBox(
                            height: 7.0,
                          ),
                          LocationInputField(
                            controller: _destinationController,
                            title: "Destination",
                          ),
                          SizedBox(
                            height: 7.0,
                          ),
                        ],
                      ): Container(),
                    ],
                  ),

//****************************************************************
                  // SizedBox(
                  //   width: double.infinity,
                  //   height: 150,
                  //   child: ListView.builder(
                  //     scrollDirection: Axis.horizontal,
                  //     itemCount: 3,
                  //     itemBuilder: (context, index) {
                  //       return DriverCard(
                  //         onpress: () {
                  //           print("hello");
                  //           Navigator.push(
                  //             context,
                  //             MaterialPageRoute(
                  //               builder: (context) => DriverInfoPage(),
                  //             ),
                  //           );
                  //         },
                  //       );
                  //     },
                  //   ),
                  // )
                ],
              ),
            ),
          ),
          Expanded(
            child: (!isPackageDetailsFilled)?DraggableScrollableSheet(
              initialChildSize:
                  0.3, // Initial size of the sheet (30% of the screen)
              minChildSize:
                  0.2, // Minimum size of the sheet (10% of the screen)
              maxChildSize:
                  0.8, // Maximum size of the sheet (80% of the screen)
              builder:
                  (BuildContext context, ScrollController scrollController) {
                return Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
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
                                decoration: BoxDecoration(
                                  color: Colors.grey,
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(10),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 16,
                            ),
                            Text(
                              "Package type",
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
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
                            SizedBox(
                              height: 16,
                            ),
                            Text(
                              "Package Size",
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Radio<String>(
                                      value: 'Option A',
                                      groupValue: _selectedOption,
                                      onChanged: (String? value) {
                                        setState(() {
                                          _selectedOption = value;
                                        });
                                      },
                                    ),
                                    Text('1 - 999 Kg'),
                                  ],
                                ),
                                // Radio button for option B
                                Row(
                                  children: [
                                    Radio<String>(
                                      value: 'Option B',
                                      groupValue: _selectedOption,
                                      onChanged: (String? value) {
                                        setState(() {
                                          _selectedOption = value;
                                        });
                                      },
                                    ),
                                    Text('1 - 3 Ton'),
                                  ],
                                ),
                                // Radio button for option C
                                Row(
                                  children: [
                                    Radio<String>(
                                      value: 'Option C',
                                      groupValue: _selectedOption,
                                      onChanged: (String? value) {
                                        setState(() {
                                          _selectedOption = value;
                                        });
                                      },
                                    ),
                                    Text('4 - 7 Ton'),
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
                                    Text('other'),
                                  ],
                                ),
                                (_selectedOption == "other")
                                    ? TextField(
                                        decoration: InputDecoration(
                                            hintText: "specify size"),
                                      )
                                    : Container(),
                              ],
                            ),
                            Divider(),
                            SizedBox(
                              height: 10.0,
                            ),
                            InkWell(
                              onTap: () {},
                              child: Row(
                                children: [
                                  Icon(Icons.camera),
                                  Text("Take package picture")
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 10.0,
                            ),
                            Divider(),
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: (!isPhotoTaken)
                                  ? MaterialButton(
                                      elevation: 0,
                                      color: Colors.blue,
                                      onPressed: () {
                                        setState(() {
                                          isPackageDetailsFilled = true;
                                        });
                                      },
                                      child: Text(
                                        "Continue",
                                        style: TextStyle(color: Colors.white),
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
            ): Container(),
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
        margin: EdgeInsets.symmetric(horizontal: 5),
        padding: EdgeInsets.symmetric(horizontal: 15),
        // width: 130,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          border: (index == selectedIndex)
              ? Border.all(width: 2, color: Colors.blue)
              : Border.all(width: 1, color: Colors.black12),
          borderRadius: BorderRadius.all(
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
