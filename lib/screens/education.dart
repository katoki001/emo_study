import 'package:flutter/material.dart';
import '../widgets/subject_card.dart';

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
    // Add more subjects...
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Your Subject'),
        backgroundColor: Colors.deepPurple,
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
                // Start AI assessment for this subject
                _startAIAssessment(subject['subject']);
              },
            );
          },
        ),
      ),
    );
  }

  void _startAIAssessment(String subject) {
    print('Starting AI assessment for $subject');
    // Call your Python AI backend here
  }
}
