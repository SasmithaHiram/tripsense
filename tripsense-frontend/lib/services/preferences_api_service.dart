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
    // Always use current-user endpoint inferred from token
    final uri = Uri.parse('$baseUrl$preferencesEndpoint');
    final headers = await _headers();

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

  /// Fetch stored preferences (and potentially suggestions) for a given user.
  /// Returns a JSON map if found, or null if none exist (e.g., 404).
  Future<Map<String, dynamic>?> getUserPreferences(int userId) async {
    final uri = Uri.parse('$baseUrl$preferencesEndpoint/user/$userId');
    final headers = await _headers();
    final res = await http.get(uri, headers: headers);

    // Treat 200..299 as valid with JSON payload
    if (res.statusCode >= 200 && res.statusCode < 300) {
      try {
        final data = jsonDecode(res.body);
        if (data is Map<String, dynamic>) return data;
        return {};
      } catch (_) {
        return {};
      }
    }

    // If backend returns 404 for "no preferences", return null
    if (res.statusCode == 404) {
      return null;
    }

    // Other errors
    String message = 'Failed to load preferences (${res.statusCode})';
    try {
      final data = jsonDecode(res.body);
      if (data is Map && data['message'] is String) {
        message = data['message'] as String;
      }
    } catch (_) {}
    throw Exception(message);
  }

  /// Fetch preferences for the current authenticated user using token.
  /// Returns a JSON map if found, or null if none exist (404).
  Future<Map<String, dynamic>?> getMyPreferences() async {
    final uri = Uri.parse('$baseUrl$preferencesEndpoint');
    final headers = await _headers();
    // Backend expects POST for this endpoint; send an empty JSON body
    final res = await http.post(uri, headers: headers, body: jsonEncode({}));

    if (res.statusCode >= 200 && res.statusCode < 300) {
      try {
        final data = jsonDecode(res.body);
        if (data is Map<String, dynamic>) return data;
        return {};
      } catch (_) {
        return {};
      }
    }
    if (res.statusCode == 404) return null;

    String message = 'Failed to load preferences (${res.statusCode})';
    try {
      final data = jsonDecode(res.body);
      if (data is Map && data['message'] is String) {
        message = data['message'] as String;
      }
    } catch (_) {}
    throw Exception(message);
  }

  Future<Map<String, String>> _headers() async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token == null || token.isEmpty) {
      throw Exception('Missing auth token. Please log in again.');
    }
    headers['Authorization'] = 'Bearer $token';
    return Map<String, String>.from(headers);
  }
}
