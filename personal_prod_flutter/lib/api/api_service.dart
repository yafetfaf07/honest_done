import 'api_client.dart';
import 'api_exception.dart';
import 'token_store.dart';
import '../models/models.dart';

/// Talks to the `/api/v1` endpoints.
class ApiService {
  ApiService({required this.client, required this.tokens});

  final ApiClient client;
  final TokenStore tokens;

  static const String _userBase = '/api/v1/user';
  static const String _goalBase = '/api/v1/goal';
  static const String _taskBase = '/api/v1/task';
  static const String _questionBase = '/api/v1/question';

  // ---- auth -------------------------------------------------------------

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final (body, headers) = await client.postWithHeaders(
      '$_userBase/login',
      body: {'email': email, 'password': password},
    );
    await _persistSession(body, headers);
    return body;
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final (body, headers) = await client.postWithHeaders(
      '$_userBase/register',
      body: {'name': name, 'email': email, 'password': password},
    );
    await _persistSession(body, headers);
    return body;
  }

  Future<UserProfile> me() async {
    final json = await client.getJson('$_userBase/me');
    await tokens.saveUser(json);
    return UserProfile.fromJson(json);
  }

  Future<void> logout() async {
    try {
      await client.post('$_userBase/logout');
    } on ApiException {
      // Clearing the local session matters more than the server call; a failed
      // logout request must not leave the user stuck signed in.
    }
    await tokens.clear();
  }

  Future<bool> refresh() async {
    final refreshToken = await tokens.refreshToken;
    if (refreshToken == null || refreshToken.isEmpty) return false;
    try {
      final response = await client.postUnauthenticated(
        '$_userBase/refresh',
        body: {'refresh_token': refreshToken},
      );
      final newAccess = response['access_token'] as String?;
      if (newAccess == null) return false;
      final newRefresh =
          response['refresh_token'] as String? ?? refreshToken;
      await tokens.saveSession(
        accessToken: newAccess,
        refreshToken: newRefresh,
      );
      return true;
    } on ApiException {
      return false;
    }
  }

  /// Captures the access token from the body and the refresh token from the
  /// http-only cookie header, since a native client cannot read cookies itself.
  Future<void> _persistSession(
    Map<String, dynamic> body,
    Map<String, String> headers,
  ) async {
    final accessToken = body['access_token'] as String?;
    if (accessToken == null) {
      throw ApiException(
        message: 'The server did not return a session token.',
      );
    }
    final refreshToken = TokenStore.refreshTokenFromHeaders(headers);
    if (refreshToken == null) {
      throw ApiException(
        message: 'The server did not return a refresh token.',
      );
    }
    await tokens.saveSession(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
    await tokens.saveUser(body);
  }

  // ---- goals ------------------------------------------------------------

  Future<List<Goal>> goals() async {
    final list = await client.getList('$_goalBase/getGoal');
    return list
        .whereType<Map<String, dynamic>>()
        .map(Goal.fromJson)
        .toList(growable: false);
  }

  Future<Goal> createGoal({
    required String name,
    required String description,
    required DateTime targetDate,
  }) async {
    final json = await client.post(
      '$_goalBase/create',
      body: {
        'name': name,
        'description': description,
        // Sent as UTC ISO-8601; Go parses RFC3339.
        'target_date': targetDate.toUtc().toIso8601String(),
      },
    );
    return Goal.fromJson(json);
  }

  Future<void> deleteGoal(String goalId) => client.delete('$_goalBase/$goalId');

  // ---- tasks ------------------------------------------------------------

  Future<List<Task>> tasks() async {
    final list = await client.getList('$_taskBase/getTask');
    return list
        .whereType<Map<String, dynamic>>()
        .map(Task.fromJson)
        .toList(growable: false);
  }

  Future<Task> createTask({
    required String goalId,
    required String title,
    required DateTime scheduleTime,
  }) async {
    final json = await client.post(
      '$_taskBase/create/$goalId',
      body: {
        'title': title,
        'schedule_time': scheduleTime.toUtc().toIso8601String(),
      },
    );
    return Task.fromJson(json);
  }

  Future<Task> setTaskCompleted(String taskId, bool completed) async {
    final action = completed ? 'complete' : 'uncomplete';
    final json = await client.patch('$_taskBase/$taskId/$action');
    return Task.fromJson(json);
  }

  Future<void> deleteTask(String taskId) => client.delete('$_taskBase/$taskId');

  // ---- questions --------------------------------------------------------

  Future<List<Question>> questionsForTask(String taskId) async {
    final list = await client.getList('$_questionBase/getQuestion/$taskId');
    return list
        .whereType<Map<String, dynamic>>()
        .map(Question.fromJson)
        .toList(growable: false);
  }
}