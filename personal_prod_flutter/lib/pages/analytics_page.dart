import 'package:flutter/material.dart';

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      key: ValueKey('analytics-page'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.bar_chart, size: 56, color: Colors.green),
          SizedBox(height: 12),
          Text(
            'Analytics',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}