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
  });

  @override
  Widget build(BuildContext context) {
    final maxValue = weeklyData.reduce((a, b) => a > b ? a : b);
    final minValue = weeklyData.reduce((a, b) => a < b ? a : b);
    final average = weeklyData.reduce((a, b) => a + b) / weeklyData.length;
    const chartHeight = 42.0; // Reduced to match container

    return Container(
      padding: const EdgeInsets.all(8), // Reduced padding
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 4,
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
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              if (showAverage)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: _getColorForValue(average).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.trending_up,
                        size: 8,
                        color: _getColorForValue(average),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${average.toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _getColorForValue(average),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),

          const SizedBox(height: 8), // Reduced spacing

          // Chart Area - Use the exact height needed
          SizedBox(
            height: chartHeight, // Use the variable
            child: Stack(
              children: [
                // Grid Lines
                _buildGridLines(chartHeight),

                // Data Line
                _buildDataLine(),

                // Data Points
                _buildDataPoints(chartHeight),

                // Average Line
                if (showAverage) _buildAverageLine(average, chartHeight),
              ],
            ),
          ),

          const SizedBox(height: 6), // Reduced

          // X-Axis Labels
          if (showLabels)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2), // Reduced
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: ['M', 'T', 'W', 'T', 'F', 'S', 'S']
                    .map((day) => Text(
                          day,
                          style: TextStyle(
                            fontSize: 9, // Smaller
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ))
                    .toList(),
              ),
            ),

          const SizedBox(height: 6), // Reduced

          // Legend - Made even more compact
          _buildLegend(maxValue, minValue, average),
        ],
      ),
    );
  }

  Widget _buildGridLines(double chartHeight) {
    return Column(
      children: [
        for (int i = 0; i <= 1; i++) // Only 2 grid lines (0%, 100%)
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Colors.grey.withOpacity(0.1), // Very light
                    width: 0.5,
                  ),
                ),
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 2), // Minimal
                  child: Text(
                    '${(100 - i * 100)}%',
                    style: TextStyle(
                      fontSize: 7, // Very small
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
      points.add(Offset(x, 1 - y));
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

  Widget _buildDataPoints(double chartHeight) {
    final double stepX = 1.0 / (weeklyData.length - 1);

    return Row(
      children: weeklyData.asMap().entries.map((entry) {
        final index = entry.key;
        final value = entry.value;
        final x = index * stepX;
        final y = value / 100.0;

        return Expanded(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: EdgeInsets.only(
                  bottom: (1 - y) * chartHeight - 4), // -4 instead of -6
              child: GestureDetector(
                onTap: () {},
                child: Container(
                  width: 8, // Smaller
                  height: 8, // Smaller
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _getColorForValue(value),
                      width: 1.5, // Thinner
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAverageLine(double average, double chartHeight) {
    final y = average / 100.0;

    return Positioned(
      left: 0,
      right: 0,
      bottom: (1 - y) * chartHeight,
      child: Container(
        height: 0.5,
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.5), // Lighter
        ),
      ),
    );
  }

  Widget _buildLegend(double maxValue, double minValue, double average) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildLegendItem(
          'High',
          '${maxValue.toStringAsFixed(0)}%',
          Colors.green,
        ),
        _buildLegendItem(
          'Avg',
          '${average.toStringAsFixed(0)}%',
          Colors.orange,
        ),
        _buildLegendItem(
          'Low',
          '${minValue.toStringAsFixed(0)}%',
          Colors.red,
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, String value, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(4), // Smaller
          decoration: BoxDecoration(
            color: color.withOpacity(0.05), // Very light
            shape: BoxShape.circle,
          ),
          child: Icon(
            _getIconForLabel(label),
            size: 12, // Smaller
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 8, // Smaller
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 1),
        Text(
          value,
          style: TextStyle(
            fontSize: 9, // Smaller
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  IconData _getIconForLabel(String label) {
    switch (label) {
      case 'High':
        return Icons.arrow_upward;
      case 'Avg':
        return Icons.show_chart;
      case 'Low':
        return Icons.arrow_downward;
      default:
        return Icons.circle;
    }
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

    final fillPath = Path.from(path)
      ..lineTo(points.last.dx * size.width, size.height)
      ..lineTo(points.first.dx * size.width, size.height)
      ..close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          primaryColor.withOpacity(0.05), // Very light fill
          primaryColor.withOpacity(0.01),
        ],
      ).createShader(Rect.fromLTRB(0, 0, size.width, size.height));

    canvas.drawPath(fillPath, fillPaint);

    final linePaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5 // Thinner line
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
