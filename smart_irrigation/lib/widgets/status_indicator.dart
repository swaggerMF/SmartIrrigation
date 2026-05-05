import 'package:flutter/material.dart';

class StatusIndicator extends StatelessWidget {
  final bool isConnected;

  const StatusIndicator({super.key, required this.isConnected});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: isConnected ? Colors.greenAccent : Colors.redAccent,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          isConnected ? 'MQTT' : 'Offline',
          style: const TextStyle(fontSize: 12, color: Colors.white70),
        ),
      ],
    );
  }
}
