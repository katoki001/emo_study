import 'package:supabase_flutter/supabase_flutter.dart';

/// Single service for all persistent data: chat history + uploaded lectures.
/// Call [SupabaseStorageService.instance] anywhere in the app.
class SupabaseStorageService {
  SupabaseStorageService._();
  static final instance = SupabaseStorageService._();

  SupabaseClient get _db => Supabase.instance.client;
  String get _uid => _db.auth.currentUser!.id;

  // ─────────────────────────────────────────────
  // CHAT MESSAGES
  // ─────────────────────────────────────────────

  /// Returns all messages for [subject], oldest-first.
  Future<List<ChatMessage>> loadMessages(String subject) async {
    final rows = await _db
        .from('chat_messages')
        .select()
        .eq('user_id', _uid)
        .eq('subject', subject)
        .order('created_at', ascending: true);

    return (rows as List)
        .map((r) => ChatMessage.fromMap(r as Map<String, dynamic>))
        .toList();
  }

  /// Persists a single message and returns it with the server-assigned id.
  Future<ChatMessage> saveMessage({
    required String subject,
    required String role, // 'user' | 'ai'
    required String text,
  }) async {
    final row = await _db
        .from('chat_messages')
        .insert({
          'user_id': _uid,
          'subject': subject,
          'role': role,
          'text': text,
        })
        .select()
        .single();

    return ChatMessage.fromMap(row as Map<String, dynamic>);
  }

  /// Deletes all messages for [subject] for the current user.
  Future<void> clearHistory(String subject) async {
    await _db
        .from('chat_messages')
        .delete()
        .eq('user_id', _uid)
        .eq('subject', subject);
  }

  // ─────────────────────────────────────────────
  // LECTURES / SUMMARIES
  // ─────────────────────────────────────────────

  /// Returns all saved lectures for [subject], newest-first.
  Future<List<Lecture>> loadLectures(String subject) async {
    final rows = await _db
        .from('lectures')
        .select()
        .eq('user_id', _uid)
        .eq('subject', subject)
        .order('created_at', ascending: false);

    return (rows as List)
        .map((r) => Lecture.fromMap(r as Map<String, dynamic>))
        .toList();
  }

  /// Saves a lecture summary after upload.
  Future<Lecture> saveLecture({
    required String subject,
    required String filename,
    required String summary,
  }) async {
    final row = await _db
        .from('lectures')
        .insert({
          'user_id': _uid,
          'subject': subject,
          'filename': filename,
          'summary': summary,
        })
        .select()
        .single();

    return Lecture.fromMap(row as Map<String, dynamic>);
  }

  /// Deletes a single lecture by id.
  Future<void> deleteLecture(String lectureId) async {
    await _db.from('lectures').delete().eq('id', lectureId);
  }
}

// ─────────────────────────────────────────────
// MODELS
// ─────────────────────────────────────────────

class ChatMessage {
  final String id;
  final String subject;
  final String role; // 'user' | 'ai'
  final String text;
  final DateTime createdAt;

  const ChatMessage({
    required this.id,
    required this.subject,
    required this.role,
    required this.text,
    required this.createdAt,
  });

  factory ChatMessage.fromMap(Map<String, dynamic> m) => ChatMessage(
        id: m['id'] as String,
        subject: m['subject'] as String,
        role: m['role'] as String,
        text: m['text'] as String,
        createdAt: DateTime.parse(m['created_at'] as String),
      );

  Map<String, String> toDisplayMap() => {'role': role, 'text': text};
}

class Lecture {
  final String id;
  final String subject;
  final String filename;
  final String summary;
  final DateTime createdAt;

  const Lecture({
    required this.id,
    required this.subject,
    required this.filename,
    required this.summary,
    required this.createdAt,
  });

  factory Lecture.fromMap(Map<String, dynamic> m) => Lecture(
        id: m['id'] as String,
        subject: m['subject'] as String,
        filename: m['filename'] as String,
        summary: m['summary'] as String,
        createdAt: DateTime.parse(m['created_at'] as String),
      );
}
