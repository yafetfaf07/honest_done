import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:personal_prod/pages/credentials/login.dart';
import 'package:personal_prod/pages/home_page.dart';
import 'package:personal_prod/pages/onboard/onboard_page1.dart';
import 'package:personal_prod/state/auth_provider.dart';
import 'package:personal_prod/state/goals_provider.dart';
import 'package:personal_prod/state/tasks_provider.dart';

/// Decides between onboarding, login, and the app shell.
///
/// This replaces `FirstPage` being the app's home unconditionally, which meant a
/// returning user landed on the onboarding screen on every launch.
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  /// Onboarding is shown once, before the first sign-in attempt. Set to true
  /// for an existing user who already has a session or a cached profile.
  bool _showOnboarding = false;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return switch (auth.status) {
      AuthStatus.unknown => const _Splash(),
      AuthStatus.signedIn => const SignedInLoader(child: HomePage()),
      AuthStatus.signedOut => _showOnboarding
          ? FirstPage(
              onGetStarted: () => setState(() => _showOnboarding = false),
            )
          : const LoginPage(),
    };
  }
}

class _Splash extends StatelessWidget {
  const _Splash();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.book, size: 56),
            SizedBox(height: 24),
            SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ],
        ),
      ),
    );
  }
}

/// Loads the signed-in user's goals and tasks once the session is confirmed.
///
/// Kept separate from [AuthGate] so the requests fire only for someone who is
/// actually authenticated.
class SignedInLoader extends StatefulWidget {
  const SignedInLoader({super.key, required this.child});

  final Widget child;

  @override
  State<SignedInLoader> createState() => _SignedInLoaderState();
}

class _SignedInLoaderState extends State<SignedInLoader> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  void _load() {
    if (!mounted) return;
    context.read<GoalsProvider>().load();
    context.read<TasksProvider>().load();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}