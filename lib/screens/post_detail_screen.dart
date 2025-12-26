import 'package:flutter/material.dart';
import 'package:noticesinfo/models/post_detail.dart';
import 'package:noticesinfo/services/api_service.dart';
import 'package:noticesinfo/screens/full_screen_image_screen.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:noticesinfo/screens/generic_content_screen.dart';
import 'package:noticesinfo/screens/faq_screen.dart';
import 'package:noticesinfo/screens/author_posts_screen.dart'; // Import the new screen
import 'package:noticesinfo/screens/edit_post_screen.dart'; // Import edit post screen
import 'package:share_plus/share_plus.dart'; // Import share_plus package

import '../l10n/app_localizations.dart';
import '../models/author.dart'; // Used for FAQ navigation
import 'package:provider/provider.dart'; // Import provider
import 'package:noticesinfo/services/translation_service.dart'; // Import TranslationService

class PostDetailScreen extends StatefulWidget {
  final int postId;

  const PostDetailScreen({Key? key, required this.postId}) : super(key: key);

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  late Future<PostDetailResponse> _postDetailFuture;
  final PageController _pageController = PageController();
  final ApiService _apiService = ApiService();
  bool _isFollowing = false;
  int? _currentUserId;
  int _authorTotalPosts = 0;
  int _authorTotalFollowers = 0;
  bool _isFavorited = false; // Track favorite status
  PostDetailData? _postData; // Store post data for edit functionality

  late TranslationService _translationService;
  late String _targetLanguageCode;

  @override
  void initState() {
    super.initState();
    _postDetailFuture = _apiService.fetchPostDetail(widget.postId);
    // Note: The fetchPostDetail endpoint automatically increments the view count on the backend
    // No need to call viewPost separately as it would cause double-counting
    _loadCurrentUserAndAuthorProfile();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _translationService = Provider.of<TranslationService>(context);
    _targetLanguageCode = AppLocalizations.of(context)?.localeName ?? 'en';
  }

  Future<void> _loadCurrentUserAndAuthorProfile() async {
    _currentUserId = await _apiService.getUserId();

    // After fetching post details, get the author's ID and fetch their profile
    final postDetailResponse = await _postDetailFuture;
    final authorId = postDetailResponse.data.author.id;

    // Only fetch author profile if a user is logged in
    if (_currentUserId != null) {
      final authorProfileResult = await _apiService.fetchAuthorProfile(authorId);

      if (authorProfileResult['success'] && authorProfileResult['data'] != null) {
        final authorData = authorProfileResult['data'];
        setState(() {
          _authorTotalPosts = authorData['total_posts'] ?? 0;
          _authorTotalFollowers = authorData['total_followers'] ?? 0;
          _isFollowing = authorData['is_following'] ?? false;
        });
      } else {
        // Handle error or set default values if author profile fetch fails
        setState(() {
          _authorTotalPosts = 0;
          _authorTotalFollowers = 0;
          _isFollowing = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(authorProfileResult['message'] ?? 'Failed to load author profile.')),
          );
        }
      }
    } else {
      // If user is not logged in, set default values for author stats and following status
      setState(() {
        _authorTotalPosts = 0; // Not available from PostDetail if user is not logged in
        _authorTotalFollowers = postDetailResponse.data.author.followersCount ?? 0;
        _isFollowing = false; // Not logged in, so cannot be following
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _sharePost(int postId) async {
    try {
      final response = await _apiService.sharePost(postId);
      if (response['success'] == true && response['data'] != null && response['data']['share_url'] != null) {
        final String shareUrl = response['data']['share_url'];
        await Share.share(shareUrl);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? 'Failed to generate share link.')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $error')),
      );
    }
  }

  // Added _navigateToContentScreen method
  Future<void> _navigateToContentScreen(
      BuildContext context, String title, String url) async {
    try {
      final response = await _apiService.fetchData(url);
      if (response['success'] == true) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (ctx) => GenericContentScreen(
              title: title,
              content: response['data']['content'],
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load $title')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $error')),
      );
    }
  }

