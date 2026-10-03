import 'dart:convert';

/// Reads the user id out of the JWT payload.
///
/// This only decodes; it does not verify the signature. That is safe here
/// because the value is only used as a cache key and for display, never for an
/// authorisation decision. Anything that matters is re-checked by the server.
String? userIdFromAccessToken(String? token) {
  if (token == null || token.isEmpty) return null;
  final parts = token.split('.');
  if (parts.length != 3) return null;
  try {
    final payload = jsonDecode(
      utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
    );
    if (payload is Map) {
      final id = payload['user_id'];
      if (id is String) return id;
    }
  } on FormatException {
    return null;
  }
  return null;
}

/// The session's subject and expiry, decoded from the access token.
class TokenClaims {
  const TokenClaims({required this.userId, required this.expiresAt});

  final String userId;
  final DateTime expiresAt;

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}

TokenClaims? claimsFromAccessToken(String? token) {
  if (token == null || token.isEmpty) return null;
  final parts = token.split('.');
  if (parts.length != 3) return null;
  try {
    final payload = jsonDecode(
      utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
    );
    if (payload is! Map) return null;
    final userId = payload['user_id'];
    final exp = payload['exp'];
    if (userId is! String || exp is! int) return null;
    return TokenClaims(
      userId: userId,
      expiresAt: DateTime.fromMillisecondsSinceEpoch(exp * 1000),
    );
  } on FormatException {
    return null;
  }
}