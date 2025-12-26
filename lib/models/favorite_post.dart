import 'package:noticesinfo/models/author.dart';

class FavoritePost {
  final int id;
  final String? title;
  final String? slug;
  final int? views;
  final String? description;
  final int? categoryId;
  final int? parentCategoryId;
  final String? sourceInfo;
  final String? township;
  final int? userId;
  final String? locationCity;
  final String? lat;
  final String? lng;
  final String? createdAt;
  final String? updatedAt;
  final String? image;
  final String? imageTitle;
  final String? author;
  final String? date;
  final List<Media>? media;
  final Author? user;

  FavoritePost({
    required this.id,
    this.title,
    this.slug,
    this.views,
    this.description,
    this.categoryId,
    this.parentCategoryId,
    this.sourceInfo,
    this.township,
    this.userId,
    this.locationCity,
    this.lat,
    this.lng,
    this.createdAt,
    this.updatedAt,
    this.image,
    this.imageTitle,
    this.author,
    this.date,
    this.media,
    this.user,
  });

  factory FavoritePost.fromJson(Map<String, dynamic> json) {
    return FavoritePost(
      id: json['id'],
      title: json['title'] as String?,
      slug: json['slug'] as String?,
      views: json['views'] as int?,
      description: json['description'] as String?,
      categoryId: json['category_id'] as int?,
      parentCategoryId: json['parent_category_id'] as int?,
      sourceInfo: json['source_info'] as String?,
      township: json['township'] as String?,
      userId: json['user_id'] as int?,
      locationCity: json['location_city'] as String?,
      lat: json['lat'] as String?,
      lng: json['lng'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      image: json['image'] as String?,
      imageTitle: json['image_title'] as String?,
      author: json['author'] as String?,
      date: json['date'] as String?,
      media: json['media'] != null
          ? (json['media'] as List).map((m) => Media.fromJson(m)).toList()
          : null,
      user: json['user'] != null ? Author.fromJson(json['user']) : null,
    );
  }
}

class Media {
  final int id;
  final int postId;
  final String type;
  final String url;
  final String? createdAt;
  final String? updatedAt;

  Media({
    required this.id,
    required this.postId,
    required this.type,
    required this.url,
    this.createdAt,
    this.updatedAt,
  });

  factory Media.fromJson(Map<String, dynamic> json) {
    return Media(
      id: json['id'],
      postId: json['post_id'],
      type: json['type'],
      url: json['url'],
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }
}
