import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const _kBroker = 'mqtt_broker';
  static const _kPort = 'mqtt_port';
  static const _kClientId = 'mqtt_client_id';
  static const _kUsername = 'mqtt_username';
  static const _kPassword = 'mqtt_password';
  static const _kSoilThreshold = 'threshold_soil';
  static const _kTempThreshold = 'threshold_temp';
  static const _kWaterThreshold = 'threshold_water';
  static const _kBackendUrl = 'backend_url';

  Future<Map<String, dynamic>> loadMqttSettings() async {
    final p = await SharedPreferences.getInstance();
    return {
      'broker': p.getString(_kBroker) ?? 'broker.hivemq.com',
      'port': p.getInt(_kPort) ?? 1883,
      'clientId': p.getString(_kClientId) ?? 'smart_irrigation_app',
      'username': p.getString(_kUsername) ?? '',
      'password': p.getString(_kPassword) ?? '',
    };
  }

  Future<void> saveMqttSettings({
    required String broker,
    required int port,
    required String clientId,
    String username = '',
    String password = '',
  }) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_kBroker, broker);
    await p.setInt(_kPort, port);
    await p.setString(_kClientId, clientId);
    await p.setString(_kUsername, username);
    await p.setString(_kPassword, password);
  }

  Future<Map<String, double>> loadThresholds() async {
    final p = await SharedPreferences.getInstance();
    return {
      'soil': p.getDouble(_kSoilThreshold) ?? 40.0,
      'temperature': p.getDouble(_kTempThreshold) ?? 32.0,
      'water': p.getDouble(_kWaterThreshold) ?? 20.0,
    };
  }

  Future<void> saveThresholds({
    required double soilMoisture,
    required double temperature,
    required double waterLevel,
  }) async {
    final p = await SharedPreferences.getInstance();
    await p.setDouble(_kSoilThreshold, soilMoisture);
    await p.setDouble(_kTempThreshold, temperature);
    await p.setDouble(_kWaterThreshold, waterLevel);
  }

  Future<String> loadBackendUrl() async {
    final p = await SharedPreferences.getInstance();
    return p.getString(_kBackendUrl) ?? 'http://10.0.2.2:8000';
  }

  Future<void> saveBackendUrl(String url) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_kBackendUrl, url);
  }
}
