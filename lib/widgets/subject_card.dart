import 'package:flutter/material.dart';

class SubjectCard extends StatelessWidget {
  final String subject;
  final IconData icon;
  final Color color;
  final String description;
  final VoidCallback onTap;
  final double progress; // 0.0 to 1.0

  const SubjectCard({
    super.key,
    required this.subject,
    required this.icon,
    required this.color,
    required this.description,
    required this.onTap,
    this.progress = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 10,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
          ],
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withOpacity(0.05),
              color.withOpacity(0.15),
            ],
          ),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with icon and subject
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    subject,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
                if (progress > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getProgressColor(progress),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${(progress * 100).toInt()}%',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 12),

            // Description
            Text(
              description,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 16),

            // Progress bar (if progress > 0)
            if (progress > 0)
              Column(
                children: [
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: color.withOpacity(0.1),
                    color: _getProgressColor(progress),
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Progress',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        '${(progress * 100).toInt()}% complete',
                        style: TextStyle(
                          fontSize: 12,
                          color: color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

            const SizedBox(height: 12),

            // AI Assessment Button
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.auto_awesome,
                    color: color,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'AI Knowledge Assessment',
                    style: TextStyle(
                      fontSize: 14,
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            // Quick actions
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildActionButton('Study Plan', Icons.schedule, color),
                _buildActionButton('Quizzes', Icons.quiz, color),
                _buildActionButton('Resources', Icons.menu_book, color),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 18,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: color,
          ),
        ),
      ],
    );
  }

  Color _getProgressColor(double progress) {
    if (progress >= 0.8) return Colors.green;
    if (progress >= 0.6) return Colors.blue;
    if (progress >= 0.4) return Colors.orange;
    return Colors.red;
  }
}

// Example usage in your Education Screen:
class SubjectGrid extends StatelessWidget {
  final List<Map<String, dynamic>> subjects = [
    {
      'subject': 'Physics',
      'icon': Icons.rocket_launch,
      'color': Colors.blue,
      'description': 'Mechanics, Thermodynamics, Electromagnetism',
      'progress': 0.65,
    },
    {
      'subject': 'Mathematics',
      'icon': Icons.calculate,
      'color': Colors.purple,
      'description': 'Algebra, Calculus, Statistics',
      'progress': 0.80,
    },
    {
      'subject': 'Chemistry',
      'icon': Icons.science,
      'color': Colors.green,
      'description': 'Organic, Inorganic, Physical Chemistry',
      'progress': 0.45,
    },
    {
      'subject': 'Biology',
      'icon': Icons.eco,
      'color': Colors.teal,
      'description': 'Cell Biology, Genetics, Human Anatomy',
      'progress': 0.70,
    },
    {
      'subject': 'Computer Science',
      'icon': Icons.code,
      'color': Colors.orange,
      'description': 'Programming, Algorithms, Data Structures',
      'progress': 0.90,
    },
    {
      'subject': 'History',
      'icon': Icons.history,
      'color': Colors.brown,
      'description': 'World History, Ancient Civilizations',
      'progress': 0.30,
    },
  ];

  SubjectGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
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
            // Handle subject tap
            print('Selected: ${subject['subject']}');
            // You can navigate to subject details screen
            // or start AI assessment
          },
        );
      },
    );
  }
}
