import 'dart:convert';
import 'package:http/http.dart' as http;

class AIService {
  // Replace this with your actual Gradio Live URL from Colab
  static const String baseUrl = 'https://0c981c65cd9f20d1c3.gradio.live';

  /// Sends a prompt to the Gradio API and returns the string response
  static Future<String> getAIResponse(String message) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/api/predict'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'data': [message]
            }),
          )
          .timeout(const Duration(
              seconds: 45)); // Increased timeout for CPU inference

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Gradio returns data as a list; we take the first element
        return data['data'][0].toString();
      } else {
        return "Error: Server returned ${response.statusCode}";
      }
    } catch (e) {
      print('AIService Error: $e');
      return "Connection failed. Make sure your Colab tunnel is active.";
    }
  }

  /// Cleans AI response to extract only the JSON part
  static String cleanJson(String rawResponse) {
    try {
      if (rawResponse.contains('{')) {
        final int startIndex = rawResponse.indexOf('{');
        final int endIndex = rawResponse.lastIndexOf('}') + 1;
        return rawResponse.substring(startIndex, endIndex);
      }
      return rawResponse;
    } catch (e) {
      return rawResponse;
    }
  }

  /// Checks if the backend is reachable
  static Future<bool> checkHealth() async {
    try {
      final response = await http
          .get(Uri.parse(baseUrl))
          .timeout(const Duration(seconds: 3));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
