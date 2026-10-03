import 'package:flutter/material.dart';
import 'package:personal_prod/theme/colors.dart';
import 'package:personal_prod/theme/spacing.dart';

class TasksList extends StatefulWidget {
  const TasksList({super.key});

  @override
  State<TasksList> createState() => _TasksListState();
}

class _TasksListState extends State<TasksList> {
  bool isSelected = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: AppSpacing.spaceSm),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.spaceMd,
        vertical: AppSpacing.spaceLg,
      ),
      decoration: BoxDecoration(
        color: colors.bgSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.borderSubtle),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Radio<bool>(
            value: true,
            groupValue: isSelected,
            toggleable: true,
            onChanged: (bool? value) {
              setState(() {
                isSelected = value ?? false;
              });
            },
          ),
          const SizedBox(width: AppSpacing.spaceXs),
          Expanded(
            child: Text(
              'Brand Identity Design',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: colors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.spaceMd),
          Text(
            '14:00',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}