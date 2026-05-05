import 'dart:convert';
import 'package:http/http.dart' as http;

class AiDecisionResult {
  final String decision;
  final String recommendation;
  final String explanation;

  const AiDecisionResult({
    required this.decision,
    required this.recommendation,
    required this.explanation,
  });

  factory AiDecisionResult.fromJson(Map<String, dynamic> json) {
    return AiDecisionResult(
      decision: json['decision'] as String,
      recommendation: json['recommendation'] as String,
      explanation: json['explanation'] as String,
    );
  }

  bool get pumpShouldBeOn => decision == 'ON';
}

class AiService {
  final String baseUrl;

  const AiService({this.baseUrl = 'http://10.0.2.2:8000'});

  Future<AiDecisionResult> getIrrigationDecision({
    required double soilMoisture,
    required double temperature,
    required double humidity,
    required double waterLevel,
  }) async {
    final response = await http
        .post(
          Uri.parse('$baseUrl/ai/irrigation-decision'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'soil_moisture': soilMoisture,
            'temperature': temperature,
            'humidity': humidity,
            'water_level': waterLevel,
          }),
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      return AiDecisionResult.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    }
    throw Exception('Backend returned status ${response.statusCode}');
  }
}
