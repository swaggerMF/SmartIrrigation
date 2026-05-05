import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/log_entry.dart';
import '../providers/irrigation_provider.dart';

class LogsScreen extends StatelessWidget {
  const LogsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Logs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Clear logs',
            onPressed: () => context.read<IrrigationProvider>().clearLogs(),
          ),
        ],
      ),
      body: Consumer<IrrigationProvider>(
        builder: (_, provider, __) {
          final logs = provider.logs;
          if (logs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 64, color: Colors.grey),
                  SizedBox(height: 12),
                  Text('No events yet',
                      style: TextStyle(color: Colors.grey, fontSize: 16)),
                  SizedBox(height: 4),
                  Text('Connect to MQTT to start receiving events',
                      style: TextStyle(color: Colors.grey, fontSize: 13)),
                ],
              ),
            );
          }

          return ListView.separated(
            itemCount: logs.length,
            separatorBuilder: (_, __) =>
                const Divider(height: 1, indent: 64),
            itemBuilder: (_, i) {
              final entry = logs[i];
              final color = _color(entry.type);
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: color.withOpacity(0.15),
                  child: Icon(_icon(entry.type), color: color, size: 20),
                ),
                title: Text(entry.message),
                subtitle: Text(entry.typeLabel,
                    style: TextStyle(color: color, fontSize: 12)),
                trailing: Text(
                  _fmt(entry.timestamp),
                  style:
                      const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Color _color(LogType type) {
    switch (type) {
      case LogType.mqttConnected:
        return Colors.green;
      case LogType.mqttDisconnected:
        return Colors.orange;
      case LogType.pumpOn:
        return Colors.blue;
      case LogType.pumpOff:
        return Colors.blueGrey;
      case LogType.error:
        return Colors.red;
      case LogType.aiDecisionGenerated:
      case LogType.aiDecisionApplied:
        return Colors.purple;
      case LogType.modeChanged:
        return Colors.teal;
      case LogType.sensorUpdated:
        return Colors.grey;
    }
  }

  IconData _icon(LogType type) {
    switch (type) {
      case LogType.mqttConnected:
        return Icons.wifi;
      case LogType.mqttDisconnected:
        return Icons.wifi_off;
      case LogType.pumpOn:
        return Icons.play_arrow;
      case LogType.pumpOff:
        return Icons.stop;
      case LogType.error:
        return Icons.error_outline;
      case LogType.aiDecisionGenerated:
        return Icons.psychology;
      case LogType.aiDecisionApplied:
        return Icons.check_circle;
      case LogType.modeChanged:
        return Icons.settings;
      case LogType.sensorUpdated:
        return Icons.sensors;
    }
  }

  String _fmt(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:'
      '${dt.minute.toString().padLeft(2, '0')}:'
      '${dt.second.toString().padLeft(2, '0')}';
}
