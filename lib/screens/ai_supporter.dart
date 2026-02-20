// lib/screens/ai_supporter_screen.dart
import 'package:flutter/material.dart';
import '../services/ai_service.dart';

class AISupporterScreen extends StatefulWidget {
  const AISupporterScreen({super.key});

  @override
  State<AISupporterScreen> createState() => _AISupporterScreenState();
}

class _AISupporterScreenState extends State<AISupporterScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  bool _isTyping = false;

  void _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({'text': text, 'isUser': true});
      _isTyping = true;
    });
    _messageController.clear();

    // Get real response from AIService
    final response = await AIService.getAIResponse(text);

    setState(() {
      _isTyping = false;
      _messages.add({
        'text': response,
        'isUser': false,
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        _buildQuickActions(),
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: ListView.builder(
              reverse: true,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[_messages.length - 1 - index];
                return _buildMessageBubble(message);
              },
            ),
          ),
        ),
        if (_isTyping)
          const Padding(
            padding: EdgeInsets.only(bottom: 8.0),
            child: Text("AI is thinking...",
                style:
                    TextStyle(fontStyle: FontStyle.italic, color: Colors.grey)),
          ),
        _buildInputArea(),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: Row(
        children: [
          CircleAvatar(
              backgroundColor: Colors.blue[100],
              child: const Icon(Icons.assistant, color: Colors.blue)),
          const SizedBox(width: 16),
          const Text('AI Learning Assistant',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _quickActionChip('Explain photosynthesis'),
          const SizedBox(width: 8),
          _quickActionChip('Math help'),
          const SizedBox(width: 8),
          _quickActionChip('Study tips'),
        ],
      ),
    );
  }

  Widget _quickActionChip(String label) {
    return ActionChip(
      label: Text(label),
      onPressed: () {
        _messageController.text = label;
        _sendMessage();
      },
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    bool isUser = message['isUser'];
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: isUser ? Colors.deepPurple[100] : Colors.blue[100],
          borderRadius: BorderRadius.circular(15),
        ),
        child: Text(message['text']),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Ask me anything...',
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none),
              ),
            ),
          ),
          const SizedBox(width: 12),
          FloatingActionButton(
            onPressed: _sendMessage,
            mini: true,
            backgroundColor: Colors.deepPurple,
            child: const Icon(Icons.send, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
