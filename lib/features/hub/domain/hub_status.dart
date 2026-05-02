enum HubStatus {
  overdue('Overdue', 0),
  dueSoon('Due soon', 1),
  upcoming('Upcoming', 2),
  ok('OK', 3),
  unknown('No date', 4);

  const HubStatus(this.label, this.sortOrder);

  final String label;
  final int sortOrder;

  static HubStatus fromDueDate(DateTime? nextDueDate, {DateTime? now}) {
    if (nextDueDate == null) {
      return HubStatus.unknown;
    }

    final today = _dateOnly(now ?? DateTime.now());
    final dueDate = _dateOnly(nextDueDate);
    final daysUntilDue = dueDate.difference(today).inDays;

    if (daysUntilDue < 0) {
      return HubStatus.overdue;
    }

    if (daysUntilDue <= 30) {
      return HubStatus.dueSoon;
    }

    if (daysUntilDue <= 90) {
      return HubStatus.upcoming;
    }

    return HubStatus.ok;
  }

  static int compare(HubStatus left, HubStatus right) {
    return left.sortOrder.compareTo(right.sortOrder);
  }

  static DateTime _dateOnly(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }
}
