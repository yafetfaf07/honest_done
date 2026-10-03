import 'package:flutter/material.dart';
import 'package:personal_prod/theme/colors.dart';

class CustomCircularProgress extends StatelessWidget {
  const CustomCircularProgress({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return SizedBox(
      width: 60,
      height: 60,
      child: Stack(
        alignment: Alignment.center,
        children: [
          const SizedBox(
            width: 150,
            height: 150,
            child: CircularProgressIndicator(
              value: 0.85,
              strokeWidth: 4,
              strokeCap: StrokeCap.round,
            ),
          ),
          Text(
            '85%',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
              color: colors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }
}