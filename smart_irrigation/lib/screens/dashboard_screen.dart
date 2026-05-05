import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/irrigation_provider.dart';
import '../widgets/dashboard_card.dart';
import '../widgets/status_indicator.dart';
import 'ai_decision_screen.dart';
import 'automation_settings_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Irrigation'),
        actions: [
          Consumer<IrrigationProvider>(
            builder: (_, p, __) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: StatusIndicator(isConnected: p.mqttConnected),
            ),
          ),
        ],
      ),
      body: Consumer<IrrigationProvider>(
        builder: (context, provider, _) {
          final data = provider.sensorData;
          return RefreshIndicator(
            onRefresh: () async {
              if (!provider.mqttConnected) await provider.connectMqtt();
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (!provider.mqttConnected)
                  _ConnectionBanner(
                    isConnecting: provider.isConnecting,
                    onConnect: provider.connectMqtt,
                  ),
                const SizedBox(height: 8),
                _PumpStatusCard(
                  pumpOn: provider.pumpOn,
                  mode: provider.controlMode.displayName,
                ),
                const SizedBox(height: 12),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.2,
                  children: [
                    DashboardCard(
                      icon: Icons.grass,
                      title: 'Soil Moisture',
                      value: '${data.soilMoisture.toStringAsFixed(1)}%',
                      color: _soilColor(data.soilMoisture),
                    ),
                    DashboardCard(
                      icon: Icons.thermostat,
                      title: 'Temperature',
                      value: '${data.temperature.toStringAsFixed(1)}°C',
                      color: _tempColor(data.temperature),
                    ),
                    DashboardCard(
                      icon: Icons.water_drop,
                      title: 'Air Humidity',
                      value: '${data.humidity.toStringAsFixed(1)}%',
                      color: Colors.blue,
                    ),
                    DashboardCard(
                      icon: Icons.water,
                      title: 'Water Level',
                      value: '${data.waterLevel.toStringAsFixed(1)}%',
                      color: _waterColor(data.waterLevel),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.psychology),
                        label: const Text('AI Decision'),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const AiDecisionScreen()),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.tune),
                        label: const Text('Thresholds'),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  const AutomationSettingsScreen()),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Last update: ${_formatTime(data.timestamp)}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Color _soilColor(double v) {
    if (v < 30) return Colors.orange;
    if (v < 50) return Colors.amber.shade700;
    return Colors.green;
  }

  Color _tempColor(double v) {
    if (v > 35) return Colors.red;
    if (v > 28) return Colors.orange;
    return Colors.blue;
  }

  Color _waterColor(double v) {
    if (v < 20) return Colors.red;
    if (v < 40) return Colors.orange;
    return Colors.blue;
  }

  String _formatTime(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:'
      '${dt.minute.toString().padLeft(2, '0')}:'
      '${dt.second.toString().padLeft(2, '0')}';
}

class _PumpStatusCard extends StatelessWidget {
  final bool pumpOn;
  final String mode;

  const _PumpStatusCard({required this.pumpOn, required this.mode});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: pumpOn ? Colors.green.shade50 : Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Icon(
              Icons.water_drop,
              size: 44,
              color: pumpOn ? Colors.green : Colors.red,
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pump: ${pumpOn ? "ON" : "OFF"}',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: pumpOn ? Colors.green.shade700 : Colors.red.shade700,
                  ),
                ),
                Text('Mode: $mode',
                    style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ConnectionBanner extends StatelessWidget {
  final bool isConnecting;
  final VoidCallback onConnect;

  const _ConnectionBanner(
      {required this.isConnecting, required this.onConnect});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.orange.shade50,
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Icon(Icons.wifi_off, color: Colors.orange.shade700),
            const SizedBox(width: 8),
            const Expanded(
                child: Text('Not connected to MQTT broker')),
            TextButton(
              onPressed: isConnecting ? null : onConnect,
              child: isConnecting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child:
                          CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Connect'),
            ),
          ],
        ),
      ),
    );
  }
}
