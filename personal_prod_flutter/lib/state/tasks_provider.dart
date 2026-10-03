import 'package:flutter/foundation.dart';

import '../api/api_exception.dart';
import '../api/api_service.dart';
import '../models/models.dart';
import 'load_state.dart';

/// Holds the task list and the pending-state of individual rows.
class TasksProvider extends ChangeNotifier {
  TasksProvider({required this.api});

  final ApiService api;

  LoadState _state = LoadState.idle;
  List<Task> _tasks = const <Task>[];
  String? _error;

  /// Task ids with an in-flight completion request, so a row can show progress
  /// without blocking the rest of the list.
  final Set<String> _pending = <String>{};

  LoadState get state => _state;
  List<Task> get tasks => _tasks;
  String? get error => _error;
  bool get isInitialLoad => _state == LoadState.loading && _tasks.isEmpty;

  bool isPending(String taskId) => _pending.contains(taskId);

  List<Task> get upcoming {
    final open = _tasks.where((t) => !t.isCompleted).toList()
      ..sort((a, b) => a.scheduleTime.compareTo(b.scheduleTime));
    return open;
  }

  List<Task> get completed {
    final done = _tasks.where((t) => t.isCompleted).toList()
      ..sort((a, b) => b.scheduleTime.compareTo(a.scheduleTime));
    return done;
  }

  Future<void> load({bool force = false}) async {
    if (_state == LoadState.loading && !force) return;
    _state = LoadState.loading;
    _error = null;
    notifyListeners();

    try {
      _tasks = await api.tasks();
      _state = LoadState.ready;
    } on ApiException catch (e) {
      // A brand new account gets 404 from getTask; that is an empty list, not a
      // failure, and must not be shown as an error.
      if (e.statusCode == 404) {
        _tasks = const <Task>[];
        _state = LoadState.ready;
      } else {
        _error = e.message;
        _state = LoadState.failed;
      }
    }
    notifyListeners();
  }

  Future<bool> setCompleted(Task task, bool completed) async {
    _pending.add(task.id);
    notifyListeners();

    try {
      final updated = await api.setTaskCompleted(task.id, completed);
      _replace(updated);
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      return false;
    } finally {
      _pending.remove(task.id);
      notifyListeners();
    }
  }

  Future<bool> create({
    required String goalId,
    required String title,
    required DateTime scheduleTime,
  }) async {
    try {
      final task = await api.createTask(
        goalId: goalId,
        title: title,
        scheduleTime: scheduleTime,
      );
      _tasks = <Task>[..._tasks, task];
      _error = null;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    }
  }

  Future<bool> delete(String taskId) async {
    final previous = _tasks;
    _tasks = _tasks.where((t) => t.id != taskId).toList(growable: false);
    notifyListeners();

    try {
      await api.deleteTask(taskId);
      return true;
    } on ApiException catch (e) {
      _tasks = previous;
      _error = e.message;
      notifyListeners();
      return false;
    }
  }

  Future<List<Question>> questionsFor(String taskId) {
    return api.questionsForTask(taskId);
  }

  void _replace(Task updated) {
    _tasks = _tasks
        .map((t) => t.id == updated.id ? updated : t)
        .toList(growable: false);
  }
}