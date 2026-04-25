import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Single service for all persistent data: chat history + uploaded lectures.
/// Drop-in replacement for SupabaseStorageService.
/// Call [FirebaseStorageService.instance] anywhere in the app.
class FirebaseStorageService {
  FirebaseStorageService._();
  static final instance = FirebaseStorageService._();

  FirebaseFirestore get _db => FirebaseFirestore.instance;
  String get _uid => FirebaseAuth.instance.currentUser!.uid;

  // ─────────────────────────────────────────────
  // CHAT MESSAGES
  // ─────────────────────────────────────────────

  /// Returns all messages for [subject], oldest-first.
  Future<List<ChatMessage>> loadMessages(String subject) async {
    final snap = await _db
        .collection('chat_messages')
        .where('user_id', isEqualTo: _uid)
        .where('subject', isEqualTo: subject)
        .orderBy('created_at', descending: false)
        .get();

    return snap.docs.map((d) => ChatMessage.fromMap(d.id, d.data())).toList();
  }

  /// Persists a single message and returns it with the server-assigned id.
  Future<ChatMessage> saveMessage({
    required String subject,
    required String role, // 'user' | 'ai'
    required String text,
  }) async {
    final data = {
      'user_id': _uid,
      'subject': subject,
      'role': role,
      'text': text,
      'created_at': FieldValue.serverTimestamp(),
    };

    final ref = await _db.collection('chat_messages').add(data);
    final snap = await ref.get();

    return ChatMessage.fromMap(snap.id, snap.data()!);
  }

  /// Deletes all messages for [subject] for the current user.
  Future<void> clearHistory(String subject) async {
    final snap = await _db
        .collection('chat_messages')
        .where('user_id', isEqualTo: _uid)
        .where('subject', isEqualTo: subject)
        .get();

    final batch = _db.batch();
    for (final doc in snap.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  // ─────────────────────────────────────────────
  // LECTURES / SUMMARIES
  // ─────────────────────────────────────────────

  /// Returns all saved lectures for [subject], newest-first.
  Future<List<Lecture>> loadLectures(String subject) async {
    final snap = await _db
        .collection('lectures')
        .where('user_id', isEqualTo: _uid)
        .where('subject', isEqualTo: subject)
        .orderBy('created_at', descending: true)
        .get();

    return snap.docs.map((d) => Lecture.fromMap(d.id, d.data())).toList();
  }

  /// Saves a lecture summary after upload.
  Future<Lecture> saveLecture({
    required String subject,
    required String filename,
    required String summary,
  }) async {
    final data = {
      'user_id': _uid,
      'subject': subject,
      'filename': filename,
      'summary': summary,
      'created_at': FieldValue.serverTimestamp(),
    };

    final ref = await _db.collection('lectures').add(data);
    final snap = await ref.get();

    return Lecture.fromMap(snap.id, snap.data()!);
  }

  /// Deletes a single lecture by id.
  Future<void> deleteLecture(String lectureId) async {
    await _db.collection('lectures').doc(lectureId).delete();
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

  factory ChatMessage.fromMap(String id, Map<String, dynamic> m) => ChatMessage(
        id: id,
        subject: m['subject'] as String,
        role: m['role'] as String,
        text: m['text'] as String,
        // Firestore returns Timestamp, not a String
        createdAt: (m['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
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

  factory Lecture.fromMap(String id, Map<String, dynamic> m) => Lecture(
        id: id,
        subject: m['subject'] as String,
        filename: m['filename'] as String,
        summary: m['summary'] as String,
        createdAt: (m['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );
}
