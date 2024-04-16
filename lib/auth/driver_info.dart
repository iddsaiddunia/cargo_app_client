import 'package:cargo_app/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DriverInfoPage extends StatefulWidget {
  const DriverInfoPage({super.key});

  @override
  State<DriverInfoPage> createState() => _DriverInfoPageState();
}

class _DriverInfoPageState extends State<DriverInfoPage> {
  late GoogleMapController _controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        Column(
          children: [
            Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height / 1.6,
              color: Colors.red,
              child: GoogleMap(
                mapType: MapType.normal,
                initialCameraPosition: const CameraPosition(
                  target:
                      LatLng(37.7749, -122.4194), // San Francisco coordinates
                  zoom: 12.0,
                ),
                onMapCreated: (GoogleMapController controller) {
                  _controller = controller;
                },
              ),
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                color: const Color.fromARGB(255, 245, 245, 245),
                padding: const EdgeInsets.all(20),
                child: Column(
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
                                  color:
                                      const Color.fromARGB(255, 150, 150, 150),
                                ),
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(7.0),
                                ),
                              ),
                              child: Image.asset(
                                "assets/img/cargo-truck (1).png",
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("John Doe"),
                                  Icon(
                                    Icons.star,
                                    size: 18,
                                    color: Color.fromARGB(255, 231, 212, 42),
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
                            borderRadius: BorderRadius.all(Radius.circular(35)),
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
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Isuzu carrier 602"),
                            Text(
                              "DXY 205",
                              style: TextStyle(fontWeight: FontWeight.w600),
                            )
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Arriving In"),
                            Text(
                              "05 Min",
                              style: TextStyle(fontWeight: FontWeight.w600),
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
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                      ),
                      child: const Center(
                        child: Text(
                          "Cancel Pickup",
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
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
