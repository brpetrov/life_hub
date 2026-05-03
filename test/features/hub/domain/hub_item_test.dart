import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_hub/features/hub/domain/frequency.dart';
import 'package:life_hub/features/hub/domain/hub_category.dart';
import 'package:life_hub/features/hub/domain/hub_item.dart';
import 'package:life_hub/features/hub/domain/hub_status.dart';

void main() {
  group('HubItem', () {
    test('parses Firestore timestamps and current ISO date strings', () {
      final item = HubItem.fromFirestore('item-1', {
        'name': 'Boiler service',
        'category': 'home',
        'description': 'Annual service',
        'frequencyMonths': 12,
        'lastDoneDate': '2025-05-02T09:00:00.000',
        'nextDueDate': Timestamp.fromDate(DateTime(2026, 5, 2)),
        'source': 'preset',
        'presetId': 'home-boiler-service',
        'notificationsMuted': true,
        'archived': false,
        'createdAt': Timestamp.fromDate(DateTime(2026, 1, 1)),
        'updatedAt': Timestamp.fromDate(DateTime(2026, 1, 2)),
      });

      expect(item.id, 'item-1');
      expect(item.category, HubCategory.home);
      expect(item.frequency.months, 12);
      expect(item.source, HubItemSource.preset);
      expect(item.presetId, 'home-boiler-service');
      expect(item.notificationsMuted, isTrue);
      expect(item.lastDoneDate, DateTime(2025, 5, 2, 9));
      expect(item.nextDueDate, DateTime(2026, 5, 2));
    });

    test('serializes date fields as Firestore timestamps', () {
      final item = HubItem(
        id: 'item-1',
        name: ' Dental checkup ',
        category: HubCategory.health,
        description: ' Book appointment ',
        frequency: const Frequency(6),
        source: HubItemSource.custom,
        lastDoneDate: DateTime(2026, 1, 1),
        nextDueDate: DateTime(2026, 7, 1),
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 2),
      );

      final data = item.toFirestore();

      expect(data['name'], 'Dental checkup');
      expect(data['description'], 'Book appointment');
      expect(data['category'], 'health');
      expect(data['frequencyMonths'], 6);
      expect(data['notificationsMuted'], isFalse);
      expect(data['lastDoneDate'], isA<Timestamp>());
      expect(data['nextDueDate'], isA<Timestamp>());
      expect(data['createdAt'], isA<Timestamp>());
      expect(data['updatedAt'], isA<Timestamp>());
    });

    test('calculates status from next due date', () {
      final item = HubItem(
        id: 'item-1',
        name: 'Passport renewal',
        category: HubCategory.documents,
        description: 'Check expiry',
        frequency: const Frequency(120),
        source: HubItemSource.preset,
        nextDueDate: DateTime(2026, 5, 1),
      );

      expect(item.status(now: DateTime(2026, 5, 2)), HubStatus.overdue);
    });

    test('mark done updates completion and rolls the next due date', () {
      final item = HubItem(
        id: 'item-1',
        name: 'Device backup',
        category: HubCategory.tech,
        description: 'Back up files',
        frequency: const Frequency(1),
        source: HubItemSource.preset,
        nextDueDate: DateTime(2026, 5, 2),
      );

      final completedAt = DateTime(2026, 5, 31, 18);
      final updated = item.markDone(completedAt);

      expect(updated.lastDoneDate, completedAt);
      expect(updated.nextDueDate, DateTime(2026, 6, 30, 18));
      expect(updated.updatedAt, completedAt);
    });
  });
}
