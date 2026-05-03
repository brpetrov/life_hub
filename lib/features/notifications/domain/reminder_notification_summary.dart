import '../../hub/domain/hub_item.dart';

class ReminderNotificationSummary {
  const ReminderNotificationSummary({
    required this.overdueCount,
    required this.dueTodayCount,
    required this.dueSoonCount,
  });

  factory ReminderNotificationSummary.fromItems(
    Iterable<HubItem> items, {
    DateTime? now,
    int dueSoonDays = 7,
  }) {
    final today = _dateOnly(now ?? DateTime.now());
    final dueSoonEnd = today.add(Duration(days: dueSoonDays));
    var overdueCount = 0;
    var dueTodayCount = 0;
    var dueSoonCount = 0;

    for (final item in items) {
      final nextDueDate = item.nextDueDate;

      if (nextDueDate == null || item.notificationsMuted) {
        continue;
      }

      final dueDate = _dateOnly(nextDueDate);

      if (dueDate.isBefore(today)) {
        overdueCount++;
      } else if (dueDate == today) {
        dueTodayCount++;
      } else if (!dueDate.isAfter(dueSoonEnd)) {
        dueSoonCount++;
      }
    }

    return ReminderNotificationSummary(
      overdueCount: overdueCount,
      dueTodayCount: dueTodayCount,
      dueSoonCount: dueSoonCount,
    );
  }

  final int overdueCount;
  final int dueTodayCount;
  final int dueSoonCount;

  int get totalCount => overdueCount + dueTodayCount + dueSoonCount;

  bool get hasItems => totalCount > 0;

  String get title {
    return totalCount == 1
        ? '1 reminder needs attention'
        : '$totalCount reminders need attention';
  }

  String get body {
    final parts = [
      if (overdueCount > 0) _countText(overdueCount, 'overdue'),
      if (dueTodayCount > 0) _countText(dueTodayCount, 'due today'),
      if (dueSoonCount > 0) _countText(dueSoonCount, 'due soon'),
    ];

    return parts.join(', ');
  }

  static DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  static String _countText(int count, String label) {
    return '$count $label';
  }
}
