import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../auth/auth_service.dart';
import '../../settings/data/firestore_app_settings_repository.dart';
import '../../settings/domain/app_settings.dart';
import '../data/firestore_hub_item_repository.dart';
import 'hub_dashboard.dart';
import 'hub_setup_screen.dart';

class HubScreen extends StatelessWidget {
  const HubScreen({required this.authService, required this.user, super.key});

  final AuthService authService;
  final User user;

  @override
  Widget build(BuildContext context) {
    final itemRepository = FirestoreHubItemRepository(userId: user.uid);
    final settingsRepository = FirestoreAppSettingsRepository(userId: user.uid);

    return _HubHome(
      itemRepository: itemRepository,
      settingsRepository: settingsRepository,
      signedInEmail: user.email,
      onSignOut: authService.signOut,
    );
  }
}

class _HubHome extends StatelessWidget {
  const _HubHome({
    required this.itemRepository,
    required this.settingsRepository,
    required this.onSignOut,
    this.signedInEmail,
  });

  final FirestoreHubItemRepository itemRepository;
  final FirestoreAppSettingsRepository settingsRepository;
  final VoidCallback onSignOut;
  final String? signedInEmail;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AppSettings>(
      stream: settingsRepository.watchSettings(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return _SettingsErrorScreen(
            error: snapshot.error.toString(),
            onSignOut: onSignOut,
          );
        }

        final settings = snapshot.data ?? AppSettings.defaults();

        if (!settings.onboardingComplete) {
          return HubSetupScreen(
            repository: itemRepository,
            settingsRepository: settingsRepository,
            isOnboarding: true,
            onSignOut: onSignOut,
          );
        }

        return HubDashboard(
          repository: itemRepository,
          signedInEmail: signedInEmail,
          onSignOut: onSignOut,
          onAddReminders: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) {
                  return HubSetupScreen(
                    repository: itemRepository,
                    settingsRepository: settingsRepository,
                    isOnboarding: false,
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}

class _SettingsErrorScreen extends StatelessWidget {
  const _SettingsErrorScreen({required this.error, required this.onSignOut});

  final String error;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Life Hub'),
        actions: [
          IconButton(
            tooltip: 'Sign out',
            onPressed: onSignOut,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 56,
                  color: theme.colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  'Could not load settings',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  error,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
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
