import 'package:flutter/material.dart';

class UserProgress with ChangeNotifier {
  double _overallProgress = 0.0;
  Map<String, double> _subjectProgress = {};
  Map<String, dynamic> _emotionData = {};

  double get overallProgress => _overallProgress;
  Map<String, double> get subjectProgress => _subjectProgress;
  Map<String, dynamic> get emotionData => _emotionData;

  void updateProgress(String subject, double progress) {
    _subjectProgress[subject] = progress;
    _calculateOverallProgress();
    notifyListeners();
  }

  void updateEmotionData(Map<String, dynamic> data) {
    _emotionData = data;
    notifyListeners();
  }

  void _calculateOverallProgress() {
    if (_subjectProgress.isEmpty) {
      _overallProgress = 0.0;
      return;
    }

    double total = _subjectProgress.values.reduce((a, b) => a + b);
    _overallProgress = total / _subjectProgress.length;
  }
}
