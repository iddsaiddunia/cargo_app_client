import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_place/google_place.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  final _controller = TextEditingController();
  late GooglePlace googlePlace;
  List<AutocompletePrediction> predictions = [];
  Timer? _debounce;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    String apiKey = "AIzaSyBw_qR2Kdnjn2K6fwCbiBYyf-wfeVZshEk";
    googlePlace = GooglePlace(apiKey);
  }

  void autoCompleteSearch(String value) async{
    var result = await googlePlace.autocomplete.get(value);
    if(result !=null && result.predictions != null && mounted){
      print(result.predictions!.first.description);
      setState(() {
        predictions = result.predictions!;
      });

    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Center(
          child: TextField(
            controller: _controller,
            decoration: InputDecoration(
              label: Text("Destination"),
            ),
            onChanged: (value){
              if(_debounce?.isActive ?? false) _debounce!.cancel();
              _debounce = Timer(const Duration(milliseconds: 1000), () {
                if(value.isNotEmpty){
                  //places Api
                  autoCompleteSearch(value);
                }
                else{
                  //clear result
                }
              });


            },
          ),
        ),
      ),
    );
  }
}

// class AboutPage extends StatefulWidget {
//   const AboutPage({super.key});
//
//   @override
//   State<AboutPage> createState() => _AboutPageState();
// }
//
// class _AboutPageState extends State<AboutPage> {
//   TextEditingController controller = TextEditingController();
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//
//       ),
//       body: Center(
//
//         child: Column(
//
//           mainAxisAlignment: MainAxisAlignment.start,
//           children: <Widget>[
//             SizedBox(height: 20),
//             placesAutoCompleteTextField(),
//           ],
//         ),
//       ),
//     );
//   }
//   placesAutoCompleteTextField() {
//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 20),
//       child: GooglePlaceAutoCompleteTextField(
//         textEditingController: controller,
//         googleAPIKey: "AIzaSyBw_qR2Kdnjn2K6fwCbiBYyf-wfeVZshEk",
//         inputDecoration: InputDecoration(
//           hintText: "Search your location",
//           border: InputBorder.none,
//           enabledBorder: InputBorder.none,
//         ),
//         debounceTime: 400,
//         countries: ["tz"],
//         isLatLngRequired: true,
//         getPlaceDetailWithLatLng: (Prediction prediction) {
//           print("placeDetails" + prediction.lat.toString());
//         },
//
//         itemClick: (Prediction prediction) {
//           controller.text = prediction.description ?? "";
//           controller.selection = TextSelection.fromPosition(
//               TextPosition(offset: prediction.description?.length ?? 0));
//         },
//         seperatedBuilder: Divider(),
//         containerHorizontalPadding: 10,
//
//         // OPTIONAL// If you want to customize list view item builder
//         itemBuilder: (context, index, Prediction prediction) {
//           return Container(
//             padding: EdgeInsets.all(10),
//             child: Row(
//               children: [
//                 Icon(Icons.location_on),
//                 SizedBox(
//                   width: 7,
//                 ),
//                 Expanded(child: Text("${prediction.description ?? ""}"))
//               ],
//             ),
//           );
//         },
//
//         isCrossBtnShown: true,
//
//         // default 600 ms ,
//       ),
//     );
//   }
// }
