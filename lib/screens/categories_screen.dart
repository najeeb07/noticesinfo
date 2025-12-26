import 'package:flutter/material.dart';
import 'package:noticesinfo/services/api_service.dart';
import 'package:noticesinfo/screens/sub_categories_screen.dart'; // Import SubCategoriesScreen
import 'package:provider/provider.dart'; // Import provider
import 'package:noticesinfo/services/translation_service.dart'; // Import TranslationService

import '../l10n/app_localizations.dart'; // Import for AppLocalizations

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  List<dynamic> _categories = [];
  bool _isLoading = true;
  String? _error;

  late TranslationService _translationService;
  late String _targetLanguageCode;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _translationService = Provider.of<TranslationService>(context);
    _targetLanguageCode = AppLocalizations.of(context)?.localeName ?? 'en';
  }

  Future<void> _fetchCategories() async {
    try {
      final response = await ApiService().fetchCategories();
      if (response['success']) {
        setState(() {
          _categories = response['data'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = response['message'] ?? 'Failed to load categories';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'An error occurred: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _error != null
            ? Center(child: Text('Error: $_error'))
            : GridView.builder(
                padding: const EdgeInsets.all(16.0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16.0,
                  mainAxisSpacing: 16.0,
                  childAspectRatio: 1.0, // Adjust as needed
                ),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  final imageUrl = ApiService().getFullImageUrl(category['icon']); // Use ApiService's getFullImageUrl
                  return Card(
                    elevation: 4.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SubCategoriesScreen(
                              categoryId: category['id'],
                              categoryName: category['name'],
                              selectionMode: SubCategorySelectionMode.viewPosts, // Pass viewPosts mode
                            ),
                          ),
                        );
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (imageUrl.isNotEmpty)
                            Image.network(
                              imageUrl,
                              height: 80,
                              width: 80,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.broken_image, size: 80),
                            )
                          else
                            const Icon(Icons.category, size: 80),
                          const SizedBox(height: 8.0),
                          FutureBuilder<String>(
                            future: _translationService.translateText(
                              category['name'],
                              _targetLanguageCode,
                            ),
                            builder: (context, snapshot) {
                              return Text(
                                snapshot.data ?? category['name'],
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
  }
}
