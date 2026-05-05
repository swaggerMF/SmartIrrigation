import 'package:flutter/foundation.dart';
import '../models/sensor_data.dart';
import '../models/log_entry.dart';
import '../models/control_mode.dart';
import '../services/mqtt_service.dart';
import '../services/ai_service.dart';
import '../services/storage_service.dart';

class IrrigationProvider extends ChangeNotifier {
  final MqttService _mqttService = MqttService();
  final StorageService _storageService = StorageService();
  AiService _aiService = const AiService();

  // Sensor data (defaults shown until first MQTT message arrives)
  SensorData _sensorData = SensorData(
    soilMoisture: 0.0,
    temperature: 0.0,
    humidity: 0.0,
    waterLevel: 0.0,
    timestamp: DateTime.now(),
  );

  bool _pumpOn = false;
  ControlMode _controlMode = ControlMode.manual;
  bool _mqttConnected = false;
  bool _isConnecting = false;
  final List<LogEntry> _logs = [];
  AiDecisionResult? _aiDecisionResult;
  bool _isLoadingAi = false;

  // Threshold values
  double _soilThreshold = 40.0;
  double _tempThreshold = 32.0;
  double _waterThreshold = 20.0;

  // MQTT settings
  String _broker = 'broker.hivemq.com';
  int _port = 1883;
  String _clientId = 'smart_irrigation_app';
  String _username = '';
  String _password = '';
  String _backendUrl = 'http://10.0.2.2:8000';

  // Getters
  SensorData get sensorData => _sensorData;
  bool get pumpOn => _pumpOn;
  ControlMode get controlMode => _controlMode;
  bool get mqttConnected => _mqttConnected;
  bool get isConnecting => _isConnecting;
  List<LogEntry> get logs => List.unmodifiable(_logs);
  AiDecisionResult? get aiDecisionResult => _aiDecisionResult;
  bool get isLoadingAi => _isLoadingAi;
  double get soilThreshold => _soilThreshold;
  double get tempThreshold => _tempThreshold;
  double get waterThreshold => _waterThreshold;
  String get broker => _broker;
  int get port => _port;
  String get clientId => _clientId;
  String get username => _username;
  String get password => _password;
  String get backendUrl => _backendUrl;

  IrrigationProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final mqttSettings = await _storageService.loadMqttSettings();
    _broker = mqttSettings['broker'] as String;
    _port = mqttSettings['port'] as int;
    _clientId = mqttSettings['clientId'] as String;
    _username = mqttSettings['username'] as String;
    _password = mqttSettings['password'] as String;

    final thresholds = await _storageService.loadThresholds();
    _soilThreshold = thresholds['soil']!;
    _tempThreshold = thresholds['temperature']!;
    _waterThreshold = thresholds['water']!;

    _backendUrl = await _storageService.loadBackendUrl();
    _aiService = AiService(baseUrl: _backendUrl);

