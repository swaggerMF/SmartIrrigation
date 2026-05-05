import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/irrigation_provider.dart';
import '../widgets/sensor_value_card.dart';

class SensorDetailsScreen extends StatelessWidget {
  const SensorDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sensor Details')),
      body: Consumer<IrrigationProvider>(
        builder: (_, provider, __) {
          final data = provider.sensorData;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              SensorValueCard(
                icon: Icons.grass,
                title: 'Soil Moisture',
                value: data.soilMoisture,
                unit: '%',
                interpretation: _soilInterpretation(data.soilMoisture),
                color: _soilColor(data.soilMoisture),
                minValue: 0,
                maxValue: 100,
              ),
              SensorValueCard(
                icon: Icons.thermostat,
                title: 'Temperature',
                value: data.temperature,
                unit: '°C',
                interpretation: _tempInterpretation(data.temperature),
                color: _tempColor(data.temperature),
                minValue: -10,
                maxValue: 50,
              ),
              SensorValueCard(
                icon: Icons.water_drop,
                title: 'Air Humidity',
                value: data.humidity,
                unit: '%',
                interpretation: _humidityInterpretation(data.humidity),
                color: Colors.blue,
                minValue: 0,
                maxValue: 100,
              ),
              SensorValueCard(
                icon: Icons.water,
                title: 'Water Level',
                value: data.waterLevel,
                unit: '%',
                interpretation: _waterInterpretation(data.waterLevel),
                color: _waterColor(data.waterLevel),
                minValue: 0,
                maxValue: 100,
              ),
              const SizedBox(height: 8),
              Text(
                'Last updated: ${_fmt(data.timestamp)}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          );
        },
      ),
    );
  }

  String _soilInterpretation(double v) {
    if (v < 20) return 'Soil moisture is critically low — irrigation needed urgently';
    if (v < 40) return 'Soil moisture is low — irrigation recommended';
    if (v < 70) return 'Soil moisture is optimal';
    return 'Soil moisture is high — no irrigation needed';
  }

  String _tempInterpretation(double v) {
    if (v < 5) return 'Temperature is very low';
    if (v < 20) return 'Temperature is cool';
    if (v < 30) return 'Temperature is normal';
    if (v < 35) return 'Temperature is high — consider irrigation';
    return 'Temperature is very high — irrigation may help cool the soil';
  }

  String _humidityInterpretation(double v) {
    if (v < 30) return 'Air humidity is low';
    if (v < 60) return 'Air humidity is normal';
    return 'Air humidity is high';
  }

  String _waterInterpretation(double v) {
    if (v < 20) return 'Water level is too low — refill the reservoir';
    if (v < 40) return 'Water level is sufficient';
    return 'Water level is good';
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

  String _fmt(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:'
      '${dt.minute.toString().padLeft(2, '0')}:'
      '${dt.second.toString().padLeft(2, '0')}';
}
