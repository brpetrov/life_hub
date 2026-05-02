class Frequency {
  const Frequency(this.months) : assert(months >= 0);

  final int months;

  bool get repeats => months > 0;

  String get label => labelForMonths(months);

  DateTime? nextDueDateAfter(DateTime completedAt) {
    if (!repeats) {
      return null;
    }

    return addMonths(completedAt, months);
  }

  static String labelForMonths(int months) {
    if (months <= 0) {
      return 'No repeat';
    }

    if (months == 1) {
      return 'Monthly';
    }

    if (months == 12) {
      return 'Yearly';
    }

    if (months > 12 && months % 12 == 0) {
      final years = months ~/ 12;
      return 'Every $years years';
    }

    return 'Every $months months';
  }

  static DateTime addMonths(DateTime date, int months) {
    if (months < 0) {
      throw ArgumentError.value(months, 'months', 'Must not be negative.');
    }

    final monthIndex = date.month - 1 + months;
    final year = date.year + monthIndex ~/ 12;
    final month = monthIndex % 12 + 1;
    final day = date.day.clamp(1, _daysInMonth(year, month));

    if (date.isUtc) {
      return DateTime.utc(
        year,
        month,
        day,
        date.hour,
        date.minute,
        date.second,
        date.millisecond,
        date.microsecond,
      );
    }

    return DateTime(
      year,
      month,
      day,
      date.hour,
      date.minute,
      date.second,
      date.millisecond,
      date.microsecond,
    );
  }

  static int _daysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }
}
