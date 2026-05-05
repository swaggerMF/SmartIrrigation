class SensorData {
  final double soilMoisture;
  final double temperature;
  final double humidity;
  final double waterLevel;
  final DateTime timestamp;

  const SensorData({
    required this.soilMoisture,
    required this.temperature,
    required this.humidity,
    required this.waterLevel,
    required this.timestamp,
  });

  SensorData copyWith({
    double? soilMoisture,
    double? temperature,
    double? humidity,
    double? waterLevel,
    DateTime? timestamp,
  }) {
    return SensorData(
      soilMoisture: soilMoisture ?? this.soilMoisture,
      temperature: temperature ?? this.temperature,
      humidity: humidity ?? this.humidity,
      waterLevel: waterLevel ?? this.waterLevel,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
