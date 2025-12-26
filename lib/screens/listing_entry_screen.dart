import 'dart:developer' as developer;
import 'dart:io'; // For File
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Import image_picker
import 'package:noticesinfo/services/api_service.dart';
import 'package:noticesinfo/screens/home_screen.dart'; // Import the home screen
import 'package:google_maps_flutter/google_maps_flutter.dart'; // Import google_maps_flutter
import 'package:geocoding/geocoding.dart'; // Import geocoding
import 'package:flutter_typeahead/flutter_typeahead.dart'; // Import flutter_typeahead

class ListingEntryScreen extends StatefulWidget {
  final int categoryId;
  final String categoryName;
  final int subCategoryId;
  final String subCategoryName;

  const ListingEntryScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
    required this.subCategoryId,
    required this.subCategoryName,
  });

  @override
  State<ListingEntryScreen> createState() => _ListingEntryScreenState();
}

class _ListingEntryScreenState extends State<ListingEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationCityController = TextEditingController();
  final TextEditingController _sourceInfoController = TextEditingController();
  final TextEditingController _townshipController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;
  List<XFile> _selectedImages = []; // To store selected images
  final ImagePicker _picker = ImagePicker(); // Image picker instance

  GoogleMapController? _mapController;
  LatLng _selectedLocation = const LatLng(17.4065, 78.4772); // Default to Hyderabad, India
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _markers.add(
      Marker(
        markerId: const MarkerId('selected-location'),
        position: _selectedLocation,
      ),
    );
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage();
      if (images.isNotEmpty) {
        setState(() {
          // Limit to 5 images
          _selectedImages = images.take(5).toList();
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error picking images: $e';
      });
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _onTapMap(LatLng latLng) async {
    setState(() {
      _selectedLocation = latLng;
      _markers.clear();
      _markers.add(
        Marker(
          markerId: const MarkerId('selected-location'),
          position: latLng,
        ),
      );
    });

    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latLng.latitude, latLng.longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        String city = place.locality ?? place.subAdministrativeArea ?? '';
        String address = [place.street, place.subLocality, place.locality, place.administrativeArea, place.country]
            .where((element) => element != null && element.isNotEmpty)
            .join(', ');
        _locationCityController.text = city;
        _townshipController.text = address; // Update township with full address
        _sourceInfoController.text = ''; // Clear source info
      }
    } catch (e) {
      developer.log('Error getting placemark: $e', name: 'ListingEntryScreen');
    }
  }

  Future<List<String>> _getSuggestions(String pattern) async {
    if (pattern.isEmpty) {
      return [];
    }
    try {
      List<Location> locations = await locationFromAddress(pattern);
      return locations.map((loc) => '${loc.latitude},${loc.longitude}').toList(); // Return lat,lng for suggestions
    } catch (e) {
      developer.log('Error getting location suggestions: $e', name: 'ListingEntryScreen');
      return [];
    }
  }

  Future<void> _onSuggestionSelected(String suggestion) async {
    List<String> latLng = suggestion.split(',');
    double lat = double.parse(latLng[0]);
    double lng = double.parse(latLng[1]);

    LatLng newLocation = LatLng(lat, lng);

    setState(() {
      _selectedLocation = newLocation;
      _markers.clear();
      _markers.add(
        Marker(
          markerId: const MarkerId('selected-location'),
          position: newLocation,
        ),
      );
    });

    _mapController?.animateCamera(CameraUpdate.newLatLng(newLocation));

    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        String city = place.locality ?? place.subAdministrativeArea ?? '';
        String address = [place.street, place.subLocality, place.locality, place.administrativeArea, place.country]
            .where((element) => element != null && element.isNotEmpty)
            .join(', ');
        _locationCityController.text = city;
        _townshipController.text = address; // Update township with full address
        _sourceInfoController.text = ''; // Clear source info
      }
    } catch (e) {
      developer.log('Error getting placemark from suggestion: $e', name: 'ListingEntryScreen');
    }
  }

  Future<void> _submitPost() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedImages.isEmpty) {
        setState(() {
          _errorMessage = 'Please select at least one image.';
        });
        return;
      }

      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final ApiService apiService = ApiService();
      final int? userId = await apiService.getUserId(); // Get user ID from ApiService

      if (userId == null) {
        setState(() {
          _errorMessage = 'User not logged in. Please log in to create a post.';
          _isLoading = false;
        });
        return;
      }

      try {
        final response = await apiService.createPost(
          userId: userId, // Use the retrieved user ID
          title: _titleController.text,
          description: _descriptionController.text,
          categoryId: widget.subCategoryId, // sub_category_id
          parentCategoryId: widget.categoryId, // category_id
          locationCity: _locationCityController.text,
          lat: _selectedLocation.latitude,
          lng: _selectedLocation.longitude,
          sourceInfo: _sourceInfoController.text,
          township: _townshipController.text,
          media: _selectedImages.map((image) => image.path).toList(), // Pass image paths
        );

        developer.log('API Response: $response', name: 'ListingEntryScreen');
        developer.log('Response success status: ${response['success']}', name: 'ListingEntryScreen');

        if (response['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Post created successfully!')),
          );
          Navigator.popUntil(context, (route) => route.isFirst);
        } else {
          setState(() {
            _errorMessage = response['message'] ?? 'Failed to create post.';
            if (response['errors'] != null) {
              _errorMessage = (_errorMessage ?? '') + '\n' + response['errors'].values.expand((e) => e).join('\n');
            }
          });
        }
      } catch (e) {
        setState(() {
          _errorMessage = 'An error occurred: $e';
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationCityController.dispose();
    _sourceInfoController.dispose();
    _townshipController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Post'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Category: ${widget.categoryName}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Subcategory: ${widget.subCategoryName}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _pickImages,
                      icon: const Icon(Icons.image),
                      label: const Text('Select Images (Max 5)'),
                    ),
                    if (_selectedImages.isNotEmpty)
                      SizedBox(
                        height: 100,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _selectedImages.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Stack(
                                children: [
                                  Image.file(
                                    File(_selectedImages[index].path),
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                  ),
                                  Positioned(
                                    right: 0,
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _selectedImages.removeAt(index);
                                        });
                                      },
                                      child: const Icon(
                                        Icons.remove_circle,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    const SizedBox(height: 20),
                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(labelText: 'Title'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(labelText: 'Description'),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a description';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // Map UI and Autocomplete
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Location Search', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        TypeAheadField<String>(
                          controller: _locationCityController,
                          builder: (context, controller, focusNode) => TextField(
                            controller: controller,
                            focusNode: focusNode,
                            autofocus: false,
                            decoration: const InputDecoration(
                              labelText: 'Search City',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          suggestionsCallback: (pattern) async {
                            return await _getSuggestions(pattern);
                          },
                          itemBuilder: (context, suggestion) {
                            // Convert lat,lng back to a readable city name for display
                            List<String> latLng = suggestion.split(',');
                            return FutureBuilder<List<Placemark>>(
                              future: placemarkFromCoordinates(double.parse(latLng[0]), double.parse(latLng[1])),
                              builder: (context, snapshot) {
                                if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                                  Placemark place = snapshot.data!.first;
                                  return ListTile(
                                    title: Text(place.locality ?? place.subAdministrativeArea ?? 'Unknown Location'),
                                    subtitle: Text(place.country ?? ''),
                                  );
                                }
                                return const ListTile(
                                  title: Text('Loading...'),
                                );
                              },
                            );
                          },
                          onSelected: (suggestion) {
                            _onSuggestionSelected(suggestion);
                          },
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 300, // Height for the map
                          child: GoogleMap(
                            onMapCreated: _onMapCreated,
                            initialCameraPosition: CameraPosition(
                              target: _selectedLocation,
                              zoom: 14.0,
                            ),
                            onTap: _onTapMap,
                            markers: _markers,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _sourceInfoController,
                      decoration: const InputDecoration(labelText: 'Source Info'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter source info';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _townshipController,
                      decoration: const InputDecoration(labelText: 'Township'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter township';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _submitPost,
                      child: const Text('Submit Post'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
