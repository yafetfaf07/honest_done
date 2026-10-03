import 'package:flutter/material.dart';
import 'package:personal_prod/components/goal_card.dart';
import 'package:personal_prod/pages/add_goal_page.dart';
import 'package:personal_prod/theme/colors.dart';
import 'package:personal_prod/theme/spacing.dart';

class GoalsPage extends StatelessWidget {
  const GoalsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const AddGoalPage(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: ListView(
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
          const GoalCard(
            icon: Icons.code,
            category: GoalCategory.accent,
            progress: 0.68,
            date: 'Oct 24, 2024',
            title: 'Become React Developer',
            description:
                'Mastering Next.js, TypeScript, and Framer Motion for high-end UI.',
            target: 'Oct 2024',
          ),
          GoalCard(
            icon: Icons.terminal,
            category: GoalCategory.category,
            progress: 0.35,
            date: 'Dec 15, 2024',
            title: 'Learn Golang',
            description:
                'Building highly scalable microservices and understanding concurrency patterns.',
            target: 'Dec 2024',
          ),
        ],
      ),
    );
  }
}