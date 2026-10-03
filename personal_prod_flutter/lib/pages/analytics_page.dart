import 'package:flutter/material.dart';
import 'package:personal_prod/theme/colors.dart';

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Center(
      key: const ValueKey('analytics-page'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.bar_chart, size: 56, color: colors.accentSolid),
          const SizedBox(height: 12),
          Text(
            'Analytics',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}