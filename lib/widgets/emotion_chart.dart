import 'package:flutter/material.dart';

class EmotionChart extends StatelessWidget {
  final Map<String, double> data;

  const EmotionChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Chart
          SizedBox(
            height: 150,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: data.entries.map((entry) {
                return _buildBar(entry.key, entry.value);
              }).toList(),
            ),
          ),

          // Labels
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: data.keys.map((key) {
              return SizedBox(
                width: 60,
                child: Text(
                  key,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),

          // Score Labels
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: data.entries.map((entry) {
              return Text(
                entry.value.toStringAsFixed(1),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: _getColorForScore(entry.value),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBar(String label, double value) {
    double percentage = value / 10.0;
    Color color = _getColorForScore(value);

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 40,
          height: 120 * percentage,
          decoration: BoxDecoration(
            color: color.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8),
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                color.withOpacity(0.8),
                color.withOpacity(0.3),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Color _getColorForScore(double score) {
    if (score >= 8) return Colors.green;
    if (score >= 6) return Colors.blue;
    if (score >= 4) return Colors.orange;
    return Colors.red;
  }
}
