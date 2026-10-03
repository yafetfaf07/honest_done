/// Thrown when a request fails or the server returns an error body.
///
/// The backend returns several different error shapes, all of which end up
/// here so callers can show one consistent message.
class ApiException implements Exception {
  ApiException({
    required this.message,
    this.statusCode,
    this.isUnauthorized = false,
    this.isConflict = false,
  });

  /// The message to show the user, already extracted from whatever shape the
  /// server used.
  final String message;

  /// The HTTP status, or null when the request never completed (no network,
  /// timeout, DNS failure).
  final int? statusCode;

  /// True when the session is missing or expired and the user must sign in.
  final bool isUnauthorized;

  /// True for 409, used by register (email taken) and task create (slot clash).
  final bool isConflict;

  bool get isNetworkFailure => statusCode == null;

  @override
  String toString() => 'ApiException($statusCode): $message';
}