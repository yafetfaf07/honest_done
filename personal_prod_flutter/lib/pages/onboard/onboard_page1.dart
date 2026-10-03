import 'package:flutter/material.dart';
import 'package:personal_prod/pages/credentials/login.dart';
import 'package:personal_prod/theme/colors.dart';
import 'package:personal_prod/theme/spacing.dart';

class FirstPage extends StatelessWidget {
  const FirstPage({super.key});

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
                    "Finch",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 30,
                      color: colors.textPrimary,
                    ),
                  ),
                  Text(
                    "Your AI personal assistant",
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontSize: 24,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (ctx) => Login()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.spaceLg,
                      horizontal: AppSpacing.spaceXl,
                    ),
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Add widget',
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