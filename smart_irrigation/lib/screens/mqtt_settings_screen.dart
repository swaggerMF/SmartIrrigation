import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/irrigation_provider.dart';

class MqttSettingsScreen extends StatefulWidget {
  const MqttSettingsScreen({super.key});

  @override
  State<MqttSettingsScreen> createState() => _MqttSettingsScreenState();
}

class _MqttSettingsScreenState extends State<MqttSettingsScreen> {
  final _brokerCtrl = TextEditingController();
  final _portCtrl = TextEditingController();
  final _clientIdCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _backendUrlCtrl = TextEditingController();
  bool _populated = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_populated) {
      final p = context.read<IrrigationProvider>();
      _brokerCtrl.text = p.broker;
      _portCtrl.text = p.port.toString();
      _clientIdCtrl.text = p.clientId;
      _usernameCtrl.text = p.username;
      _passwordCtrl.text = p.password;
      _backendUrlCtrl.text = p.backendUrl;
      _populated = true;
    }
  }

  @override
  void dispose() {
    _brokerCtrl.dispose();
    _portCtrl.dispose();
    _clientIdCtrl.dispose();
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    _backendUrlCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('MQTT Settings')),
      body: Consumer<IrrigationProvider>(
        builder: (context, provider, _) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Connection status badge
              Card(
                color: provider.mqttConnected
                    ? Colors.green.shade50
                    : Colors.red.shade50,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Icon(
                        provider.mqttConnected ? Icons.wifi : Icons.wifi_off,
                        color: provider.mqttConnected
                            ? Colors.green
                            : Colors.red,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        provider.mqttConnected
                            ? 'Connected to ${provider.broker}'
                            : 'Not connected',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: provider.mqttConnected
                              ? Colors.green.shade700
                              : Colors.red.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              const Text('MQTT Broker',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _Field(
                  ctrl: _brokerCtrl,
                  label: 'Broker Address',
                  hint: 'broker.hivemq.com'),
              _Field(
                  ctrl: _portCtrl,
                  label: 'Port',
                  hint: '1883',
                  inputType: TextInputType.number),
              _Field(
                  ctrl: _clientIdCtrl,
                  label: 'Client ID',
                  hint: 'smart_irrigation_app'),
              _Field(
                  ctrl: _usernameCtrl,
                  label: 'Username (optional)',
                  hint: ''),
              _Field(
                  ctrl: _passwordCtrl,
                  label: 'Password (optional)',
                  hint: '',
                  obscure: true),

              const SizedBox(height: 16),
              const Text('AI Backend',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              const Text(
                'Use 10.0.2.2 instead of localhost for Android emulator.',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 8),
              _Field(
                  ctrl: _backendUrlCtrl,
                  label: 'Backend URL',
                  hint: 'http://10.0.2.2:8000'),

              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: provider.mqttConnected
                          ? provider.disconnectMqtt
                          : null,
                      child: const Text('Disconnect'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                        foregroundColor: Colors.white,
                      ),
                      onPressed:
                          provider.isConnecting ? null : _saveAndConnect,
                      child: provider.isConnecting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : const Text('Save & Connect'),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _saveAndConnect() async {
    final provider = context.read<IrrigationProvider>();
    await provider.saveMqttSettings(
      broker: _brokerCtrl.text.trim(),
      port: int.tryParse(_portCtrl.text) ?? 1883,
      clientId: _clientIdCtrl.text.trim(),
      username: _usernameCtrl.text.trim(),
      password: _passwordCtrl.text,
    );
    await provider.saveBackendUrl(_backendUrlCtrl.text.trim());
    await provider.connectMqtt();
  }
}

class _Field extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;
  final String hint;
  final TextInputType inputType;
  final bool obscure;

  const _Field({
    required this.ctrl,
    required this.label,
    required this.hint,
    this.inputType = TextInputType.text,
    this.obscure = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: ctrl,
        keyboardType: inputType,
        obscureText: obscure,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: const OutlineInputBorder(),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
      ),
    );
  }
}
