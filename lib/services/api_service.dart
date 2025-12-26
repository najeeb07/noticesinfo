import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:noticesinfo/models/app_slider.dart'; // Import the AppSlider model
import 'package:noticesinfo/models/post.dart'; // Import the Post model
import 'package:noticesinfo/models/post_detail.dart'; // Import the PostDetail model
import 'package:noticesinfo/models/search_post.dart'; // Import the SearchPost model
import 'package:mime/mime.dart'; // Import for MIME type detection
import 'dart:io'; // Import for File class
import 'package:http_parser/http_parser.dart'; // Import for MediaType

class ApiService {
  // Use a single client so we can intercept all requests in one place
  final http.Client _client = LoggingClient();
  static const String baseUrl = 'https://noticesinfo.com/api/v1';
  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';
  static const String _userNameKey = 'user_name'; // New: Key for storing user name
  static const String _userCreatedAtKey = 'user_created_at'; // New: Key for storing user created_at
  static const String _userEmailKey = 'user_email'; // New: Key for storing user email
  static const String _userProfilePicKey = 'user_profile_pic'; // New: Key for storing user profile picture

  int? _currentUserId;
  String? _currentToken;
  String? _currentUserName; // New: Field to hold the current user name in memory
  String? _currentUserCreatedAt; // New: Field to hold the current user created_at in memory
  String? _currentUserEmail; // New: Field to hold the current user email in memory
  String? _currentUserProfilePic; // New: Field to hold the current user profile picture in memory
  bool? _isFollowing; // New: Field to hold the following status

  int? get currentUserId => _currentUserId;
  String? get currentToken => _currentToken;
  String? get currentUserName => _currentUserName; // New: Getter for current user name
  String? get currentUserCreatedAt => _currentUserCreatedAt; // New: Getter for current user created_at
  String? get currentUserEmail => _currentUserEmail; // New: Getter for current user email
  String? get currentUserProfilePic => _currentUserProfilePic; // New: Getter for current user profile picture
  bool? get isFollowing => _isFollowing; // New: Getter for following status

  // New: Method to update user profile
  Future<Map<String, dynamic>> updateProfile({
    required String name,
    File? profilePic,
  }) async {
    final url = Uri.parse('$baseUrl/user/update-profile');
    try {
      final token = await getToken();
      if (token == null) {
        return {'success': false, 'message': 'No token found. User not logged in.'};
      }

      final request = http.MultipartRequest('POST', url);
      request.headers['Accept'] = 'application/json';
      request.headers['Authorization'] = 'Bearer $token';

      request.fields['name'] = name;

      if (profilePic != null) {
        final mimeType = _getMimeType(profilePic.path);
        request.files.add(await http.MultipartFile.fromPath(
          'profile_pic',
          profilePic.path,
          contentType: mimeType != null ? MediaType.parse(mimeType) : null,
        ));
      }

      final streamed = await _client.send(request);
      final responseBody = await streamed.stream.bytesToString();
      final responseData = json.decode(responseBody);

      if (streamed.statusCode == 200) {
        if (responseData['success'] == true) {
          final updatedUser = responseData['data'];
          if (updatedUser != null) {
            await _saveUserName(updatedUser['name']);
            _currentUserName = updatedUser['name'];

            if (updatedUser['profile_pic_url'] != null) {
              await _saveUserProfilePic(updatedUser['profile_pic_url']);
              _currentUserProfilePic = updatedUser['profile_pic_url'];
            } else {
              await _saveUserProfilePic('');
              _currentUserProfilePic = '';
            }
          }
          return {'success': true, 'message': responseData['message'], 'data': responseData['data']};
        } else {
          return {'success': false, 'message': responseData['message'], 'errors': responseData['errors']};
        }
      } else if (streamed.statusCode == 422) {
        return {'success': false, 'message': responseData['message'], 'errors': responseData['errors']};
      } else {
        return {'success': false, 'message': 'Failed to update profile. Status code: ${streamed.statusCode}'};
      }
    } catch (error) {
      return {'success': false, 'message': 'An error occurred: $error'};
    }
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<void> _saveUserId(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_userIdKey, userId);
  }

