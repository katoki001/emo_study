import 'package:flutter/material.dart';
import '../widgets/emotion_chart.dart';
import '../widgets/progress_chart.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  final List<double> weeklyProgress = [65, 72, 68, 85, 78, 90, 82];
  final Map<String, double> emotionData = {
    'Focus': 7.2,
    'Motivation': 6.8,
    'Stress Resilience': 8.0,
    'Rest': 5.5,
    'Confidence': 7.8,
  };

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(10), // Reduced from 12
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress Overview
          _buildSectionContainer(
            title: 'Weekly Progress',
            trailing: _buildTrendBadge('+12%', Colors.green),
            child: SizedBox(
              height: 160, // Reduced from 160
              child: ProgressChart(
                weeklyData: weeklyProgress,
                title: 'Learning Progress',
                showAverage: true,
              ),
            ),
          ),

          const SizedBox(height: 12), // Reduced from 16

          // Emotion Analysis Section
          _buildSectionContainer(
            title: 'Emotion Analysis',
            trailing: IconButton(
              icon: const Icon(Icons.refresh, size: 18), // Smaller
              onPressed: _updateEmotionAnalysis,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 160, // Reduced from 180
                  child: EmotionChart(data: emotionData),
                ),
                const SizedBox(height: 10), // Reduced from 12
                _buildAIRecommendation(),
              ],
            ),
          ),

          const SizedBox(height: 20), // Reduced from 30
        ],
      ),
    );
  }

  Widget _buildSectionContainer({
    required String title,
    Widget? trailing,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(12), // Reduced from 14
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12), // Smaller
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.04),
            blurRadius: 4, // Smaller
            spreadRadius: 0.5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14, // Smaller
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              trailing ?? const SizedBox.shrink(),
            ],
          ),
          const SizedBox(height: 10), // Reduced from 12
          child,
        ],
      ),
    );
  }

  Widget _buildTrendBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.trending_up, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAIRecommendation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'AI Recommendation:',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            'Your rest score is low. Consider taking a break and doing quick meditation.',
            style: TextStyle(
              color: Colors.blue[800],
              fontStyle: FontStyle.italic,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  void _updateEmotionAnalysis() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Emotion State'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('How are you feeling right now?'),
            const SizedBox(height: 16),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _buildEmotionButton('😊 Focused'),
                _buildEmotionButton('😴 Tired'),
                _buildEmotionButton('😅 Stressed'),
                _buildEmotionButton('😃 Motivated'),
                _buildEmotionButton('😌 Relaxed'),
                _buildEmotionButton('😟 Anxious'),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Skip'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Emotion analysis updated!'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text('Update Analysis'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmotionButton(String label) {
    return OutlinedButton(
      onPressed: () {},
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        side: BorderSide(color: Colors.grey[300]!),
      ),
      child: Text(label, style: const TextStyle(fontSize: 12)),
    );
  }
}
