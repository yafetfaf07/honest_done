import 'package:flutter/material.dart';

import 'package:personal_prod/theme/colors.dart';
import 'package:personal_prod/theme/spacing.dart';

/// Full-bleed empty state: icon, a short explanation, and an optional action.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.spaceXl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: colors.textMuted),
            const SizedBox(height: AppSpacing.spaceLg),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.spaceSm),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: colors.textSecondary),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppSpacing.spaceXl),
              FilledButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}

/// Failure state with a retry, so a transient network problem is recoverable
/// without leaving the screen.
class ErrorStateView extends StatelessWidget {
  const ErrorStateView({super.key, required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.spaceXl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_outlined, size: 48, color: colors.dangerText),
            const SizedBox(height: AppSpacing.spaceLg),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: colors.textSecondary),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.spaceXl),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Try again'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Centred progress indicator used while a first load is in flight.
class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

/// Picks the right view for a provider's state, so every list page handles
/// loading, empty, and failure the same way.
class AsyncViewBuilder extends StatelessWidget {
  const AsyncViewBuilder({
    super.key,
    required this.isLoading,
    required this.isEmpty,
    required this.error,
    required this.onRetry,
    required this.emptyChild,
    required this.child,
  });

  final bool isLoading;
  final bool isEmpty;
  final String? error;
  final VoidCallback onRetry;
  final Widget emptyChild;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const LoadingView();
    if (error != null && isEmpty) {
      return ErrorStateView(message: error!, onRetry: onRetry);
    }
    if (isEmpty) return emptyChild;
    return child;
  }
}