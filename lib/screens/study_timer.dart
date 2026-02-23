import 'dart:async';
import 'package:flutter/material.dart';

class StudyTimerScreen extends StatefulWidget {
  const StudyTimerScreen({super.key});

  @override
  State<StudyTimerScreen> createState() => _StudyTimerScreenState();
}

class _StudyTimerScreenState extends State<StudyTimerScreen> {
  // TIMER STATE
  bool _isRunning = false;
  bool _startLocked = false; // <--- REQUIRED FIX
  Duration _timeLeft = const Duration(minutes: 25);
  Timer? _timer;

  // SETTINGS
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 20),
          // TIMER CIRCLE
          Container(
            width: 240,
            height: 250,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _isStudyTime ? Colors.deepPurple : Colors.green,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _isStudyTime ? 'STUDY' : 'BREAK',
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
                  _isRunning ? 'Keep going!' : 'Ready to start',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // BUTTONS
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!_isRunning)
                _buildButton(
                  icon: Icons.play_arrow,
                  label: 'Start',
                  color: Colors.green,
                  onPressed: _startTimer,
                ),
              const SizedBox(width: 24),
              if (_isRunning)
                _buildButton(
                  icon: Icons.pause,
                  label: 'Pause',
                  color: Colors.orange,
                  onPressed: _pauseTimer,
                ),
              const SizedBox(width: 24),
              _buildButton(
                icon: Icons.stop,
                label: 'Stop',
                color: Colors.red,
                onPressed: _stopTimer,
              ),
            ],
          ),

          const SizedBox(height: 24),

          // SESSION COUNTER
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.deepPurple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Sessions: $_sessionsDone',
              style: const TextStyle(
                color: Colors.deepPurple,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(height: 24),

          // TIME SETTINGS
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Study:', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 10),
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: () => _changeTime(true, -5),
                    ),
                    Text(
                      '${_studyTime.inMinutes} min',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () => _changeTime(true, 5),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Break:', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 10),
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: () => _changeTime(false, -5),
                    ),
                    Text(
                      '${_breakTime.inMinutes} min',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
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

  // REUSABLE BUTTON WIDGET
  Widget _buildButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
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
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  // START TIMER — FIXED VERSION
  void _startTimer() {
    if (_startLocked) return;
    _startLocked = true;

    if (_isRunning) {
      _startLocked = false;
      return;
    }

    _timer?.cancel();

    setState(() {
      _isRunning = true;
    });

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

    Future.delayed(const Duration(milliseconds: 80), () {
      _startLocked = false;
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
    });
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
