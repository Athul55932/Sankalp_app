import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl;

  ApiService(this.baseUrl);

  Future<String> fetchResponse(String query) async {
    final response = await http.post(
      Uri.parse('$baseUrl/chatbot'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'query': query}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['response']; // Adjust based on your API response structure
    } else {
      throw Exception('Failed to load response');
    }
  }
}