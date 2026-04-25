import 'dart:convert';
import 'package:ai_learning_companion/services/firebase_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import '../widgets/subject_card.dart';
import '../providers/settings_provider.dart';
import '../l10n/app_strings.dart';

import 'lectures_screen.dart';

// ── Update this whenever ngrok restarts ──────────────────────
const String kApiBase = "Educational link here";

final List<Map<String, dynamic>> kSubjects = [
  {
    'subjectKey': 'subject_physics',
    'icon': Icons.rocket_launch,
    'color': Colors.blue,
    'descKey': 'subject_physics_desc',
    'progress': 0.0,
  },
  {
    'subjectKey': 'subject_math',
    'icon': Icons.calculate,
    'color': Colors.green,
    'descKey': 'subject_math_desc',
    'progress': 0.0,
  },
  {
    'subjectKey': 'subject_chemistry',
    'icon': Icons.science,
    'color': Colors.orange,
    'descKey': 'subject_chemistry_desc',
    'progress': 0.0,
  },
  {
    'subjectKey': 'subject_biology',
    'icon': Icons.eco,
    'color': Colors.purple,
    'descKey': 'subject_biology_desc',
    'progress': 0.0,
  },
  {
    'subjectKey': 'subject_cs',
    'icon': Icons.computer,
    'color': Colors.red,
    'descKey': 'subject_cs_desc',
    'progress': 0.0,
  },
  {
    'subjectKey': 'subject_history',
    'icon': Icons.history,
    'color': Colors.brown,
    'descKey': 'subject_history_desc',
    'progress': 0.0,
  },
];

// ─────────────────────────────────────────────────────────────────────────────
// EDUCATION SCREEN
// ─────────────────────────────────────────────────────────────────────────────

class EducationScreen extends StatelessWidget {
  const EducationScreen({super.key});

  void _openAiChat(
      BuildContext context, String subject, Color color, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          _AiChatSheet(subject: subject, color: color, isDark: isDark),
    );
  }

  void _openLecturesScreen(
      BuildContext context, String subject, Color color, IconData icon) {
    Navigator.pushNamed(
      context,
      '/lectures',
      arguments: LecturesScreenArgs(
        subject: subject,
        color: color,
        icon: icon,
      ),
    );
  }

  Future<void> _uploadLecture(
      BuildContext context, String subject, Color color, String lang) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'docx', 'txt', 'md'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;
    final bytes = file.bytes;
    final name = file.name;

    if (bytes == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppStrings.get('file_read_error', lang))));
      }
      return;
    }

    if (context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          title: Row(children: [
            SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: color)),
            const SizedBox(width: 12),
            Text(AppStrings.get('summarizing', lang)),
          ]),
          content: Text(AppStrings.get('uploading_summarizing', lang)),
        ),
      );
    }

    try {
      final request =
          http.MultipartRequest('POST', Uri.parse('$kApiBase/summarize'));
      request.files
          .add(http.MultipartFile.fromBytes('file', bytes, filename: name));
      // ── TRANSLATION: send current language so backend translates summary ──
      request.fields['language'] = lang;

      final streamed = await request.send();
      final res = await http.Response.fromStream(streamed);

      if (context.mounted) Navigator.of(context).pop();

      final body = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode != 200) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: ${body['error'] ?? res.body}')));
        }
        return;
      }

      final summary = body['summary'] as String;

      await FirebaseStorageService.instance.saveLecture(
        subject: subject,
        filename: name,
        summary: summary,
      );

      if (context.mounted) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text(AppStrings.get('summary', lang),
                style: TextStyle(color: color)),
            content: SingleChildScrollView(child: Text(summary)),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(AppStrings.get('close', lang)))
            ],
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final lang = settings.language;
    final isDark = settings.isDark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1A1A2E) : null,
      appBar: AppBar(
        title: Text(AppStrings.get('choose_subject', lang)),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.85,
          ),
          itemCount: kSubjects.length,
          itemBuilder: (context, index) {
            final s = kSubjects[index];
            final color = s['color'] as Color;
            final icon = s['icon'] as IconData;
            final subject = AppStrings.get(s['subjectKey'] as String, lang);
            final desc = AppStrings.get(s['descKey'] as String, lang);
            return SubjectCard(
              subject: subject,
              icon: icon,
              color: color,
              description: desc,
              progress: s['progress'] as double,
              onTap: () => _openLecturesScreen(context, subject, color, icon),
              onUploadLecture: () =>
                  _uploadLecture(context, subject, color, lang),
              onAiHelper: () => _openAiChat(context, subject, color, isDark),
              onFlashcards: () =>
                  _openLecturesScreen(context, subject, color, icon),
            );
          },
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AI CHAT SHEET
// ─────────────────────────────────────────────────────────────────────────────

class _AiChatSheet extends StatefulWidget {
  final String subject;
  final Color color;
  final bool isDark;
  const _AiChatSheet(
      {required this.subject, required this.color, required this.isDark});

  @override
  State<_AiChatSheet> createState() => _AiChatSheetState();
}

