import 'package:shared_preferences/shared_preferences.dart';

class LocationStorageService {
  static const String _cityKey = 'selectedCity';
  static const String _latitudeKey = 'selectedLatitude';
  static const String _longitudeKey = 'selectedLongitude';

  Future<void> saveCity({required String city, required double latitude, required double longitude}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cityKey, city);
    await prefs.setDouble(_latitudeKey, latitude);
    await prefs.setDouble(_longitudeKey, longitude);
  }

  Future<Map<String, dynamic>?> getSavedCity() async {
    final prefs = await SharedPreferences.getInstance();
    final city = prefs.getString(_cityKey);
    final latitude = prefs.getDouble(_latitudeKey);
    final longitude = prefs.getDouble(_longitudeKey);

    if (city != null && latitude != null && longitude != null) {
      return {
        'city': city,
        'latitude': latitude,
        'longitude': longitude,
      };
    }
    return null;
  }

  Future<void> clearSavedCity() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cityKey);
    await prefs.remove(_latitudeKey);
    await prefs.remove(_longitudeKey);
  }
}
