// lib/screens/ai_supporter_screen.dart
import 'package:flutter/material.dart';
import '../services/colab_ai_service.dart';

// ─── Chat message model ────────────────────────────────────────────────────

class ChatMessage {
  final String text;
  final bool isUser;
  final MentalState? mentalState; // only on AI messages

  const ChatMessage({
    required this.text,
    required this.isUser,
    this.mentalState,
  });
}

// ─── Mental state display config ──────────────────────────────────────────

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

// ─── Screen ────────────────────────────────────────────────────────────────

class AISupporterScreen extends StatefulWidget {
  const AISupporterScreen({super.key});

  @override
  State<AISupporterScreen> createState() => _AISupporterScreenState();
}

class _AISupporterScreenState extends State<AISupporterScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];

  bool _isTyping = false;
  bool _serverOnline = false;
  MentalState _latestState = MentalState.neutral();

  @override
  void initState() {
    super.initState();
    _checkServer();
  }

  // ── Server health ──────────────────────────────────────────────────────
  Future<void> _checkServer() async {
    final online = await ColabAIService.isReachable();
    if (mounted) setState(() => _serverOnline = online);
  }

  // ── Send message ───────────────────────────────────────────────────────
  Future<void> _sendMessage([String? override]) async {
    final text = (override ?? _controller.text).trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
      _isTyping = true;
    });
    _controller.clear();
    _scrollToBottom();

    final result = await ColabAIService.sendMessage(text);

    if (mounted) {
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
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // ── Build ──────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        if (!_serverOnline) _buildOfflineBanner(),
        _buildQuickActions(),
        Expanded(child: _buildMessageList()),
        if (_isTyping) _buildTypingIndicator(),
        _buildInputArea(),
      ],
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    final dominant = _latestState.dominantState;
    final style = _styleFor(dominant);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: style.color.withOpacity(0.10),
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
          // Animated avatar
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            child: CircleAvatar(
              radius: 24,
              backgroundColor: style.color.withOpacity(0.2),
              child: Icon(style.icon, color: style.color, size: 26),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Emotional AI Support',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  child: Text(
                    dominant == 'Normal'
                        ? 'Here to listen and support you'
                        : 'Sensing some $dominant — I\'m here with you',
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
          // Connection status + refresh
          GestureDetector(
            onTap: _checkServer,
            child: Tooltip(
              message: _serverOnline
                  ? 'Colab connected ✓'
                  : 'Colab offline — tap to retry',
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 9,
                    height: 9,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _serverOnline ? Colors.green : Colors.red,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.refresh, size: 18, color: Colors.grey[500]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Offline banner ─────────────────────────────────────────────────────
  Widget _buildOfflineBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        border: Border.all(color: Colors.orange.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.cloud_off, color: Colors.orange, size: 18),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Colab model is offline. Run the API cell in your notebook and update the URL in ColabAIService.',
              style: TextStyle(fontSize: 12, color: Colors.deepOrange),
            ),
          ),
        ],
      ),
    );
  }

  // ── Quick actions ──────────────────────────────────────────────────────
  Widget _buildQuickActions() {
    const chips = [
      ("I'm feeling anxious", Icons.air),
      ("I feel really low", Icons.cloud),
      ("I need someone to talk to", Icons.favorite),
      ("I'm overwhelmed", Icons.waves),
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

  // ── Message list ───────────────────────────────────────────────────────
  Widget _buildMessageList() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 6, 16, 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: _messages.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              controller: _scrollController,
              itemCount: _messages.length,
              itemBuilder: (context, i) => _buildBubble(_messages[i]),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_outline, size: 52, color: Colors.pink[200]),
          const SizedBox(height: 14),
          const Text("I'm here for you.",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87)),
          const SizedBox(height: 6),
          Text("How are you feeling today?",
              style: TextStyle(fontSize: 14, color: Colors.grey[500])),
        ],
      ),
    );
  }

  // ── Single message bubble ──────────────────────────────────────────────
  Widget _buildBubble(ChatMessage msg) {
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
              color: msg.isUser ? Colors.deepPurple[100] : Colors.grey[50],
              border:
                  msg.isUser ? null : Border.all(color: Colors.grey.shade200),
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
            child: Text(msg.text,
                style: const TextStyle(fontSize: 14.5, height: 1.4)),
          ),
        ),
        // Mental state bar — only on AI messages
        if (!msg.isUser && msg.mentalState != null)
          _buildMentalStateBar(msg.mentalState!),
      ],
    );
  }

  // ── Mental state bar ───────────────────────────────────────────────────
  Widget _buildMentalStateBar(MentalState state) {
    final entries = state.toMap().entries.toList();

    return Container(
      margin: const EdgeInsets.only(bottom: 10, top: 2),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.psychology_outlined,
                  size: 13, color: Colors.grey[500]),
              const SizedBox(width: 4),
              Text('Mental State Estimation',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600],
                      letterSpacing: 0.3)),
            ],
          ),
          const SizedBox(height: 8),
          ...entries.map((e) => _buildStateRow(e.key, e.value)),
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
            width: 80,
            child: Row(
              children: [
                Icon(style.icon, size: 12, color: style.color),
                const SizedBox(width: 4),
                Text(label,
                    style: TextStyle(
                        fontSize: 11,
                        color: style.color,
                        fontWeight: FontWeight.w600)),
              ],
            ),
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
            width: 40,
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

  // ── Typing indicator ───────────────────────────────────────────────────
  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Row(
        children: [
          Icon(Icons.favorite, size: 13, color: Colors.pink[300]),
          const SizedBox(width: 6),
          Text('Understanding your feelings...',
              style: TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey[500])),
        ],
      ),
    );
  }

  // ── Input area ─────────────────────────────────────────────────────────
  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      decoration: BoxDecoration(
        color: Colors.white,
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
              decoration: InputDecoration(
                hintText: 'Share how you feel...',
                hintStyle: TextStyle(color: Colors.grey[400]),
                filled: true,
                fillColor: Colors.grey[100],
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
            backgroundColor: _isTyping ? Colors.grey[300] : Colors.deepPurple,
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

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
