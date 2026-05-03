import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:life_hub/app/app_theme.dart';
import 'package:life_hub/features/hub/data/hub_item_repository.dart';
import 'package:life_hub/features/hub/domain/frequency.dart';
import 'package:life_hub/features/hub/domain/hub_category.dart';
import 'package:life_hub/features/hub/domain/hub_item.dart';
import 'package:life_hub/features/notifications/data/reminder_notification_scheduler.dart';
import 'package:life_hub/features/settings/data/app_settings_repository.dart';
import 'package:life_hub/features/settings/domain/app_settings.dart';
import 'package:life_hub/features/settings/presentation/settings_screen.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('updates the selected theme mode', (tester) async {
    final settingsRepository = _FakeAppSettingsRepository();

    await tester.pumpSettingsScreen(settingsRepository: settingsRepository);

    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();

    expect(settingsRepository.updatedThemeModes, [AppThemePreference.dark]);
  });

  testWidgets('enables reminder notifications after permission is granted', (
    tester,
  ) async {
    final settingsRepository = _FakeAppSettingsRepository();
    final scheduler = _FakeReminderNotificationScheduler();

    await tester.pumpSettingsScreen(
      settingsRepository: settingsRepository,
      notificationScheduler: scheduler,
    );

    await tester.tap(find.byType(Switch).first);
    await tester.pumpAndSettle();

    expect(scheduler.permissionRequestCount, 1);
    expect(settingsRepository.updatedNotificationPreferences, hasLength(1));
    expect(
      settingsRepository.updatedNotificationPreferences.single.enabled,
      isTrue,
    );
  });

  testWidgets('exports active reminders as JSON', (tester) async {
    await tester.pumpSettingsScreen(
      itemRepository: _FakeHubItemRepository(items: [_item]),
    );

    await tester.ensureVisible(find.text('Export reminders'));
    await tester.pump();
    await tester.tap(find.text('Export reminders'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Reminder export'), findsOneWidget);
    expect(find.textContaining('"name": "MOT"'), findsOneWidget);
    expect(find.textContaining('"category": "car"'), findsOneWidget);
  });

  testWidgets('asks for a password before deleting the account', (
    tester,
  ) async {
    String? deletedWithPassword;

    await tester.pumpSettingsScreen(
      onDeleteAccount: (password) async {
        deletedWithPassword = password;
      },
    );

    await tester.ensureVisible(find.text('Delete account').first);
    await tester.pump();
    await tester.tap(find.text('Delete account').first);
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Password'),
      'secret-password',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Delete account'));
    await tester.pumpAndSettle();

    expect(deletedWithPassword, 'secret-password');
  });
}

extension on WidgetTester {
  Future<void> pumpSettingsScreen({
    AppSettingsRepository? settingsRepository,
    HubItemRepository? itemRepository,
    ReminderNotificationScheduler? notificationScheduler,
    Future<void> Function(String password)? onDeleteAccount,
  }) {
    return pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        home: SettingsScreen(
          settings: AppSettings.defaults().copyWith(onboardingComplete: true),
          settingsRepository:
              settingsRepository ?? _FakeAppSettingsRepository(),
          itemRepository: itemRepository ?? _FakeHubItemRepository(),
          notificationScheduler:
              notificationScheduler ?? _FakeReminderNotificationScheduler(),
          signedInEmail: 'test@example.com',
          displayName: 'Test User',
          onDeleteAccount: onDeleteAccount ?? (_) async {},
        ),
      ),
    );
  }
}

class _FakeAppSettingsRepository implements AppSettingsRepository {
  final List<AppThemePreference> updatedThemeModes = [];
  final List<_NotificationPreferences> updatedNotificationPreferences = [];
  var completeOnboardingCalls = 0;
  var deleteSettingsCalls = 0;

  @override
  Stream<AppSettings> watchSettings() => Stream.value(AppSettings.defaults());

  @override
  Future<void> completeOnboarding() async {
    completeOnboardingCalls++;
  }

  @override
  Future<void> updateThemeMode(AppThemePreference themeMode) async {
    updatedThemeModes.add(themeMode);
  }

  @override
  Future<void> updateNotificationPreferences({
    required bool notificationsEnabled,
    required int notificationHour,
    required int notificationDueSoonDays,
    required int quietHoursStartHour,
    required int quietHoursEndHour,
  }) async {
    updatedNotificationPreferences.add(
      _NotificationPreferences(
        enabled: notificationsEnabled,
        hour: notificationHour,
        dueSoonDays: notificationDueSoonDays,
        quietStart: quietHoursStartHour,
        quietEnd: quietHoursEndHour,
      ),
    );
  }

  @override
  Future<void> deleteSettings() async {
    deleteSettingsCalls++;
  }
}

class _NotificationPreferences {
  const _NotificationPreferences({
    required this.enabled,
    required this.hour,
    required this.dueSoonDays,
    required this.quietStart,
    required this.quietEnd,
  });

  final bool enabled;
  final int hour;
  final int dueSoonDays;
  final int quietStart;
  final int quietEnd;
}

class _FakeReminderNotificationScheduler
    implements ReminderNotificationScheduler {
  var permissionRequestCount = 0;
  var cancelDailySummaryCount = 0;
  var permissionGranted = true;

  @override
  Future<bool> requestPermissions() async {
    permissionRequestCount++;
    return permissionGranted;
  }

  @override
  Future<void> syncDailySummary({
    required AppSettings settings,
    required List<HubItem> items,
  }) async {}

  @override
  Future<void> cancelDailySummary() async {
    cancelDailySummaryCount++;
  }
}

class _FakeHubItemRepository implements HubItemRepository {
  _FakeHubItemRepository({this.items = const []});

  final List<HubItem> items;
  final List<String> deletedIds = [];
  var deleteAllItemsCalls = 0;

  @override
  Stream<List<HubItem>> watchItems() => Stream.value(items);

  @override
  Future<List<HubItem>> fetchItems() async => items;

  @override
  Future<void> createItem(HubItem item) async {}

  @override
  Future<void> createItems(List<HubItem> items) async {}

  @override
  Future<void> updateItem(HubItem item) async {}

  @override
  Future<void> markDone(HubItem item) async {}

  @override
  Future<void> deleteItem(String id) async {
    deletedIds.add(id);
  }

  @override
  Future<void> deleteAllItems() async {
    deleteAllItemsCalls++;
  }
}

final _item = HubItem(
  id: 'mot',
  name: 'MOT',
  category: HubCategory.car,
  description: 'Book annual MOT.',
  frequency: const Frequency(12),
  source: HubItemSource.preset,
  presetId: 'car-mot',
  nextDueDate: DateTime(2026, 5, 10),
);
