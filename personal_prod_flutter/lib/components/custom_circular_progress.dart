import 'package:flutter/material.dart';

class CustomCircularProgress extends StatelessWidget {
  const CustomCircularProgress({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 30, // Adjust size to fit your layout
      height: 30,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // The Circular Progress Indicator
          const SizedBox(
            width: 120,
            height: 120,
            child: CircularProgressIndicator(
              value: 0.85, // 85% progress
              strokeWidth: 2, // Thickness of the progress ring
              backgroundColor: Color(0xFFE8EBF9), // Light background track color
              valueColor: AlwaysStoppedAnimation<Color>(
                Color(0xFF2EBD59), // Vivid green color matching the design
              ),
              strokeCap: StrokeCap.round, // Rounds off the progress edges
            ),
          ),
          // Centered Text Display
          Text(
            '85%',
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF252B3B), // Dark slate grey text color
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }
}