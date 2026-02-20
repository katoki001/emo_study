// lib/screens/education_screen.dart
import 'package:flutter/material.dart';
import '../widgets/subject_card.dart';
import '../screens/assessment_screen.dart';
import '../services/ai_service.dart'; // Import your AI Service
import 'dart:convert';

class EducationScreen extends StatelessWidget {
  EducationScreen({super.key});

  final List<Map<String, dynamic>> subjects = [
    {
      'subject': 'Physics',
      'icon': Icons.rocket_launch,
      'color': Colors.blue,
      'description': 'AI will assess your physics knowledge',
      'progress': 0.0
    },
    {
      'subject': 'Mathematics',
      'icon': Icons.calculate,
      'color': Colors.green,
      'description': 'AI will assess your math skills',
      'progress': 0.0
    },
    {
      'subject': 'Chemistry',
      'icon': Icons.science,
      'color': Colors.orange,
      'description': 'AI will assess your chemistry knowledge',
      'progress': 0.0
    },
    {
      'subject': 'Biology',
      'icon': Icons.eco,
      'color': Colors.purple,
      'description': 'AI will assess your biology understanding',
      'progress': 0.0
    },
    {
      'subject': 'Computer Science',
      'icon': Icons.computer,
      'color': Colors.red,
      'description': 'AI will assess your coding skills',
      'progress': 0.0
    },
    {
      'subject': 'History',
      'icon': Icons.history,
      'color': Colors.brown,
      'description': 'AI will assess your historical knowledge',
      'progress': 0.0
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Your Subject'),
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
          itemCount: subjects.length,
          itemBuilder: (context, index) {
            final subjectData = subjects[index];
            return SubjectCard(
              subject: subjectData['subject'],
              icon: subjectData['icon'],
              color: subjectData['color'],
              description: subjectData['description'],
              progress: subjectData['progress'],
              onTap: () => _startAIAssessment(context, subjectData['subject']),
            );
          },
        ),
      ),
    );
  }

  Future<void> _startAIAssessment(BuildContext context, String subject) async {
    // 1. Show Loading Dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // 2. Request initial question from AI
      final prompt =
          '''Generate a starter multiple choice question for the subject: $subject. 
      Return ONLY JSON format: {"question": "...", "options": ["A", "B", "C", "D"], "correctAnswer": "..."}''';

      final aiResponse = await AIService.getAIResponse(prompt);

      // Clean and Parse JSON
      final cleanJson = aiResponse.substring(
          aiResponse.indexOf('{'), aiResponse.lastIndexOf('}') + 1);
      final firstQuestion = jsonDecode(cleanJson);

      // 3. Close Loading
      if (context.mounted) Navigator.of(context).pop();

      // 4. Navigate to Assessment Screen
      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AssessmentScreen(
              subject: subject,
              assessmentData: {
                "questions": [firstQuestion]
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) Navigator.of(context).pop();
      _showErrorDialog(context, e.toString());
    }
  }

  void _showErrorDialog(BuildContext context, String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Connection Error'),
        content: const Text(
            'Could not reach the AI. Is your Colab Gradio link still active?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Retry'))
        ],
      ),
    );
  }
}
