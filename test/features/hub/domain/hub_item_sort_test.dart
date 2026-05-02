import 'package:flutter_test/flutter_test.dart';
import 'package:life_hub/features/hub/domain/frequency.dart';
import 'package:life_hub/features/hub/domain/hub_category.dart';
import 'package:life_hub/features/hub/domain/hub_item.dart';
import 'package:life_hub/features/hub/domain/hub_item_sort.dart';

void main() {
  group('HubItemSort', () {
    test('sorts items by dashboard priority', () {
      final now = DateTime(2026, 5, 2);
      final items = [
        _item('unknown', 'Unknown', null),
        _item('ok', 'OK', DateTime(2026, 9, 1)),
        _item('due-soon', 'Due soon', DateTime(2026, 5, 20)),
        _item('upcoming', 'Upcoming', DateTime(2026, 6, 15)),
        _item('overdue', 'Overdue', DateTime(2026, 5, 1)),
      ];

      final sorted = HubItemSort.sortedByDashboardPriority(items, now: now);

      expect(sorted.map((item) => item.id), [
        'overdue',
        'due-soon',
        'upcoming',
        'ok',
        'unknown',
      ]);
    });

    test('sorts matching statuses by due date, then name', () {
      final now = DateTime(2026, 5, 2);
      final items = [
        _item('second-alpha', 'Alpha', DateTime(2026, 5, 10)),
        _item('first', 'Beta', DateTime(2026, 5, 5)),
        _item('second-beta', 'Beta', DateTime(2026, 5, 10)),
      ];

      final sorted = HubItemSort.sortedByDashboardPriority(items, now: now);

      expect(sorted.map((item) => item.id), [
        'first',
        'second-alpha',
        'second-beta',
      ]);
    });
  });
}

HubItem _item(String id, String name, DateTime? nextDueDate) {
  return HubItem(
    id: id,
    name: name,
    category: HubCategory.custom,
    description: '',
    frequency: const Frequency(1),
    source: HubItemSource.custom,
    nextDueDate: nextDueDate,
  );
}
