import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:life_hub/app/app_theme.dart';
import 'package:life_hub/features/hub/data/hub_item_repository.dart';
import 'package:life_hub/features/hub/domain/hub_item.dart';
import 'package:life_hub/features/hub/presentation/hub_setup_screen.dart';
import 'package:life_hub/features/settings/data/app_settings_repository.dart';
import 'package:life_hub/features/settings/domain/app_settings.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('saves selected presets and completes onboarding', (
    tester,
  ) async {
    final repository = _FakeHubItemRepository();
    final settingsRepository = _FakeAppSettingsRepository();

    await tester.pumpSetupScreen(
      repository: repository,
      settingsRepository: settingsRepository,
    );

    expect(
      tester.widget<FilledButton>(findSaveSetupButton()).onPressed,
      isNull,
    );

    await tester.tap(find.text('MOT'));
    await tester.pumpAndSettle();

    expect(
      tester.widget<FilledButton>(findSaveSetupButton()).onPressed,
      isNotNull,
    );

    await tester.tap(find.text('Save setup'));
    await tester.pumpAndSettle();

    expect(repository.createdItems, hasLength(1));
    expect(repository.createdItems.single.name, 'MOT');
    expect(repository.createdItems.single.presetId, 'car-mot');
    expect(repository.createdItems.single.nextDueDate, isNull);
    expect(settingsRepository.completeOnboardingCalls, 1);
  });

  testWidgets('adds and saves a custom reminder without a due date', (
    tester,
  ) async {
    final repository = _FakeHubItemRepository();
    final settingsRepository = _FakeAppSettingsRepository();

    await tester.pumpSetupScreen(
      repository: repository,
      settingsRepository: settingsRepository,
    );

    await tester.tap(find.text('Custom reminder'));
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextFormField, 'Name'), 'Rates');
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Description'),
      'Review renewal.',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Add'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Save setup'));
    await tester.pumpAndSettle();

    expect(repository.createdItems, hasLength(1));
    expect(repository.createdItems.single.name, 'Rates');
    expect(repository.createdItems.single.source, HubItemSource.custom);
    expect(repository.createdItems.single.nextDueDate, isNull);
  });
}

Finder findSaveSetupButton() {
  return find.widgetWithText(FilledButton, 'Save setup');
}

extension on WidgetTester {
  Future<void> pumpSetupScreen({
    required HubItemRepository repository,
    required AppSettingsRepository settingsRepository,
  }) {
    return pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: HubSetupScreen(
          repository: repository,
          settingsRepository: settingsRepository,
          isOnboarding: true,
        ),
      ),
    );
  }
}

class _FakeHubItemRepository implements HubItemRepository {
  final List<HubItem> createdItems = [];

  @override
  Stream<List<HubItem>> watchItems() => Stream.value(const []);

  @override
  Future<List<HubItem>> fetchItems() async => createdItems;

  @override
  Future<void> createItem(HubItem item) async {
    createdItems.add(item);
  }

  @override
  Future<void> createItems(List<HubItem> items) async {
    createdItems.addAll(items);
  }

  @override
  Future<void> deleteItem(String id) async {}

  @override
  Future<void> deleteAllItems() async {
    createdItems.clear();
  }

  @override
  Future<void> markDone(HubItem item) async {}

  @override
  Future<void> updateItem(HubItem item) async {}
}

class _FakeAppSettingsRepository implements AppSettingsRepository {
  var completeOnboardingCalls = 0;

  @override
  Stream<AppSettings> watchSettings() => Stream.value(AppSettings.defaults());

  @override
  Future<void> completeOnboarding() async {
    completeOnboardingCalls++;
  }

  @override
  Future<void> updateThemeMode(AppThemePreference themeMode) async {}

  @override
  Future<void> deleteSettings() async {}
}
