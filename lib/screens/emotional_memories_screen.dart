import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../providers/settings_provider.dart';
import '../l10n/app_strings.dart';

// ─────────────────────────────────────────────────────────────────────────────
// MODEL
// ─────────────────────────────────────────────────────────────────────────────

class EmotionalMemory {
  final String id;
  final String title;
  final String summary;
  final String dominantState;
  final Map<String, double> stateScores;
  final List<_MemoryTurn> turns;
  final DateTime createdAt;

  const EmotionalMemory({
    required this.id,
    required this.title,
    required this.summary,
    required this.dominantState,
    required this.stateScores,
    required this.turns,
    required this.createdAt,
  });

  factory EmotionalMemory.fromMap(String id, Map<String, dynamic> m) {
    final rawScores = m['state_scores'];
    final scoresMap = (rawScores is Map)
        ? rawScores.cast<String, dynamic>()
        : <String, dynamic>{};

    final rawTurns = m['turns'];
    final turnsList = (rawTurns is List) ? rawTurns : <dynamic>[];

    return EmotionalMemory(
      id: id,
      title: (m['title'] ?? '').toString(),
      summary: (m['summary'] ?? '').toString(),
      dominantState: (m['dominant_state'] ?? 'Normal').toString(),
      stateScores: scoresMap.map((k, v) => MapEntry(k, (v as num).toDouble())),
      turns: turnsList
          .map((t) => _MemoryTurn.fromMap(
                (t is Map) ? t.cast<String, dynamic>() : <String, dynamic>{},
              ))
          .toList(),
      // Firestore returns Timestamp, not String
      createdAt: (m['created_at'] is Timestamp)
          ? (m['created_at'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }
}

class _MemoryTurn {
  final String role;
  final String text;
  const _MemoryTurn({required this.role, required this.text});
  factory _MemoryTurn.fromMap(Map<String, dynamic> m) => _MemoryTurn(
        role: (m['role'] ?? 'user').toString(),
        text: (m['text'] ?? '').toString(),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// FIREBASE SERVICE  (replaces EmotionalMemoryService / Supabase)
// ─────────────────────────────────────────────────────────────────────────────

class EmotionalMemoryService {
  EmotionalMemoryService._();
  static final instance = EmotionalMemoryService._();

  FirebaseFirestore get _db => FirebaseFirestore.instance;
  String get _uid => FirebaseAuth.instance.currentUser!.uid;

  static const _collection = 'emotional_memories';

  Future<List<EmotionalMemory>> loadAll() async {
    final snap = await _db
        .collection(_collection)
        .where('user_id', isEqualTo: _uid)
        .orderBy('created_at', descending: true)
        .get();

    return snap.docs
        .map((d) => EmotionalMemory.fromMap(d.id, d.data()))
        .toList();
  }

  Future<EmotionalMemory?> save({
    required String title,
    required String summary,
    required String dominantState,
    required Map<String, double> stateScores,
    required List<Map<String, String>> turns,
  }) async {
    try {
      final payload = {
        'user_id': _uid,
        'title': title,
        'summary': summary,
        'dominant_state': dominantState,
        'state_scores': stateScores.map((k, v) => MapEntry(k, v)),
        'turns': turns.map((t) => <String, dynamic>{...t}).toList(),
        'created_at': FieldValue.serverTimestamp(),
      };

      final ref = await _db.collection(_collection).add(payload);
      final snap = await ref.get();
      return EmotionalMemory.fromMap(snap.id, snap.data()!);
    } catch (e, st) {
      debugPrint('EmotionalMemoryService.save error: $e\n$st');
      rethrow;
    }
  }

  Future<void> delete(String id) async {
    await _db.collection(_collection).doc(id).delete();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STYLE HELPERS
// ─────────────────────────────────────────────────────────────────────────────

class _StateStyle {
  final Color color;
  final IconData icon;
  const _StateStyle(this.color, this.icon);
}

const Map<String, _StateStyle> _stateStyles = {
  'Normal': _StateStyle(Color(0xFF43A047), Icons.sentiment_satisfied_alt),
  'Anxiety': _StateStyle(Color(0xFFFF8F00), Icons.air),
  'Bipolar': _StateStyle(Color(0xFF8E24AA), Icons.swap_vert),
  'Depression': _StateStyle(Color(0xFF1E88E5), Icons.cloud),
  'Suicidal': _StateStyle(Color(0xFFE53935), Icons.favorite_border),
};

_StateStyle _styleFor(String state) =>
    _stateStyles[state] ?? const _StateStyle(Color(0xFF78909C), Icons.circle);

// ─────────────────────────────────────────────────────────────────────────────
// SCREEN  (unchanged except service calls — already correct)
// ─────────────────────────────────────────────────────────────────────────────

class EmotionalMemoriesScreen extends StatefulWidget {
  const EmotionalMemoriesScreen({super.key});

  @override
  State<EmotionalMemoriesScreen> createState() =>
      _EmotionalMemoriesScreenState();
}

class _EmotionalMemoriesScreenState extends State<EmotionalMemoriesScreen> {
  List<EmotionalMemory> _memories = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await EmotionalMemoryService.instance.loadAll();
      if (mounted)
        setState(() {
          _memories = data;
          _loading = false;
        });
    } catch (e) {
      if (mounted)
        setState(() {
          _error = e.toString();
          _loading = false;
        });
    }
  }

  Future<void> _delete(EmotionalMemory mem) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) =>
          _DeleteDialog(isDark: context.read<SettingsProvider>().isDark),
    );
    if (confirmed != true) return;
    await EmotionalMemoryService.instance.delete(mem.id);
    setState(() => _memories.removeWhere((m) => m.id == mem.id));
  }

  void _openDetail(EmotionalMemory mem) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => _MemoryDetailScreen(memory: mem),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final isDark = settings.isDark;
    final lang = settings.language;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0F172A) : const Color(0xFFF8F4FF),
      body: SafeArea(
        child: Column(
          children: [
            _Header(isDark: isDark, lang: lang, onRefresh: _load),
            Expanded(child: _buildBody(isDark, lang)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(bool isDark, String lang) {
    if (_loading)
      return const Center(
          child: CircularProgressIndicator(color: Colors.deepPurple));
    if (_error != null)
      return _ErrorState(error: _error!, onRetry: _load, isDark: isDark);
    if (_memories.isEmpty) return _EmptyState(isDark: isDark, lang: lang);
    return RefreshIndicator(
      onRefresh: _load,
      color: Colors.deepPurple,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        itemCount: _memories.length,
        itemBuilder: (_, i) => _MemoryCard(
          memory: _memories[i],
          isDark: isDark,
          onTap: () => _openDetail(_memories[i]),
          onDelete: () => _delete(_memories[i]),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// All widgets below (_Header, _MemoryCard, _StatePill, _MiniScoreBars,
// _MemoryDetailScreen, _DetailCard, _TurnBubble, _EmptyState, _ErrorState,
// _DeleteDialog) are IDENTICAL to your original — no changes needed.
// ─────────────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final bool isDark;
  final String lang;
  final VoidCallback onRefresh;
  const _Header(
      {required this.isDark, required this.lang, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: Colors.deepPurple.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.auto_stories_outlined,
                color: Colors.deepPurple, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppStrings.get('emotional_memories', lang),
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87)),
                Text(AppStrings.get('past_sessions', lang),
                    style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white38 : Colors.grey[500])),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.refresh,
                color: isDark ? Colors.white54 : Colors.grey[600]),
            onPressed: onRefresh,
          ),
        ],
      ),
    );
  }
}

class _MemoryCard extends StatelessWidget {
  final EmotionalMemory memory;
  final bool isDark;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  const _MemoryCard(
      {required this.memory,
      required this.isDark,
      required this.onTap,
      required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final dominantEntry = memory.stateScores.isNotEmpty
        ? memory.stateScores.entries
            .reduce((a, b) => a.value >= b.value ? a : b)
        : MapEntry('Normal', 100.0);
    final trueDominant = dominantEntry.key;
    final style = _styleFor(trueDominant);
    final date = _formatDate(memory.createdAt);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E2A3A) : Colors.white,
          border: Border.all(color: style.color.withOpacity(0.30), width: 1.5),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
                color: style.color.withOpacity(isDark ? 0.06 : 0.08),
                blurRadius: 10,
                offset: const Offset(0, 3))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(14, 12, 8, 10),
              decoration: BoxDecoration(
                color: style.color.withOpacity(isDark ? 0.12 : 0.07),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(17)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                      radius: 16,
                      backgroundColor: style.color.withOpacity(0.20),
                      child: Icon(style.icon, color: style.color, size: 16)),
                  const SizedBox(width: 10),
                  Expanded(
                      child: Text(memory.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white : Colors.black87))),
                  _StatePill(state: trueDominant, style: style),
                  const SizedBox(width: 4),
                  IconButton(
                      icon: Icon(Icons.delete_outline,
                          size: 18,
                          color: isDark ? Colors.white30 : Colors.grey[400]),
                      splashRadius: 18,
                      onPressed: onDelete),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
              child: Text(memory.summary,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 13,
                      height: 1.45,
                      color: isDark ? Colors.white70 : Colors.black54)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 0),
              child: _MiniScoreBars(scores: memory.stateScores, isDark: isDark),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
              child: Row(
                children: [
                  Icon(Icons.access_time_outlined,
                      size: 12,
                      color: isDark ? Colors.white30 : Colors.grey[400]),
                  const SizedBox(width: 4),
                  Text(date,
                      style: TextStyle(
                          fontSize: 11,
                          color: isDark ? Colors.white30 : Colors.grey[400])),
                  const Spacer(),
                  Icon(Icons.chat_bubble_outline,
                      size: 12,
                      color: isDark ? Colors.white30 : Colors.grey[400]),
                  const SizedBox(width: 4),
                  Text('${memory.turns.length} messages',
                      style: TextStyle(
                          fontSize: 11,
                          color: isDark ? Colors.white30 : Colors.grey[400])),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays == 0)
      return 'Today ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}

class _StatePill extends StatelessWidget {
  final String state;
  final _StateStyle style;
  const _StatePill({required this.state, required this.style});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
          color: style.color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: style.color.withOpacity(0.35))),
      child: Text(state,
          style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: style.color,
              letterSpacing: 0.3)),
    );
  }
}

