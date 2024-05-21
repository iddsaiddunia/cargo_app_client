import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_place/google_place.dart';
import 'package:google_places_flutter/google_places_flutter.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController _searchController = TextEditingController();
  bool _isDisposed = false;

  @override
  void dispose() {
    _searchController.dispose();
    _isDisposed = true;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          // title: Text('Search Location'),
          ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GooglePlaceAutoCompleteTextField(
          textEditingController: _searchController,
          googleAPIKey: "AIzaSyAjsJbodhou5nNntMWPdhRsWqz2h1Tgzoc",
          inputDecoration: InputDecoration(
            hintText: 'Search places...',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          debounceTime: 800,
          countries: const ["tz"],
          isLatLngRequired: true,
          getPlaceDetailWithLatLng: (prediction) {
            final placeId = prediction.placeId;
            if (placeId != null && !_isDisposed) {
              _selectPlace(placeId);
            }
          },
          itemClick: (prediction) {
            final placeId = prediction.placeId;
            if (placeId != null && !_isDisposed) {
              _selectPlace(placeId);
            }
          },
        ),
      ),
    );
  }

  Future<void> _selectPlace(String placeId) async {
    var placeDetails =
        await GooglePlace('AIzaSyAjsJbodhou5nNntMWPdhRsWqz2h1Tgzoc')
            .details
            .get(placeId);
    if (!_isDisposed && placeDetails != null && placeDetails.result != null) {
      var place = placeDetails.result!;

      if (mounted) {
        Navigator.pop(context, place.formattedAddress);
      }
    }
  }
}
