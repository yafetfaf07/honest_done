import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:personal_prod/components/add_task_sheet.dart';
import 'package:personal_prod/components/state_views.dart';
import 'package:personal_prod/components/task_actions.dart';
import 'package:personal_prod/components/tasks_list.dart';
import 'package:personal_prod/models/models.dart';
import 'package:personal_prod/state/goals_provider.dart';
import 'package:personal_prod/state/load_state.dart';
import 'package:personal_prod/state/tasks_provider.dart';
import 'package:personal_prod/theme/colors.dart';
import 'package:personal_prod/theme/spacing.dart';

/// Full task list, split into upcoming and completed.
///
/// Reached from the dashboard's "View All", which used to be an inert button.
class TasksPage extends StatelessWidget {
  const TasksPage({super.key});

  Future<void> _openAdd(BuildContext context) async {
    final created = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const AddTaskSheet(),
    );
    if (created == true && context.mounted) {
      await context.read<GoalsProvider>().refresh();
    }
  }

  Future<void> _delete(BuildContext context, Task task) => deleteTask(context, task);

  Future<void> _toggle(BuildContext context, Task task, bool completed) =>
      toggleTask(context, task, completed);

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TasksProvider>();
    final upcoming = provider.upcoming;
    final completed = provider.completed;

    return Scaffold(
      appBar: AppBar(title: const Text('Tasks')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAdd(context),
        icon: const Icon(Icons.add),
        label: const Text('New task'),
      ),
      body: AsyncViewBuilder(
        isLoading: provider.isInitialLoad,
        isEmpty: provider.state == LoadState.ready &&
            upcoming.isEmpty &&
            completed.isEmpty,
        error: provider.error,
        onRetry: () => provider.load(force: true),
        emptyChild: EmptyState(
          icon: Icons.task_alt,
          title: 'No tasks yet',
          message: 'Break one of your goals down into tasks you can actually do.',
          actionLabel: 'Add a task',
          onAction: () => _openAdd(context),
        ),
        child: RefreshIndicator(
          onRefresh: () => provider.load(force: true),
          child: ListView(
            key: const ValueKey('tasks-page'),
            padding: EdgeInsets.fromLTRB(
              AppSpacing.layoutMargin,
              AppSpacing.spaceLg,
              AppSpacing.layoutMargin,
              AppSpacing.fabHeight +
                  AppSpacing.spaceXl +
                  MediaQuery.paddingOf(context).bottom,
            ),
            children: [
              if (upcoming.isNotEmpty) ...[
                _SectionLabel(label: 'UPCOMING', count: upcoming.length),
                for (final task in upcoming)
                  TaskTile(
                    key: ValueKey(task.id),
                    task: task,
                    pending: provider.isPending(task.id),
                    onToggle: (value) => _toggle(context, task, value),
                    onDelete: () => _delete(context, task),
                  ),
              ],
              if (completed.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.spaceXl),
                _SectionLabel(label: 'COMPLETED', count: completed.length),
                for (final task in completed)
                  TaskTile(
                    key: ValueKey(task.id),
                    task: task,
                    pending: provider.isPending(task.id),
                    onToggle: (value) => _toggle(context, task, value),
                    onDelete: () => _delete(context, task),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label, required this.count});

  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.spaceSm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
              color: colors.textSecondary,
            ),
          ),
          Text(
            '$count',
            style: TextStyle(color: colors.textMuted),
          ),
        ],
      ),
    );
  }
}