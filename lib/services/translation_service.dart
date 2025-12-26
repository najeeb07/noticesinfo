import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_cloud_translation/google_cloud_translation.dart';
import 'package:flutter/foundation.dart'; // Import for ChangeNotifier and kDebugMode
import 'package:flutter/services.dart' show PlatformException;

class TranslationService extends ChangeNotifier {
  static const String _apiKeyStorageKey = 'google_translate_api_key';
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  Translation? _translator; // Changed GoogleCloudTranslation to Translation

  Future<void> initialize(String? apiKey) async {
    if (apiKey != null && apiKey.isNotEmpty) {
      await _secureStorage.write(key: _apiKeyStorageKey, value: apiKey);
      _translator = Translation(apiKey: apiKey); // Changed GoogleCloudTranslation to Translation
    } else {
      final storedApiKey = await _secureStorage.read(key: _apiKeyStorageKey);
      if (storedApiKey != null && storedApiKey.isNotEmpty) {
        _translator = Translation(apiKey: storedApiKey); // Changed GoogleCloudTranslation to Translation
      } else {
        if (kDebugMode) {
          print('Warning: Google Translate API key not provided and not found in secure storage.');
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
        text: text, // Changed to named argument
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
    await _secureStorage.write(key: _apiKeyStorageKey, value: apiKey);
    _translator = Translation(apiKey: apiKey); // Changed GoogleCloudTranslation to Translation
    notifyListeners();
  }

  // Method to retrieve the stored API key
  Future<String?> getApiKey() async {
    return await _secureStorage.read(key: _apiKeyStorageKey);
  }

  // Method to clear the API key
  Future<void> clearApiKey() async {
    await _secureStorage.delete(key: _apiKeyStorageKey);
    _translator = null;
  }
}
