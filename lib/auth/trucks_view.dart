// import 'package:cargo_app/widgets.dart';
// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';

// class TrucksViewPage extends StatefulWidget {
//   const TrucksViewPage({super.key});

//   @override
//   State<TrucksViewPage> createState() => _TrucksViewPageState();
// }

// class _TrucksViewPageState extends State<TrucksViewPage> {
//   late GoogleMapController _controller;
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           GoogleMap(
//             mapType: MapType.normal,
//             initialCameraPosition: const CameraPosition(
//               target: LatLng(37.7749, -122.4194), // San Francisco coordinates
//               zoom: 12.0,
//             ),
//             onMapCreated: (GoogleMapController controller) {
//               _controller = controller;
//             },
//           ),
//           Padding(
//             padding: const EdgeInsets.symmetric(vertical: 18.0),
//             child: SafeArea(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       MenuButton(
//                         ontap: () {
//                           print("hello");
                        
//                           CustomDrawer();
//                         },
//                       ),
//                       const Column(
//                         children: [
//                           LocationInputField(),
//                           SizedBox(
//                             height: 7.0,
//                           ),
//                           LocationInputField(),
//                           SizedBox(
//                             height: 7.0,
//                           ),
//                         ],
//                       )
//                     ],
//                   ),
//                   SizedBox(
//                     width: double.infinity,
//                     height: 150,
//                     child: ListView.builder(
//                       scrollDirection: Axis.horizontal,
//                       itemCount: 3,
//                       itemBuilder: (context, index) {
//                         return const DriverCard();
//                       },
//                     ),
//                   )
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
