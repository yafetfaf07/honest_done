import 'package:flutter/foundation.dart';

import '../api/api_exception.dart';
import '../api/api_service.dart';
import '../models/models.dart';
import 'load_state.dart';

/// Holds the goal list and keeps it in sync with task changes, because goal
/// progress is derived from completed tasks on the server.
class GoalsProvider extends ChangeNotifier {
  GoalsProvider({required this.api});

  final ApiService api;

  LoadState _state = LoadState.idle;
  List<Goal> _goals = const <Goal>[];
  String? _error;

  LoadState get state => _state;
  List<Goal> get goals => _goals;
  String? get error => _error;
  bool get isEmpty => _state == LoadState.ready && _goals.isEmpty;

  /// True while a request is in flight and there is nothing on screen yet, so
  /// the page shows a loader rather than an empty state.
  bool get isInitialLoad => _state == LoadState.loading && _goals.isEmpty;

  Future<void> load({bool force = false}) async {
    if (_state == LoadState.loading && !force) return;
    _state = LoadState.loading;
    _error = null;
    notifyListeners();

    try {
      _goals = await api.goals();
      _state = LoadState.ready;
    } on ApiException catch (e) {
      _error = e.message;
      _state = LoadState.failed;
    }
    notifyListeners();
  }

  Future<bool> create({
    required String name,
    required String description,
    required DateTime targetDate,
  }) async {
    try {
      final goal = await api.createGoal(
        name: name,
        description: description,
        targetDate: targetDate,
      );
      _goals = <Goal>[..._goals, goal];
      _state = LoadState.ready;
      _error = null;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    }
  }

  Future<bool> delete(String goalId) async {
    final previous = _goals;
    _goals = _goals.where((g) => g.id != goalId).toList(growable: false);
    notifyListeners();

    try {
      await api.deleteGoal(goalId);
      return true;
    } on ApiException catch (e) {
      // Put it back: the optimistic removal did not stick.
      _goals = previous;
      _error = e.message;
      notifyListeners();
      return false;
    }
  }

  /// Pulls a fresh copy. Used after a task changes, since completing a task
  /// changes its goal's progress.
  Future<void> refresh() => load(force: true);
}