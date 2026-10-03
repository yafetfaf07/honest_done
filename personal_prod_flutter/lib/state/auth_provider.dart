import 'package:flutter/foundation.dart';

import '../api/api_exception.dart';
import '../api/api_service.dart';
import '../api/token_claims.dart';
import '../models/models.dart';

enum AuthStatus { unknown, signedOut, signedIn }

/// Owns the session: who is signed in, and the tokens backing that.
class AuthProvider extends ChangeNotifier {
  AuthProvider({required this.api}) {
    // A request that cannot be renewed after refreshing drops the session
    // rather than leaving a half-signed-in UI behind.
    api.client.onSessionExpired = _handleSessionExpired;
  }

  final ApiService api;

  AuthStatus _status = AuthStatus.unknown;
  UserProfile? _user;
  String? _error;
  bool _busy = false;

  AuthStatus get status => _status;
  UserProfile? get user => _user;
  String? get error => _error;
  bool get busy => _busy;
  bool get isSignedIn => _status == AuthStatus.signedIn;

  /// Restores a session on launch.
  ///
  /// The cached profile renders immediately so the app does not flash a login
  /// screen, then `/me` confirms the token is still good. A 401 here means the
  /// stored tokens are dead, so the session is dropped.
  Future<void> bootstrap() async {
    await api.tokens.load();

    final cached = await api.tokens.readUser();
    if (cached != null) _user = UserProfile.fromJson(cached);

    final claims = claimsFromAccessToken(api.tokens.accessToken);
    if (claims == null || claims.isExpired) {
      // An expired access token may still be renewable via the refresh token.
      final refreshed = await api.refresh();
      if (!refreshed) {
        await _reset();
        notifyListeners();
        return;
      }
    }

    try {
      _user = await api.me();
      _status = AuthStatus.signedIn;
      _error = null;
    } on ApiException catch (e) {
      if (e.isUnauthorized) {
        await _reset();
        notifyListeners();
        return;
      }
      // Network trouble: keep whatever was cached rather than signing the user
      // out because the server was briefly unreachable.
      _status = _user != null ? AuthStatus.signedIn : AuthStatus.signedOut;
      _error = e.message;
    }
    notifyListeners();
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    return _guard(() async {
      await api.login(email: email.trim(), password: password);
      _user = await api.me();
    });
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    return _guard(() async {
      await api.register(
        name: name.trim(),
        email: email.trim(),
        password: password,
      );
      _user = await api.me();
    });
  }

  Future<void> logout() async {
    _busy = true;
    notifyListeners();
    await api.logout();
    await _reset();
    _busy = false;
    notifyListeners();
  }

  void clearError() {
    if (_error == null) return;
    _error = null;
    notifyListeners();
  }

  /// Called by the HTTP client when refreshing fails. Guarded so a burst of
  /// parallel 401s does not clear the session repeatedly.
  void _handleSessionExpired() {
    if (_status == AuthStatus.signedOut) return;
    api.tokens.clear().then((_) {
      _user = null;
      _status = AuthStatus.signedOut;
      _error = 'Your session expired. Please sign in again.';
      notifyListeners();
    });
  }

  Future<bool> _guard(Future<void> Function() action) async {
    _busy = true;
    _error = null;
    notifyListeners();
    try {
      await action();
      _status = AuthStatus.signedIn;
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      return false;
    } catch (e) {
      _error = 'Something went wrong. Try again.';
      if (kDebugMode) debugPrint('unexpected auth error: $e');
      return false;
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  Future<void> _reset() async {
    await api.tokens.clear();
    _user = null;
    _status = AuthStatus.signedOut;
    _error = null;
  }
}