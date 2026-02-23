import 'package:flutter/material.dart';

class EmotionChart extends StatelessWidget {
  final Map<String, double> data;

  const EmotionChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          SizedBox(
            height: 44,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: data.entries.map((entry) {
                return _buildBar(entry.key, entry.value);
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: data.entries.map((entry) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 40,
                    child: Text(
                      _getShortLabel(entry.key),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    entry.value.toStringAsFixed(1),
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      color: _getColorForScore(entry.value),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBar(String label, double value) {
    double percentage = value / 12.0;
    Color color = _getColorForScore(value);
    const barHeight = 55.0;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 20,
          height: barHeight * percentage,
          decoration: BoxDecoration(
            color: color.withOpacity(0.3),
            borderRadius: BorderRadius.circular(6),
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

  String _getShortLabel(String label) {
    if (label == 'Stress Resilience') return 'Stress';
    if (label == 'Motivation') return 'Motiv.';
    return label;
  }

  Color _getColorForScore(double score) {
    if (score >= 8) return Colors.green;
    if (score >= 6) return Colors.blue;
    if (score >= 4) return Colors.orange;
    return Colors.red;
  }
}
