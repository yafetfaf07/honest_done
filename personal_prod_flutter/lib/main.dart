import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:personal_prod/api/api_client.dart';
import 'package:personal_prod/api/api_service.dart';
import 'package:personal_prod/api/token_store.dart';
import 'package:personal_prod/pages/auth_gate.dart';
import 'package:personal_prod/state/auth_provider.dart';
import 'package:personal_prod/state/goals_provider.dart';
import 'package:personal_prod/state/tasks_provider.dart';
import 'package:personal_prod/theme/app_theme.dart';
import 'package:personal_prod/theme/colors.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final tokens = TokenStore();

  // The refresh supplier has to point back at the service that owns the client,
  // so the reference is captured lazily instead of at construction.
  late final ApiService service;
  service = ApiService(
    tokens: tokens,
    client: ApiClient(
      baseUrl: apiBaseUrl,
      readAccessToken: () async => tokens.accessToken,
      supplyRefreshToken: () => service.refresh(),
    ),
  );

  runApp(FinchApp(service: service));
}

/// Backend origin per platform.
///
/// The Android emulator reaches the host machine's localhost through 10.0.2.2;
/// every other target runs on the host itself.
const String apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://10.0.2.2:8080',
);

class FinchApp extends StatelessWidget {
  const FinchApp({super.key, required this.service});

  final ApiService service;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ApiService>.value(value: service),
        ChangeNotifierProvider(
          create: (_) => AuthProvider(api: service)..bootstrap(),
        ),
        // Goals and tasks are only meaningful while signed in, but the providers
        // are cheap to construct and hold no data until loaded.
        ChangeNotifierProvider(create: (_) => GoalsProvider(api: service)),
        ChangeNotifierProvider(create: (_) => TasksProvider(api: service)),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Finch',
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: ThemeMode.system,
        builder: (context, child) {
          // Keep the session gate above the theme's brightness: the splash
          // screen must follow the system theme in both modes.
          return ColoredBox(
            color: context.colors.bgPage,
            child: child ?? const SizedBox.shrink(),
          );
        },
        home: const AuthGate(),
      ),
    );
  }
}