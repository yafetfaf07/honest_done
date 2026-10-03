import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:personal_prod/api/api_exception.dart';
import 'package:personal_prod/components/quiz_sheet.dart';
import 'package:personal_prod/models/models.dart';
import 'package:personal_prod/state/goals_provider.dart';
import 'package:personal_prod/state/tasks_provider.dart';

/// Completes or reopens a task and keeps derived goal progress in sync.
///
/// Shared by the dashboard and the tasks page so both refresh goals the same way
/// and both offer the task's quiz.
Future<void> toggleTask(
  BuildContext context,
  Task task,
  bool completed,
) async {
  final tasks = context.read<TasksProvider>();
  final ok = await tasks.setCompleted(task, completed);
  if (!context.mounted) return;

  if (!ok) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(tasks.error ?? 'Could not update that task.')),
    );
    return;
  }

  // Completion is what the server derives goal progress from.
  await context.read<GoalsProvider>().refresh();

  // Only completed tasks are worth quizzing on.
  if (!completed || !context.mounted) return;

  final questions = await _questionsFor(context, task.id);
  if (!context.mounted) return;
  if (questions == null || questions.isEmpty) return;

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => QuizSheet(questions: questions),
  );
}

/// Returns the task's questions, or null if the lookup failed.
///
/// A missing quiz is not an error worth interrupting the user for, so network
/// problems are swallowed here rather than surfaced as a failure on completion.
Future<List<Question>?> _questionsFor(BuildContext context, String taskId) async {
  try {
    return await context.read<TasksProvider>().questionsFor(taskId);
  } on ApiException {
    return null;
  }
}

/// Deletes a task and refreshes the goal it belonged to.
Future<void> deleteTask(BuildContext context, Task task) async {
  final tasks = context.read<TasksProvider>();
  final ok = await tasks.delete(task.id);
  if (!context.mounted) return;

  if (!ok) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(tasks.error ?? 'Could not delete that task.')),
    );
    return;
  }
  await context.read<GoalsProvider>().refresh();
}