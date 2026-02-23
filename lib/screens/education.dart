import 'package:flutter/material.dart';
import '../widgets/subject_card.dart';

class EducationScreen extends StatelessWidget {
  EducationScreen({super.key});

  final List<Map<String, dynamic>> subjects = [
    {
      'subject': 'Physics',
      'icon': Icons.rocket_launch,
      'color': Colors.blue,
      'description': 'Explore physics concepts and principles',
      'progress': 0.0
    },
    {
      'subject': 'Mathematics',
      'icon': Icons.calculate,
      'color': Colors.green,
      'description': 'Dive into mathematical problems',
      'progress': 0.0
    },
    {
      'subject': 'Chemistry',
      'icon': Icons.science,
      'color': Colors.orange,
      'description': 'Learn about chemical reactions',
      'progress': 0.0
    },
    {
      'subject': 'Biology',
      'icon': Icons.eco,
      'color': Colors.purple,
      'description': 'Discover life sciences',
      'progress': 0.0
    },
    {
      'subject': 'Computer Science',
      'icon': Icons.computer,
      'color': Colors.red,
      'description': 'Master programming concepts',
      'progress': 0.0
    },
    {
      'subject': 'History',
      'icon': Icons.history,
      'color': Colors.brown,
      'description': 'Explore historical events',
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
              onTap: () {
                // TODO: Navigate to subject-specific content
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content:
                        Text('${subjectData['subject']} section coming soon!'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
