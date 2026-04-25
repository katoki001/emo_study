import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../l10n/app_strings.dart';
import '../services/colab_ai_service.dart';
import 'emotional_memories_screen.dart'; // EmotionalMemoryService lives here

class ChatMessage {
  final String text;
  final bool isUser;
  final MentalState? mentalState;
  const ChatMessage(
      {required this.text, required this.isUser, this.mentalState});
}

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

class AISupporterScreen extends StatefulWidget {
  const AISupporterScreen({super.key});

  @override
  State<AISupporterScreen> createState() => _AISupporterScreenState();
}

class _AISupporterScreenState extends State<AISupporterScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  final List<ChatMessage> _messages = [];
  final List<Map<String, String>> _history = [];

  bool _isTyping = false;
  bool _serverOnline = false;
  bool _savingMemory = false;
  MentalState _latestState = MentalState.neutral();

  @override
  void initState() {
    super.initState();
    _checkServer();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollCtrl.dispose();
    // Save silently when navigating away if there was an actual exchange
    if (_history.length >= 2) {
      _saveMemoryBackground();
    }
    super.dispose();
  }

  Future<void> _checkServer() async {
    final online = await ColabAIService.isReachable();
    if (mounted) setState(() => _serverOnline = online);
  }

  // ── Save current session as a memory, then clear ─────────────────────────

  Future<void> _resetConversation() async {
    if (_history.length >= 2) await _saveMemory();
    await ColabAIService.resetSession();
    if (mounted) {
      setState(() {
        _messages.clear();
        _history.clear();
        _latestState = MentalState.neutral();
      });
    }
  }

  // Called from dispose — no setState, no mounted checks, fire and forget
  Future<void> _saveMemoryBackground() async {
    try {
      final firstUserMsg = _history.firstWhere((m) => m['role'] == 'user',
              orElse: () => {'content': 'Session'})['content'] ??
          'Session';
      final title = firstUserMsg.length > 48
          ? '${firstUserMsg.substring(0, 45)}…'
          : firstUserMsg;

      final lastAiMsg = _history.lastWhere((m) => m['role'] == 'assistant',
              orElse: () => {'content': ''})['content'] ??
          '';
      final summary = lastAiMsg.length > 160
          ? '${lastAiMsg.substring(0, 157)}…'
          : lastAiMsg;

      final turns = _history
          .map((m) => <String, String>{
                'role': m['role'] ?? '',
                'text': m['content'] ?? '',
              })
          .toList();

      final Map<String, double> scoresJson;
      int aiMessageCount = 0;
      final Map<String, double> accumulatedScores = {};
      for (final msg in _messages) {
        if (!msg.isUser && msg.mentalState != null) {
          aiMessageCount++;
          msg.mentalState!.toMap().forEach((state, value) {
            accumulatedScores[state] = (accumulatedScores[state] ?? 0) + value;
          });
        }
      }
      scoresJson = aiMessageCount > 0
          ? accumulatedScores.map((k, v) => MapEntry(k, v / aiMessageCount))
          : _latestState.toMap();

      final dominantState = scoresJson.isNotEmpty
          ? scoresJson.entries.reduce((a, b) => a.value >= b.value ? a : b).key
          : 'Normal';

      await EmotionalMemoryService.instance.save(
        title: title,
        summary: summary.isEmpty ? 'No AI response recorded.' : summary,
        dominantState: dominantState,
        stateScores: scoresJson,
        turns: turns,
      );
    } catch (e) {
      debugPrint('_saveMemoryBackground error: $e');
    }
  }

  Future<void> _saveMemory() async {
    if (mounted) setState(() => _savingMemory = true);

    try {
      // Build a short title from the first user message
      final firstUserMsg = _history.firstWhere((m) => m['role'] == 'user',
              orElse: () => {'content': 'Session'})['content'] ??
          'Session';
      final title = firstUserMsg.length > 48
          ? '${firstUserMsg.substring(0, 45)}…'
          : firstUserMsg;

      // Build a one-sentence summary from the last assistant message
      final lastAiMsg = _history.lastWhere((m) => m['role'] == 'assistant',
              orElse: () => {'content': ''})['content'] ??
          '';
      final summary = lastAiMsg.length > 160
          ? '${lastAiMsg.substring(0, 157)}…'
          : lastAiMsg;

      // Convert history {role, content} → {role, text} for storage
      // Explicitly typed as List<Map<String, String>> to match service
      final turns = _history
          .map((m) => <String, String>{
                'role': m['role'] ?? '',
                'text': m['content'] ?? '',
              })
          .toList();

      // Average state scores across ALL AI messages in this conversation
      // so the dominant colour reflects the whole session, not just the last reply
      final Map<String, double> accumulatedScores = {};
      int aiMessageCount = 0;

      for (final msg in _messages) {
        if (!msg.isUser && msg.mentalState != null) {
          aiMessageCount++;
          msg.mentalState!.toMap().forEach((state, value) {
            accumulatedScores[state] = (accumulatedScores[state] ?? 0) + value;
          });
        }
      }

      // Average them out (fall back to latest state if no AI messages found)
      final Map<String, double> scoresJson;
      if (aiMessageCount > 0) {
        scoresJson =
            accumulatedScores.map((k, v) => MapEntry(k, v / aiMessageCount));
      } else {
        scoresJson = _latestState.toMap();
      }

      final dominantState = scoresJson.isNotEmpty
          ? scoresJson.entries.reduce((a, b) => a.value >= b.value ? a : b).key
          : 'Normal';

      await EmotionalMemoryService.instance.save(
        title: title,
        summary: summary.isEmpty ? 'No AI response recorded.' : summary,
        dominantState: dominantState,
        stateScores: scoresJson,
        turns: turns,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(children: [
              Icon(Icons.check_circle_outline, color: Colors.white, size: 16),
              SizedBox(width: 8),
              Text('Memory saved', style: TextStyle(fontSize: 13)),
            ]),
            backgroundColor: Colors.deepPurple,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('_saveMemory error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Could not save memory: $e',
              style: const TextStyle(fontSize: 11),
              maxLines: 3,
            ),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _savingMemory = false);
    }
  }

  // ── Open memories screen ─────────────────────────────────────────────────

  void _openMemories() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const EmotionalMemoriesScreen()),
    );
  }

  // ── Send message ─────────────────────────────────────────────────────────

  Future<void> _sendMessage([String? override]) async {
    final text = (override ?? _controller.text).trim();
    if (text.isEmpty || _isTyping) return;
    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
      _isTyping = true;
    });
    _history.add({'role': 'user', 'content': text});
    _controller.clear();
    _scrollToBottom();

    final result = await ColabAIService.sendMessage(
      message: text,
      history: List.from(_history),
      language: context.read<SettingsProvider>().language,
    );

    if (mounted) {
      _history.add({'role': 'assistant', 'content': result.response});
      setState(() {
        _isTyping = false;
        _latestState = result.mentalState;
        _messages.add(ChatMessage(
          text: result.response,
          isUser: false,
          mentalState: result.mentalState,
        ));
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final isDark = settings.isDark;
    final lang = settings.language;

    return Stack(
      children: [
        Column(
          children: [
            _buildHeader(isDark, lang),
            if (!_serverOnline) _buildOfflineBanner(isDark, lang),
            _buildQuickActions(lang),
            Expanded(child: _buildMessageList(isDark, lang)),
            if (_isTyping) _buildTypingIndicator(isDark, lang),
            _buildInputArea(isDark, lang),
          ],
        ),
        // Saving overlay
        if (_savingMemory)
          Container(
            color: Colors.black38,
            child: const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: Colors.white),
                  SizedBox(height: 14),
                  Text('Saving memory…',
                      style: TextStyle(color: Colors.white, fontSize: 14)),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildHeader(bool isDark, String lang) {
    final dominant = _latestState.dominantState;
    final style = _styleFor(dominant);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark
            ? style.color.withOpacity(0.15)
            : style.color.withOpacity(0.10),
        border: Border.all(color: style.color.withOpacity(0.35), width: 1.5),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: style.color.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4))
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: style.color.withOpacity(0.2),
            child: Icon(style.icon, color: style.color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.get('emotional_ai_support', lang),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  child: Text(
                    dominant == 'Normal'
                        ? AppStrings.get('here_to_listen', lang)
                        : '${AppStrings.get('sensing', lang)} $dominant — ${AppStrings.get('here_with_you', lang)}',
                    key: ValueKey(dominant),
                    style: TextStyle(
                        fontSize: 12,
                        color: style.color,
                        fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
          // ── Memories button ─────────────────────────────────────────
          IconButton(
            icon: Icon(Icons.auto_stories_outlined,
                size: 20, color: isDark ? Colors.white70 : Colors.grey[700]),
            tooltip: AppStrings.get('view_memories', lang),
            onPressed: _openMemories,
          ),
          // ── New session button ───────────────────────────────────────
          IconButton(
            icon: Icon(Icons.refresh,
                size: 20, color: isDark ? Colors.white70 : Colors.grey[700]),
            tooltip: AppStrings.get('new_conversation', lang),
            onPressed: _resetConversation,
          ),
          // ── Server status dot ────────────────────────────────────────
          GestureDetector(
            onTap: _checkServer,
            child: Tooltip(
              message: _serverOnline
                  ? 'Colab connected ✓'
                  : 'Colab offline — tap to retry',
              child: Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _serverOnline ? Colors.green : Colors.red,
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
    );
  }

  Widget _buildOfflineBanner(bool isDark, String lang) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? Colors.orange.withOpacity(0.15) : Colors.orange[50],
        border: Border.all(color: Colors.orange.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.cloud_off, color: Colors.orange, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              AppStrings.get('colab_offline', lang),
              style: const TextStyle(fontSize: 12, color: Colors.deepOrange),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(String lang) {
    final chips = [
      (AppStrings.get('chip_anxious', lang), Icons.air),
      (AppStrings.get('chip_low', lang), Icons.cloud),
      (AppStrings.get('chip_not_here', lang), Icons.favorite_border),
      (AppStrings.get('chip_overwhelmed', lang), Icons.waves),
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
      child: Row(
        children: chips
            .map((c) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ActionChip(
                    avatar: Icon(c.$2, size: 15),
                    label: Text(c.$1, style: const TextStyle(fontSize: 13)),
                    onPressed: () => _sendMessage(c.$1),
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildMessageList(bool isDark, String lang) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 6, 16, 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2A3A) : Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: _messages.isEmpty
          ? _buildEmptyState(isDark, lang)
          : ListView.builder(
              controller: _scrollCtrl,
              itemCount: _messages.length,
              itemBuilder: (_, i) => _buildBubble(_messages[i], isDark),
            ),
    );
  }

  Widget _buildEmptyState(bool isDark, String lang) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_outline, size: 52, color: Colors.pink[200]),
          const SizedBox(height: 14),
          Text(
            AppStrings.get('here_for_you', lang),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            AppStrings.get('how_feeling_today', lang),
            style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white54 : Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildBubble(ChatMessage msg, bool isDark) {
    return Column(
      crossAxisAlignment:
          msg.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Align(
          alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.74),
            margin: const EdgeInsets.symmetric(vertical: 4),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            decoration: BoxDecoration(
              color: msg.isUser
                  ? Colors.deepPurple[isDark ? 300 : 100]
                  : (isDark ? const Color(0xFF263445) : Colors.grey[50]),
              border: msg.isUser
                  ? null
                  : Border.all(
                      color: isDark ? Colors.white12 : Colors.grey.shade200),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(18),
                topRight: const Radius.circular(18),
                bottomLeft: Radius.circular(msg.isUser ? 18 : 4),
                bottomRight: Radius.circular(msg.isUser ? 4 : 18),
              ),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 2))
              ],
            ),
            child: Text(
              msg.text,
              style: TextStyle(
                fontSize: 14.5,
                height: 1.4,
                color: msg.isUser
                    ? Colors.white
                    : (isDark ? Colors.white : Colors.black87),
              ),
            ),
          ),
        ),
        if (!msg.isUser && msg.mentalState != null)
          _buildMentalStateBar(msg.mentalState!, isDark),
      ],
    );
  }

  Widget _buildMentalStateBar(MentalState state, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10, top: 2),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF263445) : Colors.grey[50],
        border:
            Border.all(color: isDark ? Colors.white12 : Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(Icons.psychology_outlined,
                size: 13, color: isDark ? Colors.white38 : Colors.grey[500]),
            const SizedBox(width: 4),
            Text(
              'Mental State Estimation',
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white54 : Colors.grey[600],
                  letterSpacing: 0.3),
            ),
          ]),
          const SizedBox(height: 8),
          ...state.toMap().entries.map((e) => _buildStateRow(e.key, e.value)),
        ],
      ),
    );
  }

  Widget _buildStateRow(String label, double value) {
    final style = _styleFor(label);
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        children: [
          SizedBox(
            width: 86,
            child: Row(children: [
              Icon(style.icon, size: 12, color: style.color),
              const SizedBox(width: 4),
              Text(label,
                  style: TextStyle(
                      fontSize: 11,
                      color: style.color,
                      fontWeight: FontWeight.w600)),
            ]),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: value / 100.0,
                minHeight: 6,
                backgroundColor: style.color.withOpacity(0.12),
                valueColor: AlwaysStoppedAnimation<Color>(
                    style.color.withOpacity(0.75)),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 42,
            child: Text('${value.toStringAsFixed(1)}%',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: style.color)),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator(bool isDark, String lang) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Row(children: [
        Icon(Icons.favorite, size: 13, color: Colors.pink[300]),
        const SizedBox(width: 6),
        Text(
          AppStrings.get('understanding_feelings', lang),
          style: TextStyle(
              fontSize: 12,
              fontStyle: FontStyle.italic,
              color: isDark ? Colors.white54 : Colors.grey[500]),
        ),
      ]),
    );
  }

  Widget _buildInputArea(bool isDark, String lang) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF16213E) : Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, -2))
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              minLines: 1,
              maxLines: 4,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              decoration: InputDecoration(
                hintText: AppStrings.get('share_how_you_feel', lang),
                hintStyle: TextStyle(
                    color: isDark ? Colors.white38 : Colors.grey[400]),
                filled: true,
                fillColor: isDark ? const Color(0xFF1E2A3A) : Colors.grey[100],
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none),
              ),
            ),
          ),
          const SizedBox(width: 10),
          FloatingActionButton(
            onPressed: _isTyping ? null : _sendMessage,
            mini: true,
            backgroundColor: _isTyping
                ? (isDark ? Colors.white24 : Colors.grey[300])
                : Colors.deepPurple,
            elevation: 2,
            child: Icon(
              _isTyping ? Icons.hourglass_top : Icons.send,
              color: Colors.white,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }
}
