import 'package:flutter/material.dart';

class ProgressChart extends StatelessWidget {
  final List<double> weeklyData;
  final String title;
  final Color primaryColor;
  final Color secondaryColor;
  final bool showLabels;
  final bool showAverage;

  const ProgressChart({
    super.key,
    required this.weeklyData,
    this.title = 'Weekly Progress',
    this.primaryColor = Colors.deepPurple,
    this.secondaryColor = Colors.purple,
    this.showLabels = true,
    this.showAverage = true,
    // Removed the duplicate 'data' parameter
  });

  @override
  Widget build(BuildContext context) {
    final maxValue = weeklyData.reduce((a, b) => a > b ? a : b);
    final minValue = weeklyData.reduce((a, b) => a < b ? a : b);
    final average = weeklyData.reduce((a, b) => a + b) / weeklyData.length;

    return Container(
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
          // Title and Stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              if (showAverage)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getColorForValue(average).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.trending_up,
                        size: 16,
                        color: _getColorForValue(average),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Avg: ${average.toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: _getColorForValue(average),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),

          const SizedBox(height: 20),

          // Chart Area
          SizedBox(
            height: 180,
            child: Stack(
              children: [
                // Grid Lines
                _buildGridLines(),

                // Data Line
                _buildDataLine(),

                // Data Points
                _buildDataPoints(),

                // Average Line
                if (showAverage) _buildAverageLine(average),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // X-Axis Labels
          if (showLabels)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
                    .map((day) => Text(
                          day,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ))
                    .toList(),
              ),
            ),

          const SizedBox(height: 20),

          // Legend
          _buildLegend(maxValue, minValue, average),
        ],
      ),
    );
  }

  Widget _buildGridLines() {
    return Column(
      children: [
        for (int i = 0; i <= 4; i++)
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Colors.grey.withOpacity(0.2),
                    width: 1,
                  ),
                ),
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Text(
                    '${(100 - i * 25)}%',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[400],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDataLine() {
    final List<Offset> points = [];
    final double stepX = 1.0 / (weeklyData.length - 1);

    for (int i = 0; i < weeklyData.length; i++) {
      final x = i * stepX;
      final y = weeklyData[i] / 100.0;
      points.add(Offset(x, 1 - y)); // Invert Y because origin is top-left
    }

    return CustomPaint(
      size: const Size(double.infinity, double.infinity),
      painter: _LineChartPainter(
        points: points,
        primaryColor: primaryColor,
        secondaryColor: secondaryColor,
      ),
    );
  }

  Widget _buildDataPoints() {
    final double stepX = 1.0 / (weeklyData.length - 1);

    return Row(
      children: weeklyData.asMap().entries.map((entry) {
        final index = entry.key;
        final value = entry.value;
        // ignore: unused_local_variable
        final x = index * stepX;
        final y = value / 100.0;

        return Expanded(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: EdgeInsets.only(bottom: (1 - y) * 180 - 10),
              child: Column(
                children: [
                  // Tooltip on hover
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: Tooltip(
                      message: '${value.toStringAsFixed(0)}%',
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getColorForValue(value).withOpacity(0.9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${value.toStringAsFixed(0)}%',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _getColorForValue(value),
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _getColorForValue(value).withOpacity(0.5),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAverageLine(double average) {
    final y = average / 100.0;

    return Positioned(
      left: 0,
      right: 0,
      bottom: (1 - y) * 180,
      child: Container(
        height: 1,
        decoration: BoxDecoration(
          color: Colors.orange,
          gradient: LinearGradient(
            colors: [
              Colors.orange.withOpacity(0),
              Colors.orange,
              Colors.orange.withOpacity(0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegend(double maxValue, double minValue, double average) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildLegendItem(
          'Highest',
          '${maxValue.toStringAsFixed(1)}%',
          Colors.green,
          Icons.arrow_upward,
        ),
        _buildLegendItem(
          'Average',
          '${average.toStringAsFixed(1)}%',
          Colors.orange,
          Icons.show_chart,
        ),
        _buildLegendItem(
          'Lowest',
          '${minValue.toStringAsFixed(1)}%',
          Colors.red,
          Icons.arrow_downward,
        ),
      ],
    );
  }

  Widget _buildLegendItem(
      String label, String value, Color color, IconData icon) {
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
            size: 18,
            color: color,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Color _getColorForValue(double value) {
    if (value >= 80) return Colors.green;
    if (value >= 60) return Colors.blue.shade600;
    if (value >= 40) return Colors.orange;
    return Colors.red;
  }
}

class _LineChartPainter extends CustomPainter {
  final List<Offset> points;
  final Color primaryColor;
  final Color secondaryColor;

  _LineChartPainter({
    required this.points,
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    final path = Path();
    path.moveTo(points.first.dx * size.width, points.first.dy * size.height);

    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx * size.width, points[i].dy * size.height);
    }

    // Fill under the line
    final fillPath = Path.from(path)
      ..lineTo(points.last.dx * size.width, size.height)
      ..lineTo(points.first.dx * size.width, size.height)
      ..close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          primaryColor.withOpacity(0.1),
          primaryColor.withOpacity(0.05),
        ],
      ).createShader(Rect.fromLTRB(0, 0, size.width, size.height));

    canvas.drawPath(fillPath, fillPaint);

    // Draw the line
    final linePaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Example usage in Progress Screen:
class ProgressScreenExample extends StatelessWidget {
  final List<double> sampleData = [65, 72, 68, 85, 78, 90, 82];

  ProgressScreenExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress Chart Example'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ProgressChart(
          weeklyData: sampleData,
          title: 'Learning Progress This Week',
          primaryColor: Colors.deepPurple,
          secondaryColor: Colors.purple,
          showLabels: true,
          showAverage: true,
        ),
      ),
    );
  }
}
