import 'package:flutter/material.dart';
import 'package:personal_prod/components/goal_card.dart';
import 'package:personal_prod/pages/add_goal_page.dart';

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
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
      ),
      body: ListView(
        key: const ValueKey('goals-page'),
        padding: const EdgeInsets.only(top: 12, bottom: 96),
        children: const [
          GoalCard(
            icon: Icons.code,
            iconBackgroundColor: Color(0xffe7f3ec),
            progressColor: Color(0xff2fbf71),
            progress: 0.68,
            date: 'Oct 24, 2024',
            title: 'Become React Developer',
            description: 'Mastering Next.js, TypeScript, and Framer Motion for high-end UI.',
            target: 'Oct 2024',
          ),
          GoalCard(
            icon: Icons.terminal,
            iconBackgroundColor: Color(0xffe6eefc),
            progressColor: Color(0xff4f7df8),
            progress: 0.35,
            date: 'Dec 15, 2024',
            title: 'Learn Golang',
            description: 'Building highly scalable microservices and understanding concurrency patterns.',
            target: 'Dec 2024',
          ),
        ],
      ),
    );
  }
}