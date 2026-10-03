import 'package:flutter/material.dart';

import 'package:personal_prod/models/models.dart';
import 'package:personal_prod/theme/colors.dart';
import 'package:personal_prod/theme/spacing.dart';
import 'package:personal_prod/theme/surfaces.dart';

class GoalCard extends StatelessWidget {
  const GoalCard({
    super.key,
    required this.goal,
    required this.category,
    this.onDelete,
  });

  /// A goal from the API. Replaces the previous all-hardcoded constructor, whose
  /// progress and dates never came from anywhere.
  final Goal goal;
  final GoalCategory category;
  final VoidCallback? onDelete;

  /// Goal progress arrives from the server as 0-100.
  static double _fraction(int progress) {
    if (progress <= 0) return 0;
    if (progress >= 100) return 1;
    return progress / 100;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final solid = category.solid(colors);
    final subtle = category.subtle(colors);
    final onSubtle = category.text(colors);
    final fraction = _fraction(goal.progress);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: AppSpacing.spaceSm),
      padding: const EdgeInsets.all(AppSpacing.spaceLg),
      decoration: BoxDecoration(
        color: colors.bgSurface,
        borderRadius: AppRadii.xlAll,
        boxShadow: AppShadows.cardBorder(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: subtle,
                  borderRadius: AppRadii.smAll,
                ),
                child: Icon(_iconFor(goal.name), color: onSubtle),
              ),
              const SizedBox(width: AppSpacing.spaceMd),
              Expanded(
                child: Text(
                  goal.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 22,
                    color: colors.textPrimary,
                  ),
                ),
              ),
              if (onDelete != null)
                IconButton(
                  onPressed: onDelete,
                  icon: Icon(Icons.delete_outline, color: colors.textMuted),
                  tooltip: 'Delete goal',
                ),
            ],
          ),
          if (goal.description.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.spaceMd),
            Text(
              goal.description,
              style: TextStyle(color: colors.textSecondary),
            ),
          ],
          const SizedBox(height: AppSpacing.spaceMd),
          Row(
            children: [
              Text(
                '${goal.completedTaskCount}/${goal.taskCount} tasks',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: onSubtle,
                ),
              ),
              const SizedBox(width: AppSpacing.spaceSm),
              Icon(Icons.date_range, size: 18, color: colors.textMuted),
              const SizedBox(width: AppSpacing.spaceXs),
              Expanded(
                child: Text(
                  _formatDate(goal.targetDate),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: colors.textSecondary),
                ),
              ),
              Text(
                '${goal.progress}%',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.spaceSm),
          ClipRRect(
            borderRadius: AppRadii.fullAll,
            child: LinearProgressIndicator(
              value: fraction,
              minHeight: 6,
              color: solid,
              backgroundColor: colors.bgSunken,
            ),
          ),
        ],
      ),
    );
  }

  /// Picks an icon from the goal name so cards are not visually identical.
  static IconData _iconFor(String name) {
    final text = name.toLowerCase();
    if (text.contains('learn') || text.contains('study') || text.contains('read')) {
      return Icons.menu_book_outlined;
    }
    if (text.contains('run') ||
        text.contains('fit') ||
        text.contains('gym') ||
        text.contains('train')) {
      return Icons.directions_run;
    }
    if (text.contains('write') || text.contains('blog')) {
      return Icons.edit_note;
    }
    if (text.contains('ship') || text.contains('build') || text.contains('launch')) {
      return Icons.rocket_launch_outlined;
    }
    return Icons.track_changes;
  }

  static String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final local = date.toLocal();
    return '${months[local.month - 1]} ${local.day}, ${local.year}';
  }
}