import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/control_mode.dart';
import '../providers/irrigation_provider.dart';

class PumpControlScreen extends StatelessWidget {
  const PumpControlScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pump Control')),
      body: Consumer<IrrigationProvider>(
        builder: (_, provider, __) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Big pump status indicator
              Card(
                color: provider.pumpOn
                    ? Colors.green.shade50
                    : Colors.red.shade50,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Column(
                    children: [
                      Icon(
                        provider.pumpOn
                            ? Icons.water_drop
                            : Icons.water_drop_outlined,
                        size: 72,
                        color: provider.pumpOn ? Colors.green : Colors.red,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        provider.pumpOn ? 'PUMP ON' : 'PUMP OFF',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: provider.pumpOn
                              ? Colors.green.shade700
                              : Colors.red.shade700,
                        ),
                      ),
                      Text(
                        'Mode: ${provider.controlMode.displayName}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Manual ON/OFF buttons — only enabled in manual mode
              if (provider.controlMode == ControlMode.manual) ...[
                const Text(
                  'Manual Control',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding:
                              const EdgeInsets.symmetric(vertical: 16),
                          disabledBackgroundColor: Colors.grey.shade300,
                        ),
                        icon: const Icon(Icons.power_settings_new),
                        label: const Text('Turn ON'),
                        onPressed:
                            provider.pumpOn || !provider.mqttConnected
                                ? null
                                : () => provider.controlPump(true),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding:
                              const EdgeInsets.symmetric(vertical: 16),
                          disabledBackgroundColor: Colors.grey.shade300,
                        ),
                        icon: const Icon(Icons.power_off),
                        label: const Text('Turn OFF'),
                        onPressed:
                            !provider.pumpOn || !provider.mqttConnected
                                ? null
                                : () => provider.controlPump(false),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],

              // Control mode selector
              const Text(
                'Control Mode',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              ...ControlMode.values.map(
                (mode) => RadioListTile<ControlMode>(
                  title: Text(mode.displayName),
                  subtitle: Text(_modeDesc(mode)),
                  value: mode,
                  groupValue: provider.controlMode,
                  onChanged: (v) {
                    if (v != null) provider.setControlMode(v);
                  },
                ),
              ),

              if (!provider.mqttConnected)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Connect to MQTT to send commands',
                    style:
                        TextStyle(color: Colors.orange.shade700, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  String _modeDesc(ControlMode mode) {
    switch (mode) {
      case ControlMode.manual:
        return 'You control the pump directly with the buttons above';
      case ControlMode.ruleBased:
        return 'App decides automatically based on sensor thresholds';
      case ControlMode.ai:
        return 'AI/LLM backend makes irrigation decisions';
    }
  }
}
