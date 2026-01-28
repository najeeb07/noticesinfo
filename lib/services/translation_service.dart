import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_cloud_translation/google_cloud_translation.dart';
import 'package:flutter/foundation.dart'; // Import for ChangeNotifier and kDebugMode
import 'package:flutter/services.dart' show PlatformException;

class TranslationService extends ChangeNotifier {
  static const String _apiKeyStorageKey = 'google_translate_api_key';
  Translation? _translator;

  Future<void> initialize(String? apiKey) async {
    final prefs = await SharedPreferences.getInstance();
    if (apiKey != null && apiKey.isNotEmpty) {
      await prefs.setString(_apiKeyStorageKey, apiKey);
      _translator = Translation(apiKey: apiKey);
    } else {
      final storedApiKey = prefs.getString(_apiKeyStorageKey);
      if (storedApiKey != null && storedApiKey.isNotEmpty) {
        _translator = Translation(apiKey: storedApiKey);
      } else {
        if (kDebugMode) {
          print('Warning: Google Translate API key not provided and not found in shared preferences.');
        }
        _translator = null;
      }
    }
    notifyListeners(); // Notify listeners that the service has been initialized
  }

  Future<String> translateText(String text, String targetLanguage) async {
    // Skip translation if target language is English (default language)
    if (targetLanguage == 'en') {
      return text;
    }

    if (_translator == null || text.trim().isEmpty) {
      if (kDebugMode && text.trim().isNotEmpty) {
        print('Translation service not initialized or API key missing. Returning original text.');
      }
      return text;
    }

    try {
      final response = await _translator!.translate(
        text: text,
        to: targetLanguage,
      );
      return response.translatedText; // Access translated text via .text property
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print('Translation error (PlatformException): ${e.message}');
      }
      return text;
    } catch (e) {
      if (kDebugMode) {
        print('Translation error: $e');
      }
      return text;
    }
  }

  // Method to manually set the API key if it needs to be updated or provided dynamically
  Future<void> setApiKey(String apiKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_apiKeyStorageKey, apiKey);
    _translator = Translation(apiKey: apiKey);
    notifyListeners();
  }

  // Method to retrieve the stored API key
  Future<String?> getApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_apiKeyStorageKey);
  }

  // Method to clear the API key
  Future<void> clearApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_apiKeyStorageKey);
    _translator = null;
  }
}
