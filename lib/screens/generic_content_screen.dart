import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

class GenericContentScreen extends StatelessWidget {
  final String title;
  final String content;

  const GenericContentScreen({
    Key? key,
    required this.title,
    required this.content,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Html(
          data: content,
        ),
      ),
    );
  }
}
