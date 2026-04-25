// lib/services/colab_ai_service.dart
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;

// ── Mental State ─────────────────────────────────────────────────────────────

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

  factory MentalState.fromJson(Map<String, dynamic> json) => MentalState(
        normal: (json['Normal'] ?? json['Նորմալ'] ?? 100.0).toDouble(),
        anxiety: (json['Anxiety'] ?? json['Տագնապ'] ?? 0.0).toDouble(),
        bipolar: (json['Bipolar'] ?? json['Բիպոլյար'] ?? 0.0).toDouble(),
        depression: (json['Depression'] ?? json['Դեպրեսիա'] ?? 0.0).toDouble(),
        suicidal: (json['Suicidal'] ?? json['Ինքնասպանական'] ?? 0.0).toDouble(),
      );

  factory MentalState.neutral() => const MentalState(
      normal: 100, anxiety: 0, bipolar: 0, depression: 0, suicidal: 0);

  Map<String, double> toMap() => {
        'Normal': normal,
        'Anxiety': anxiety,
        'Bipolar': bipolar,
        'Depression': depression,
        'Suicidal': suicidal,
      };

  // The dominant non-normal label if any state exceeds 10%
  String get dominantState {
    final nonNormal = {
      'Anxiety': anxiety,
      'Bipolar': bipolar,
      'Depression': depression,
      'Suicidal': suicidal,
    };
    final top = nonNormal.entries.reduce((a, b) => a.value > b.value ? a : b);
    return top.value > 10 ? top.key : 'Normal';
  }
}

// ── Chat Result ───────────────────────────────────────────────────────────────

class ChatResult {
  final String response;
  final MentalState mentalState;
  final bool isError;

  const ChatResult({
    required this.response,
    required this.mentalState,
    this.isError = false,
  });

  factory ChatResult.fromJson(Map<String, dynamic> json) => ChatResult(
        response: json['response'] ?? '',
        mentalState: MentalState.fromJson(
            (json['mental_state'] as Map<String, dynamic>?) ?? {}),
      );

  factory ChatResult.error(String msg) => ChatResult(
        response: msg,
        mentalState: MentalState.neutral(),
        isError: true,
      );
}

// ── Service ───────────────────────────────────────────────────────────────────

class ColabAIService {
  // ── Paste your MENTAL HEALTH backend ngrok URL here ──
  static const String baseUrl = "Mental health link here";

  static const Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'ngrok-skip-browser-warning': 'true',
  };

  // Stable session ID for this app launch
  static final String _sessionId =
      DateTime.now().millisecondsSinceEpoch.toString() +
          Random().nextInt(9999).toString();

  // ── Send a message ────────────────────────────────────────────────────────
  // language comes from SettingsProvider.language ('en' or 'hy')
  // Backend translates the reply AND mental state labels before sending back
  static Future<ChatResult> sendMessage({
    required String message,
    required List<Map<String, String>> history,
    String language = 'en', // ← NEW: pass from SettingsProvider
  }) async {
    try {
      final res = await http
          .post(
            Uri.parse('$baseUrl/chat'),
            headers: _headers,
            body: jsonEncode({
              'message': message,
              'history': history,
              'session_id': _sessionId,
              'language': language, // ← backend translates before sending
            }),
          )
          .timeout(const Duration(seconds: 60));

      if (res.statusCode == 200) {
        return ChatResult.fromJson(jsonDecode(res.body));
      }
      return ChatResult.error(
          'Server error (${res.statusCode}). Please try again.');
    } catch (e) {
      return ChatResult.error(
          "Couldn't reach the AI. Make sure the Colab notebook is running.");
    }
  }

  // ── Reset session ─────────────────────────────────────────────────────────
  static Future<void> resetSession() async {
    try {
      await http
          .post(
            Uri.parse('$baseUrl/reset'),
            headers: _headers,
            body: jsonEncode({'session_id': _sessionId}),
          )
          .timeout(const Duration(seconds: 8));
    } catch (_) {}
  }

  // ── Health check ──────────────────────────────────────────────────────────
  static Future<bool> isReachable() async {
    try {
      final res = await http
          .get(Uri.parse('$baseUrl/health'), headers: _headers)
          .timeout(const Duration(seconds: 8));
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
