import 'package:flutter_test/flutter_test.dart';
import 'package:life_hub/features/hub/domain/frequency.dart';

void main() {
  group('Frequency labels', () {
    test('formats common frequencies', () {
      expect(const Frequency(0).label, 'No repeat');
      expect(const Frequency(1).label, 'Monthly');
      expect(const Frequency(3).label, 'Every 3 months');
      expect(const Frequency(12).label, 'Yearly');
      expect(const Frequency(24).label, 'Every 2 years');
    });
  });

  group('Frequency due date rolling', () {
    test('adds months while preserving time', () {
      final start = DateTime(2026, 5, 2, 9, 30);

      expect(
        const Frequency(3).nextDueDateAfter(start),
        DateTime(2026, 8, 2, 9, 30),
      );
    });

    test('clamps to the last valid day of the target month', () {
      final start = DateTime(2026, 1, 31);

      expect(const Frequency(1).nextDueDateAfter(start), DateTime(2026, 2, 28));
    });

    test('returns no next date for one-off reminders', () {
      final start = DateTime(2026, 5, 2);

      expect(const Frequency(0).nextDueDateAfter(start), isNull);
    });
  });
}