class _MiniScoreBars extends StatelessWidget {
  final Map<String, double> scores;
  final bool isDark;
  const _MiniScoreBars({required this.scores, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final significant = scores.entries.where((e) => e.value >= 5).toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    if (significant.isEmpty) return const SizedBox.shrink();
    return Column(
      children: significant.take(3).map((e) {
        final st = _styleFor(e.key);
        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            children: [
              SizedBox(
                  width: 72,
                  child: Row(children: [
                    Icon(st.icon, size: 10, color: st.color),
                    const SizedBox(width: 3),
                    Text(e.key,
                        style: TextStyle(
                            fontSize: 10,
                            color: st.color,
                            fontWeight: FontWeight.w600))
                  ])),
              Expanded(
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                          value: e.value / 100.0,
                          minHeight: 4,
                          backgroundColor: st.color.withOpacity(0.10),
                          valueColor: AlwaysStoppedAnimation<Color>(
                              st.color.withOpacity(0.65))))),
              const SizedBox(width: 6),
              Text('${e.value.toStringAsFixed(0)}%',
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: st.color)),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _MemoryDetailScreen extends StatelessWidget {
  final EmotionalMemory memory;
  const _MemoryDetailScreen({required this.memory});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final isDark = settings.isDark;
    final dominantEntry = memory.stateScores.isNotEmpty
        ? memory.stateScores.entries
            .reduce((a, b) => a.value >= b.value ? a : b)
        : MapEntry('Normal', 100.0);
    final style = _styleFor(dominantEntry.key);

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0F172A) : const Color(0xFFF8F4FF),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1E2A3A) : Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.deepPurple),
        title: Text(memory.title,
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87)),
        actions: [
          _StatePill(state: dominantEntry.key, style: style),
          const SizedBox(width: 12)
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _DetailCard(
              isDark: isDark,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Icon(Icons.summarize_outlined,
                          size: 14,
                          color: isDark ? Colors.white38 : Colors.grey[500]),
                      const SizedBox(width: 6),
                      Text('Session Summary',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                              color:
                                  isDark ? Colors.white38 : Colors.grey[500]))
                    ]),
                    const SizedBox(height: 8),
                    Text(memory.summary,
                        style: TextStyle(
                            fontSize: 14,
                            height: 1.5,
                            color: isDark ? Colors.white70 : Colors.black54)),
                  ])),
          const SizedBox(height: 12),
          _DetailCard(
              isDark: isDark,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Icon(Icons.psychology_outlined,
                          size: 14,
                          color: isDark ? Colors.white38 : Colors.grey[500]),
                      const SizedBox(width: 6),
                      Text('Mental State at Session End',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                              color:
                                  isDark ? Colors.white38 : Colors.grey[500]))
                    ]),
                    const SizedBox(height: 12),
                    ...memory.stateScores.entries.map((e) {
                      final st = _styleFor(e.key);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(children: [
                          SizedBox(
                              width: 90,
                              child: Row(children: [
                                Icon(st.icon, size: 12, color: st.color),
                                const SizedBox(width: 4),
                                Text(e.key,
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: st.color,
                                        fontWeight: FontWeight.w600))
                              ])),
                          Expanded(
                              child: ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                      value: e.value / 100.0,
                                      minHeight: 7,
                                      backgroundColor:
                                          st.color.withOpacity(0.12),
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          st.color.withOpacity(0.75))))),
                          const SizedBox(width: 8),
                          SizedBox(
                              width: 44,
                              child: Text('${e.value.toStringAsFixed(1)}%',
                                  style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: st.color))),
                        ]),
                      );
                    }),
                  ])),
          const SizedBox(height: 12),
          _DetailCard(
              isDark: isDark,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Icon(Icons.chat_outlined,
                          size: 14,
                          color: isDark ? Colors.white38 : Colors.grey[500]),
                      const SizedBox(width: 6),
                      Text('Conversation',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                              color:
                                  isDark ? Colors.white38 : Colors.grey[500]))
                    ]),
                    const SizedBox(height: 12),
                    ...memory.turns
                        .map((t) => _TurnBubble(turn: t, isDark: isDark)),
                  ])),
        ],
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  final bool isDark;
  final Widget child;
  const _DetailCard({required this.isDark, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2A3A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: isDark ? Colors.white10 : Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: child,
    );
  }
}

