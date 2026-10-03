import 'package:flutter/material.dart';

import 'package:personal_prod/theme/colors.dart';
import 'package:personal_prod/theme/spacing.dart';
import 'package:personal_prod/theme/surfaces.dart';

/// First-run welcome. Previously pushed a `Login` widget that never existed, so
/// the button threw; the gate now decides what comes next.
class FirstPage extends StatelessWidget {
  const FirstPage({super.key, required this.onGetStarted});

  final VoidCallback onGetStarted;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.layoutMargin,
          ),
          child: Column(
            children: [
              const Spacer(),
              Column(
                children: [
                  Icon(Icons.book, size: 64, color: colors.accentSolid),
                  const SizedBox(height: AppSpacing.spaceMd),
                  Text(
                    'Finch',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 30,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.spaceXs),
                  Text(
                    'Your personal assistant',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onGetStarted,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.spaceLg,
                      horizontal: AppSpacing.spaceXl,
                    ),
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadii.mdAll,
                    ),
                  ),
                  child: const Text(
                    'Get started',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.spaceXl),
            ],
          ),
        ),
      ),
    );
  }
}