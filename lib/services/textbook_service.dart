import 'dart:convert';
import 'package:achiver_app/models/textbook_content.dart';
import 'package:http/http.dart' as http;

class TextbookService {
  Future<List<TextbookContent>> fetchTextbookContent({
    required String language,
  }) async {
    try {
      // Replace with your actual backend URL
      final response = await http.get(
        Uri.parse('https://your-api-endpoint.com/textbooks?lang=$language'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (data.isEmpty) {
          throw Exception('No content available for language: $language');
        }
        return data.map((json) => TextbookContent.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch content: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching content: $e');
    }
  }
}
