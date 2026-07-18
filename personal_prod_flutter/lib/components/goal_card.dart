import 'package:flutter/material.dart';

class GoalCard extends StatelessWidget {
  const GoalCard({
    super.key,
    required this.icon,
    required this.iconBackgroundColor,
    required this.progressColor,
    required this.progress,
    required this.date,
    required this.title,
    required this.description,
    required this.target,
  });

  final IconData icon;
  final Color iconBackgroundColor;
  final Color progressColor;
  final double progress;
  final String date;
  final String title;
  final String description;
  final String target;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Align(
            alignment: AlignmentGeometry.centerLeft,
            child: Text(
              title,
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 24),
            ),
          ),
          Text(description, style: TextStyle(color: Colors.grey)),
          Align(
            alignment: Alignment.centerRight,
            child: Text("${(progress*100).toString()}%"),
          ),
          Align(
            alignment: AlignmentGeometry.centerLeft,
            child: Container(
              height: 3,
              width: MediaQuery.of(context).size.width * progress,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: const Color.fromARGB(255, 20, 20, 20),
              ),
            ),
          ),
          const SizedBox(height: 12),

          Row(children: [Icon(Icons.date_range), Text("Target:$date")]),
        ],
      ),
    );
  }
}
