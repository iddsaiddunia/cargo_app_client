import 'package:cargo_app/services/provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Location {
  final String name;
  final String address;

  Location({required this.name, required this.address});
}

class LocationSearchPage extends StatefulWidget {
  const LocationSearchPage({super.key});

  @override
  State<LocationSearchPage> createState() => _LocationSearchPageState();
}

class _LocationSearchPageState extends State<LocationSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Location> _searchResults = [];

  void _performSearch(String query) {
    // Perform search operation (e.g., querying a database or an API)
    // For demonstration, we'll populate some dummy search results
    List<Location> results = [
      Location(name: 'Location 1', address: 'Address 1'),
      Location(name: 'Location 2', address: 'Address 2'),
      Location(name: 'Location 3', address: 'Address 3'),
    ];

    setState(() {
      _searchResults = results;
    });
  }

  void _selectLocation(Location location) {
    // Handle selection of the location (e.g., pass it to another page)
    // For demonstration, we'll just print the selected location
    print('Selected location: ${location.name}');
  }

  // @override
  // void dispose() {
  //   super.dispose();
  //   // _searchController.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    final destinationProvider =
        Provider.of<DestinationProvider>(context, listen: false);
        
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: SafeArea(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    width: 1,
                    color: const Color.fromARGB(255, 170, 170, 170),
                  ),
                  borderRadius: const BorderRadius.all(Radius.circular(4)),
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                      hintText: 'Search for a location...',
                      prefixIcon: Icon(Icons.search),
                      border: InputBorder.none),
                  onChanged: (query) {
                    // Perform search based on the query
                    _performSearch(query);
                  },
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_searchResults[index].name),
                  subtitle: Text(_searchResults[index].address),
                  onTap: () {
                    destinationProvider.setDestination(_searchResults[index].name);
                    _selectLocation(_searchResults[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
