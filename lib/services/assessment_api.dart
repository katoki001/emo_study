// lib/services/ai_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class AIService {
  // PASTE YOUR GRADIO URL HERE (from Colab)
  static const String baseUrl =
      'https://4769ed71a82b493044.gradio.live3'; // CHANGE THIS

  // Send message to AI model and get response
  static Future<String> getAIResponse(String message) async {
    try {
      // GRADIO EXPECTS THIS EXACT FORMAT
      final response = await http.post(
        Uri.parse('$baseUrl/api/predict'), //  MUST BE /api/predict
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'data': [message] //  MUST BE {"data": ["your prompt"]}
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // GRADIO RETURNS THIS EXACT STRUCTURE
        return data['data'][0].toString(); // MUST BE data[0]
      } else {
        throw Exception('Failed: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
      return "Connection failed. Is Colab still running?";
    }
  }

  // Health check for Gradio
  static Future<bool> checkHealth() async {
    try {
      final response = await http
          .get(
            Uri.parse(baseUrl), // Gradio root returns 200 if running
          )
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