  Future<void> _toggleFavorite() async {
    // Check if user is logged in
    if (_currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to add favorites')),
      );
      return;
    }

    try {
      final response = await _apiService.toggleFavorite(widget.postId);
      if (response['success'] == true) {
        setState(() {
          _isFavorited = response['favorited'] ?? false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? 'Favorite status updated')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? 'Failed to update favorite')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $error')),
      );
    }
  }


  void _navigateToEditPost() {
    if (_postData != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EditPostScreen(
            post: _postData!,
            categoryId: _postData!.parentCategory.id, // Parent category ID from post data
            subCategoryId: _postData!.category.id, // Subcategory ID from post data
          ),
        ),
      ).then((result) {
        if (result == true) {
          // Refresh the post detail if edit was successful
          setState(() {
            _postDetailFuture = _apiService.fetchPostDetail(widget.postId);
          });
          _loadCurrentUserAndAuthorProfile();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          // Edit button - only show if current user is the author
          if (_postData != null && _currentUserId != null && _currentUserId == _postData!.author.id)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: _navigateToEditPost,
              tooltip: 'Edit Post',
            ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _sharePost(widget.postId),
          ),
        ],
      ),
      body: FutureBuilder<PostDetailResponse>(
        future: _postDetailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final post = snapshot.data!.data;
            // Store post data for edit functionality
            if (_postData == null || _postData!.id != post.id) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                setState(() {
                  _postData = post;
                });
              });
            }
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 250,
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: post.media.length,
                      itemBuilder: (context, index) {
                        final mediaItem = post.media[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FullScreenImageScreen(
                                  imageUrl: ApiService().getFullImageUrl(mediaItem.url),
                                ),
                              ),
                            );
                          },
                          child: Image.network(
                            ApiService().getFullImageUrl(mediaItem.url),
                            width: double.infinity,
                            height: 250,
                            fit: BoxFit.cover,
                          ),
                        );
                      },
                    ),
                  ),
                  if (post.media.isNotEmpty)
                    Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: SmoothPageIndicator(
                          controller: _pageController,
                          count: post.media.length,
                          effect: const WormEffect(
                            dotHeight: 8.0,
                            dotWidth: 8.0,
                            type: WormType.thinUnderground,
                          ),
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: FutureBuilder<String>(
                                future: _translationService.translateText(
                                    post.title, _targetLanguageCode),
                                builder: (context, snapshot) {
                                  return Text(
                                    snapshot.data ?? post.title,
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  );
                                },
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                _isFavorited ? Icons.favorite : Icons.favorite_border,
                                color: _isFavorited ? Colors.red : Colors.grey,
                              ),
                              onPressed: _toggleFavorite,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        FutureBuilder<String>(
                          future: _translationService.translateText(
                              '${post.locationCity}, ${post.township}',
                              _targetLanguageCode),
                          builder: (context, snapshot) {
                            return Text(
                              snapshot.data ?? '${post.locationCity}, ${post.township}',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        FutureBuilder<String>(
                          future: _translationService.translateText('Description', _targetLanguageCode),
                          builder: (context, snapshot) {
                            return Text(
                              snapshot.data ?? 'Description',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 8),
                        FutureBuilder<String>(
                          future: _translationService.translateText(post.description, _targetLanguageCode),
                          builder: (context, snapshot) {
                            return Text(
                              snapshot.data ?? post.description,
                              style: const TextStyle(fontSize: 16),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        FutureBuilder<String>(
                          future: _translationService.translateText('Source of Information', _targetLanguageCode),
                          builder: (context, snapshot) {
                            return Text(
                              snapshot.data ?? 'Source of Information',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 8),
                        FutureBuilder<String>(
                          future: _translationService.translateText(post.sourceInfo, _targetLanguageCode),
                          builder: (context, snapshot) {
                            return Text(
                              snapshot.data ?? post.sourceInfo,
                              style: const TextStyle(fontSize: 16),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.info_outline, color: Colors.deepPurple),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    FutureBuilder<String>(
                                      future: _translationService.translateText('Safety Tips', _targetLanguageCode),
                                      builder: (context, snapshot) {
                                        return Text(
                                          snapshot.data ?? 'Safety Tips',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        );
                                      },
                                    ),
                                    const SizedBox(height: 4),
                                    FutureBuilder<String>(
                                      future: _translationService.translateText(
                                          'Safety is everyone\'s responsibility, and staying informed is the first step. The',
                                          _targetLanguageCode),
                                      builder: (context, snapshot) {
                                        return Text(
                                          snapshot.data ??
                                              'Safety is everyone\'s responsibility, and staying informed is the first step. The',
                                          style: const TextStyle(fontSize: 14),
                                        );
                                      },
                                    ),
                                    Align(
                                      alignment: Alignment.bottomRight,
                                      child: GestureDetector(
                                        onTap: () {
                                          _navigateToContentScreen(
                                              context, 'Safety Tips', '/safety-tips');
                                        },
                                        child: FutureBuilder<String>(
                                          future: _translationService.translateText('READ MORE', _targetLanguageCode),
                                          builder: (context, snapshot) {
                                            return Text(
                                              snapshot.data ?? 'READ MORE',
                                              style: const TextStyle(
                                                color: Colors.deepPurple,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSectionCard(
                    context,
                    icon: Icons.description,
                    title: 'Terms & Conditions',
                    content:
                        'Welcome to Notices Info. By downloading, accessing, or using this app, you agree to',
                    onReadMore: () {
                      _navigateToContentScreen(
                          context, 'Terms & Conditions', '/terms');
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildSectionCard(
                    context,
                    icon: Icons.help_outline,
                    title: 'Frequently Asked Questions',
                    content:
                        '1. What is Notices Info?\nNotices Info is a community-driven app that\n\n2. How do I post a notice on Notices Info?',
                    onReadMore: () {
                      Navigator.of(context).pushNamed(FaqScreen.routeName);
                    },
                  ),
                  // const SizedBox(height: 16),
                  // _buildStatisticCard(post.views, post.likes),
                  const SizedBox(height: 16),
                  _buildAuthorCard(post.author),
                ],
              ),
            );
          } else {
            return const Center(child: Text('No post data available.'));
          }
        },
      ),
    );
  }

  Widget _buildSectionCard(BuildContext context,
      {required IconData icon,
      required String title,
      required String content,
      required VoidCallback onReadMore}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey[200], // Changed to match Safety Tips
        borderRadius: BorderRadius.circular(8.0),
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
          Row(
            children: [
              Icon(icon, color: Colors.deepPurple), // Changed icon color to match Safety Tips
              const SizedBox(width: 8),
              Expanded(
                child: FutureBuilder<String>(
                  future: _translationService.translateText(title, _targetLanguageCode),
                  builder: (context, snapshot) {
                    return Text(
                      snapshot.data ?? title,
                      style: const TextStyle(
                        fontSize: 16, // Reduced font size
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
              ),
              const Icon(Icons.keyboard_arrow_up),
            ],
          ),
          const SizedBox(height: 8),
          FutureBuilder<String>(
            future: _translationService.translateText(content, _targetLanguageCode),
            builder: (context, snapshot) {
              return Text(
                snapshot.data ?? content,
                style: const TextStyle(fontSize: 14), // Reduced font size
              );
            },
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: GestureDetector(
              onTap: onReadMore,
              child: FutureBuilder<String>(
                future: _translationService.translateText('READ MORE', _targetLanguageCode),
                builder: (context, snapshot) {
                  return Text(
                    snapshot.data ?? 'READ MORE',
                    style: const TextStyle(
                      color: Colors.deepPurple,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticCard(int views, int likes) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
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
          Row(
            children: [
              const Icon(Icons.bar_chart, color: Colors.black87),
              const SizedBox(width: 8),
              Expanded(
                child: FutureBuilder<String>(
                  future: _translationService.translateText('Statistic', _targetLanguageCode),
                  builder: (context, snapshot) {
                    return Text(
                      snapshot.data ?? 'Statistic',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
              ),
              const Icon(Icons.keyboard_arrow_up),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  Text(
                    views.toString(),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.remove_red_eye, size: 18, color: Colors.grey),
                      const SizedBox(width: 4),
                      FutureBuilder<String>(
                        future: _translationService.translateText('Views', _targetLanguageCode),
                        builder: (context, snapshot) {
                          return Text(snapshot.data ?? 'Views',
                              style: const TextStyle(fontSize: 16, color: Colors.grey));
                        },
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                height: 50,
                width: 1,
                color: Colors.grey,
              ),
              Column(
                children: [
                  Text(
                    likes.toString(),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.favorite_border, size: 18, color: Colors.grey),
                      const SizedBox(width: 4),
                      FutureBuilder<String>(
                        future: _translationService.translateText('Likes', _targetLanguageCode),
                        builder: (context, snapshot) {
                          return Text(snapshot.data ?? 'Likes',
                              style: const TextStyle(fontSize: 16, color: Colors.grey));
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAuthorCard(Author author) {
    // Check if the current user is the author of the post
    final bool isCurrentUserAuthor = (_currentUserId == author.id);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
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
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                // backgroundImage: NetworkImage(ApiService().getFullImageUrl(author.avatar)),
                backgroundColor: Colors.grey[200],
              ),
              const SizedBox(width: 16),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AuthorPostsScreen(
                              authorId: author.id,
                              authorName: author.name,
                            ),
                          ),
                        );
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            author.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            author.name, // Assuming author.name is also the email for now
                            style: const TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: List.generate(5, (index) {
                              return Icon(
                                index < author.id ? Icons.star : Icons.star_border,
                                color: Colors.amber,
                                size: 20,
                              );
                            }),
                          ),
                        ],
                      ),
                    ),
                  ),
              // Add Follow/Following button if not the current user
              if (!isCurrentUserAuthor && _currentUserId != null)
                SizedBox(
                  width: 100, // Fixed width for the button
                  child: ElevatedButton(
                    onPressed: () async {
                      final response = await _apiService.toggleFollowUser(author.id);
                      if (response['success'] == true) {
                        setState(() {
                        final String? status = response['data']['status'];
                        _isFollowing = (status == 'followed'); // Changed to check for 'followed' status
                        _authorTotalFollowers = response['data']['total_followers'] ?? _authorTotalFollowers;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(response['message'])),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to update follow status: ${response['message'] ?? 'Unknown error'}')),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isFollowing ? Colors.grey : Colors.deepPurple,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), // Adjust padding
                    ),
                    child: FutureBuilder<String>(
                      future: _translationService.translateText(
                          _isFollowing ? 'Following' : 'Follow', _targetLanguageCode),
                      builder: (context, snapshot) {
                        return Text(
                          snapshot.data ?? (_isFollowing ? 'Following' : 'Follow'),
                          style: const TextStyle(fontSize: 14),
                        );
                      },
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  Text(
                    _authorTotalPosts.toString(),
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  FutureBuilder<String>(
                    future: _translationService.translateText('Posts', _targetLanguageCode),
                    builder: (context, snapshot) {
                      return Text(
                        snapshot.data ?? 'Posts',
                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                      );
                    },
                  ),
                ],
              ),
              Column(
                children: [
                  Text(
                    _authorTotalFollowers.toString(),
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  FutureBuilder<String>(
                    future: _translationService.translateText('Followers', _targetLanguageCode),
                    builder: (context, snapshot) {
                      return Text(
                        snapshot.data ?? 'Followers',
                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
