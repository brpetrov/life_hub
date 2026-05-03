import 'package:flutter_test/flutter_test.dart';
import 'package:life_hub/features/hub/domain/frequency.dart';
import 'package:life_hub/features/hub/domain/hub_category.dart';
import 'package:life_hub/features/hub/domain/hub_item.dart';
import 'package:life_hub/features/notifications/domain/reminder_notification_summary.dart';

void main() {
  group('ReminderNotificationSummary', () {
    test('counts overdue, due today, and due soon reminders', () {
      final summary = ReminderNotificationSummary.fromItems(
        [
          _item('overdue', DateTime(2026, 5, 2)),
          _item('today', DateTime(2026, 5, 3)),
          _item('soon', DateTime(2026, 5, 10)),
          _item('later', DateTime(2026, 5, 12)),
        ],
        now: DateTime(2026, 5, 3, 14),
        dueSoonDays: 7,
      );

      expect(summary.overdueCount, 1);
      expect(summary.dueTodayCount, 1);
      expect(summary.dueSoonCount, 1);
      expect(summary.totalCount, 3);
      expect(summary.title, '3 reminders need attention');
      expect(summary.body, '1 overdue, 1 due today, 1 due soon');
    });

    test('ignores reminders without due dates and muted reminders', () {
      final summary = ReminderNotificationSummary.fromItems([
        _item('no-date', null),
        _item('muted', DateTime(2026, 5, 3), notificationsMuted: true),
      ], now: DateTime(2026, 5, 3));

      expect(summary.hasItems, isFalse);
      expect(summary.totalCount, 0);
    });
  });
}

HubItem _item(
  String id,
  DateTime? nextDueDate, {
  bool notificationsMuted = false,
}) {
  return HubItem(
    id: id,
    name: id,
    category: HubCategory.custom,
    description: '',
    frequency: const Frequency(12),
    source: HubItemSource.custom,
    nextDueDate: nextDueDate,
    notificationsMuted: notificationsMuted,
  );
}
