import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:personal_prod/components/goal_card.dart';
import 'package:personal_prod/components/state_views.dart';
import 'package:personal_prod/models/models.dart';
import 'package:personal_prod/pages/add_goal_page.dart';
import 'package:personal_prod/state/goals_provider.dart';
import 'package:personal_prod/theme/colors.dart';
import 'package:personal_prod/theme/spacing.dart';

/// Goal list backed by `GET /api/v1/goal/getGoal`.
///
/// Previously showed two fixed goals with invented progress, which meant the page
/// looked complete while never touching the backend.
class GoalsPage extends StatelessWidget {
  const GoalsPage({super.key});

  Future<void> _openAdd(BuildContext context) async {
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const AddGoalPage()),
    );
    if (created == true && context.mounted) {
      await context.read<GoalsProvider>().load(force: true);
    }
  }

  Future<void> _confirmDelete(BuildContext context, Goal goal) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete goal?'),
        content: Text(
          'This also deletes every task under "${goal.name}". This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: dialogContext.colors.dangerSolid,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final provider = context.read<GoalsProvider>();
    final ok = await provider.delete(goal.id);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.error ?? 'Could not delete that goal.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final goals = context.watch<GoalsProvider>();

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openAdd(context),
        child: const Icon(Icons.add),
      ),
      body: AsyncViewBuilder(
        isLoading: goals.isInitialLoad,
        isEmpty: goals.isEmpty,
        error: goals.error,
        onRetry: () => goals.load(force: true),
        emptyChild: EmptyState(
          icon: Icons.track_changes,
          title: 'No goals yet',
          message: 'Create your first goal and start breaking it into tasks.',
          actionLabel: 'Create a goal',
          onAction: () => _openAdd(context),
        ),
        child: RefreshIndicator(
          onRefresh: () => goals.load(force: true),
          child: ListView(
            key: const ValueKey('goals-page'),
            padding: EdgeInsets.fromLTRB(
              AppSpacing.layoutMargin,
              AppSpacing.spaceLg,
              AppSpacing.layoutMargin,
              AppSpacing.fabHeight +
                  AppSpacing.spaceLg +
                  MediaQuery.paddingOf(context).bottom,
            ),
            children: [
              for (var i = 0; i < goals.goals.length; i++)
                GoalCard(
                  key: ValueKey(goals.goals[i].id),
                  goal: goals.goals[i],
                  // Alternating categories keeps a long list scannable.
                  category: i.isEven ? GoalCategory.accent : GoalCategory.category,
                  onDelete: () => _confirmDelete(context, goals.goals[i]),
                ),
            ],
          ),
        ),
      ),
    );
  }
}