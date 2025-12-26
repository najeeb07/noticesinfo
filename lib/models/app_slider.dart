class AppSlider {
  final int id;
  final String title;
  final String image;
  final String link;

  AppSlider({
    required this.id,
    required this.title,
    required this.image,
    required this.link,
  });

  factory AppSlider.fromJson(Map<String, dynamic> json) {
    return AppSlider(
      id: json['id'],
      title: json['title'],
      image: json['image'],
      link: json['link'],
    );
  }
}
