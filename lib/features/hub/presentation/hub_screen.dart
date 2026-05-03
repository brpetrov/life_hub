import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../app/app_theme.dart';
import '../../auth/auth_service.dart';
import '../../settings/data/firestore_app_settings_repository.dart';
import '../../settings/domain/app_settings.dart';
import '../../settings/presentation/settings_screen.dart';
import '../data/firestore_hub_item_repository.dart';
import '../../notifications/data/local_reminder_notification_scheduler.dart';
import '../../notifications/data/reminder_notification_scheduler.dart';
import '../../notifications/presentation/reminder_notification_sync.dart';
import 'hub_dashboard.dart';
import 'hub_setup_screen.dart';

class HubScreen extends StatelessWidget {
  HubScreen({
    required this.authService,
    required this.user,
    ReminderNotificationScheduler? notificationScheduler,
    this.onThemeModeChanged,
    super.key,
  }) : notificationScheduler =
           notificationScheduler ?? LocalReminderNotificationScheduler();

  final AuthService authService;
  final User user;
  final ReminderNotificationScheduler notificationScheduler;
  final ValueChanged<ThemeMode>? onThemeModeChanged;

  @override
  Widget build(BuildContext context) {
    final itemRepository = FirestoreHubItemRepository(userId: user.uid);
    final settingsRepository = FirestoreAppSettingsRepository(userId: user.uid);

    return _HubHome(
      itemRepository: itemRepository,
      settingsRepository: settingsRepository,
      notificationScheduler: notificationScheduler,
      signedInEmail: user.email,
      displayName: user.displayName,
      onSignOut: () {
        notificationScheduler.cancelDailySummary();
        authService.signOut();
      },
      onThemeModeChanged: onThemeModeChanged,
      onDeleteAccount: (password) async {
        await authService.reauthenticateWithPassword(password);
        await notificationScheduler.cancelDailySummary();
        await itemRepository.deleteAllItems();
        await settingsRepository.deleteSettings();
        await authService.deleteCurrentUser();
      },
    );
  }
}

class _HubHome extends StatelessWidget {
  const _HubHome({
    required this.itemRepository,
    required this.settingsRepository,
    required this.notificationScheduler,
    required this.onSignOut,
    required this.onDeleteAccount,
    this.onThemeModeChanged,
    this.signedInEmail,
    this.displayName,
  });

  final FirestoreHubItemRepository itemRepository;
  final FirestoreAppSettingsRepository settingsRepository;
  final ReminderNotificationScheduler notificationScheduler;
  final VoidCallback onSignOut;
  final Future<void> Function(String password) onDeleteAccount;
  final ValueChanged<ThemeMode>? onThemeModeChanged;
  final String? signedInEmail;
  final String? displayName;

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
          return _ThemeModeSync(
            themeMode: settings.themeMode.materialThemeMode,
            onThemeModeChanged: onThemeModeChanged,
            child: HubSetupScreen(
              repository: itemRepository,
              settingsRepository: settingsRepository,
              isOnboarding: true,
              onSignOut: onSignOut,
            ),
          );
        }

        return _ThemeModeSync(
          themeMode: settings.themeMode.materialThemeMode,
          onThemeModeChanged: onThemeModeChanged,
          child: ReminderNotificationSync(
            settings: settings,
            itemRepository: itemRepository,
            scheduler: notificationScheduler,
            child: HubDashboard(
              repository: itemRepository,
              signedInEmail: signedInEmail,
              onSignOut: onSignOut,
              onOpenSettings: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) {
                      return SettingsScreen(
                        settings: settings,
                        settingsRepository: settingsRepository,
                        itemRepository: itemRepository,
                        notificationScheduler: notificationScheduler,
                        signedInEmail: signedInEmail,
                        displayName: displayName,
                        onDeleteAccount: onDeleteAccount,
                      );
                    },
                  ),
                );
              },
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
            ),
          ),
        );
      },
    );
  }
}

class _ThemeModeSync extends StatefulWidget {
  const _ThemeModeSync({
    required this.themeMode,
    required this.child,
    this.onThemeModeChanged,
  });

  final ThemeMode themeMode;
  final Widget child;
  final ValueChanged<ThemeMode>? onThemeModeChanged;

  @override
  State<_ThemeModeSync> createState() => _ThemeModeSyncState();
}

class _ThemeModeSyncState extends State<_ThemeModeSync> {
  @override
  void initState() {
    super.initState();
    _syncThemeMode();
  }

  @override
  void didUpdateWidget(covariant _ThemeModeSync oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.themeMode != widget.themeMode) {
      _syncThemeMode();
    }
  }

  void _syncThemeMode() {
    final callback = widget.onThemeModeChanged;

    if (callback == null) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      callback(widget.themeMode);
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
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
