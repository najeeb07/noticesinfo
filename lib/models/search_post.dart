class SearchPost {
  final int id;
  final String title;
  final String description;
  final String? image;
  final String date;
  final String author;
  final int views;
  final double? distanceKm;

  SearchPost({
    required this.id,
    required this.title,
    required this.description,
    this.image,
    required this.date,
    required this.author,
    required this.views,
    this.distanceKm,
  });

  factory SearchPost.fromJson(Map<String, dynamic> json) {
    return SearchPost(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      image: json['image'],
      date: json['date'],
      author: json['author'],
      views: json['views'] ?? 0,
      distanceKm: json['distance_km']?.toDouble(),
    );
  }
}
