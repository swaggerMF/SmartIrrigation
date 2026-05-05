enum ControlMode { manual, ruleBased, ai }

extension ControlModeExtension on ControlMode {
  String get displayName {
    switch (this) {
      case ControlMode.manual:
        return 'Manual';
      case ControlMode.ruleBased:
        return 'Rule-Based';
      case ControlMode.ai:
        return 'AI/LLM';
    }
  }

  String get mqttValue {
    switch (this) {
      case ControlMode.manual:
        return 'MANUAL';
      case ControlMode.ruleBased:
        return 'RULE_BASED';
      case ControlMode.ai:
        return 'AI';
    }
  }

  static ControlMode fromMqtt(String value) {
    switch (value.toUpperCase()) {
      case 'RULE_BASED':
        return ControlMode.ruleBased;
      case 'AI':
        return ControlMode.ai;
      default:
        return ControlMode.manual;
    }
  }
}
