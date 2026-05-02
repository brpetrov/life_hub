import 'hub_item.dart';
import 'hub_status.dart';

class HubItemSort {
  const HubItemSort._();

  static int byStatusDueDateAndName(
    HubItem left,
    HubItem right, {
    DateTime? now,
  }) {
    final statusCompare = HubStatus.compare(
      left.status(now: now),
      right.status(now: now),
    );

    if (statusCompare != 0) {
      return statusCompare;
    }

    final dueDateCompare = _compareNullableDates(
      left.nextDueDate,
      right.nextDueDate,
    );

    if (dueDateCompare != 0) {
      return dueDateCompare;
    }

    return left.name.toLowerCase().compareTo(right.name.toLowerCase());
  }

  static List<HubItem> sortedByDashboardPriority(
    Iterable<HubItem> items, {
    DateTime? now,
  }) {
    return items.toList()..sort((left, right) {
      return byStatusDueDateAndName(left, right, now: now);
    });
  }

  static int _compareNullableDates(DateTime? left, DateTime? right) {
    return switch ((left, right)) {
      (null, null) => 0,
      (null, _) => 1,
      (_, null) => -1,
      (final leftDate?, final rightDate?) => leftDate.compareTo(rightDate),
    };
  }
}