    notifyListeners();
  }

  Future<void> connectMqtt() async {
    if (_isConnecting) return;
    _isConnecting = true;
    notifyListeners();

    _mqttService.onMessage = _handleMqttMessage;
    _mqttService.onConnected = () {
      _mqttConnected = true;
      _isConnecting = false;
      _addLog(LogEntry(
        type: LogType.mqttConnected,
        message: 'Connected to $_broker:$_port',
      ));
      notifyListeners();
    };
    _mqttService.onDisconnected = () {
      _mqttConnected = false;
      _isConnecting = false;
      _addLog(LogEntry(
        type: LogType.mqttDisconnected,
        message: 'Disconnected from MQTT broker',
      ));
      notifyListeners();
    };

    final success = await _mqttService.connect(
      broker: _broker,
      port: _port,
      clientId: _clientId,
      username: _username.isNotEmpty ? _username : null,
      password: _password.isNotEmpty ? _password : null,
    );

    if (!success) {
      _isConnecting = false;
      _addLog(LogEntry(
        type: LogType.error,
        message: 'Failed to connect to $_broker:$_port',
      ));
      notifyListeners();
    }
  }

  void disconnectMqtt() {
    _mqttService.disconnect();
    _mqttConnected = false;
    notifyListeners();
  }

  void _handleMqttMessage(String topic, String message) {
    switch (topic) {
      case MqttService.topicSoilMoisture:
        final v = double.tryParse(message);
        if (v != null) {
          _sensorData =
              _sensorData.copyWith(soilMoisture: v, timestamp: DateTime.now());
          _addLog(LogEntry(
              type: LogType.sensorUpdated, message: 'Soil moisture: $v%'));
        }
      case MqttService.topicTemperature:
        final v = double.tryParse(message);
        if (v != null) _sensorData = _sensorData.copyWith(temperature: v);
      case MqttService.topicHumidity:
        final v = double.tryParse(message);
        if (v != null) _sensorData = _sensorData.copyWith(humidity: v);
      case MqttService.topicWaterLevel:
        final v = double.tryParse(message);
        if (v != null) _sensorData = _sensorData.copyWith(waterLevel: v);
      case MqttService.topicPumpStatus:
        _pumpOn = message.toUpperCase() == 'ON';
        _addLog(LogEntry(
          type: _pumpOn ? LogType.pumpOn : LogType.pumpOff,
          message: 'Pump status: ${_pumpOn ? "ON" : "OFF"}',
        ));
      case MqttService.topicControlMode:
        _controlMode = ControlModeExtension.fromMqtt(message);
        _addLog(LogEntry(
          type: LogType.modeChanged,
          message: 'Mode changed to: ${_controlMode.displayName}',
        ));
    }

    // Evaluate rule-based automation on every sensor update
    if (topic.startsWith('smart_irrigation/sensors/')) {
      _runRuleBasedCheck();
    }

    notifyListeners();
  }

  // Send pump command via MQTT and update local state
  void controlPump(bool turnOn) {
    final cmd = turnOn ? 'ON' : 'OFF';
    _mqttService.publish(MqttService.topicPumpControl, cmd);
    _pumpOn = turnOn;
    _addLog(LogEntry(
      type: turnOn ? LogType.pumpOn : LogType.pumpOff,
      message: 'Pump command sent: $cmd',
    ));
    notifyListeners();
  }

  void setControlMode(ControlMode mode) {
    _controlMode = mode;
    _mqttService.publish(MqttService.topicControlMode, mode.mqttValue);
    _addLog(LogEntry(
      type: LogType.modeChanged,
      message: 'Mode set to: ${mode.displayName}',
    ));
    notifyListeners();
  }

  // Rule-based check runs after any sensor update when mode is RULE_BASED
  void _runRuleBasedCheck() {
    if (_controlMode != ControlMode.ruleBased) return;
    final should = evaluateRules(
      soilMoisture: _sensorData.soilMoisture,
      waterLevel: _sensorData.waterLevel,
      temperature: _sensorData.temperature,
    );
    if (should && !_pumpOn) controlPump(true);
    if (!should && _pumpOn) controlPump(false);
  }

  // Isolated rule function — easy to modify without touching the rest of the provider
  bool evaluateRules({
    required double soilMoisture,
    required double waterLevel,
    required double temperature,
  }) {
    // Never irrigate when water reservoir is too low
    if (waterLevel < _waterThreshold) return false;
    // Irrigate when soil is dry
    if (soilMoisture < _soilThreshold) return true;
    // Irrigate when hot and moderately dry
    if (temperature > _tempThreshold && soilMoisture < 45.0) return true;
    return false;
  }

  Future<void> generateAiDecision() async {
    _isLoadingAi = true;
    _aiDecisionResult = null;
    notifyListeners();

    try {
      _aiDecisionResult = await _aiService.getIrrigationDecision(
        soilMoisture: _sensorData.soilMoisture,
        temperature: _sensorData.temperature,
        humidity: _sensorData.humidity,
        waterLevel: _sensorData.waterLevel,
      );
      _addLog(LogEntry(
        type: LogType.aiDecisionGenerated,
        message: 'AI decision: ${_aiDecisionResult!.decision}',
      ));
    } catch (e) {
      _addLog(LogEntry(type: LogType.error, message: 'AI backend error: $e'));
    } finally {
      _isLoadingAi = false;
      notifyListeners();
    }
  }

  void applyAiDecision() {
    if (_aiDecisionResult == null) return;
    controlPump(_aiDecisionResult!.pumpShouldBeOn);
    _addLog(LogEntry(
      type: LogType.aiDecisionApplied,
      message: 'Applied AI decision: ${_aiDecisionResult!.decision}',
    ));
    notifyListeners();
  }

  Future<void> saveMqttSettings({
    required String broker,
    required int port,
    required String clientId,
    String username = '',
    String password = '',
  }) async {
    _broker = broker;
    _port = port;
    _clientId = clientId;
    _username = username;
    _password = password;
    await _storageService.saveMqttSettings(
      broker: broker,
      port: port,
      clientId: clientId,
      username: username,
      password: password,
    );
    notifyListeners();
  }

  Future<void> saveThresholds({
    required double soil,
    required double temperature,
    required double water,
  }) async {
    _soilThreshold = soil;
    _tempThreshold = temperature;
    _waterThreshold = water;
    await _storageService.saveThresholds(
      soilMoisture: soil,
      temperature: temperature,
      waterLevel: water,
    );
    notifyListeners();
  }

  Future<void> saveBackendUrl(String url) async {
    _backendUrl = url;
    _aiService = AiService(baseUrl: url);
    await _storageService.saveBackendUrl(url);
    notifyListeners();
  }

  void _addLog(LogEntry entry) {
    _logs.insert(0, entry);
    if (_logs.length > 100) _logs.removeLast();
  }

  void clearLogs() {
    _logs.clear();
    notifyListeners();
  }
}