  // New: Method to save user name
  Future<void> _saveUserName(String userName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userNameKey, userName);
  }

  // New: Method to save user created_at
  Future<void> _saveUserCreatedAt(String userCreatedAt) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userCreatedAtKey, userCreatedAt);
  }

  // New: Method to save user email
  Future<void> _saveUserEmail(String userEmail) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userEmailKey, userEmail);
  }

  // New: Method to save user profile picture
  Future<void> _saveUserProfilePic(String userProfilePic) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userProfilePicKey, userProfilePic);
  }

  Future<String?> getToken() async {
    if (_currentToken != null) return _currentToken;
    final prefs = await SharedPreferences.getInstance();
    _currentToken = prefs.getString(_tokenKey);
    return _currentToken;
  }

  Future<int?> getUserId() async {
    if (_currentUserId != null) return _currentUserId;
    final prefs = await SharedPreferences.getInstance();
    _currentUserId = prefs.getInt(_userIdKey);
    return _currentUserId;
  }

  // New: Method to get user name
  Future<String?> getUserName() async {
    if (_currentUserName != null) return _currentUserName;
    final prefs = await SharedPreferences.getInstance();
    _currentUserName = prefs.getString(_userNameKey);
    return _currentUserName;
  }

  // New: Method to get user created_at
  Future<String?> getUserCreatedAt() async {
    if (_currentUserCreatedAt != null) return _currentUserCreatedAt;
    final prefs = await SharedPreferences.getInstance();
    _currentUserCreatedAt = prefs.getString(_userCreatedAtKey);
    return _currentUserCreatedAt;
  }

  // New: Method to get user email
  Future<String?> getUserEmail() async {
    if (_currentUserEmail != null) return _currentUserEmail;
    final prefs = await SharedPreferences.getInstance();
    _currentUserEmail = prefs.getString(_userEmailKey);
    return _currentUserEmail;
  }

  // New: Method to get user profile picture
  Future<String?> getUserProfilePic() async {
    if (_currentUserProfilePic != null) return _currentUserProfilePic;
    final prefs = await SharedPreferences.getInstance();
    _currentUserProfilePic = prefs.getString(_userProfilePicKey);
    return _currentUserProfilePic;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_userNameKey); // Remove user name on logout
    await prefs.remove(_userCreatedAtKey); // Remove user created_at on logout
    await prefs.remove(_userEmailKey); // Remove user email on logout
    await prefs.remove(_userProfilePicKey); // Remove user profile picture on logout
    _currentToken = null;
    _currentUserId = null;
    _currentUserName = null; // Clear in-memory user name
    _currentUserCreatedAt = null; // Clear in-memory user created_at
    _currentUserEmail = null; // Clear in-memory user email
    _currentUserProfilePic = null; // Clear in-memory user profile picture
    _isFollowing = null; // Clear in-memory following status
  }

  // New: Method to call the logout API endpoint
  Future<Map<String, dynamic>> logoutApi() async {
    final url = Uri.parse('$baseUrl/logout');
    try {
      final token = await getToken();
      if (token == null) {
        return {'success': false, 'message': 'No token found. User not logged in.'};
      }

      final response = await _client.post(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        if (responseData['success'] == true) {
          await logout(); // Clear local storage on successful API logout
          return {'success': true, 'message': responseData['message']};
        } else {
          return {'success': false, 'message': responseData['message']};
        }
      } else {
        return {'success': false, 'message': 'Failed to logout. Status code: ${response.statusCode}'};
      }
    } catch (error) {
      return {'success': false, 'message': 'An error occurred: $error'};
    }
  }

  Future<Map<String, dynamic>> fetchCategories() async {
    final url = Uri.parse('$baseUrl/categories');
    try {
      final response = await _client.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        if (responseData['success'] == true) {
          return {'success': true, 'message': responseData['message'], 'data': responseData['data']};
        } else {
          return {'success': false, 'message': responseData['message']};
        }
      } else {
        return {'success': false, 'message': 'Failed to fetch categories. Status code: ${response.statusCode}'};
      }
    } catch (error) {
      return {'success': false, 'message': 'An error occurred: $error'};
    }
  }

  Future<List<AppSlider>> fetchSliders() async {
    final url = Uri.parse('$baseUrl/sliders');
    try {
      final response = await _client.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        List<dynamic> sliderJson = responseData['data'];
        return sliderJson.map((json) => AppSlider.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load sliders: ${responseData['message'] ?? response.statusCode}');
      }
    } catch (error) {
      throw Exception('An error occurred while fetching sliders: $error');
    }
  }

  Future<List<Post>> fetchAllPosts({int page = 1, double? lat, double? lng, int radius = 100}) async {
    String queryString = 'page=$page';
    if (lat != null && lng != null) {
      queryString += '&lat=$lat&lng=$lng&radius=$radius';
    }
    final url = Uri.parse('$baseUrl/all/posts?$queryString');
    try {
      final response = await _client.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        List<dynamic> postJson = responseData['data'];
        return postJson.map((json) => Post.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load posts: ${responseData['message'] ?? response.statusCode}');
      }
    } catch (error) {
      throw Exception('An error occurred while fetching posts: $error');
    }
  }
  Future<List<Post>> fetchPopularPosts({int page = 1, double? lat, double? lng, int radius = 100}) async {
    String queryString = 'page=$page';
    if (lat != null && lng != null) {
      queryString += '&lat=$lat&lng=$lng&radius=$radius';
    }
    final url = Uri.parse('$baseUrl/posts/popular?$queryString');
    try {
      final response = await _client.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        List<dynamic> postJson = responseData['data'];
        return postJson.map((json) => Post.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load posts: ${responseData['message'] ?? response.statusCode}');
      }
    } catch (error) {
      throw Exception('An error occurred while fetching posts: $error');
    }
  }

  Future<Map<String, dynamic>> fetchSubCategories(int categoryId) async {
    final url = Uri.parse('$baseUrl/categories/$categoryId/subcategories');
    try {
      final response = await _client.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        if (responseData['success'] == true) {
          return {'success': true, 'message': responseData['message'], 'data': responseData['data']};
        } else {
          return {'success': false, 'message': responseData['message']};
        }
      } else {
        return {'success': false, 'message': 'Failed to fetch subcategories. Status code: ${response.statusCode}'};
      }
    } catch (error) {
      return {'success': false, 'message': 'An error occurred: $error'};
    }
  }

  Future<PostDetailResponse> fetchPostDetail(int postId) async {
    final url = Uri.parse('$baseUrl/posts/$postId');
    try {
      final response = await _client.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        return PostDetailResponse.fromJson(responseData);
      } else {
        throw Exception('Failed to load post detail: ${responseData['message'] ?? response.statusCode}');
      }
    } catch (error) {
      throw Exception('An error occurred while fetching post detail: $error');
    }
  }

  Future<List<Post>> fetchPostsBySubCategory(int subCategoryId, {int page = 1}) async {
    final url = Uri.parse('$baseUrl/categories/$subCategoryId/posts?page=$page');
    try {
      final response = await _client.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        List<dynamic> postJson = responseData['data'];
        return postJson.map((json) => Post.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load posts for subcategory: ${responseData['message'] ?? response.statusCode}');
      }
    } catch (error) {
      throw Exception('An error occurred while fetching posts for subcategory: $error');
    }
  }

  Future<List<SearchPost>> searchPosts({required String query, int page = 1, double? lat, double? lng, int radius = 100}) async {
    String queryString = 'q=$query&page=$page';
    if (lat != null && lng != null) {
      queryString += '&lat=$lat&lng=$lng&radius=$radius';
    }
    final url = Uri.parse('$baseUrl/posts/search?$queryString');
    try {
      final response = await _client.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        List<dynamic> postJson = responseData['data'];
        return postJson.map((json) => SearchPost.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load search posts: ${responseData['message'] ?? response.statusCode}');
      }
    } catch (error) {
      throw Exception('An error occurred while fetching search posts: $error');
    }
  }

  Future<Map<String, dynamic>> fetchData(String endpoint) async {
    final url = Uri.parse('$baseUrl$endpoint');
    try {
      final response = await _client.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      final responseData = json.decode(response.body);
      return responseData;
    } catch (error) {
      developer.log('Error fetching data from $endpoint: $error', name: 'api');
      return {'success': false, 'message': 'An error occurred: $error'};
    }
  }

  String getFullImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return ''; // Or a placeholder image URL
    }
    return 'https://www.noticesinfo.com/$imagePath';
  }

  Future<Map<String, dynamic>> firebaseLogin(String? idToken) async {
    if (idToken == null) {
      return {'success': false, 'message': 'Firebase ID token is null.'};
    }

    final url = Uri.parse('$baseUrl/auth/firebase-login');
    try {
      final response = await _client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'idToken': idToken}),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        final appToken = responseData['token'];
        final user = responseData['user'];

        if (appToken != null && user != null) {
          final userId = user['id'];
          final name = user['name'];
          final email = user['email'];
          final profilePic = user['profilePic']; // This might be null if not present

          await _saveToken(appToken);
          await _saveUserId(userId); // userId is already int from backend
          await _saveUserName(name);
          await _saveUserEmail(email);
          if (profilePic != null) {
            await _saveUserProfilePic(profilePic);
          } else {
            await _saveUserProfilePic(''); // Save empty string if profilePic is null
          }

          _currentToken = appToken;
          _currentUserId = userId;
          _currentUserName = name;
          _currentUserEmail = email;
          _currentUserProfilePic = profilePic;

          return {'success': true, 'message': 'Login successful', 'data': responseData};
        } else {
          return {'success': false, 'message': 'Invalid response data from server.'};
        }
      } else {
        return {'success': false, 'message': 'Failed to login with Firebase. Status code: ${response.statusCode}'};
      }
    } catch (error) {
      return {'success': false, 'message': 'An error occurred during Firebase login: $error'};
    }
  }

  Future<Map<String, dynamic>> firebasePhoneLogin(
      String? idToken, String phone, String name) async {
    if (idToken == null) {
      return {'success': false, 'message': 'Firebase ID token is null.'};
    }

    final url = Uri.parse('$baseUrl/auth/firebase-phone-login');
    try {
      final response = await _client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'idToken': idToken,
          'phone': phone,
          'name': name,
        }),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        final data = responseData['data'];
        if (data != null) {
          final appToken = data['token'];
          final user = data['user'];

          if (appToken != null && user != null) {
            final userId = user['id'];
            final userName = user['name'];
            final userCreatedAt = user['created_at'];
            final userUpdatedAt = user['updated_at']; // New: Extract updated_at

            await _saveToken(appToken);
            await _saveUserId(userId);
            await _saveUserName(userName);
            // No email, phone, or firebase_uid in the new response, so no need to save them.
            // If needed, you would add _saveUserCreatedAt and _saveUserUpdatedAt methods.

            _currentToken = appToken;
            _currentUserId = userId;
            _currentUserName = userName;
            _currentUserCreatedAt = userCreatedAt; // Update in-memory created_at
            // _currentUserEmail, _currentUserProfilePic, _isFollowing are not in the new response, keep as is or clear if necessary.

            return {'success': true, 'message': 'Login successful', 'data': responseData};
          } else {
            return {'success': false, 'message': 'Invalid response data from server.'};
          }
        } else {
          return {'success': false, 'message': 'No data field in the response.'};
        }
      } else {
        return {'success': false, 'message': 'Failed to login with phone. Status code: ${response.statusCode}'};
      }
    } catch (error) {
      return {'success': false, 'message': 'An error occurred during Firebase phone login: $error'};
    }
  }

  // New: Method to fetch user profile
  Future<Map<String, dynamic>> fetchUserProfile() async {
    final url = Uri.parse('$baseUrl/user/my-profile');
    try {
      final token = await getToken();
      if (token == null) {
        return {'success': false, 'message': 'No token found. User not logged in.'};
      }

      final response = await _client.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        if (responseData['success'] == true) {
          return {'success': true, 'message': responseData['message'], 'data': responseData['data']};
        } else {
          return {'success': false, 'message': responseData['message']};
        }
      } else {
        return {'success': false, 'message': 'Failed to fetch user profile. Status code: ${response.statusCode}'};
      }
    } catch (error) {
      return {'success': false, 'message': 'An error occurred: $error'};
    }
  }

  // New: Method to fetch a specific user's profile
  Future<Map<String, dynamic>> fetchAuthorProfile(int authorId) async {
    final url = Uri.parse('$baseUrl/users/$authorId/profile');
    try {
      final token = await getToken();
      Map<String, String> headers = {
        'Accept': 'application/json',
      };
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await _client.get(
        url,
        headers: headers,
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        if (responseData['success'] == true) {
          return {'success': true, 'message': responseData['message'], 'data': responseData['data']};
        } else {
          return {'success': false, 'message': responseData['message']};
        }
      } else {
        return {'success': false, 'message': 'Failed to fetch author profile. Status code: ${response.statusCode}'};
      }
    } catch (error) {
      return {'success': false, 'message': 'An error occurred: $error'};
    }
  }

  // New: Method to toggle follow/unfollow a user
  Future<Map<String, dynamic>> toggleFollowUser(int userIdToToggle) async {
    final url = Uri.parse('$baseUrl/users/$userIdToToggle/toggle-follow');
    try {
      final token = await getToken();
      if (token == null) {
        return {'success': false, 'message': 'No token found. User not logged in.'};
      }

      final response = await _client.post(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        if (responseData['success'] == true) {
          return {'success': true, 'message': responseData['message'], 'data': responseData['data']};
        } else {
          return {'success': false, 'message': responseData['message']};
        }
      } else {
        return {'success': false, 'message': 'Failed to toggle follow status. Status code: ${response.statusCode}'};
      }
    } catch (error) {
      return {'success': false, 'message': 'An error occurred: $error'};
    }
  }

  Future<Map<String, dynamic>> getAuthorPosts(int authorId, int page) async {
    final url = Uri.parse('$baseUrl/users/$authorId/posts?page=$page');
    try {
      final response = await _client.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return responseData;
      } else {
        return {'success': false, 'message': 'Failed to fetch author posts. Status code: ${response.statusCode}'};
      }
    } catch (error) {
      return {'success': false, 'message': 'An error occurred: $error'};
    }
  }

  // New: Method to record a post view
  Future<Map<String, dynamic>> viewPost(int postId) async {
    final url = Uri.parse('$baseUrl/posts/$postId/view');
    try {
      final token = await getToken();
      Map<String, String> headers = {
        'Accept': 'application/json',
      };
      // It's possible to view a post without being logged in,
      // but if a token exists, send it for authenticated view tracking.
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await _client.post(
        url,
        headers: headers,
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return responseData; // Assuming backend sends success/message in body
      } else {
        return {'success': false, 'message': 'Failed to record post view. Status code: ${response.statusCode}'};
      }
    } catch (error) {
      return {'success': false, 'message': 'An error occurred while recording post view: $error'};
    }
  }

  Future<Map<String, dynamic>> sharePost(int postId) async {
    final url = Uri.parse('$baseUrl/posts/$postId/share');
    try {
      final token = await getToken();
      if (token == null) {
        return {'success': false, 'message': 'No token found. User not logged in.'};
      }

      final response = await _client.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return responseData;
      } else {
        return {'success': false, 'message': 'Failed to share post. Status code: ${response.statusCode}'};
      }
    } catch (error) {
      return {'success': false, 'message': 'An error occurred: $error'};
    }
  }

  Future<Map<String, dynamic>> createPost({
    required int userId,
    required String title,
    required String description,
    required int categoryId, // This is the sub_category_id
    required int parentCategoryId, // This is the parent_category_id
    required String locationCity,
    required double lat,
    required double lng,
    required String sourceInfo,
    required String township,
    List<String>? media, // List of file paths for images
  }) async {
    final url = Uri.parse('$baseUrl/posts');
    try {
      final request = http.MultipartRequest('POST', url);

      request.fields['user_id'] = userId.toString();
      request.fields['title'] = title;
      request.fields['description'] = description;
      request.fields['category_id'] = categoryId.toString(); // Subcategory ID
      request.fields['parent_category_id'] = parentCategoryId.toString(); // Parent Category ID
      request.fields['location_city'] = locationCity;
      request.fields['lat'] = lat.toString();
      request.fields['lng'] = lng.toString();
      request.fields['source_info'] = sourceInfo;
      request.fields['township'] = township;

      if (media != null && media.isNotEmpty) {
        for (String filePath in media) {
          final mimeType = _getMimeType(filePath);
          request.files.add(await http.MultipartFile.fromPath(
            'media[]',
            filePath,
            contentType: mimeType != null ? MediaType.parse(mimeType) : null,
          ));
        }
      }

      // Ensure the server responds with JSON. Some servers return 406
      // if the Accept header is missing or doesn't allow application/json.
      // Do not set Content-Type here — MultipartRequest will set it (with boundary).
      request.headers['Accept'] = 'application/json';

      final token = await getToken();
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

  final streamed = await _client.send(request);
  final responseBody = await streamed.stream.bytesToString();
      final responseData = json.decode(responseBody);

      if (streamed.statusCode == 201) { // Changed from 200 to 201 for 'Created' status
        if (responseData['success'] == true) {
          return {'success': true, 'message': responseData['message'], 'data': responseData['data']};
        } else {
          // If status is 201 but backend 'success' is false, it's an unexpected scenario,
          // but we'll still return the backend's message.
          return {'success': false, 'message': responseData['message'], 'errors': responseData['errors']};
        }
      } else if (streamed.statusCode == 422) {
        return {'success': false, 'message': responseData['message'], 'errors': responseData['errors']};
      } else {
        return {'success': false, 'message': 'Failed to create post. Status code: ${streamed.statusCode}'};
      }
    } catch (error) {
      return {'success': false, 'message': 'An error occurred: $error'};
    }
  }

  // New: Method to update an existing post
  Future<Map<String, dynamic>> updatePost({
    required int postId,
    required int userId,
    required String title,
    required String description,
    required int categoryId, // This is the sub_category_id
    required int parentCategoryId, // This is the parent_category_id
    required String locationCity,
    required double lat,
    required double lng,
    required String sourceInfo,
    required String township,
    List<String>? media, // List of file paths for new images
  }) async {
    final url = Uri.parse('$baseUrl/posts/$postId');
    try {
      final token = await getToken();
      if (token == null) {
        return {'success': false, 'message': 'No token found. User not logged in.'};
      }

      // Use POST with _method=PUT for Laravel compatibility with multipart
      final request = http.MultipartRequest('POST', url);
      
      // Add _method field for Laravel to recognize this as a PUT request
      request.fields['_method'] = 'PUT';
      request.fields['title'] = title;
      request.fields['description'] = description;
      request.fields['category_id'] = categoryId.toString(); // Subcategory ID
      request.fields['parent_category_id'] = parentCategoryId.toString(); // Parent Category ID
      request.fields['location_city'] = locationCity;
      request.fields['lat'] = lat.toString();
      request.fields['lng'] = lng.toString();
      request.fields['source_info'] = sourceInfo;
      request.fields['township'] = township;

      if (media != null && media.isNotEmpty) {
        for (String filePath in media) {
          final mimeType = _getMimeType(filePath);
          request.files.add(await http.MultipartFile.fromPath(
            'media[]',
            filePath,
            contentType: mimeType != null ? MediaType.parse(mimeType) : null,
          ));
        }
      }

      // Set headers with authorization token
      request.headers['Accept'] = 'application/json';
      request.headers['Authorization'] = 'Bearer $token';

      final streamed = await _client.send(request);
      final responseBody = await streamed.stream.bytesToString();
      final responseData = json.decode(responseBody);

      if (streamed.statusCode == 200 || streamed.statusCode == 201) {
        if (responseData['success'] == true) {
          return {'success': true, 'message': responseData['message'], 'data': responseData['data']};
        } else {
          return {'success': false, 'message': responseData['message'], 'errors': responseData['errors']};
        }
      } else if (streamed.statusCode == 422) {
        return {'success': false, 'message': responseData['message'], 'errors': responseData['errors']};
      } else {
        return {'success': false, 'message': 'Failed to update post. Status code: ${streamed.statusCode}'};
      }
    } catch (error) {
      return {'success': false, 'message': 'An error occurred: $error'};
    }
  }

  // New: Method to toggle favorite status of a post
  Future<Map<String, dynamic>> toggleFavorite(int postId) async {
    final url = Uri.parse('$baseUrl/posts/$postId/toggle-favorite');
    try {
      final token = await getToken();
      if (token == null) {
        return {'success': false, 'message': 'No token found. User not logged in.'};
      }

      final response = await _client.post(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        if (responseData['success'] == true) {
          return {
            'success': true,
            'message': responseData['message'],
            'favorited': responseData['favorited']
          };
        } else {
          return {'success': false, 'message': responseData['message']};
        }
      } else {
        return {'success': false, 'message': 'Failed to toggle favorite. Status code: ${response.statusCode}'};
      }
    } catch (error) {
      return {'success': false, 'message': 'An error occurred: $error'};
    }
  }

  // New: Method to fetch user's favorite posts
  Future<Map<String, dynamic>> fetchMyFavorites() async {
    final url = Uri.parse('$baseUrl/user/my-favorites');
    try {
      final token = await getToken();
      if (token == null) {
        return {'success': false, 'message': 'No token found. User not logged in.'};
      }

      final response = await _client.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        if (responseData['success'] == true) {
          return {
            'success': true,
            'message': responseData['message'] ?? 'Favorites fetched successfully',
            'data': responseData['data']
          };
        } else {
          return {'success': false, 'message': responseData['message']};
        }
      } else {
        return {'success': false, 'message': 'Failed to fetch favorites. Status code: ${response.statusCode}'};
      }
    } catch (error) {
      return {'success': false, 'message': 'An error occurred: $error'};
    }
  }

  // Helper function to determine MIME type from file path
  String? _getMimeType(String filePath) {
    final file = File(filePath);
    if (!file.existsSync()) {
      developer.log('File does not exist at path: $filePath', name: 'api');
      return null;
    }
    return lookupMimeType(filePath);
  }
}

