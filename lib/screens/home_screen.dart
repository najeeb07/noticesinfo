import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:noticesinfo/widgets/side_menu.dart';
import 'package:noticesinfo/services/api_service.dart'; // Import ApiService
import 'package:noticesinfo/models/app_slider.dart'; // Import AppSlider model
import 'package:noticesinfo/models/post.dart'; // Import Post model
import 'package:url_launcher/url_launcher.dart'; // Import url_launcher
import 'dart:async'; // Import for Timer
import 'package:noticesinfo/screens/all_posts_screen.dart'; // Import AllPostsScreen
import 'package:noticesinfo/screens/post_detail_screen.dart'; // Import PostDetailScreen
import 'package:noticesinfo/screens/search_results_screen.dart'; // Import SearchResultsScreen
import 'package:noticesinfo/services/location_storage_service.dart'; // Import LocationStorageService
import 'package:noticesinfo/screens/city_search_screen.dart'; // Import CitySearchScreen
import 'package:provider/provider.dart'; // Import provider
import 'package:noticesinfo/services/translation_service.dart'; // Import TranslationService

import '../l10n/app_localizations.dart'; // Import for AppLocalizations

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentCarouselIndex = 0;
  final CarouselSliderController _carouselController = CarouselSliderController();
  final ApiService _apiService = ApiService();
  final LocationStorageService _locationStorageService = LocationStorageService();
  Timer? _debounce;

  List<AppSlider> _sliders = [];
  List<Post> _recentPosts = [];
  List<Post> _popularPosts = [];
  bool _isLoadingSliders = true;
  bool _isLoadingRecentPosts = true;
  bool _isLoadingPopularPosts = true;
  String _searchQuery = '';
  String? _currentCity;
  double? _currentLatitude;
  double? _currentLongitude;

  late TranslationService _translationService;
  late String _targetLanguageCode;

  @override
  void initState() {
    super.initState();
    _loadCurrentCity().then((_) {
      _fetchSliders();
      _fetchRecentPosts();
      _fetchPopularPosts();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _translationService = Provider.of<TranslationService>(context);
    _targetLanguageCode = AppLocalizations.of(context)?.localeName ?? 'en';
  }

  @override
  void dispose() {
    _debounce?.cancel(); // Cancel the debounce timer when the widget is disposed
    super.dispose();
  }

  Future<void> _loadCurrentCity() async {
    final savedLocation = await _locationStorageService.getSavedCity();
    if (mounted) {
      setState(() {
        _currentCity = savedLocation?['city'];
        _currentLatitude = savedLocation?['latitude'];
        _currentLongitude = savedLocation?['longitude'];
      });
    }
  }

  Future<void> _fetchSliders() async {
    try {
      final fetchedSliders = await _apiService.fetchSliders();
      setState(() {
        _sliders = fetchedSliders;
        _isLoadingSliders = false;
      });
    } catch (e) {
      print('Error fetching sliders: $e');
      setState(() {
        _isLoadingSliders = false;
      });
    }
  }

  Future<void> _fetchRecentPosts() async {
    try {
      final fetchedPosts = await _apiService.fetchAllPosts(
        page: 1,
        lat: _currentLatitude,
        lng: _currentLongitude,
        radius: 100,
      );
      setState(() {
        _recentPosts = fetchedPosts;
        _isLoadingRecentPosts = false;
      });
    } catch (e) {
      print('Error fetching recent posts: $e');
      setState(() {
        _isLoadingRecentPosts = false;
      });
    }
  }

  // New: Method to fetch and shuffle popular posts
  Future<void> _fetchPopularPosts() async {
    try {
      final fetchedPosts = await _apiService.fetchAllPosts(
        page: 1,
        lat: _currentLatitude,
        lng: _currentLongitude,
        radius: 100,
      ); // Using the same API as recent posts
      fetchedPosts.shuffle(); // Shuffle the list
      setState(() {
        _popularPosts = fetchedPosts;
        _isLoadingPopularPosts = false;
      });
    } catch (e) {
      print('Error fetching popular posts: $e');
      setState(() {
        _isLoadingPopularPosts = false;
      });
    }
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.inAppWebView)) {
      throw 'Could not launch $url';
    }
  }

  void _navigateToCitySearch() async {
    await Navigator.of(context).pushNamed('/citySearch');
    _loadCurrentCity(); // Reload city after returning from search screen
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // City Display and Change Button
            // Padding(
            //   padding: const EdgeInsets.only(bottom: 16.0),
            //   child: Row(
            //     children: [
            //       const Icon(Icons.location_on, color: Colors.deepPurple),
            //       const SizedBox(width: 8),
            //       Expanded(
            //         child: GestureDetector(
            //           onTap: _navigateToCitySearch,
            //           child: Text(
            //             _currentCity ?? 'Select City',
            //
            //             style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            //                   fontWeight: FontWeight.bold,
            //                 ),
            //             overflow: TextOverflow.ellipsis,
            //
            //           ),
            //         ),
            //       ),
            //     ],
            //   ),
            // ),

            // Search Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search posts in ${_currentCity ?? 'Select City'}',
                        border: InputBorder.none,
                      ),
                      onChanged: (value) {
                        _searchQuery = value;
                        if (_debounce?.isActive ?? false) _debounce?.cancel();
                        _debounce = Timer(const Duration(milliseconds: 500), () {
                          if (_searchQuery.isNotEmpty) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SearchResultsScreen(
                                  searchQuery: _searchQuery,
                                  fetchPosts: ({required String query, int? page}) => _apiService.searchPosts(
                                    query: query,
                                    page: page ?? 1, // Provide default if page is null
                                    lat: _currentLatitude,
                                    lng: _currentLongitude,
                                    radius: 100,
                                  ),
                                ),
                              ),
                            );
                          }
                        });
                      },
                    ),
                  ),
                  GestureDetector(
                    onTap: _navigateToCitySearch,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.location_on, color: Colors.deepPurple, size: 20),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              _currentCity ?? 'Select City',
                              style: const TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.arrow_drop_down, color: Colors.deepPurple, size: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Promotions Carousel
            _isLoadingSliders
                ? const Center(child: CircularProgressIndicator())
                : _sliders.isEmpty
                    ? const Center(child: Text('No sliders available'))
                    : CarouselSlider(
                        carouselController: _carouselController,
                        options: CarouselOptions(
                          height: 180.0,
                          enlargeCenterPage: true,
                          autoPlay: true,
                          aspectRatio: 16 / 9,
                          autoPlayCurve: Curves.fastOutSlowIn,
                          enableInfiniteScroll: true,
                          autoPlayAnimationDuration: const Duration(milliseconds: 800),
                          viewportFraction: 0.8,
                          onPageChanged: (index, reason) {
                            setState(() {
                              _currentCarouselIndex = index;
                            });
                          },
                        ),
                        items: _sliders.map<Widget>((AppSlider slider) {
                          return Builder(
                            builder: (BuildContext context) {
                              return GestureDetector(
                                onTap: () => _launchUrl(slider.link),
                                child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  margin: const EdgeInsets.symmetric(horizontal: 5.0),
                                  decoration: BoxDecoration(
                                    color: Colors.amber, // Placeholder color
                                    borderRadius: BorderRadius.circular(12),
                                    image: DecorationImage(
                                      image: NetworkImage(_apiService.getFullImageUrl(slider.image)),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        FutureBuilder<String>(
                                          future: _translationService.translateText(slider.title, _targetLanguageCode),
                                          builder: (context, snapshot) {
                                            return Text(
                                              snapshot.data ?? slider.title,
                                              style: const TextStyle(
                                                color: Colors.deepPurple,
                                                fontSize: 24.0,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        }).toList(),
                      ),
            const SizedBox(height: 10),
            _isLoadingSliders || _sliders.isEmpty
                ? const SizedBox.shrink()
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: _sliders.asMap().entries.map((entry) {
                      return GestureDetector(
                        onTap: () => _carouselController.animateToPage(entry.key),
                        child: Container(
                          width: 8.0,
                          height: 8.0,
                          margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: (Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white
                                    : Colors.black)
                                .withOpacity(_currentCarouselIndex == entry.key ? 0.9 : 0.4),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
            const SizedBox(height: 20),

            // Recent Uploaded Posts
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Uploaded Posts',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AllPostsScreen( // Removed const
                          title: 'Recent Uploaded Posts',
                          fetchPosts: _apiService.fetchAllPosts, // Use existing _apiService instance
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    'View All',
                    style: TextStyle(color: Colors.deepPurple),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _isLoadingRecentPosts
                ? const Center(child: CircularProgressIndicator())
                : _recentPosts.isEmpty
                    ? const Center(child: Text('No recent posts available'))
                    : SizedBox(
                        height: 220,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _recentPosts.length,
                          itemBuilder: (context, index) {
                            final post = _recentPosts[index];
                            return _buildPostCard(post);
                          },
                        ),
                      ),
            const SizedBox(height: 20),

            // Popular Posts
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Popular Posts',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AllPostsScreen(
                          title: 'Popular Posts',
                          fetchPosts: _apiService.fetchPopularPosts, // Use existing _apiService instance
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    'View All',
                    style: TextStyle(color: Colors.deepPurple),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _isLoadingPopularPosts // New: Use loading indicator for popular posts
                ? const Center(child: CircularProgressIndicator())
                : _popularPosts.isEmpty
                    ? const Center(child: Text('No popular posts available'))
                    : SizedBox(
                        height: 220, // Adjust height as needed
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _popularPosts.length,
                          itemBuilder: (context, index) {
                            final post = _popularPosts[index];
                            return _buildPostCard(post); // Use _buildPostCard for dynamic posts
                          },
                        ),
                      ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostCard(Post post) {
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
        width: 180,
        margin: const EdgeInsets.only(right: 15),
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
                        'assets/image/notices_logo.png', // Placeholder image from assets
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
                  FutureBuilder<String>(
                    future: _translationService.translateText(post.title ?? 'No Title', _targetLanguageCode),
                    builder: (context, snapshot) {
                      return Text(
                        snapshot.data ?? post.title ?? 'No Title',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      );
                    },
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 12, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: FutureBuilder<String>(
                          future: _translationService.translateText(
                            '${post.township ?? ''}, ${post.locationCity ?? ''}',
                            _targetLanguageCode,
                          ),
                          builder: (context, snapshot) {
                            return Text(
                              snapshot.data ?? '${post.township ?? ''}, ${post.locationCity ?? ''}',
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 15,
                        backgroundImage: NetworkImage('https://via.placeholder.com/40/8A2BE2/FFFFFF?text=MA'), // Hardcoded avatar
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              post.author.name,
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              post.date ?? '', // Using date from API
                              style: const TextStyle(fontSize: 10, color: Colors.grey),
                            ),
                          ],
                        ),
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
