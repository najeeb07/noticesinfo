import 'package:flutter/material.dart';
import 'package:noticesinfo/services/api_service.dart';
import 'package:noticesinfo/screens/sub_categories_screen.dart'; // Import SubCategoriesScreen and SubCategorySelectionMode

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({super.key});

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  List<dynamic> _categories = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Category'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Error: $_error'))
              : _categories.isEmpty
                  ? const Center(child: Text('No categories found.'))
                  : GridView.builder(
                      padding: const EdgeInsets.all(16.0),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3, // Display in 3 columns as requested
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
                                    selectionMode: SubCategorySelectionMode.addPost, // Pass addPost mode
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
                                    height: 40, // Smaller icon for 3 columns
                                    width: 40,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) =>
                                        const Icon(Icons.broken_image, size: 40),
                                  )
                                else
                                  const Icon(Icons.category, size: 40),
                                const SizedBox(height: 8.0),
                                Flexible(
                                  child: Text(
                                    category['name'],
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
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