/// A simple HTTP client wrapper that logs requests and responses.
class LoggingClient extends http.BaseClient {
  final http.Client _inner;

  LoggingClient([http.Client? inner]) : _inner = inner ?? http.Client();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final stopwatch = Stopwatch()..start();

    // Log request line
    developer.log('➡️ HTTP ${request.method} ${request.url}', name: 'api');

    // Log headers
    request.headers.forEach((k, v) {
      developer.log('Request header: $k: $v', name: 'api');
    });

    // Try to log body for common request types
    if (request is http.Request) {
      if (request.body.isNotEmpty) {
        developer.log('Request body: ${request.body}', name: 'api');
      }
    } else if (request is http.MultipartRequest) {
      developer.log('Multipart fields: ${request.fields}', name: 'api');
      developer.log('Multipart files: ${request.files.map((f) => f.filename).toList()}', name: 'api');
    }

    try {
      final streamedResponse = await _inner.send(request);

      final elapsed = stopwatch.elapsed;

      // Read the response body for logging
      final bytes = await streamedResponse.stream.toBytes();
      final bodyString = bytes.isNotEmpty ? utf8.decode(bytes) : '';

      developer.log('⬅️ HTTP ${request.method} ${request.url} ${streamedResponse.statusCode} (${elapsed.inMilliseconds} ms)', name: 'api');
      developer.log('Response headers: ${streamedResponse.headers}', name: 'api');
      if (bodyString.isNotEmpty) {
        developer.log('Response body: $bodyString', name: 'api');
      }

      // Return a new StreamedResponse with the bytes we consumed
      return http.StreamedResponse(Stream.fromIterable([bytes]), streamedResponse.statusCode,
          request: streamedResponse.request,
          headers: streamedResponse.headers,
          reasonPhrase: streamedResponse.reasonPhrase,
          isRedirect: streamedResponse.isRedirect);
    } catch (error, stack) {
      final elapsed = stopwatch.elapsed;
      developer.log('❌ HTTP ${request.method} ${request.url} error after ${elapsed.inMilliseconds} ms: $error', name: 'api', error: error, stackTrace: stack);
      rethrow;
    }
  }
}
