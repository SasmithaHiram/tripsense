import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // Spring backend base URL
  static const String baseUrl = 'http://localhost:8080/api/v1';

  // Endpoints
  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/users/register';

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
      // Parse token from body or Authorization header
      String? token;
      try {
        final data = jsonDecode(res.body);
        if (data is Map) {
          token =
              (data['token'] ??
                      data['accessToken'] ??
                      data['access_token'] ??
                      data['jwt'])
                  as String?;
        }
      } catch (_) {
        // ignore JSON parse errors
      }

      // If not found in body, try the Authorization header
      token ??= _extractTokenFromAuthHeader(
        res.headers['authorization'] ?? res.headers['Authorization'],
      );

      // Persist normalized token if present
      if (token != null && token.isNotEmpty) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', _normalizeToken(token));
        return true;
      }

      // If the server did not provide a token, fail clearly so
      // token-protected endpoints (like /preferences) won't 403 silently.
      throw Exception(
        'Login succeeded but no token was provided by the server',
      );
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

  // Normalizes tokens to raw JWT by stripping a leading "Bearer " prefix.
  String _normalizeToken(String token) {
    final t = token.trim();
    const bearer = 'Bearer ';
    if (t.startsWith(bearer)) return t.substring(bearer.length).trim();
    return t;
  }

  // Extracts the token part from an Authorization header value if present.
  String? _extractTokenFromAuthHeader(String? headerValue) {
    if (headerValue == null || headerValue.trim().isEmpty) return null;
    final v = headerValue.trim();
    const bearer = 'Bearer ';
    if (v.startsWith(bearer)) return v.substring(bearer.length).trim();
    return v; // if server sent token without prefix
  }
}
