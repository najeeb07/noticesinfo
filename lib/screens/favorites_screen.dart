import 'package:flutter/material.dart';
import 'package:noticesinfo/services/api_service.dart';
import 'package:noticesinfo/models/favorite_post.dart';
import 'package:noticesinfo/screens/post_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final ApiService _apiService = ApiService();
  late Future<Map<String, dynamic>> _favoritesFuture;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLoginAndFetchFavorites();
  }

  Future<void> _checkLoginAndFetchFavorites() async {
    final userId = await _apiService.getUserId();
    setState(() {
      _isLoggedIn = userId != null;
    });
    
    if (_isLoggedIn) {
      _favoritesFuture = _apiService.fetchMyFavorites();
    }
  }

  Future<void> _refreshFavorites() async {
    setState(() {
      _favoritesFuture = _apiService.fetchMyFavorites();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoggedIn) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_border,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Please login to view favorites',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshFavorites,
      child: FutureBuilder<Map<String, dynamic>>(
        future: _favoritesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _refreshFavorites,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          } else if (snapshot.hasData) {
            final response = snapshot.data!;
            
            if (response['success'] != true) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 60, color: Colors.orange),
                    const SizedBox(height: 16),
                    Text(response['message'] ?? 'Failed to load favorites'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _refreshFavorites,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            final List<dynamic> favoritesData = response['data'] ?? [];
            
            if (favoritesData.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.favorite_border,
                      size: 80,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No favorites yet',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Start adding posts to your favorites!',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              );
            }

            final List<FavoritePost> favorites = favoritesData
                .map((json) => FavoritePost.fromJson(json))
                .toList();

            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final post = favorites[index];
                return _buildFavoriteCard(post);
              },
            );
          } else {
            return const Center(child: Text('No data available.'));
          }
        },
      ),
    );
  }

  Widget _buildFavoriteCard(FavoritePost post) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PostDetailScreen(postId: post.id),
            ),
          ).then((_) => _refreshFavorites()); // Refresh after returning
        },
        borderRadius: BorderRadius.circular(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            if (post.image != null && post.image!.isNotEmpty)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12.0)),
                child: Image.network(
                  _apiService.getFullImageUrl(post.image),
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: double.infinity,
                      height: 200,
                      color: Colors.grey[300],
                      child: const Icon(Icons.image_not_supported, size: 50),
                    );
                  },
                ),
              ),
            
            // Content
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    post.title ?? 'No Title',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  
                  // Location
                  if (post.locationCity != null || post.township != null)
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${post.locationCity ?? ''}, ${post.township ?? ''}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 8),
                  
                  // Description
                  if (post.description != null && post.description!.isNotEmpty)
                    Text(
                      post.description!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 12),
                  
                  // Footer with author and views
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Author
                      if (post.user != null)
                        Row(
                          children: [
                            const CircleAvatar(
                              radius: 12,
                              backgroundColor: Colors.grey,
                              child: Icon(Icons.person, size: 14, color: Colors.white),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              post.user!.name,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      
                      // Views
                      if (post.views != null)
                        Row(
                          children: [
                            const Icon(Icons.remove_red_eye, size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              '${post.views}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
