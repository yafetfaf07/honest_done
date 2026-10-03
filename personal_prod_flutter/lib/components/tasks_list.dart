import 'package:flutter/material.dart';

import 'package:personal_prod/models/models.dart';
import 'package:personal_prod/theme/colors.dart';
import 'package:personal_prod/theme/spacing.dart';
import 'package:personal_prod/theme/surfaces.dart';

/// A single task row.
///
/// Was a self-contained card with a hardcoded title and a local radio that
/// changed nothing; it now renders a real task and reports the toggle upward.
class TaskTile extends StatelessWidget {
  const TaskTile({
    super.key,
    required this.task,
    required this.onToggle,
    this.pending = false,
    this.onDelete,
  });

  final Task task;
  final ValueChanged<bool> onToggle;
  final bool pending;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final done = task.isCompleted;

    // The transparency Material gives the checkbox its required ancestor, so
    // the row can be dropped into any container without wrapping it in a
    // Scaffold first.
    return Material(
      type: MaterialType.transparency,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: AppSpacing.spaceSm),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.spaceSm,
          vertical: AppSpacing.spaceMd,
        ),
        decoration: BoxDecoration(
          color: colors.bgSurface,
          borderRadius: AppRadii.lgAll,
          boxShadow: AppShadows.cardBorder(context),
        ),
        child: Row(
          children: [
            SizedBox(
              height: 24,
              width: 24,
              child: pending
                  ? const Padding(
                      padding: EdgeInsets.all(2),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Checkbox(
                      value: done,
                      onChanged: (value) => onToggle(value ?? false),
                    ),
            ),
            const SizedBox(width: AppSpacing.spaceXs),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: done ? colors.textMuted : colors.textPrimary,
                      decoration: done ? TextDecoration.lineThrough : null,
                      decorationColor: colors.textMuted,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.spaceXs),
                  Text(
                    _timeLabel(task.scheduleTime),
                    style: TextStyle(fontSize: 13, color: colors.textMuted),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.spaceSm),
            if (onDelete != null)
              IconButton(
                onPressed: pending ? null : onDelete,
                icon: Icon(Icons.close, size: 18, color: colors.textMuted),
                tooltip: 'Delete task',
              ),
          ],
        ),
      ),
    );
  }
}

String _timeLabel(DateTime time) {
  final local = time.toLocal();
  final hour = local.hour == 0 ? 12 : (local.hour > 12 ? local.hour - 12 : local.hour);
  final minute = local.minute.toString().padLeft(2, '0');
  final suffix = local.hour >= 12 ? 'PM' : 'AM';
  return '$hour:$minute $suffix';
}