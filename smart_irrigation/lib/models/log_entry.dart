enum LogType {
  mqttConnected,
  mqttDisconnected,
  sensorUpdated,
  pumpOn,
  pumpOff,
  modeChanged,
  aiDecisionGenerated,
  aiDecisionApplied,
  error,
}

class LogEntry {
  final String id;
  final LogType type;
  final String message;
  final DateTime timestamp;

  LogEntry({
    required this.type,
    required this.message,
    DateTime? timestamp,
  })  : id = DateTime.now().microsecondsSinceEpoch.toString(),
        timestamp = timestamp ?? DateTime.now();

  String get typeLabel {
    switch (type) {
      case LogType.mqttConnected:
        return 'MQTT Connected';
      case LogType.mqttDisconnected:
        return 'MQTT Disconnected';
      case LogType.sensorUpdated:
        return 'Sensor Update';
      case LogType.pumpOn:
        return 'Pump ON';
      case LogType.pumpOff:
        return 'Pump OFF';
      case LogType.modeChanged:
        return 'Mode Changed';
      case LogType.aiDecisionGenerated:
        return 'AI Decision';
      case LogType.aiDecisionApplied:
        return 'AI Applied';
      case LogType.error:
        return 'Error';
    }
  }
}
