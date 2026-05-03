import 'package:flutter/material.dart';

import '../features/auth/auth_gate.dart';
import 'app_theme.dart';
import 'firebase_startup_state.dart';

export 'firebase_startup_state.dart';

class LifeHubApp extends StatefulWidget {
  const LifeHubApp({required this.firebaseState, super.key});

  final FirebaseStartupState firebaseState;

  @override
  State<LifeHubApp> createState() => _LifeHubAppState();
}

class _LifeHubAppState extends State<LifeHubApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void _setThemeMode(ThemeMode themeMode) {
    if (_themeMode == themeMode) {
      return;
    }

    setState(() {
      _themeMode = themeMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Life Hub',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: _themeMode,
      home: _homeForState(widget.firebaseState),
    );
  }

  Widget _homeForState(FirebaseStartupState state) {
    return switch (state.status) {
      FirebaseStartupStatus.ready => AuthGate(
        onThemeModeChanged: _setThemeMode,
      ),
      FirebaseStartupStatus.notConfigured => FirebaseSetupScreen(
        title: 'Firebase setup needed',
        message: state.message,
      ),
      FirebaseStartupStatus.failed => FirebaseSetupScreen(
        title: 'Firebase failed to start',
        message: state.message,
      ),
    };
  }
}

class FirebaseSetupScreen extends StatelessWidget {
  const FirebaseSetupScreen({
    required this.title,
    required this.message,
    super.key,
  });

  final String title;
  final String? message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Life Hub')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.cloud_off_outlined,
                  size: 48,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 20),
                Text(title, style: theme.textTheme.headlineSmall),
                const SizedBox(height: 12),
                Text(
                  'The app shell is ready. Connect this Flutter project to a '
                  'Firebase project, then restart the app.',
                  style: theme.textTheme.bodyLarge,
                ),
                if (message != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    message!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                SelectableText(
                  'flutterfire configure',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
