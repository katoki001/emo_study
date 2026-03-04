import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../l10n/app_strings.dart';

class StudyTimerScreen extends StatefulWidget {
  const StudyTimerScreen({super.key});

  @override
  State<StudyTimerScreen> createState() => _StudyTimerScreenState();
}

class _StudyTimerScreenState extends State<StudyTimerScreen> {
  bool _isRunning = false;
  bool _startLocked = false;
  Duration _timeLeft = const Duration(minutes: 25);
  Timer? _timer;

  Duration _studyTime = const Duration(minutes: 25);
  Duration _breakTime = const Duration(minutes: 5);
  bool _isStudyTime = true;
  int _sessionsDone = 0;

  @override
  void initState() {
    super.initState();
    _timeLeft = _studyTime;
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final lang = settings.language;
    final isDark = settings.isDark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 20),

          // Timer circle
          Container(
            width: 240,
            height: 250,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _isStudyTime ? Colors.deepPurple : Colors.green,
              boxShadow: [
                BoxShadow(
                  color: (_isStudyTime ? Colors.deepPurple : Colors.green)
                      .withOpacity(0.3),
                  blurRadius: 24,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _isStudyTime
                      ? AppStrings.get('study', lang)
                      : AppStrings.get('break', lang),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _formatTime(_timeLeft),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 56,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _isRunning
                      ? AppStrings.get('keep_going', lang)
                      : AppStrings.get('ready_to_start', lang),
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!_isRunning)
                _buildButton(
                  icon: Icons.play_arrow,
                  label: AppStrings.get('start', lang),
                  color: Colors.green,
                  onPressed: _startTimer,
                  isDark: isDark,
                ),
              const SizedBox(width: 24),
              if (_isRunning)
                _buildButton(
                  icon: Icons.pause,
                  label: AppStrings.get('pause', lang),
                  color: Colors.orange,
                  onPressed: _pauseTimer,
                  isDark: isDark,
                ),
              const SizedBox(width: 24),
              _buildButton(
                icon: Icons.stop,
                label: AppStrings.get('stop', lang),
                color: Colors.red,
                onPressed: _stopTimer,
                isDark: isDark,
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Session counter
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.deepPurple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${AppStrings.get('sessions', lang)}: $_sessionsDone',
              style: const TextStyle(
                color: Colors.deepPurple,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Time settings
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E2A3A) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppStrings.get('study_label', lang),
                      style: TextStyle(
                        fontSize: 16,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                      icon: Icon(Icons.remove,
                          color: isDark ? Colors.white70 : Colors.black87),
                      onPressed: () => _changeTime(true, -5),
                    ),
                    Text(
                      '${_studyTime.inMinutes} min',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.add,
                          color: isDark ? Colors.white70 : Colors.black87),
                      onPressed: () => _changeTime(true, 5),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppStrings.get('break_label', lang),
                      style: TextStyle(
                        fontSize: 16,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                      icon: Icon(Icons.remove,
                          color: isDark ? Colors.white70 : Colors.black87),
                      onPressed: () => _changeTime(false, -5),
                    ),
                    Text(
                      '${_breakTime.inMinutes} min',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.add,
                          color: isDark ? Colors.white70 : Colors.black87),
                      onPressed: () => _changeTime(false, 5),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
    required bool isDark,
  }) {
    return Column(
      children: [
        FloatingActionButton(
          onPressed: onPressed,
          backgroundColor: color,
          child: Icon(icon, color: Colors.white),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white54 : Colors.grey,
          ),
        ),
      ],
    );
  }

  void _startTimer() {
    if (_startLocked) return;
    _startLocked = true;
    if (_isRunning) {
      _startLocked = false;
      return;
    }
    _timer?.cancel();
    setState(() => _isRunning = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (_timeLeft.inSeconds > 0) {
          _timeLeft -= const Duration(seconds: 1);
        } else {
          timer.cancel();
          _isRunning = false;
          _sessionComplete();
        }
      });
    });
    Future.delayed(
        const Duration(milliseconds: 80), () => _startLocked = false);
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() => _isRunning = false);
  }

  void _stopTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _timeLeft = _studyTime;
      _isStudyTime = true;
    });
  }

  void _sessionComplete() {
    setState(() {
      if (_isStudyTime) {
        _sessionsDone++;
        _isStudyTime = false;
        _timeLeft = _breakTime;
      } else {
        _isStudyTime = true;
        _timeLeft = _studyTime;
      }
    });
  }

  void _changeTime(bool isStudy, int minutes) {
    if (_isRunning) return;
    setState(() {
      if (isStudy) {
        int newMin = _studyTime.inMinutes + minutes;
        if (newMin >= 1 && newMin <= 60) {
          _studyTime = Duration(minutes: newMin);
          if (_isStudyTime) _timeLeft = _studyTime;
        }
      } else {
        int newMin = _breakTime.inMinutes + minutes;
        if (newMin >= 1 && newMin <= 30) {
          _breakTime = Duration(minutes: newMin);
          if (!_isStudyTime) _timeLeft = _breakTime;
        }
      }
    });
  }

  String _formatTime(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.inMinutes % 60)}:${two(d.inSeconds % 60)}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
