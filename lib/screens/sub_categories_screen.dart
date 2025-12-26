import 'package:flutter/material.dart';
import 'package:noticesinfo/services/api_service.dart';
import 'package:noticesinfo/screens/all_posts_screen.dart'; // Import AllPostsScreen
import 'package:noticesinfo/models/post.dart'; // Import Post model
import 'package:noticesinfo/screens/listing_entry_screen.dart'; // Import ListingEntryScreen
import 'package:provider/provider.dart'; // Import provider
import 'package:noticesinfo/services/translation_service.dart';

import '../l10n/app_localizations.dart'; // Import TranslationService

enum SubCategorySelectionMode {
  viewPosts,
  addPost,
}

class SubCategoriesScreen extends StatefulWidget {
  final int categoryId;
  final String categoryName;
  final SubCategorySelectionMode selectionMode; // New parameter

  const SubCategoriesScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
    this.selectionMode = SubCategorySelectionMode.viewPosts, // Default to viewPosts
  });

  @override
  State<SubCategoriesScreen> createState() => _SubCategoriesScreenState();
}

class _SubCategoriesScreenState extends State<SubCategoriesScreen> {
  List<dynamic> _subCategories = [];
  bool _isLoading = true;
  String? _error;

  late TranslationService _translationService;
  late String _targetLanguageCode;

  @override
  void initState() {
    super.initState();
    _fetchSubCategories();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _translationService = Provider.of<TranslationService>(context);
    _targetLanguageCode = AppLocalizations.of(context)?.localeName ?? 'en';
  }

  Future<void> _fetchSubCategories() async {
    try {
      final response = await ApiService().fetchSubCategories(widget.categoryId);
      if (response['success']) {
        setState(() {
          _subCategories = response['data'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = response['message'] ?? 'Failed to load subcategories';
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
    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<String>(
          future: _translationService.translateText(
            '${widget.categoryName} Subcategories',
            _targetLanguageCode,
          ),
          builder: (context, snapshot) {
            return Text(snapshot.data ?? '${widget.categoryName} Subcategories');
          },
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Error: $_error'))
              : _subCategories.isEmpty
                  ? const Center(child: Text('No subcategories found.'))
                  : GridView.builder(
                      padding: const EdgeInsets.all(16.0),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3, // Display in 3 columns as requested
                        crossAxisSpacing: 16.0,
                        mainAxisSpacing: 16.0,
                        childAspectRatio: 1.0, // Adjust as needed
                      ),
                      itemCount: _subCategories.length,
                      itemBuilder: (context, index) {
                        final subCategory = _subCategories[index];
                        final imageUrl = ApiService().getFullImageUrl(subCategory['icon']); // Use ApiService's getFullImageUrl
                        return Card(
                          elevation: 4.0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: InkWell(
                            onTap: () {
                              if (widget.selectionMode == SubCategorySelectionMode.addPost) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ListingEntryScreen(
                                      categoryId: widget.categoryId,
                                      categoryName: widget.categoryName,
                                      subCategoryId: subCategory['id'],
                                      subCategoryName: subCategory['name'],
                                    ),
                                  ),
                                );
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AllPostsScreen(
                                      title: subCategory['name'],
                                      fetchPosts: ({int page = 1}) =>
                                          ApiService().fetchPostsBySubCategory(subCategory['id'], page: page),
                                    ),
                                  ),
                                );
                              }
                            },
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (imageUrl.isNotEmpty)
                                  Image.network(
                                    imageUrl,
                                    height: 40, // Smaller icon for 3 columns
                                    width: 40,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) =>
                                        const Icon(Icons.broken_image, size: 40),
                                  )
                                else
                                const Icon(Icons.category, size: 40),
                                const SizedBox(height: 8.0),
                                FutureBuilder<String>(
                                  future: _translationService.translateText(
                                    subCategory['name'],
                                    _targetLanguageCode,
                                  ),
                                  builder: (context, snapshot) {
                                    return Text(
                                      snapshot.data ?? subCategory['name'],
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 14.0,
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
                    ),
    );
  }
}
