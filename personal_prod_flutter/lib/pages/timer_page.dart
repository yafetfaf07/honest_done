import 'package:flutter/material.dart';

class TimerPage extends StatelessWidget {
  const TimerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      key: ValueKey('timer-page'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timer_sharp, size: 56, color: Colors.green),
          SizedBox(height: 12),
          Text(
            'Timer',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}