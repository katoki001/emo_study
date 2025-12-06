import 'package:flutter/material.dart';

class SubjectCard extends StatelessWidget {
  final String subject;
  final IconData icon;
  final Color color;
  final String description;
  final VoidCallback onTap;
  final double progress;

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
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isSmallScreen = screenWidth < 240;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.all(4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.15),
              blurRadius: 6,
              spreadRadius: 1,
              offset: const Offset(0, 2),
            ),
          ],
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withOpacity(0.05),
              color.withOpacity(0.1),
            ],
          ),
          border: Border.all(
            color: color.withOpacity(0.2),
            width: 0.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with icon and subject
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: isSmallScreen ? 16 : 18,
                  ),
                ),
                if (progress > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: _getProgressColor(progress),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${(progress * 100).toInt()}%',
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 8),

            // Subject title
            Text(
              subject,
              style: TextStyle(
                fontSize: isSmallScreen ? 14 : 15,
                fontWeight: FontWeight.bold,
                color: color,
                height: 1.2,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 4),

            // Description
            Expanded(
              child: Text(
                description,
                style: TextStyle(
                  fontSize: isSmallScreen ? 10 : 11,
                  color: Colors.grey[700],
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // Progress bar (if progress > 0)
            if (progress > 0) ...[
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: color.withOpacity(0.1),
                color: _getProgressColor(progress),
                minHeight: 4,
                borderRadius: BorderRadius.circular(2),
              ),
              const SizedBox(height: 4),
              SizedBox(
                height: 14,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Progress',
                      style: TextStyle(
                        fontSize: 9,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      '${(progress * 100).toInt()}%',
                      style: TextStyle(
                        fontSize: 9,
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Quick actions (only icons)
            const SizedBox(height: 8),
            SizedBox(
              height: 15,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildActionIcon(Icons.auto_awesome, color, 'AI Assessment'),
                  _buildActionIcon(Icons.schedule, color, 'Study Plan'),
                  _buildActionIcon(Icons.quiz, color, 'Quizzes'),
                  if (!isSmallScreen)
                    _buildActionIcon(Icons.menu_book, color, 'Resources'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionIcon(IconData icon, Color color, String tooltip) {
    return Tooltip(
      message: tooltip,
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: color,
          size: 14,
        ),
      ),
    );
  }

  Color _getProgressColor(double progress) {
    if (progress >= 0.8) return Colors.green;
    if (progress >= 0.6) return Colors.blue;
    if (progress >= 0.4) return Colors.orange;
    return Colors.red;
  }
}

// MOST IMPORTANT: How you use the Grid in your EducationScreen
class EducationScreen extends StatelessWidget {
  final List<Map<String, dynamic>> subjects = [
    {
      'subject': 'Physics',
      'icon': Icons.rocket_launch,
      'color': Colors.blue,
      'description': 'Mechanics, Thermodynamics',
      'progress': 0.65,
    },
    {
      'subject': 'Mathematics',
      'icon': Icons.calculate,
      'color': Colors.purple,
      'description': 'Algebra, Calculus, Stats',
      'progress': 0.80,
    },
    {
      'subject': 'Chemistry',
      'icon': Icons.science,
      'color': Colors.green,
      'description': 'Organic, Inorganic',
      'progress': 0.45,
    },
    {
      'subject': 'Biology',
      'icon': Icons.eco,
      'color': Colors.teal,
      'description': 'Cell Biology, Genetics',
      'progress': 0.70,
    },
    {
      'subject': 'Computer Science',
      'icon': Icons.code,
      'color': Colors.orange,
      'description': 'Programming, Algorithms',
      'progress': 0.90,
    },
    {
      'subject': 'History',
      'icon': Icons.history,
      'color': Colors.brown,
      'description': 'World History',
      'progress': 0.30,
    },
  ];

  EducationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return SafeArea(
      // ADD THIS - prevents overflow behind system UI
      child: SingleChildScrollView(
        // ADD THIS - makes entire screen scrollable
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: screenHeight - 400, // Ensure minimum height
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                  child: Text(
                    'Subjects',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                ),

                // Grid View wrapped with Flexible
                Flexible(
                  child: GridView.builder(
                    shrinkWrap:
                        true, // IMPORTANT: makes GridView only take needed space
                    physics:
                        const NeverScrollableScrollPhysics(), // IMPORTANT: prevents nested scrolling
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount:
                          MediaQuery.of(context).size.width > 600 ? 3 : 2,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio:
                          0.85, // Adjust this for card proportions
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
                          print('Selected: ${subject['subject']}');
                        },
                      );
                    },
                  ),
                ),

                // Bottom padding
                SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
