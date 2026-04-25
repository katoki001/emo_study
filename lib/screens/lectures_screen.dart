import 'dart:convert';
import 'package:ai_learning_companion/services/firebase_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import '../providers/settings_provider.dart';
import '../l10n/app_strings.dart';
import 'package:firebase_auth/firebase_auth.dart';

const String _kApiBase = "https://YOUR-EDUCATIONAL-URL.ngrok-free.app";

// ─────────────────────────────────────────────────────────────────────────────
// ROUTE ARGUMENTS
// ─────────────────────────────────────────────────────────────────────────────

class LecturesScreenArgs {
  final String subject;
  final Color color;
  final IconData icon;

  const LecturesScreenArgs({
    required this.subject,
    required this.color,
    required this.icon,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// LECTURES SCREEN
// ─────────────────────────────────────────────────────────────────────────────

class LecturesScreen extends StatefulWidget {
  const LecturesScreen({super.key});

  static const routeName = '/lectures';

  @override
  State<LecturesScreen> createState() => _LecturesScreenState();
}

class _LecturesScreenState extends State<LecturesScreen> {
  List<Lecture> _lectures = [];
  bool _loading = true;
  bool _uploading = false;

  late LecturesScreenArgs _args;
  bool _argsInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_argsInitialized) return;
    _argsInitialized = true;
    _args = ModalRoute.of(context)!.settings.arguments as LecturesScreenArgs;
    _loadLectures();
  }

  Future<void> _loadLectures() async {
    setState(() => _loading = true);
    try {
      final list =
          await FirebaseStorageService.instance.loadLectures(_args.subject);
      if (mounted) setState(() => _lectures = list);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed to load: $e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ── Upload & summarise ──────────────────────────────────────
  Future<void> _uploadLecture() async {
    final lang = context.read<SettingsProvider>().language;

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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppStrings.get('file_read_error', lang))));
      }
      return;
    }

    setState(() => _uploading = true);

    try {
      final request =
          http.MultipartRequest('POST', Uri.parse('$_kApiBase/summarize'));
      request.files
          .add(http.MultipartFile.fromBytes('file', bytes, filename: name));
      // ── TRANSLATION: send current language so backend translates summary ──
      request.fields['language'] = lang;

      final streamed = await request.send();
      final res = await http.Response.fromStream(streamed);

      final body = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode != 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: ${body['error'] ?? res.body}')));
        }
        return;
      }

      final summary = body['summary'] as String;

      final saved = await FirebaseStorageService.instance.saveLecture(
        subject: _args.subject,
        filename: name,
        summary: summary,
      );

      if (mounted) setState(() => _lectures.insert(0, saved));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Upload failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  // ── Delete ──────────────────────────────────────────────────
  Future<void> _deleteLecture(Lecture lecture) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete lecture?'),
        content: Text('"${lecture.filename}" will be permanently removed.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed != true) return;
    await FirebaseStorageService.instance.deleteLecture(lecture.id);
    if (mounted) {
      setState(() => _lectures.removeWhere((l) => l.id == lecture.id));
    }
  }

  // ── Open flashcards ─────────────────────────────────────────
  void _openFlashcards(Lecture lecture) {
    Navigator.pushNamed(
      context,
      FlashcardsScreen.routeName,
      arguments: FlashcardsScreenArgs(
        lecture: lecture,
        color: _args.color,
      ),
    );
  }

  // ── Open summary dialog ─────────────────────────────────────
  void _showSummary(Lecture lecture) {
    final isDark = context.read<SettingsProvider>().isDark;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Row(children: [
          Icon(Icons.summarize_rounded, color: _args.color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(lecture.filename,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 14, color: _args.color)),
          ),
        ]),
        content: SingleChildScrollView(
          child: Text(lecture.summary,
              style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.white70 : Colors.black87)),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close')),
          FilledButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _openFlashcards(lecture);
            },
            icon: const Icon(Icons.style_rounded, size: 16),
            label: const Text('Flashcards'),
            style: FilledButton.styleFrom(backgroundColor: _args.color),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final lang = settings.language;
    final isDark = settings.isDark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final bg = isDark ? const Color(0xFF1A1A2E) : null;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: _args.color,
        foregroundColor: Colors.white,
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_args.icon, size: 20, color: Colors.white),
            const SizedBox(width: 8),
            Text(_args.subject,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        actions: [
          if (_uploading)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Center(
                  child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))),
            )
          else
            IconButton(
              tooltip: AppStrings.get('lecture', lang),
              icon: const Icon(Icons.upload_file_rounded),
              onPressed: _uploadLecture,
            ),
        ],
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator(color: _args.color))
          : _lectures.isEmpty
              ? _EmptyState(color: _args.color, onUpload: _uploadLecture)
              : RefreshIndicator(
                  color: _args.color,
                  onRefresh: _loadLectures,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _lectures.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) {
                      final lec = _lectures[i];
                      return _LectureCard(
                        key: ValueKey(lec.id),
                        lecture: lec,
                        color: _args.color,
                        isDark: isDark,
                        textColor: textColor,
                        onTapSummary: () => _showSummary(lec),
                        onTapFlashcards: () => _openFlashcards(lec),
                        onDelete: () => _deleteLecture(lec),
                      );
                    },
                  ),
                ),
      floatingActionButton: _lectures.isNotEmpty && !_uploading
          ? FloatingActionButton.extended(
              backgroundColor: _args.color,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.upload_file_rounded),
              label: Text(AppStrings.get('lecture', lang)),
              onPressed: _uploadLecture,
            )
          : null,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// LECTURE CARD
