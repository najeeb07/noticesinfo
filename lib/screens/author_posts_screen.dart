import 'package:flutter/material.dart';
import 'package:noticesinfo/models/post.dart';
import 'package:noticesinfo/services/api_service.dart';
import 'package:noticesinfo/screens/post_detail_screen.dart'; // Assuming this is the post detail screen
import 'package:noticesinfo/widgets/post_card.dart'; // Assuming a reusable post card widget

class AuthorPostsScreen extends StatefulWidget {
  final int authorId;
  final String authorName;

  const AuthorPostsScreen({Key? key, required this.authorId, required this.authorName}) : super(key: key);

  @override
  _AuthorPostsScreenState createState() => _AuthorPostsScreenState();
}

class _AuthorPostsScreenState extends State<AuthorPostsScreen> {
  List<Post> _posts = [];
  int _currentPage = 1;
  int _lastPage = 1;
  bool _isLoading = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchAuthorPosts();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent &&
          _currentPage < _lastPage &&
          !_isLoading) {
        _loadMorePosts();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchAuthorPosts() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await ApiService().getAuthorPosts(widget.authorId, _currentPage);
      if (response['success']) {
        final List<dynamic> postData = response['data']['posts'];
        final paginationData = response['data']['pagination'];

        setState(() {
          _posts.addAll(postData.map((json) => Post.fromJson(json)).toList());
          _lastPage = paginationData['last_page'];
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching author posts: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMorePosts() async {
    if (_currentPage < _lastPage) {
      setState(() {
        _currentPage++;
      });
      await _fetchAuthorPosts();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.authorName}\'s Posts'),
      ),
      body: _posts.isEmpty && _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _posts.isEmpty
              ? Center(child: Text('No posts found for ${widget.authorName}.'))
              : ListView.builder(
                  controller: _scrollController,
                  itemCount: _posts.length + (_isLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _posts.length) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final post = _posts[index];
                    return GestureDetector(
                      onTap: () => _navigateToPostDetail(post),
                      child: PostCard(post: post), // Assuming PostCard takes a Post object
                    );
                  },
                ),
    );
  }
}
