import 'package:flutter/material.dart';
import 'package:noticesinfo/services/api_service.dart';
import 'package:noticesinfo/models/post.dart'; // Import Post model
import 'package:noticesinfo/widgets/post_card.dart'; // Import PostCard widget
import 'package:noticesinfo/screens/post_detail_screen.dart'; // Import PostDetailScreen

import '../main.dart'; // Import MainScreen

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ApiService _apiService = ApiService();
  String _userName = 'Guest User';
  String _userEmail = 'N/A';
  String _joinedDate = 'N/A';
  int _totalPosts = 0;
  int _totalFollowers = 0;
  int _totalFollowing = 0;
  bool _isLoading = true;
  int? _loggedInUserId; // To store the logged-in user's ID
  String? _profileImageUrl; // To store the user's profile picture URL
  List<Post> _userPosts = [];
  int _currentPage = 1;
  int _lastPage = 1;
  bool _isLoadingUserPosts = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent &&
          _currentPage < _lastPage &&
          !_isLoadingUserPosts) {
        _loadMoreUserPosts();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Ensure profile data is refreshed when returning from profile edit screen
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    setState(() {
      _isLoading = true;
    });

    final result = await _apiService.fetchUserProfile();

    if (result['success'] && result['data'] != null) {
      final userData = result['data'];
      setState(() {
        _userName = userData['name'] ?? 'Guest User';
        _userEmail = userData['email'] ?? 'N/A';
        _totalPosts = userData['total_posts'] ?? 0;
        _totalFollowers = userData['total_followers'] ?? 0;
        _totalFollowing = userData['total_following'] ?? 0;
        _profileImageUrl = userData['profile_pic']; // Update profile image URL

        // Assuming 'created_at' is available in the user data if needed for joined date
        // For now, using the existing _apiService.getUserCreatedAt() if 'created_at' is not in /me response
        // If /me response includes 'created_at', prefer that.
        final String? createdAt = userData['created_at'] ?? _apiService.currentUserCreatedAt;
        if (createdAt != null && createdAt.isNotEmpty) {
          try {
            final DateTime dateTime = DateTime.parse(createdAt);
            _joinedDate = '${dateTime.day}-${dateTime.month}-${dateTime.year}';
          } catch (e) {
            _joinedDate = 'N/A';
          }
        } else {
          _joinedDate = 'N/A';
        }
      });
    } else {
      // Fallback to locally stored data if API call fails or no data
      final String? name = await _apiService.getUserName();
      final String? email = await _apiService.getUserEmail();
      final String? createdAt = await _apiService.getUserCreatedAt();

      setState(() {
        _userName = name ?? 'Guest User';
        _userEmail = email ?? 'N/A';
        // total_posts, followers, following will remain 0 or dummy if not fetched from API
        if (createdAt != null && createdAt.isNotEmpty) {
          try {
            final DateTime dateTime = DateTime.parse(createdAt);
            _joinedDate = '${dateTime.day}-${dateTime.month}-${dateTime.year}';
          } catch (e) {
            _joinedDate = 'N/A';
          }
        } else {
          _joinedDate = 'N/A';
        }
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Failed to load profile data.')),
        );
      }
    }
    setState(() {
      _isLoading = false;
    });

    _loggedInUserId = await _apiService.getUserId();
    if (_loggedInUserId != null) {
      _fetchUserPosts(); // Fetch posts after user profile is loaded and ID is available
    }
  }

  Future<void> _fetchUserPosts() async {
    if (_isLoadingUserPosts || _loggedInUserId == null) return;
    setState(() {
      _isLoadingUserPosts = true;
    });

    try {
      final response = await _apiService.getAuthorPosts(_loggedInUserId!, _currentPage);
      if (response['success']) {
        final List<dynamic> postData = response['data']['posts'];
        final paginationData = response['data']['pagination'];

        setState(() {
          _userPosts.addAll(postData.map((json) => Post.fromJson(json)).toList());
          _lastPage = paginationData['last_page'];
          _isLoadingUserPosts = false;
        });
      }
    } catch (e) {
      print('Error fetching user posts: $e');
      setState(() {
        _isLoadingUserPosts = false;
      });
    }
  }

  Future<void> _loadMoreUserPosts() async {
    if (_currentPage < _lastPage) {
      setState(() {
        _currentPage++;
      });
      await _fetchUserPosts();
    }
  }

  void _navigateToPostDetail(Post post) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PostDetailScreen(postId: post.id!),
      ),
    );
  }

  Future<void> _logoutUser() async {
    final result = await _apiService.logoutApi();
    if (mounted) {
      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'])),
        );
        // After successful logout, navigate back to the login screen
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const MainScreen(initialIndex: 0)), // Navigate to MainScreen, showing Home tab
          (Route<dynamic> route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Failed to logout.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.purple,
                  backgroundImage: _profileImageUrl != null && _profileImageUrl!.isNotEmpty
                      ? NetworkImage(_profileImageUrl!) as ImageProvider?
                      : null,
                  child: _profileImageUrl == null || _profileImageUrl!.isEmpty
                      ? const Icon(Icons.person, size: 60, color: Colors.white)
                      : null,
                ),
                const SizedBox(height: 10),
                Text(
                  _userName,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                Text(
                  _userEmail,
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
                Text(
                  'Joined On $_joinedDate',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 15),
                ElevatedButton.icon(
                  onPressed: () {
                    // Handle verify action
                  },
                  icon: const Icon(Icons.verified_user, color: Colors.blue),
                  label: const Text('Verify', style: TextStyle(color: Colors.blue)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[200],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatColumn(_totalPosts.toString(), 'Listing'),
                      _buildStatColumn(_totalFollowers.toString(), 'Followers'),
                      _buildStatColumn(_totalFollowing.toString(), 'Following'),
                    ],
                  ),
                ),
                const Divider(),
                const SizedBox(height: 20),
                Text(
                  'My Posts',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 10),
                _userPosts.isEmpty && _isLoadingUserPosts
                    ? const Center(child: CircularProgressIndicator())
                    : _userPosts.isEmpty
                        ? const Center(child: Text('No posts found.'))
                        : ListView.builder(
                            controller: _scrollController,
                            shrinkWrap: true, // Important for nested scroll views
                            physics: const NeverScrollableScrollPhysics(), // Disable scrolling for this ListView
                            itemCount: _userPosts.length + (_isLoadingUserPosts ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index == _userPosts.length) {
                                return const Center(child: CircularProgressIndicator());
                              }
                              final post = _userPosts[index];
                              return GestureDetector(
                                onTap: () => _navigateToPostDetail(post),
                                child: PostCard(post: post),
                              );
                            },
                          ),
                const SizedBox(height: 20),
              ],
            ),
          );
  }

  static Widget _buildStatColumn(String count, String label) {
    return Column(
      children: [
        Text(
          count,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
      ],
    );
  }
}
