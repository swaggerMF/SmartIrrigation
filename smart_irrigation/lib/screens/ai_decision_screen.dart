import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/irrigation_provider.dart';

class AiDecisionScreen extends StatelessWidget {
  const AiDecisionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI / LLM Decision')),
      body: Consumer<IrrigationProvider>(
        builder: (context, provider, _) {
          final data = provider.sensorData;
          final result = provider.aiDecisionResult;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Current sensor snapshot sent to the backend
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Current Sensor Values',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const Divider(height: 20),
                      _SensorRow(
                          icon: Icons.grass,
                          label: 'Soil Moisture',
                          value:
                              '${data.soilMoisture.toStringAsFixed(1)}%'),
                      _SensorRow(
                          icon: Icons.thermostat,
                          label: 'Temperature',
                          value:
                              '${data.temperature.toStringAsFixed(1)}°C'),
                      _SensorRow(
                          icon: Icons.water_drop,
                          label: 'Air Humidity',
                          value: '${data.humidity.toStringAsFixed(1)}%'),
                      _SensorRow(
                          icon: Icons.water,
                          label: 'Water Level',
                          value:
                              '${data.waterLevel.toStringAsFixed(1)}%'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Generate decision button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1565C0),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  icon: provider.isLoadingAi
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : const Icon(Icons.psychology),
                  label: Text(provider.isLoadingAi
                      ? 'Analyzing...'
                      : 'Generate AI Decision'),
                  onPressed: provider.isLoadingAi
                      ? null
                      : () => provider.generateAiDecision(),
                ),
              ),
              const SizedBox(height: 16),

              // AI result card
              if (result != null) ...[
                Card(
                  color: result.pumpShouldBeOn
                      ? Colors.green.shade50
                      : Colors.red.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              result.pumpShouldBeOn
                                  ? Icons.check_circle
                                  : Icons.cancel,
                              size: 32,
                              color: result.pumpShouldBeOn
                                  ? Colors.green
                                  : Colors.red,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Decision: Pump ${result.decision}',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: result.pumpShouldBeOn
                                    ? Colors.green.shade700
                                    : Colors.red.shade700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        const Text('Recommendation:',
                            style:
                                TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text(result.recommendation),
                        const SizedBox(height: 12),
                        const Text('Explanation:',
                            style:
                                TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text(result.explanation,
                            style:
                                const TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Apply decision button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          result.pumpShouldBeOn ? Colors.green : Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    icon: const Icon(Icons.play_arrow),
                    label: Text('Apply Decision (Pump ${result.decision})'),
                    onPressed: !provider.mqttConnected
                        ? null
                        : () {
                            provider.applyAiDecision();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content:
                                    Text('Applied: Pump ${result.decision}'),
                                backgroundColor: result.pumpShouldBeOn
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            );
                          },
                  ),
                ),
                if (!provider.mqttConnected)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      'Connect to MQTT to apply the decision',
                      style: TextStyle(
                          color: Colors.orange.shade700, fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _SensorRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _SensorRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(child: Text(label)),
          Text(value,
              style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
