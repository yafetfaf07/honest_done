import 'package:flutter/material.dart';
import 'package:personal_prod/theme/colors.dart';
import 'package:personal_prod/theme/spacing.dart';

class GoalCard extends StatelessWidget {
  const GoalCard({
    super.key,
    required this.icon,
    required this.category,
    required this.progress,
    required this.date,
    required this.title,
    required this.description,
    required this.target,
  });

  final IconData icon;
  final GoalCategory category;
  final double progress;
  final String date;
  final String title;
  final String description;
  final String target;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final solid = category.solid(colors);
    final subtle = category.subtle(colors);
    final onSubtle = category.text(colors);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: AppSpacing.spaceSm),
      padding: const EdgeInsets.all(AppSpacing.spaceLg),
      decoration: BoxDecoration(
        color: colors.bgSurface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.borderSubtle),
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
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: onSubtle),
              ),
              const SizedBox(width: AppSpacing.spaceMd),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 24,
                    color: colors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.spaceMd),
          Text(
            description,
            style: TextStyle(color: colors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.spaceMd),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.spaceSm,
                  vertical: AppSpacing.spaceXs,
                ),
                decoration: BoxDecoration(
                  color: subtle,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  target,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: onSubtle,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.spaceSm),
              Icon(Icons.date_range, size: 18, color: colors.textMuted),
              const SizedBox(width: AppSpacing.spaceXs),
              Expanded(
                child: Text(
                  date,
                  style: TextStyle(color: colors.textSecondary),
                ),
              ),
              Text(
                '${(progress * 100).toStringAsFixed(0)}%',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.spaceSm),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              color: solid,
              backgroundColor: colors.bgSunken,
            ),
          ),
        ],
      ),
    );
  }
}