import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/spot_rate.dart';

class MetalsApiService {
  static const String _apiKey = 'GMDBOXJDJDO7Z0SKBEYS960SKBEYS';

  Future<SpotRate> fetchSpotPrice() async {
    final uri = Uri.https('api.metals.dev', '/v1/metal/spot', {
      'api_key': _apiKey,
      'metal': 'gold',
      'currency': 'EUR',
    });

    final response = await http.get(uri).timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw Exception('API-Fehler: HTTP ${response.statusCode}');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    if (json['status'] != 'success') {
      throw Exception('API-Fehler: ${json['status']}');
    }

    return SpotRate.fromJson(json);
  }
}
