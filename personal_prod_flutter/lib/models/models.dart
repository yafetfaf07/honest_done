/// A goal, with progress derived server-side from its completed tasks.
class Goal {
  const Goal({
    required this.id,
    required this.name,
    required this.description,
    required this.targetDate,
    required this.progress,
    required this.taskCount,
    required this.completedTaskCount,
  });

  final String id;
  final String name;
  final String description;
  final DateTime targetDate;

  /// 0-100.
  final int progress;
  final int taskCount;
  final int completedTaskCount;

  factory Goal.fromJson(Map<String, dynamic> json) {
    return Goal(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      targetDate: _parseDate(json['target_date']),
      progress: _asInt(json['progress']),
      taskCount: _asInt(json['task_count']),
      completedTaskCount: _asInt(json['completed_task_count']),
    );
  }
}

/// A task belonging to a goal.
class Task {
  const Task({
    required this.id,
    required this.title,
    required this.scheduleTime,
    required this.completeTime,
    required this.status,
    required this.goalId,
  });

  static const String statusPending = 'pending';
  static const String statusCompleted = 'completed';

  final String id;
  final String title;
  final DateTime scheduleTime;

  /// Go's zero time when the task is not done, which serialises as
  /// `0001-01-01T00:00:00Z`. Treated as "no completion time".
  final DateTime? completeTime;
  final String status;
  final String goalId;

  bool get isCompleted => status == statusCompleted;

  factory Task.fromJson(Map<String, dynamic> json) {
    final rawComplete = _parseDate(json['complete_time']);
    return Task(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      scheduleTime: _parseDate(json['schedule_time']),
      completeTime: _isGoZeroTime(rawComplete) ? null : rawComplete,
      status: json['status'] as String? ?? statusPending,
      goalId: json['goal_id'] as String? ?? '',
    );
  }
}

class QuestionOption {
  const QuestionOption({
    required this.id,
    required this.text,
    required this.isCorrect,
  });

  final String id;
  final String text;
  final bool isCorrect;

  factory QuestionOption.fromJson(Map<String, dynamic> json) {
    return QuestionOption(
      id: json['id'] as String? ?? '',
      text: json['text'] as String? ?? '',
      isCorrect: json['is_correct'] as bool? ?? false,
    );
  }
}

class Question {
  const Question({
    required this.id,
    required this.text,
    required this.todoId,
    required this.options,
  });

  final String id;
  final String text;
  final String todoId;
  final List<QuestionOption> options;

  factory Question.fromJson(Map<String, dynamic> json) {
    final rawOptions = json['options'];
    return Question(
      id: json['id'] as String? ?? '',
      text: json['text'] as String? ?? '',
      todoId: json['todo_id'] as String? ?? '',
      options: rawOptions is List
          ? rawOptions
              .whereType<Map<String, dynamic>>()
              .map(QuestionOption.fromJson)
              .toList(growable: false)
          : const <QuestionOption>[],
    );
  }
}

class UserProfile {
  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
  });

  final String id;
  final String name;
  final String email;

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
    );
  }
}

DateTime _parseDate(Object? value) {
  if (value is! String || value.isEmpty) return DateTime.now();
  return DateTime.tryParse(value)?.toLocal() ?? DateTime.now();
}

/// Go serialises an unset `time.Time` as year 1 rather than null.
bool _isGoZeroTime(DateTime value) {
  return value.year <= 1;
}

int _asInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.round();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}