import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/irrigation_provider.dart';

class AutomationSettingsScreen extends StatefulWidget {
  const AutomationSettingsScreen({super.key});

  @override
  State<AutomationSettingsScreen> createState() =>
      _AutomationSettingsScreenState();
}

class _AutomationSettingsScreenState
    extends State<AutomationSettingsScreen> {
  double _soilThreshold = 40.0;
  double _tempThreshold = 32.0;
  double _waterThreshold = 20.0;
  bool _populated = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_populated) {
      final p = context.read<IrrigationProvider>();
      _soilThreshold = p.soilThreshold;
      _tempThreshold = p.tempThreshold;
      _waterThreshold = p.waterThreshold;
      _populated = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Automation Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Rule-Based Thresholds',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text(
            'When Rule-Based mode is active, the pump turns ON if soil moisture '
            'is below the minimum and water level is sufficient.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 20),
          _ThresholdSlider(
            label: 'Minimum Soil Moisture',
            value: _soilThreshold,
            unit: '%',
            min: 10,
            max: 80,
            description: 'Pump turns ON when moisture drops below this value',
            onChanged: (v) => setState(() => _soilThreshold = v),
          ),
          _ThresholdSlider(
            label: 'Maximum Temperature',
            value: _tempThreshold,
            unit: '°C',
            min: 20,
            max: 45,
            description:
                'High temperature triggers irrigation when soil moisture < 45%',
            onChanged: (v) => setState(() => _tempThreshold = v),
          ),
          _ThresholdSlider(
            label: 'Minimum Water Level',
            value: _waterThreshold,
            unit: '%',
            min: 5,
            max: 50,
            description: 'Pump stays OFF when water level is below this value',
            onChanged: (v) => setState(() => _waterThreshold = v),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: _save,
              child: const Text('Save Settings'),
            ),
          ),
        ],
      ),
    );
  }

  void _save() {
    context.read<IrrigationProvider>().saveThresholds(
          soil: _soilThreshold,
          temperature: _tempThreshold,
          water: _waterThreshold,
        );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Settings saved'),
          backgroundColor: Colors.green),
    );
  }
}

class _ThresholdSlider extends StatelessWidget {
  final String label;
  final double value;
  final String unit;
  final double min;
  final double max;
  final String description;
  final ValueChanged<double> onChanged;

  const _ThresholdSlider({
    required this.label,
    required this.value,
    required this.unit,
    required this.min,
    required this.max,
    required this.description,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(label,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(
                  '${value.toStringAsFixed(0)}$unit',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Slider(
              value: value,
              min: min,
              max: max,
              divisions: (max - min).toInt(),
              label: '${value.toStringAsFixed(0)}$unit',
              onChanged: onChanged,
            ),
            Text(description,
                style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
