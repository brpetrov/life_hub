import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../hub/presentation/hub_screen.dart';
import 'auth_service.dart';
import 'login_screen.dart';

class AuthGate extends StatelessWidget {
  AuthGate({AuthService? authService, super.key})
    : _authService = authService ?? AuthService();

  final AuthService _authService;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _authService.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _AuthLoadingScreen();
        }

        if (snapshot.hasError) {
          return _AuthErrorScreen(error: snapshot.error.toString());
        }

        final user = snapshot.data;

        if (user == null) {
          return LoginScreen(authService: _authService);
        }

        return HubScreen(authService: _authService, user: user);
      },
    );
  }
}

class _AuthLoadingScreen extends StatelessWidget {
  const _AuthLoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

class _AuthErrorScreen extends StatelessWidget {
  const _AuthErrorScreen({required this.error});

  final String error;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Life Hub')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            error,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ),
      ),
    );
  }
}
