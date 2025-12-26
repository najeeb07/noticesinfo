class Author {
  final int id;
  final String name;
  final int? followersCount;
  final int? followingCount;

  Author({
    required this.id,
    required this.name,
    this.followersCount,
    this.followingCount,
  });

  factory Author.fromJson(Map<String, dynamic> json) {
    return Author(
      id: json['id'],
      name: json['name'],
      followersCount: json['followers_count'] as int?,
      followingCount: json['following_count'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "followers_count": followersCount,
        "following_count": followingCount,
      };
}
