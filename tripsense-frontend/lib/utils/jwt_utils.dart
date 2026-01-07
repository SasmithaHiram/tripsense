import 'dart:convert';

class JwtUtils {
  static Map<String, dynamic>? _decodePayload(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final map = jsonDecode(decoded);
      if (map is Map<String, dynamic>) return map;
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Tries common claim keys to extract an integer user id from a JWT.
  /// Returns null if not present or not numeric.
  static int? extractUserId(String token) {
    final payload = _decodePayload(token);
    if (payload == null) return null;

    final candidates = ['userId', 'id', 'uid', 'user_id', 'sub'];
    for (final key in candidates) {
      if (!payload.containsKey(key)) continue;
      final value = payload[key];
      if (value is int) return value;
      if (value is String) {
        final v = int.tryParse(value);
        if (v != null) return v;
      }
    }
    return null;
  }
}