// ─────────────────────────────────────────────────────────────────────────────

class _LectureCard extends StatelessWidget {
  final Lecture lecture;
  final Color color;
  final bool isDark;
  final Color textColor;
  final VoidCallback onTapSummary;
  final VoidCallback onTapFlashcards;
  final VoidCallback onDelete;

  const _LectureCard({
    super.key,
    required this.lecture,
    required this.color,
    required this.isDark,
    required this.textColor,
    required this.onTapSummary,
    required this.onTapFlashcards,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final dateStr =
        '${lecture.createdAt.day}/${lecture.createdAt.month}/${lecture.createdAt.year}';

    return Card(
      elevation: 2,
      color: isDark ? const Color(0xFF1E2A3A) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTapSummary,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: color.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12)),
                    child:
                        Icon(Icons.description_rounded, color: color, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(lecture.filename,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                                color: textColor)),
                        const SizedBox(height: 4),
                        Text(dateStr,
                            style: TextStyle(
                                fontSize: 12,
                                color: textColor.withOpacity(0.45))),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded,
                        color: Colors.redAccent, size: 20),
                    tooltip: 'Delete',
                    onPressed: onDelete,
                    padding: EdgeInsets.zero,
                    constraints:
                        const BoxConstraints(minWidth: 32, minHeight: 32),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: color.withOpacity(isDark ? 0.08 : 0.05),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: color.withOpacity(0.15))),
                child: Text(
                  lecture.summary,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 12,
                      height: 1.5,
                      color: textColor.withOpacity(0.7)),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onTapSummary,
                      icon:
                          Icon(Icons.summarize_rounded, size: 16, color: color),
                      label: Text('Full Summary',
                          style: TextStyle(color: color, fontSize: 12)),
                      style: OutlinedButton.styleFrom(
                          side: BorderSide(color: color.withOpacity(0.4)),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 8)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: onTapFlashcards,
                      icon: const Icon(Icons.style_rounded, size: 16),
                      label: const Text('Flashcards',
                          style: TextStyle(fontSize: 12)),
                      style: FilledButton.styleFrom(
                          backgroundColor: color,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 8)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// EMPTY STATE
// ─────────────────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final Color color;
  final VoidCallback onUpload;
  const _EmptyState({required this.color, required this.onUpload});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.upload_file_rounded,
                size: 72, color: color.withOpacity(0.35)),
            const SizedBox(height: 20),
            const Text('No lectures yet',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              'Upload a PDF, DOCX, TXT or MD file.\nWe\'ll summarise it and generate flashcards for you.',
              textAlign: TextAlign.center,
              style:
                  TextStyle(fontSize: 13, color: Colors.grey[500], height: 1.6),
            ),
            const SizedBox(height: 28),
            FilledButton.icon(
              onPressed: onUpload,
              icon: const Icon(Icons.upload_rounded),
              label: const Text('Upload Lecture'),
              style: FilledButton.styleFrom(
                  backgroundColor: color,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 28, vertical: 14)),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// FLASHCARDS SCREEN
// ─────────────────────────────────────────────────────────────────────────────

class FlashcardsScreenArgs {
  final Lecture lecture;
  final Color color;
  const FlashcardsScreenArgs({required this.lecture, required this.color});
}

class FlashcardsScreen extends StatefulWidget {
  const FlashcardsScreen({super.key});

  static const routeName = '/flashcards';

  @override
  State<FlashcardsScreen> createState() => _FlashcardsScreenState();
}

class _FlashcardsScreenState extends State<FlashcardsScreen> {
  List<Map<String, String>> _cards = [];
  int _current = 0;
  bool _flipped = false;
  bool _loading = false;

