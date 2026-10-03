import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Persists the session: access token, refresh token, and the cached profile.
///
/// Access and refresh tokens both live in secure storage rather than in the
/// jsonDecode cookie jar: the backend issues the refresh token as an http-only
/// cookie, which a native client cannot read back, so the value is captured
/// from the login response headers and stored directly.
class TokenStore {
  TokenStore({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static const _accessKey = 'access_token';
  static const _refreshKey = 'refresh_token';
  static const _userKey = 'cached_user';

  /// Cookies arrive as one `set-cookie` header. The refresh token is read out of
  /// it so a native client can persist it; http-only only blocks browser
  /// JavaScript, not a native HTTP client.
  static const _refreshCookieName = 'refresh_token';

  String? _accessToken;
  String? _refreshToken;

  String? get accessToken => _accessToken;

  /// The stored refresh token, sent in the `/refresh` body because a native
  /// client has no cookie jar.
  Future<String?> get refreshToken async {
    _refreshToken ??= await _storage.read(key: _refreshKey);
    return _refreshToken;
  }

  Future<void> load() async {
    _accessToken = await _storage.read(key: _accessKey);
    _refreshToken = await _storage.read(key: _refreshKey);
  }

  Future<void> saveSession({
    required String accessToken,
    required String refreshToken,
  }) async {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
    await _storage.write(key: _accessKey, value: accessToken);
    await _storage.write(key: _refreshKey, value: refreshToken);
  }

  /// Stores the profile returned by login/register so the app can render it
  /// before `/me` responds.
  Future<void> saveUser(Map<String, dynamic> user) async {
    await _storage.write(key: _userKey, value: jsonEncode(user));
  }

  Future<Map<String, dynamic>?> readUser() async {
    final raw = await _storage.read(key: _userKey);
    if (raw == null) return null;
    try {
      final decoded = jsonDecode(raw);
      return decoded is Map ? decoded.cast<String, dynamic>() : null;
    } on FormatException {
      return null;
    }
  }

  /// Pulls the refresh token out of a `set-cookie` response header.
  ///
  /// Returns null when the header is absent, which leaves the cookie as the only
  /// channel and means refresh will not work on a native client.
  static String? refreshTokenFromHeaders(Map<String, String> headers) {
    for (final entry in headers.entries) {
      if (entry.key.toLowerCase() != 'set-cookie') continue;
      for (final part in entry.value.split(';')) {
        final pair = part.trim().split('=');
        if (pair.length == 2 && pair[0] == _refreshCookieName) {
          return pair[1];
        }
      }
    }
    return null;
  }

  Future<void> clear() async {
    _accessToken = null;
    _refreshToken = null;
    await _storage.delete(key: _accessKey);
    await _storage.delete(key: _refreshKey);
    await _storage.delete(key: _userKey);
  }
}