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
      // Try to capture and persist userId from response for later calls
      try {
        final data = jsonDecode(res.body);
        if (data is Map) {
          final dynamic uid = data['userId'] ?? data['user_id'] ?? data['uid'];
          int? userId;
          if (uid is int) {
            userId = uid;
          } else if (uid is String) {
            userId = int.tryParse(uid);
          }
          if (userId != null) {
            final sp = await SharedPreferences.getInstance();
            await sp.setInt('user_id', userId);
          }
        }
      } catch (_) {
        // ignore json parse errors
      }
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

  Future<Map<String, String>> _headers() async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  /// Fetch stored preferences and AI recommendations for a specific user.
  /// Returns a JSON map if found, or null if none exist (e.g., 404).
  Future<Map<String, dynamic>?> getUserPreferences(int userId) async {
    final uri = Uri.parse('$baseUrl$preferencesEndpoint/user/$userId');
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    final res = await http.get(uri, headers: headers);

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

  /// Convenience: get only suggestion titles from /preferences/user/{id}
  Future<List<String>> getUserSuggestionTitles(int userId) async {
    final data = await getUserPreferences(userId);
    if (data == null) return const [];
    final ai = data['aiRecommendations'];
    if (ai is Map && ai['recommendations'] is List) {
      final recs = ai['recommendations'] as List;
      return recs
          .whereType<Map>()
          .map((m) => m['title'])
          .whereType<String>()
          .toList(growable: false);
    }
    return const [];
  }
}
