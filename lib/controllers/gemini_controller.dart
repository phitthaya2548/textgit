import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/config.dart';
class GeminiController {
  static Future<String> sendMessage(String userInput) async {
    final uri = Uri.parse('${AppConfig.baseUrl}/api/gemini');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userInput': userInput}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['reply'];
    } else {
      throw Exception('Failed to get reply from Gemini');
    }
  }
}

