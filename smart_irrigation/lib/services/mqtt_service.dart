import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

typedef MqttMessageCallback = void Function(String topic, String message);

class MqttService {
  MqttServerClient? _client;
  bool _isConnected = false;

  MqttMessageCallback? onMessage;
  void Function()? onConnected;
  void Function()? onDisconnected;

  // MQTT topic constants shared with the rest of the app
  static const String topicSoilMoisture = 'smart_irrigation/sensors/soil_moisture';
  static const String topicTemperature = 'smart_irrigation/sensors/temperature';
  static const String topicHumidity = 'smart_irrigation/sensors/humidity';
  static const String topicWaterLevel = 'smart_irrigation/sensors/water_level';
  static const String topicPumpStatus = 'smart_irrigation/pump/status';
  static const String topicPumpControl = 'smart_irrigation/pump/control';
  static const String topicControlMode = 'smart_irrigation/control_mode';
  static const String topicAiDecision = 'smart_irrigation/ai/decision';

  bool get isConnected => _isConnected;

  Future<bool> connect({
    required String broker,
    required int port,
    required String clientId,
    String? username,
    String? password,
  }) async {
    try {
      _client = MqttServerClient(broker, clientId);
      _client!.port = port;
      _client!.keepAlivePeriod = 30;
      _client!.logging(on: false);
      _client!.onConnected = _handleConnected;
      _client!.onDisconnected = _handleDisconnected;
      _client!.onSubscribed = (_) {};

      MqttConnectMessage connMsg = MqttConnectMessage()
          .withClientIdentifier(clientId)
          .startClean();

      if (username != null && username.isNotEmpty) {
        connMsg = connMsg.authenticateAs(username, password);
      }

      _client!.connectionMessage = connMsg;
      await _client!.connect();

      if (_client!.connectionStatus!.state == MqttConnectionState.connected) {
        _subscribeAll();
        _client!.updates!.listen(_dispatchMessages);
        return true;
      }
      return false;
    } catch (_) {
      _isConnected = false;
      return false;
    }
  }

  void _subscribeAll() {
    for (final topic in [
      topicSoilMoisture,
      topicTemperature,
      topicHumidity,
      topicWaterLevel,
      topicPumpStatus,
      topicControlMode,
      topicAiDecision,
    ]) {
      _client!.subscribe(topic, MqttQos.atLeastOnce);
    }
  }

  void _dispatchMessages(List<MqttReceivedMessage<MqttMessage>> messages) {
    for (final msg in messages) {
      final pub = msg.payload as MqttPublishMessage;
      final payload =
          MqttPublishPayload.bytesToStringAsString(pub.payload.message);
      onMessage?.call(msg.topic, payload);
    }
  }

  void _handleConnected() {
    _isConnected = true;
    onConnected?.call();
  }

  void _handleDisconnected() {
    _isConnected = false;
    onDisconnected?.call();
  }

  void publish(String topic, String message) {
    if (!_isConnected || _client == null) return;
    final builder = MqttClientPayloadBuilder()..addString(message);
    _client!.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
  }

  void disconnect() {
    _client?.disconnect();
    _isConnected = false;
  }
}
