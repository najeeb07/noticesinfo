import 'dart:developer' as developer;
import 'dart:io'; // For File
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Import image_picker
import 'package:noticesinfo/services/api_service.dart';
import 'package:noticesinfo/models/post_detail.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart'; // Import google_maps_flutter
import 'package:geocoding/geocoding.dart'; // Import geocoding
import 'package:flutter_typeahead/flutter_typeahead.dart'; // Import flutter_typeahead

class EditPostScreen extends StatefulWidget {
  final PostDetailData post;
  final int categoryId; // Parent category ID
  final int subCategoryId; // Subcategory ID

  const EditPostScreen({
    super.key,
    required this.post,
    required this.categoryId,
    required this.subCategoryId,
  });

  @override
  State<EditPostScreen> createState() => _EditPostScreenState();
}

class _EditPostScreenState extends State<EditPostScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _locationCityController;
  late TextEditingController _sourceInfoController;
  late TextEditingController _townshipController;

  bool _isLoading = false;
  String? _errorMessage;
  List<XFile> _selectedImages = []; // To store newly selected images
  List<String> _existingImageUrls = []; // To store existing image URLs
  final ImagePicker _picker = ImagePicker(); // Image picker instance

  GoogleMapController? _mapController;
  late LatLng _selectedLocation;
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    
    // Initialize controllers with existing post data
    _titleController = TextEditingController(text: widget.post.title);
    _descriptionController = TextEditingController(text: widget.post.description);
    _locationCityController = TextEditingController(text: widget.post.locationCity);
    _sourceInfoController = TextEditingController(text: widget.post.sourceInfo);
    _townshipController = TextEditingController(text: widget.post.township);
    
    // Set initial location from existing post
    double lat = double.tryParse(widget.post.lat ?? '0') ?? 17.4065;
    double lng = double.tryParse(widget.post.lng ?? '0') ?? 78.4772;
    _selectedLocation = LatLng(lat, lng);
    
    // Load existing images
    _existingImageUrls = widget.post.media.map((m) => m.url).toList();
    
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
          // Limit to 5 images total (including existing)
          int maxNew = 5 - _existingImageUrls.length;
          _selectedImages = images.take(maxNew).toList();
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
      }
    } catch (e) {
      developer.log('Error getting placemark: $e', name: 'EditPostScreen');
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
      developer.log('Error getting location suggestions: $e', name: 'EditPostScreen');
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
      }
    } catch (e) {
      developer.log('Error getting placemark from suggestion: $e', name: 'EditPostScreen');
    }
  }

  Future<void> _submitEdit() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final ApiService apiService = ApiService();
      final int? userId = await apiService.getUserId(); // Get user ID from ApiService

      if (userId == null) {
        setState(() {
          _errorMessage = 'User not logged in. Please log in to edit the post.';
          _isLoading = false;
        });
        return;
      }

      try {
        final response = await apiService.updatePost(
          postId: widget.post.id,
          userId: userId,
          title: _titleController.text,
          description: _descriptionController.text,
          categoryId: widget.subCategoryId,
          parentCategoryId: widget.categoryId,
          locationCity: _locationCityController.text,
          lat: _selectedLocation.latitude,
          lng: _selectedLocation.longitude,
          sourceInfo: _sourceInfoController.text,
          township: _townshipController.text,
          media: _selectedImages.isNotEmpty 
              ? _selectedImages.map((image) => image.path).toList() 
              : null, // Only pass media if new images are selected
        );

        developer.log('API Response: $response', name: 'EditPostScreen');
        developer.log('Response success status: ${response['success']}', name: 'EditPostScreen');

        if (response['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Post updated successfully!')),
          );
          // Pop back to the post detail screen with a result indicating success
          Navigator.pop(context, true);
        } else {
          setState(() {
            _errorMessage = response['message'] ?? 'Failed to update post.';
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

  void _removeExistingImage(int index) {
    setState(() {
      _existingImageUrls.removeAt(index);
    });
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
        title: const Text('Edit Post'),
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
                      'Category: ${widget.post.category.name}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    
                    // Existing Images Section
                    if (_existingImageUrls.isNotEmpty) ...[
                      const Text(
                        'Current Images:',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 100,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _existingImageUrls.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Stack(
                                children: [
                                  Image.network(
                                    ApiService().getFullImageUrl(_existingImageUrls[index]),
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        width: 80,
                                        height: 80,
                                        color: Colors.grey[300],
                                        child: const Icon(Icons.broken_image),
                                      );
                                    },
                                  ),
                                  Positioned(
                                    right: 0,
                                    child: GestureDetector(
                                      onTap: () => _removeExistingImage(index),
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
                      const SizedBox(height: 10),
                    ],
                    
                    ElevatedButton.icon(
                      onPressed: _pickImages,
                      icon: const Icon(Icons.image),
                      label: Text('Add New Images (Max ${5 - _existingImageUrls.length})'),
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
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submitEdit,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Update Post'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
