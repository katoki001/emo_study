// lib/services/colab_ai_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

// ─── Mental state model ────────────────────────────────────────────────────

class MentalState {
  final double normal;
  final double anxiety;
  final double bipolar;
  final double depression;
  final double suicidal;

  const MentalState({
    required this.normal,
    required this.anxiety,
    required this.bipolar,
    required this.depression,
    required this.suicidal,
  });

  factory MentalState.fromJson(Map<String, dynamic> json) {
    return MentalState(
      normal: (json['Normal'] ?? 100.0).toDouble(),
      anxiety: (json['Anxiety'] ?? 0.0).toDouble(),
      bipolar: (json['Bipolar'] ?? 0.0).toDouble(),
      depression: (json['Depression'] ?? 0.0).toDouble(),
      suicidal: (json['Suicidal'] ?? 0.0).toDouble(),
    );
  }

  factory MentalState.neutral() => const MentalState(
      normal: 100, anxiety: 0, bipolar: 0, depression: 0, suicidal: 0);

  Map<String, double> toMap() => {
        'Normal': normal,
        'Anxiety': anxiety,
        'Bipolar': bipolar,
        'Depression': depression,
        'Suicidal': suicidal,
      };

  /// The dominant non-normal state, if any is above the threshold
  String get dominantState {
    final states = {
      'Anxiety': anxiety,
      'Bipolar': bipolar,
      'Depression': depression,
      'Suicidal': suicidal,
    };
    final top = states.entries.reduce((a, b) => a.value > b.value ? a : b);
    return (top.value > 10) ? top.key : 'Normal';
  }
}

// ─── Chat result model ─────────────────────────────────────────────────────

class ChatResult {
  final String response;
  final MentalState mentalState;
  final bool isError;

  const ChatResult({
    required this.response,
    required this.mentalState,
    this.isError = false,
  });

  factory ChatResult.fromJson(Map<String, dynamic> json) {
    return ChatResult(
      response: json['response'] ?? '',
      mentalState: MentalState.fromJson(
          (json['mental_state'] as Map<String, dynamic>?) ?? {}),
    );
  }

  factory ChatResult.error(String message) => ChatResult(
        response: message,
        mentalState: MentalState.neutral(),
        isError: true,
      );
}

// ─── Service ───────────────────────────────────────────────────────────────

class ColabAIService {
  // ⚠️  Update this every time you restart Colab (ngrok gives a new URL)
  static const String baseUrl = 'https://XXXX-XX-XX-XX-XX.ngrok-free.app';

  static Future<ChatResult> sendMessage(String message) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/chat'),
            headers: {
              'Content-Type': 'application/json',
              'ngrok-skip-browser-warning': 'true',
            },
            body: jsonEncode({'message': message}),
          )
          .timeout(const Duration(seconds: 45));

      if (response.statusCode == 200) {
        return ChatResult.fromJson(jsonDecode(response.body));
      }
      return ChatResult.error(
          'The AI model returned an error (${response.statusCode}). Please try again.');
    } catch (e) {
      return ChatResult.error(
          "Couldn't reach the AI. Please make sure the Colab notebook is running.");
    }
  }

  static Future<bool> isReachable() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/health'), headers: {
        'ngrok-skip-browser-warning': 'true'
      }).timeout(const Duration(seconds: 8));
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
