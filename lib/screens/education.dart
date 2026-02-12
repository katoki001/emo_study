import 'package:flutter/material.dart';
import '../widgets/subject_card.dart';
import '../screens/assessment_screen.dart';
import '../widgets/loading_dialog.dart';

class EducationScreen extends StatelessWidget {
  EducationScreen({super.key});

  final List<Map<String, dynamic>> subjects = [
    {
      'subject': 'Physics',
      'icon': Icons.rocket_launch,
      'color': Colors.blue,
      'description': 'AI will assess your physics knowledge',
      'progress': 0.0,
    },
    {
      'subject': 'Mathematics',
      'icon': Icons.calculate,
      'color': Colors.green,
      'description': 'AI will assess your math skills',
      'progress': 0.0,
    },
    {
      'subject': 'Chemistry',
      'icon': Icons.science,
      'color': Colors.orange,
      'description': 'AI will assess your chemistry knowledge',
      'progress': 0.0,
    },
    {
      'subject': 'Biology',
      'icon': Icons.eco,
      'color': Colors.purple,
      'description': 'AI will assess your biology understanding',
      'progress': 0.0,
    },
    {
      'subject': 'Computer Science',
      'icon': Icons.computer,
      'color': Colors.red,
      'description': 'AI will assess your coding skills',
      'progress': 0.0,
    },
    {
      'subject': 'History',
      'icon': Icons.history,
      'color': Colors.brown,
      'description': 'AI will assess your historical knowledge',
      'progress': 0.0,
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
            final subject = subjects[index];
            return SubjectCard(
              subject: subject['subject'],
              icon: subject['icon'],
              color: subject['color'],
              description: subject['description'],
              progress: subject['progress'],
              onTap: () {
                //_startAIAssessment(context, subject['subject']);
              },
            );
          },
        ),
      ),
    );
  }

  /* Future<void> _startAIAssessment(BuildContext context, String subject) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const LoadingDialog(
        message: 'Preparing AI Assessment...',
      ),
    );

    try {
      // Call AI backend API
      final assessmentData = await AssessmentAPI.startAssessment(
        subject: subject,
        difficulty: 'adaptive', // or get from user preferences
      );

      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // Navigate to assessment screen
      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AssessmentScreen(
              subject: subject,
              assessmentData: assessmentData,
            ),
          ),
        );
      }
    } catch (e) {
      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // Show error message
      if (context.mounted) {
        _showErrorDialog(context, e.toString());
      }
    }
  }

  void _showErrorDialog(BuildContext context, String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Assessment Error'),
        content: Text(
          'Failed to start assessment: $error\n\nPlease try again later.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }*/
}
