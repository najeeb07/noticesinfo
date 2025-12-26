import 'dart:convert';
import 'package:noticesinfo/models/author.dart';

PostDetailResponse postDetailResponseFromJson(String str) => PostDetailResponse.fromJson(json.decode(str));

String postDetailResponseToJson(PostDetailResponse data) => json.encode(data.toJson());

class PostDetailResponse {
  bool success;
  PostDetailData data;

  PostDetailResponse({
    required this.success,
    required this.data,
  });

  factory PostDetailResponse.fromJson(Map<String, dynamic> json) => PostDetailResponse(
        success: json["success"],
        data: PostDetailData.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "data": data.toJson(),
      };
}

class PostDetailData {
  int id;
  String title;
  String description;
  Category category;
  Category parentCategory;
  String image;
  List<Media> media;
  Author author;
  String sourceInfo;
  String township;
  String locationCity;
  String? lat;
  String? lng;
  int views;
  DateTime createdAt;

  PostDetailData({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.parentCategory,
    required this.image,
    required this.media,
    required this.author,
    required this.sourceInfo,
    required this.township,
    required this.locationCity,
    required this.lat,
    required this.lng,
    required this.views,
    required this.createdAt,
  });

  factory PostDetailData.fromJson(Map<String, dynamic> json) => PostDetailData(
        id: json["id"],
        title: json["title"],
        description: json["description"],
        category: Category.fromJson(json["category"]),
        parentCategory: Category.fromJson(json["parent_category"]),
        image: json["image"],
        media: List<Media>.from(json["media"].map((x) => Media.fromJson(x))),
        author: Author.fromJson(json["author"]),
        sourceInfo: json["source_info"],
        township: json["township"],
        locationCity: json["location_city"],
        lat: json["lat"],
        lng: json["lng"],
        views: json["views"] ?? 0,
        createdAt: DateTime.parse(json["created_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "description": description,
        "category": category.toJson(),
        "parent_category": parentCategory.toJson(),
        "image": image,
        "media": List<dynamic>.from(media.map((x) => x.toJson())),
        "author": author.toJson(),
        "source_info": sourceInfo,
        "township": township,
        "location_city": locationCity,
        "lat": lat,
        "lng": lng,
        "views": views,
        "created_at": createdAt.toIso8601String(),
      };
}

class Category {
  int id;
  String name;

  Category({
    required this.id,
    required this.name,
  });

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        id: json["id"],
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
      };
}


class Media {
  String type;
  String url;

  Media({
    required this.type,
    required this.url,
  });

  factory Media.fromJson(Map<String, dynamic> json) => Media(
        type: json["type"],
        url: json["url"],
      );

  Map<String, dynamic> toJson() => {
        "type": type,
        "url": url,
      };
}
