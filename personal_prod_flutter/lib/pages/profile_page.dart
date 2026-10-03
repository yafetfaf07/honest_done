import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:personal_prod/models/models.dart';
import 'package:personal_prod/state/auth_provider.dart';
import 'package:personal_prod/theme/colors.dart';
import 'package:personal_prod/theme/spacing.dart';
import 'package:personal_prod/theme/surfaces.dart';

/// Profile and session.
///
/// Was a centered placeholder with no way to sign out, so the only way back to
/// the login screen was to kill the app.
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  Future<void> _logout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text('You will need to sign in again to see your goals.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    // Clears the stored tokens and flips the gate back to the login screen.
    await context.read<AuthProvider>().logout();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    return Center(
      key: const ValueKey('profile-page'),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.layoutMargin),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.spaceXl),
              Center(
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: colors.accentSubtle,
                  child: Text(
                    _initials(user),
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: colors.accentText,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.spaceMd),
              Text(
                user?.name ?? 'Signed in',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                ),
              ),
              if (user?.email != null) ...[
                const SizedBox(height: AppSpacing.spaceXs),
                Text(
                  user!.email,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: colors.textSecondary),
                ),
              ],
              const SizedBox(height: AppSpacing.space2xl),
              if (auth.error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.spaceLg),
                  child: Text(
                    auth.error!,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: colors.dangerText),
                  ),
                ),
              Container(
                decoration: BoxDecoration(
                  color: colors.bgSurface,
                  borderRadius: AppRadii.lgAll,
                  boxShadow: AppShadows.cardBorder(context),
                ),
                child: Column(
                  children: [
                    _Row(
                      icon: Icons.alternate_email,
                      label: 'Email',
                      value: user?.email ?? 'Not loaded',
                    ),
                    Divider(height: 1, color: colors.borderSeparator),
                    _Row(
                      icon: Icons.badge_outlined,
                      label: 'User ID',
                      value: user?.id ?? 'Not loaded',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.spaceXl),
              OutlinedButton.icon(
                onPressed: auth.busy ? null : () => _logout(context),
                icon: auth.busy
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.logout),
                label: const Text('Sign out'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: colors.dangerText,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.spaceLg),
                  side: BorderSide(color: colors.borderDefault),
                ),
              ),
              const SizedBox(height: AppSpacing.spaceXl),
            ],
          ),
        ),
      ),
    );
  }

  static String _initials(UserProfile? user) {
    final name = (user?.name ?? '').trim();
    if (name.isEmpty) return '?';

    final parts = name.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.spaceLg),
      child: Row(
        children: [
          Icon(icon, size: 20, color: colors.textMuted),
          const SizedBox(width: AppSpacing.spaceMd),
          Text(label, style: TextStyle(color: colors.textSecondary)),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
              style: TextStyle(fontWeight: FontWeight.w600, color: colors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}