class _AiChatSheetState extends State<_AiChatSheet> {
  final TextEditingController _ctrl = TextEditingController();
  final ScrollController _scroll = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _loading = false;
  bool _initialLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final msgs =
          await FirebaseStorageService.instance.loadMessages(widget.subject);
      if (mounted) setState(() => _messages.addAll(msgs));
    } catch (e) {
      debugPrint('History load error: $e');
    } finally {
      if (mounted) setState(() => _initialLoading = false);
      _scrollDown();
    }
  }

  Future<void> _send() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;

    // ── Read language from provider ──
    final lang = context.read<SettingsProvider>().language;

    final userMsg = await FirebaseStorageService.instance.saveMessage(
      subject: widget.subject,
      role: 'user',
      text: text,
    );
    setState(() {
      _messages.add(userMsg);
      _loading = true;
    });
    _ctrl.clear();
    _scrollDown();

    try {
      final res = await http.post(
        Uri.parse('$kApiBase/chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'message': '[${widget.subject}] $text',
          'language': lang, // ── TRANSLATION: backend translates before sending
        }),
      );
      final reply = res.statusCode == 200
          ? (jsonDecode(res.body) as Map<String, dynamic>)['response'] as String
          : 'Error ${res.statusCode}';

      final aiMsg = await FirebaseStorageService.instance.saveMessage(
        subject: widget.subject,
        role: 'ai',
        text: reply,
      );
      if (mounted) setState(() => _messages.add(aiMsg));
    } catch (e) {
      final aiMsg = await FirebaseStorageService.instance.saveMessage(
        subject: widget.subject,
        role: 'ai',
        text: 'Failed: $e',
      );
      if (mounted) setState(() => _messages.add(aiMsg));
    } finally {
      if (mounted) {
        setState(() => _loading = false);
        _scrollDown();
      }
    }
  }

  Future<void> _clearHistory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Clear History'),
        content: Text(
            'Delete all messages for ${widget.subject}? This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Clear')),
        ],
      ),
    );
    if (confirmed != true) return;
    await FirebaseStorageService.instance.clearHistory(widget.subject);
    if (mounted) setState(() => _messages.clear());
  }

  void _scrollDown() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.read<SettingsProvider>().language;
    final bg = widget.isDark ? const Color(0xFF16213E) : Colors.white;
    final textColor = widget.isDark ? Colors.white : Colors.black87;

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (_, sc) => Container(
        decoration: BoxDecoration(
            color: bg,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(20))),
        child: Column(
          children: [
            Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2))),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(children: [
                Icon(Icons.auto_awesome_rounded, color: widget.color),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                      '${AppStrings.get('ai_help', lang)} – ${widget.subject}',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: widget.color)),
                ),
                if (_messages.isNotEmpty)
                  IconButton(
                    tooltip: 'Clear history',
                    icon: const Icon(Icons.delete_sweep_rounded,
                        color: Colors.redAccent, size: 20),
                    onPressed: _clearHistory,
                  ),
              ]),
            ),
            const Divider(height: 1),
            Expanded(
              child: _initialLoading
                  ? Center(
                      child: CircularProgressIndicator(color: widget.color))
                  : _messages.isEmpty && !_loading
                      ? Center(
                          child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.chat_bubble_outline_rounded,
                                size: 48, color: widget.color.withOpacity(0.4)),
                            const SizedBox(height: 12),
                            Text('Ask anything about ${widget.subject}',
                                style: TextStyle(
                                    color: textColor.withOpacity(0.5))),
                          ],
                        ))
                      : ListView.builder(
                          controller: _scroll,
                          padding: const EdgeInsets.all(12),
                          itemCount: _messages.length + (_loading ? 1 : 0),
                          itemBuilder: (_, i) {
                            if (i == _messages.length) {
                              return const Align(
                                  alignment: Alignment.centerLeft,
                                  child: Padding(
                                      padding: EdgeInsets.all(8),
                                      child: SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2))));
                            }
                            final m = _messages[i];
                            final isUser = m.role == 'user';
                            return KeyedSubtree(
                              key: ValueKey(m.id),
                              child: Align(
                                alignment: isUser
                                    ? Alignment.centerRight
                                    : Alignment.centerLeft,
                                child: Container(
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 4),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 10),
                                  constraints: BoxConstraints(
                                      maxWidth:
                                          MediaQuery.of(context).size.width *
                                              0.78),
                                  decoration: BoxDecoration(
                                    color: isUser
                                        ? widget.color.withOpacity(0.85)
                                        : (widget.isDark
                                            ? const Color(0xFF1E2A3A)
                                            : Colors.grey[100]),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(m.text,
                                      style: TextStyle(
                                          color:
                                              isUser ? Colors.white : textColor,
                                          fontSize: 13)),
                                ),
                              ),
                            );
                          },
                        ),
            ),
            SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                    left: 12,
                    right: 12,
                    bottom: MediaQuery.of(context).viewInsets.bottom + 8,
                    top: 8),
                child: Row(children: [
                  Expanded(
                    child: TextField(
                      controller: _ctrl,
                      style: TextStyle(color: textColor),
                      decoration: InputDecoration(
                        hintText:
                            '${AppStrings.get('ask_about', lang)} ${widget.subject}…',
                        hintStyle: TextStyle(
                            color:
                                widget.isDark ? Colors.white38 : Colors.grey),
                        filled: true,
                        fillColor: widget.isDark
                            ? const Color(0xFF1E2A3A)
                            : Colors.grey[100],
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                      ),
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                      backgroundColor: widget.color,
                      child: IconButton(
                          icon: const Icon(Icons.send_rounded,
                              color: Colors.white, size: 18),
                          onPressed: _send)),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
