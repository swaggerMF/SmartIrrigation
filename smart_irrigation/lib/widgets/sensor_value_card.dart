import 'package:flutter/material.dart';

class SensorValueCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final double value;
  final String unit;
  final String interpretation;
  final Color color;
  final double minValue;
  final double maxValue;

  const SensorValueCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.unit,
    required this.interpretation,
    required this.color,
    required this.minValue,
    required this.maxValue,
  });

  @override
  Widget build(BuildContext context) {
    final progress =
        ((value - minValue) / (maxValue - minValue)).clamp(0.0, 1.0);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                ),
                Text(
                  '${value.toStringAsFixed(1)}$unit',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: color),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              interpretation,
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
