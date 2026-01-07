import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UserApiService {
  static const String baseUrl = 'http://localhost:8080/api/v1';
  static const String meEndpoint = '/users/me';
  static const String usersEndpoint = '/users';

  Future<Map<String, dynamic>> getMe() async {
    final uri = Uri.parse('$baseUrl$meEndpoint');
    final headers = await _headers();
    final res = await http.get(uri, headers: headers);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final data = jsonDecode(res.body);
      if (data is Map<String, dynamic>) return data;
      return {};
    }
    throw Exception('Failed to load profile (${res.statusCode})');
  }

  Future<Map<String, dynamic>> getUserById(int userId) async {
    final uri = Uri.parse('$baseUrl$usersEndpoint/$userId');
    final headers = await _headers();
    final res = await http.get(uri, headers: headers);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final data = jsonDecode(res.body);
      if (data is Map<String, dynamic>) return data;
      return {};
    }
    throw Exception('Failed to load user ($userId): ${res.statusCode}');
  }

  Future<Map<String, dynamic>> getUserByEmail(String email) async {
    final safe = Uri.encodeComponent(email);
    final uri = Uri.parse('$baseUrl$usersEndpoint/$safe');
    final headers = await _headers();
    final res = await http.get(uri, headers: headers);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final data = jsonDecode(res.body);
      if (data is Map<String, dynamic>) return data;
      return {};
    }
    throw Exception('Failed to load user ($email): ${res.statusCode}');
  }

  Future<bool> updateMe({
    required String firstName,
    required String lastName,
    required String email,
  }) async {
    final uri = Uri.parse('$baseUrl$meEndpoint');
    final headers = await _headers();
    final body = jsonEncode({
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
    });
    final res = await http.put(uri, headers: headers, body: body);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return true;
    }
    String message = 'Failed to update profile (${res.statusCode})';
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
}
