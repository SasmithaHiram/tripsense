import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesApiService {
  static const String baseUrl = 'http://localhost:8080/api/v1';
  static const String preferencesEndpoint = '/preferences';

  String _fmtDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<bool> submitPreferences({
    required Set<String> categories,
    required List<String> locations,
    required DateTime startDate,
    required DateTime endDate,
    required int maxDistanceKm,
    required double maxBudget,
  }) async {
    final uri = Uri.parse('$baseUrl$preferencesEndpoint');
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    // Attach auth token if available
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    final body = jsonEncode({
      'categories': categories.toList(),
      'locations': locations,
      'startDate': _fmtDate(startDate),
      'endDate': _fmtDate(endDate),
      'maxDistanceKm': maxDistanceKm,
      'maxBudget': maxBudget,
    });

    final res = await http.post(uri, headers: headers, body: body);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return true;
    }

    String message = 'Submit preferences failed (${res.statusCode})';
    try {
      final data = jsonDecode(res.body);
      if (data is Map && data['message'] is String) {
        message = data['message'] as String;
      }
    } catch (_) {}
    throw Exception(message);
  }
}
