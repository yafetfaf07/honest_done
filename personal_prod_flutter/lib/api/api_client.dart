import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_exception.dart';

/// Reads the server's user id out of the stored access token so requests can be
/// authenticated. Implemented by the token store to keep this layer free of any
/// storage dependency.
typedef AccessTokenReader = Future<String?> Function();

/// Supplies a fresh access token using the stored refresh token.
typedef RefreshTokenSupplier = Future<bool> Function();

/// HTTP client for the Go backend.
///
/// Handles the bearer token, refreshes an expired access token once per request,
/// and turns the backend's several error body shapes into [ApiException].
class ApiClient {
  ApiClient({
    required this.baseUrl,
    required this.readAccessToken,
    required this.supplyRefreshToken,
    http.Client? httpClient,
  }) : _http = httpClient ?? http.Client();

  /// e.g. `http://10.0.2.2:8080` on the Android emulator.
  final String baseUrl;

  final AccessTokenReader readAccessToken;
  final RefreshTokenSupplier supplyRefreshToken;

  final http.Client _http;

  static const Duration _timeout = Duration(seconds: 15);

  /// Called when refreshing fails, so the app can drop back to the login screen.
  void Function()? onSessionExpired;

  Future<Map<String, dynamic>> getJson(
    String path, {
    Map<String, String>? query,
  }) async {
    final headers = await _headers();
    final response = await _send(() => _http.get(_uri(path, query), headers: headers));
    return _decodeMap(response);
  }

  Future<List<dynamic>> getList(
    String path, {
    Map<String, String>? query,
  }) async {
    final headers = await _headers();
    final response = await _send(() => _http.get(_uri(path, query), headers: headers));
    return _decodeList(response);
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final (json, _) = await postWithHeaders(path, body: body);
    return json;
  }

  /// POST that also surfaces the response headers.
  ///
  /// Needed at login and register: the refresh token arrives as an http-only
  /// cookie, which a native client has to read out of the header itself.
  Future<(Map<String, dynamic>, Map<String, String>)> postWithHeaders(
    String path, {
    Map<String, dynamic>? body,
    bool skipRefresh = false,
  }) async {
    final headers = await _headers(json: true);
    final response = await _send(
      () => _http.post(
        _uri(path),
        headers: headers,
        body: jsonEncode(body ?? <String, dynamic>{}),
      ),
      skipRefresh: skipRefresh,
    );
    return (_decodeMap(response), response.headers);
  }

  /// POST that neither sends nor refreshes the bearer token.
  ///
  /// Used by `/refresh` itself: letting it go through the normal path would
  /// mean a 401 from the refresh endpoint triggers another refresh, forever.
  Future<Map<String, dynamic>> postUnauthenticated(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final response = await _guard(
      () => _http.post(
        _uri(path),
        headers: const {'Content-Type': 'application/json'},
        body: jsonEncode(body ?? <String, dynamic>{}),
      ),
    );
    return _decodeMap(response);
  }

  Future<Map<String, dynamic>> patch(String path) async {
    final headers = await _headers();
    final response = await _send(() => _http.patch(_uri(path), headers: headers));
    return _decodeMap(response);
  }

  Future<void> delete(String path) async {
    final headers = await _headers();
    await _send(() => _http.delete(_uri(path), headers: headers));
  }

  Uri _uri(String path, [Map<String, String>? query]) {
    return Uri.parse('$baseUrl$path').replace(
      queryParameters: (query == null || query.isEmpty) ? null : query,
    );
  }

  Future<Map<String, String>> _headers({bool json = false}) async {
    final headers = <String, String>{};
    if (json) headers['Content-Type'] = 'application/json';
    final token = await readAccessToken();
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  /// Runs [request], and on a 401 tries one refresh before retrying once.
  Future<http.Response> _send(
    Future<http.Response> Function() request, {
    bool skipRefresh = false,
  }) async {
    var response = await _guard(request);

    if (skipRefresh || response.statusCode != 401) return response;

    // Only attempt a refresh when there was a token to begin with; otherwise
    // this is simply an unauthenticated request and retrying is pointless.
    final hadToken = (await readAccessToken()) != null;
    if (!hadToken) return response;

    final refreshed = await supplyRefreshToken();
    if (!refreshed) {
      onSessionExpired?.call();
      return response;
    }

    response = await _guard(request);
    if (response.statusCode == 401) {
      onSessionExpired?.call();
    }
    return response;
  }

  Future<http.Response> _guard(Future<http.Response> Function() request) async {
    try {
      return await request().timeout(_timeout);
    } on TimeoutException {
      throw ApiException(message: 'The server took too long to respond.');
    } on http.ClientException catch (e) {
      throw ApiException(message: 'Could not reach the server. ${e.message}');
    } catch (e) {
      throw ApiException(message: 'Could not reach the server. $e');
    }
  }

  Map<String, dynamic> _decodeMap(http.Response response) {
    _throwIfError(response);
    return _asMap(response);
  }

  List<dynamic> _decodeList(http.Response response) {
    _throwIfError(response);
    final decoded = _decodeBody(response);
    if (decoded is List) return decoded;
    throw ApiException(
      message: 'Expected a list from the server.',
      statusCode: response.statusCode,
    );
  }

  void _throwIfError(http.Response response) {
    final status = response.statusCode;
    if (status >= 200 && status < 300) return;

    throw ApiException(
      message: errorMessageFrom(response),
      statusCode: response.statusCode,
      isUnauthorized: response.statusCode == 401,
      isConflict: response.statusCode == 409,
    );
  }

  Map<String, dynamic> _asMap(http.Response response) {
    final decoded = _decodeBody(response);
    if (decoded is Map) return decoded.cast<String, dynamic>();
    throw ApiException(
      message: 'Unexpected response from the server.',
      statusCode: response.statusCode,
    );
  }

  Object? _decodeBody(http.Response response) {
    if (response.body.isEmpty) return null;
    try {
      return jsonDecode(response.body);
    } on FormatException {
      // A 200 with an unparseable body usually means two JSON documents were
      // concatenated, which is a server-side defect worth surfacing plainly.
      throw ApiException(
        message: 'The server sent a response the app could not read.',
        statusCode: response.statusCode,
      );
    }
  }
}

/// Pulls a human-readable message out of every error shape the backend emits.
///
/// Observed shapes: `{"error": "..."}`, `{"Unknown error happened": "..."}`,
/// `{"error": {}}` (a Go error value, not a string), and an empty body from
/// gin's own aborts.
String errorMessageFrom(http.Response response) {
  if (response.body.isEmpty) {
    return _fallbackFor(response.statusCode);
  }

  try {
    final decoded = jsonDecode(response.body);
    if (decoded is Map) {
      for (final key in const [
        'error',
        'Unknown error happened',
        'message',
      ]) {
        final value = decoded[key];
        if (value is String && value.trim().isNotEmpty) return value;
      }
      // `{"error": {}}` carries an error object, not a message.
      if (decoded.containsKey('error')) {
        return _fallbackFor(response.statusCode);
      }
    }
  } on FormatException {
    return _fallbackFor(response.statusCode);
  }

  return _fallbackFor(response.statusCode);
}

String _fallbackFor(int? statusCode) {
  return switch (statusCode) {
    400 => 'That request was not valid.',
    401 => 'Please sign in again.',
    403 => 'You do not have access to that.',
    404 => 'That item no longer exists.',
    409 => 'That conflicts with something that already exists.',
    _ when statusCode != null && statusCode >= 500 =>
      'The server had a problem. Try again shortly.',
    _ => 'Something went wrong.',
  };
}