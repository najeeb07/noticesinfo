import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:noticesinfo/models/search_post.dart'; // Changed from Post
import 'package:noticesinfo/services/api_service.dart';
import 'package:noticesinfo/screens/post_detail_screen.dart';

class SearchResultsScreen extends StatefulWidget {
  final String searchQuery;
  final Future<List<SearchPost>> Function({required String query, int page}) fetchPosts; // Changed to SearchPost

  const SearchResultsScreen({
    super.key,
    required this.searchQuery,
    required this.fetchPosts,
  });

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  final ApiService _apiService = ApiService();
  List<SearchPost> _posts = []; // Changed to SearchPost
  bool _isLoading = true;
  int _currentPage = 1;
  bool _hasMore = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchPosts();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent && _hasMore) {
        _fetchPosts();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchPosts() async {
    if (!_hasMore && _currentPage > 1) return;
    setState(() {
      _isLoading = true;
    });

    try {
      final fetchedPosts = await widget.fetchPosts(query: widget.searchQuery, page: _currentPage);
      setState(() {
        if (fetchedPosts.isEmpty) {
          _hasMore = false;
        } else {
          _posts.addAll(fetchedPosts);
          _currentPage++;
        }
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching search posts: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Results for "${widget.searchQuery}"'),
      ),
      body: _posts.isEmpty && _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _posts.isEmpty && !_isLoading
              ? Center(child: Text('No posts found for "${widget.searchQuery}"'))
              : GridView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(8.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
                    childAspectRatio: 0.7,
                  ),
                  itemCount: _posts.length + (_hasMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _posts.length) {
                      return _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : const SizedBox.shrink();
                    }
                    final post = _posts[index];
                    return _buildPostGridItem(post);
                  },
                ),
    );
  }

  Widget _buildPostGridItem(SearchPost post) { // Changed to SearchPost
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PostDetailScreen(postId: post.id),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: Image.network(
                    _apiService.getFullImageUrl(post.image),
                    height: 100,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        'assets/image/notices_logo.png',
                        height: 100,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      );
                    },
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.favorite_border,
                      color: Colors.grey,
                      size: 20,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.visibility,
                          color: Colors.white,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${post.views}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    post.description,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.person, size: 12, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          post.author,
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (post.distanceKm != null) ...[
                        const SizedBox(width: 8),
                        const Icon(Icons.location_on, size: 12, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          '${post.distanceKm!.toStringAsFixed(1)} km',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    post.date,
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
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
