import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

enum LocationStatus {
  granted,
  denied,
  deniedForever,
  serviceDisabled,
  unknown,
}

class LocationService {
  static bool _isRequestingPermission = false; // Static flag to prevent multiple permission requests

  Future<Map<String, dynamic>> getCurrentCityWithStatus() async {
    bool serviceEnabled;
    LocationPermission permission;
    String? city;
    double? latitude;
    double? longitude;
    LocationStatus status = LocationStatus.unknown;

    print("LocationService: Checking if location services are enabled.");
    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print("LocationService: Location services are disabled.");
      status = LocationStatus.serviceDisabled; // Indicate that services were disabled
      return {'status': status, 'city': null, 'latitude': null, 'longitude': null};
    }
    print("LocationService: Location services are enabled.");

    print("LocationService: Checking current permission status.");
    permission = await Geolocator.checkPermission();
    print("LocationService: Current permission status: $permission");

    if (permission == LocationPermission.denied) {
      if (_isRequestingPermission) {
        // If a permission request is already in progress, wait for it to complete
        // or return current status to avoid multiple prompts.
        // For simplicity, we'll just return the denied status here.
        print("LocationService: Permission request already in progress. Returning denied status.");
        status = LocationStatus.denied;
        return {'status': status, 'city': null, 'latitude': null, 'longitude': null};
      }

      _isRequestingPermission = true;
      print("LocationService: Permissions denied, requesting permissions.");
      try {
        permission = await Geolocator.requestPermission();
      } finally {
        _isRequestingPermission = false; // Reset flag after request completes
      }
      print("LocationService: Permission after request: $permission");
      if (permission == LocationPermission.denied) {
        status = LocationStatus.denied;
        return {'status': status, 'city': null, 'latitude': null, 'longitude': null};
      }
    }

    if (permission == LocationPermission.deniedForever) {
      status = LocationStatus.deniedForever;
      return {'status': status, 'city': null, 'latitude': null, 'longitude': null};
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      latitude = position.latitude;
      longitude = position.longitude;

      List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      );
      if (placemarks.isNotEmpty) {
        city = placemarks.first.locality;
        status = LocationStatus.granted;
      }
    } catch (e) {
      print("Error getting city from coordinates: $e");
      status = LocationStatus.unknown; // Or a more specific error status
    }
    return {'status': status, 'city': city, 'latitude': latitude, 'longitude': longitude};
  }
}