class _TurnBubble extends StatelessWidget {
  final _MemoryTurn turn;
  final bool isDark;
  const _TurnBubble({required this.turn, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final isUser = turn.role == 'user';
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: isUser
              ? Colors.deepPurple.withOpacity(isDark ? 0.35 : 0.12)
              : (isDark ? const Color(0xFF263445) : Colors.grey[100]),
          borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(14),
              topRight: const Radius.circular(14),
              bottomLeft: Radius.circular(isUser ? 14 : 4),
              bottomRight: Radius.circular(isUser ? 4 : 14)),
        ),
        child: Text(turn.text,
            style: TextStyle(
                fontSize: 13,
                height: 1.4,
                color: isDark ? Colors.white70 : Colors.black87)),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool isDark;
  final String lang;
  const _EmptyState({required this.isDark, required this.lang});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.auto_stories_outlined,
              size: 56, color: Colors.deepPurple.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text(AppStrings.get('no_memories_yet', lang),
              style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white54 : Colors.black45)),
          const SizedBox(height: 6),
          Text(AppStrings.get('saved_after_session', lang),
              style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.white30 : Colors.grey[400])),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  final bool isDark;
  const _ErrorState(
      {required this.error, required this.onRetry, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off, size: 48, color: Colors.redAccent),
            const SizedBox(height: 12),
            Text('Could not load memories',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87)),
            const SizedBox(height: 6),
            Text(error,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: Colors.redAccent)),
            const SizedBox(height: 20),
            TextButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}

class _DeleteDialog extends StatelessWidget {
  final bool isDark;
  const _DeleteDialog({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: isDark ? const Color(0xFF1E2A3A) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text('Delete Memory',
          style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontSize: 16,
              fontWeight: FontWeight.bold)),
      content: Text('This session memory will be permanently removed.',
          style: TextStyle(
              color: isDark ? Colors.white60 : Colors.black54, fontSize: 14)),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel',
                style: TextStyle(
                    color: isDark ? Colors.white38 : Colors.grey[500]))),
        TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete',
                style: TextStyle(
                    color: Colors.redAccent, fontWeight: FontWeight.w600))),
      ],
    );
  }
}
