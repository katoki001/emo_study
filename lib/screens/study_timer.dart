import 'dart:async';

import 'package:flutter/material.dart';

class StudyTimerScreen extends StatefulWidget {
  const StudyTimerScreen({super.key});

  @override
  State<StudyTimerScreen> createState() => _StudyTimerScreenState();
}

class _StudyTimerScreenState extends State<StudyTimerScreen> {
  TimerState _timerState = TimerState.stopped;
  Duration _studyDuration = const Duration(minutes: 25);
  Duration _breakDuration = const Duration(minutes: 5);
  Duration _remainingTime = const Duration(minutes: 25);
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _remainingTime = _studyDuration;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Timer Display
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _getTimerColor(),
              boxShadow: [
                BoxShadow(
                  color: _getTimerColor().withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  _timerState == TimerState.study ? 'STUDY TIME' : 'BREAK TIME',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _formatDuration(_remainingTime),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Monospace',
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _timerState == TimerState.study
                      ? 'Focus on your task'
                      : 'Time to relax!',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),

          // Timer Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              FloatingActionButton(
                onPressed: _startTimer,
                backgroundColor: Colors.green,
                child: const Icon(Icons.play_arrow, color: Colors.white),
              ),
              FloatingActionButton(
                onPressed: _pauseTimer,
                backgroundColor: Colors.orange,
                child: const Icon(Icons.pause, color: Colors.white),
              ),
              FloatingActionButton(
                onPressed: _stopTimer,
                backgroundColor: Colors.red,
                child: const Icon(Icons.stop, color: Colors.white),
              ),
            ],
          ),

          const SizedBox(height: 40),

          // Timer Settings
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              children: [
                _buildTimeSetting(
                    'Study Duration', _studyDuration, _updateStudyDuration),
                const SizedBox(height: 16),
                _buildTimeSetting(
                    'Break Duration', _breakDuration, _updateBreakDuration),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Ambient Sounds
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ambient Sounds',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildSoundOption('Rain', Icons.cloudy_snowing),
                      _buildSoundOption('Forest', Icons.park),
                      _buildSoundOption('Coffee Shop', Icons.coffee),
                      _buildSoundOption('White Noise', Icons.waves),
                      _buildSoundOption('Piano', Icons.piano),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSetting(
      String label, Duration duration, Function(Duration) onUpdate) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.remove),
              onPressed: () {
                int minutes = duration.inMinutes - 5;
                if (minutes >= 5) {
                  onUpdate(Duration(minutes: minutes));
                }
              },
            ),
            Text(
              '${duration.inMinutes} min',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                int minutes = duration.inMinutes + 5;
                if (minutes <= 60) {
                  onUpdate(Duration(minutes: minutes));
                }
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSoundOption(String label, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.deepPurple[50],
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.deepPurple),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: Colors.deepPurple,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Color _getTimerColor() {
    switch (_timerState) {
      case TimerState.study:
        return Colors.deepPurple;
      case TimerState.breakTime:
        return Colors.green;
      case TimerState.stopped:
        return Colors.grey;
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return '$twoDigitMinutes:$twoDigitSeconds';
  }

  void _startTimer() {
    setState(() {
      _timerState = TimerState.study;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingTime.inSeconds > 0) {
          _remainingTime = _remainingTime - const Duration(seconds: 1);
        } else {
          _switchTimerMode();
        }
      });
    });
  }

  void _pauseTimer() {
    _timer.cancel();
  }

  void _stopTimer() {
    _timer.cancel();
    setState(() {
      _timerState = TimerState.stopped;
      _remainingTime = _studyDuration;
    });
  }

  void _switchTimerMode() {
    _timer.cancel();
    setState(() {
      if (_timerState == TimerState.study) {
        _timerState = TimerState.breakTime;
        _remainingTime = _breakDuration;
        _showBreakNotification();
      } else {
        _timerState = TimerState.study;
        _remainingTime = _studyDuration;
        _showStudyNotification();
      }
    });

    _startTimer();
  }

  void _updateStudyDuration(Duration duration) {
    setState(() {
      _studyDuration = duration;
      if (_timerState == TimerState.stopped) {
        _remainingTime = duration;
      }
    });
  }

  void _updateBreakDuration(Duration duration) {
    setState(() {
      _breakDuration = duration;
    });
  }

  void _showBreakNotification() {
    // Show notification for break time
  }

  void _showStudyNotification() {
    // Show notification for study time
  }
}

enum TimerState { study, breakTime, stopped }
