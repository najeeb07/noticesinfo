import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:noticesinfo/services/location_service.dart';
import 'package:noticesinfo/services/location_storage_service.dart';

// Data class to hold Placemark and its corresponding Lat/Lng
class CitySearchResult {
  final Placemark placemark;
  final double latitude;
  final double longitude;

  CitySearchResult({required this.placemark, required this.latitude, required this.longitude});
}

class CitySearchScreen extends StatefulWidget {
  const CitySearchScreen({super.key});

  @override
  State<CitySearchScreen> createState() => _CitySearchScreenState();
}

class _CitySearchScreenState extends State<CitySearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final LocationService _locationService = LocationService();
  final LocationStorageService _locationStorageService = LocationStorageService();
  List<CitySearchResult> _searchResults = [];
  bool _isLoading = false;

  static final List<CitySearchResult> _topCities = [
    CitySearchResult(
      placemark: Placemark(locality: 'Mumbai', country: 'India'),
      latitude: 19.0760,
      longitude: 72.8777,
    ),
    CitySearchResult(
      placemark: Placemark(locality: 'Delhi', country: 'India'),
      latitude: 28.7041,
      longitude: 77.1025,
    ),
    CitySearchResult(
      placemark: Placemark(locality: 'Bangalore', country: 'India'),
      latitude: 12.9716,
      longitude: 77.5946,
    ),
    CitySearchResult(
      placemark: Placemark(locality: 'Kolkata', country: 'India'),
      latitude: 22.5726,
      longitude: 88.3639,
    ),
    CitySearchResult(
      placemark: Placemark(locality: 'Chennai', country: 'India'),
      latitude: 13.0827,
      longitude: 80.2707,
    ),
    CitySearchResult(
      placemark: Placemark(locality: 'Hyderabad', country: 'India'),
      latitude: 17.3850,
      longitude: 78.4867,
    ),
    CitySearchResult(
      placemark: Placemark(locality: 'Ahmedabad', country: 'India'),
      latitude: 23.0225,
      longitude: 72.5714,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _searchResults = _topCities; // Initialize with top cities
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _onSearchChanged() async {
    final query = _searchController.text;
    if (query.isEmpty) {
      setState(() {
        _searchResults = _topCities; // Show top cities when search is empty
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      List<Location> locations = await locationFromAddress(query);
      List<CitySearchResult> results = [];
      for (var loc in locations) {
        List<Placemark> p = await placemarkFromCoordinates(loc.latitude, loc.longitude);
        if (p.isNotEmpty) {
          results.add(CitySearchResult(
            placemark: p.first,
            latitude: loc.latitude,
            longitude: loc.longitude,
          ));
        }
      }
      setState(() {
        _searchResults = results;
      });
    } catch (e) {
      print("Error getting location suggestions: $e");
      setState(() {
        _searchResults = [];
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _useCurrentLocation() async {
    setState(() {
      _isLoading = true;
    });
    final locationResult = await _locationService.getCurrentCityWithStatus();
    final String? fetchedCity = locationResult['city'];
    final double? latitude = locationResult['latitude'];
    final double? longitude = locationResult['longitude'];

    if (mounted) {
      if (fetchedCity != null && latitude != null && longitude != null) {
        await _locationStorageService.saveCity(
          city: fetchedCity,
          latitude: latitude,
          longitude: longitude,
        );
        Navigator.of(context).pushReplacementNamed('/home');
      } else {
        // Handle cases where current location couldn't be fetched
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not get current location. Please try searching manually.')),
        );
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _selectCity(CitySearchResult result) async {
    final String? city = result.placemark.locality ?? result.placemark.subAdministrativeArea;
    final double? latitude = result.latitude;
    final double? longitude = result.longitude;

    if (city != null && latitude != null && longitude != null) {
      await _locationStorageService.saveCity(
        city: city,
        latitude: latitude,
        longitude: longitude,
      );
      Navigator.of(context).pushReplacementNamed('/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not save selected city. Missing data.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Location'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Handle back button if needed, or just pop
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search for a city',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchResults = [];
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.my_location, color: Colors.deepOrange),
            title: const Text(
              'Use my current location',
              style: TextStyle(color: Colors.deepOrange),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: _useCurrentLocation,
          ),
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Expanded(
                  child: ListView.builder(
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      final result = _searchResults[index];
                      final String title = result.placemark.locality ?? result.placemark.subAdministrativeArea ?? 'Unknown City';
                      final String subtitle = [result.placemark.administrativeArea, result.placemark.country]
                          .where((element) => element != null && element.isNotEmpty)
                          .join(', ');
                      return ListTile(
                        leading: const Icon(Icons.location_on),
                        title: Text(title),
                        subtitle: Text(subtitle),
                        onTap: () => _selectCity(result),
                      );
                    },
                  ),
                ),
        ],
      ),
    );
  }
}
