import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // Spring backend base URL
  static const String baseUrl = 'http://localhost:8080/api/v1';

  // Endpoints
  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';

  /// Attempts to login with [email] and [password].
  /// Returns true on success. Stores token if present in response.
  Future<bool> login({required String email, required String password}) async {
    final uri = Uri.parse('$baseUrl$loginEndpoint');
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    final body = jsonEncode({'email': email, 'password': password});

    final res = await http.post(uri, headers: headers, body: body);

    if (res.statusCode == 200 || res.statusCode == 201) {
      // Parse token if provided
      try {
        final data = jsonDecode(res.body);
        final token = (data is Map)
            ? (data['token'] ?? data['accessToken'] ?? data['jwt'])
            : null;
        if (token is String && token.isNotEmpty) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('auth_token', token);
        }
      } catch (_) {
        // Ignore parse errors; treat as success without token
      }
      return true;
    }

    // Extract error message if available
    String message = 'Login failed (${res.statusCode})';
    try {
      final data = jsonDecode(res.body);
      if (data is Map && data['message'] is String) {
        message = data['message'] as String;
      }
    } catch (_) {}
    throw Exception(message);
  }

  /// Registers a new user.
  Future<bool> register({
    required String role,
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    final uri = Uri.parse('$baseUrl$registerEndpoint');
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    final body = jsonEncode({
      'role': role,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'password': password,
    });

    final res = await http.post(uri, headers: headers, body: body);
    if (res.statusCode == 200 || res.statusCode == 201) {
      return true;
    }
    String message = 'Registration failed (${res.statusCode})';
    try {
      final data = jsonDecode(res.body);
      if (data is Map && data['message'] is String) {
        message = data['message'] as String;
      }
    } catch (_) {}
    throw Exception(message);
  }
}
