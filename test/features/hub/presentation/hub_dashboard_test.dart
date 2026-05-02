import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:life_hub/app/app_theme.dart';
import 'package:life_hub/features/hub/data/hub_item_repository.dart';
import 'package:life_hub/features/hub/domain/frequency.dart';
import 'package:life_hub/features/hub/domain/hub_category.dart';
import 'package:life_hub/features/hub/domain/hub_item.dart';
import 'package:life_hub/features/hub/presentation/hub_dashboard.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('shows loading state before the stream emits', (tester) async {
    final controller = StreamController<List<HubItem>>();

    await tester.pumpDashboard(
      repository: _FakeHubItemRepository(controller.stream),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await controller.close();
  });

  testWidgets('shows empty state when there are no reminders', (tester) async {
    await tester.pumpDashboard(
      repository: _FakeHubItemRepository(Stream.value(const [])),
    );
    await tester.pump();

    expect(find.text('No reminders yet'), findsOneWidget);
    expect(find.text('Signed in as test@example.com.'), findsOneWidget);
    expect(find.text('Add reminders'), findsOneWidget);
  });

  testWidgets('shows an error state when the stream fails', (tester) async {
    await tester.pumpDashboard(
      repository: _FakeHubItemRepository(
        Stream<List<HubItem>>.error(Exception('permission-denied')),
      ),
    );
    await tester.pump();

    expect(find.text('Could not load reminders'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets('shows reminders and filters by category', (tester) async {
    await tester.pumpDashboard(
      repository: _FakeHubItemRepository(Stream.value(_items)),
    );
    await tester.pump();

    expect(find.text('Reminders'), findsOneWidget);
    expect(find.text('MOT'), findsOneWidget);
    expect(find.text('Boiler service'), findsOneWidget);

    await tester.tap(find.text('Home 1'));
    await tester.pumpAndSettle();

    expect(find.text('Boiler service'), findsOneWidget);
    expect(find.text('MOT'), findsNothing);
  });

  testWidgets('opens the item details sheet', (tester) async {
    await tester.pumpDashboard(
      repository: _FakeHubItemRepository(Stream.value(_items)),
    );
    await tester.pump();

    await tester.tap(find.text('MOT'));
    await tester.pumpAndSettle();

    expect(find.text('Status'), findsOneWidget);
    expect(find.text('Frequency'), findsOneWidget);
    expect(find.text('Next due'), findsOneWidget);
    expect(find.text('Close'), findsOneWidget);
  });
}

extension on WidgetTester {
  Future<void> pumpDashboard({required HubItemRepository repository}) {
    return pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: HubDashboard(
          repository: repository,
          signedInEmail: 'test@example.com',
          onSignOut: () {},
        ),
      ),
    );
  }
}

class _FakeHubItemRepository implements HubItemRepository {
  const _FakeHubItemRepository(this._items);

  final Stream<List<HubItem>> _items;

  @override
  Stream<List<HubItem>> watchItems() => _items;

  @override
  Future<void> createItem(HubItem item) => throw UnimplementedError();

  @override
  Future<void> createItems(List<HubItem> items) => throw UnimplementedError();

  @override
  Future<void> deleteItem(String id) => throw UnimplementedError();

  @override
  Future<void> markDone(HubItem item) => throw UnimplementedError();

  @override
  Future<void> updateItem(HubItem item) => throw UnimplementedError();
}

final _items = [
  HubItem(
    id: 'mot',
    name: 'MOT',
    category: HubCategory.car,
    description: 'Book annual MOT.',
    frequency: const Frequency(12),
    source: HubItemSource.preset,
    nextDueDate: DateTime(2026, 5, 10),
  ),
  HubItem(
    id: 'boiler',
    name: 'Boiler service',
    category: HubCategory.home,
    description: 'Book annual service.',
    frequency: const Frequency(12),
    source: HubItemSource.preset,
    nextDueDate: DateTime(2026, 7, 1),
  ),
];