  late FlashcardsScreenArgs _args;
  bool _argsInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_argsInitialized) return;
    _argsInitialized = true;
    _args = ModalRoute.of(context)!.settings.arguments as FlashcardsScreenArgs;
    _loadCards();
  }

  Future<void> _loadCards() async {
    // ── Read language from provider ──
    final lang = context.read<SettingsProvider>().language;

    setState(() {
      _loading = true;
      _cards = [];
      _current = 0;
      _flipped = false;
    });
    try {
      final res = await http.post(
        Uri.parse('$_kApiBase/study'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'text': _args.lecture.summary,
          'num_cards': 6,
          'language':
              lang, // ── TRANSLATION: backend translates cards before sending
        }),
      );
      if (res.statusCode == 200) {
        final data =
            (jsonDecode(res.body) as Map<String, dynamic>)['flashcards'];
        if (mounted) {
          setState(() {
            _cards = (data as List)
                .map((e) => {
                      'question': e['question'].toString(),
                      'answer': e['answer'].toString(),
                    })
                .toList();
          });
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Server error ${res.statusCode}')));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _next() => setState(() {
        _current = (_current + 1) % _cards.length;
        _flipped = false;
      });

  void _prev() => setState(() {
        _current = (_current - 1 + _cards.length) % _cards.length;
        _flipped = false;
      });

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final lang = settings.language;
    final isDark = settings.isDark;
    final color = _args.color;
    final textColor = isDark ? Colors.white : Colors.black87;
    final bg = isDark ? const Color(0xFF1A1A2E) : null;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: color,
        foregroundColor: Colors.white,
        centerTitle: true,
        title: Column(
          children: [
            Text(AppStrings.get('cards', lang),
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            Text(_args.lecture.filename,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 11, color: Colors.white70)),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Regenerate',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loading ? null : _loadCards,
          ),
        ],
      ),
      body: _loading
          ? Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
              CircularProgressIndicator(color: color),
              const SizedBox(height: 16),
              Text(AppStrings.get('generating_cards', lang),
                  style: TextStyle(color: textColor)),
            ]))
          : _cards.isEmpty
              ? Center(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.style_outlined,
                      size: 64, color: color.withOpacity(0.3)),
                  const SizedBox(height: 16),
                  Text(AppStrings.get('no_cards', lang),
                      style: TextStyle(color: textColor)),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: _loadCards,
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Try again'),
                    style: FilledButton.styleFrom(backgroundColor: color),
                  ),
                ]))
              : Column(
                  children: [
                    LinearProgressIndicator(
                      value: (_current + 1) / _cards.length,
                      backgroundColor: color.withOpacity(0.1),
                      color: color,
                      minHeight: 4,
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                                '${AppStrings.get('card', lang)} ${_current + 1} '
                                '${AppStrings.get('of', lang)} ${_cards.length}',
                                style: TextStyle(
                                    color: Colors.grey[500], fontSize: 13)),
                            const SizedBox(height: 20),
                            Expanded(
                              child: GestureDetector(
                                onTap: () =>
                                    setState(() => _flipped = !_flipped),
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 350),
                                  transitionBuilder: (child, anim) =>
                                      ScaleTransition(
                                          scale: anim, child: child),
                                  child: Container(
                                    key: ValueKey('${_current}_$_flipped'),
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: _flipped
                                          ? color.withOpacity(0.12)
                                          : (isDark
                                              ? const Color(0xFF1E2A3A)
                                              : Colors.white),
                                      borderRadius: BorderRadius.circular(24),
                                      border: Border.all(
                                          color: color.withOpacity(0.3),
                                          width: 1.5),
                                      boxShadow: [
                                        BoxShadow(
                                            color: color.withOpacity(0.1),
                                            blurRadius: 16,
                                            offset: const Offset(0, 4)),
                                      ],
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(32),
                                      child: Builder(builder: (context) {
                                        final card = _cards[_current];
                                        final label = _flipped
                                            ? AppStrings.get('answer', lang)
                                            : AppStrings.get('question', lang);
                                        final body = _flipped
                                            ? card['answer']!
                                            : card['question']!;
                                        return Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 14,
                                                      vertical: 5),
                                              decoration: BoxDecoration(
                                                color: color.withOpacity(0.15),
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              child: Text(label,
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      color: color,
                                                      fontWeight:
                                                          FontWeight.w700)),
                                            ),
                                            const SizedBox(height: 24),
                                            Text(
                                              body,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  height: 1.5,
                                                  fontWeight: FontWeight.w600,
                                                  color: textColor),
                                            ),
                                          ],
                                        );
                                      }),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(AppStrings.get('tap_to_flip', lang),
                                style: TextStyle(
                                    color: Colors.grey[400], fontSize: 12)),
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _NavButton(
                                    icon: Icons.arrow_back_ios_rounded,
                                    color: color,
                                    onTap: _prev),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: List.generate(
                                    _cards.length,
                                    (i) => AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 200),
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 3),
                                      width: i == _current ? 20 : 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: i == _current
                                            ? color
                                            : color.withOpacity(0.25),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                  ),
                                ),
                                _NavButton(
                                    icon: Icons.arrow_forward_ios_rounded,
                                    color: color,
                                    onTap: _next),
                              ],
                            ),
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _NavButton(
      {required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Icon(icon, color: color, size: 22),
        ),
      ),
    );
  }
}
