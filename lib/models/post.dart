import 'package:noticesinfo/models/author.dart';

class Post {
  final int id;
  final String? title;
  final String? image;
  final String? date;
  final String? township;
  final String? locationCity;
  final int views;
  final Author author;

  Post({
    required this.id,
    required this.title,
    this.image,
    required this.date,
    required this.township,
    required this.locationCity,
    required this.views,
    required this.author,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      title: json['title'] as String?,
      image: json['image'] as String?,
      date: json['date'] as String?,
      township: json['township'] as String?,
      locationCity: json['location_city'] as String?,
      views: json['views'] ?? 0,
      author: json['author'] is String
          ? Author(id: 0, name: json['author'] as String) // Create dummy Author if it's a String
          : Author.fromJson(json['author']),
    );
  }
}
