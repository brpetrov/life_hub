import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:life_hub/app/app_theme.dart';
import 'package:life_hub/features/hub/data/hub_item_repository.dart';
import 'package:life_hub/features/hub/domain/frequency.dart';
import 'package:life_hub/features/hub/domain/hub_category.dart';
import 'package:life_hub/features/hub/domain/hub_item.dart';
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

  testWidgets('exports active reminders as JSON', (tester) async {
    await tester.pumpSettingsScreen(
      itemRepository: _FakeHubItemRepository(items: [_item]),
    );

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
    Future<void> Function(String password)? onDeleteAccount,
  }) {
    return pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        home: SettingsScreen(
          settings: AppSettings.defaults().copyWithForTest(
            onboardingComplete: true,
          ),
          settingsRepository:
              settingsRepository ?? _FakeAppSettingsRepository(),
          itemRepository: itemRepository ?? _FakeHubItemRepository(),
          signedInEmail: 'test@example.com',
          displayName: 'Test User',
          onDeleteAccount: onDeleteAccount ?? (_) async {},
        ),
      ),
    );
  }
}

extension on AppSettings {
  AppSettings copyWithForTest({
    bool? onboardingComplete,
    AppThemePreference? themeMode,
    bool? notificationsEnabled,
  }) {
    return AppSettings(
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
      themeMode: themeMode ?? this.themeMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

class _FakeAppSettingsRepository implements AppSettingsRepository {
  final List<AppThemePreference> updatedThemeModes = [];
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
  Future<void> deleteSettings() async {
    deleteSettingsCalls++;
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
