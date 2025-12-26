import 'package:flutter/material.dart';
import 'package:noticesinfo/services/api_service.dart';
import 'package:flutter_html/flutter_html.dart'; // To render HTML in answers

class FaqScreen extends StatefulWidget {
  static const routeName = '/faq-screen';

  const FaqScreen({Key? key}) : super(key: key);

  @override
  State<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> {
  final ApiService _apiService = ApiService();
  List<dynamic> _faqs = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchFaqs();
  }

  Future<void> _fetchFaqs() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final response = await _apiService.fetchData('/faqs');
      if (response['success'] == true) {
        setState(() {
          _faqs = response['data'];
        });
      } else {
        setState(() {
          _error = response['message'] ?? 'Failed to load FAQs';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'An error occurred: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FAQs'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                    ),
                  ),
                )
              : _faqs.isEmpty
                  ? const Center(child: Text('No FAQs available.'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(8.0),
                      itemCount: _faqs.length,
                      itemBuilder: (context, index) {
                        final faq = _faqs[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 4.0),
                          child: ExpansionTile(
                            title: Text(
                              faq['question'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Html(
                                  data: faq['answer'],
                                  style: {
                                    "body": Style(fontSize: FontSize.medium),
                                  },
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
    );
  }
}
