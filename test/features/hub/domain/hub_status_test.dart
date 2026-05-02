import 'package:flutter_test/flutter_test.dart';
import 'package:life_hub/features/hub/domain/hub_status.dart';

void main() {
  group('HubStatus', () {
    final today = DateTime(2026, 5, 2, 14, 30);

    test('calculates unknown status without a due date', () {
      expect(HubStatus.fromDueDate(null, now: today), HubStatus.unknown);
    });

    test('calculates overdue status for dates before today', () {
      expect(
        HubStatus.fromDueDate(DateTime(2026, 5, 1), now: today),
        HubStatus.overdue,
      );
    });

    test('calculates due soon status for today through 30 days', () {
      expect(
        HubStatus.fromDueDate(DateTime(2026, 5, 2), now: today),
        HubStatus.dueSoon,
      );
      expect(
        HubStatus.fromDueDate(DateTime(2026, 6, 1), now: today),
        HubStatus.dueSoon,
      );
    });

    test('calculates upcoming status for 31 through 90 days', () {
      expect(
        HubStatus.fromDueDate(DateTime(2026, 6, 2), now: today),
        HubStatus.upcoming,
      );
      expect(
        HubStatus.fromDueDate(DateTime(2026, 7, 31), now: today),
        HubStatus.upcoming,
      );
    });

    test('calculates ok status after 90 days', () {
      expect(
        HubStatus.fromDueDate(DateTime(2026, 8, 1), now: today),
        HubStatus.ok,
      );
    });

    test('sorts in dashboard priority order', () {
      final statuses = [
        HubStatus.ok,
        HubStatus.unknown,
        HubStatus.upcoming,
        HubStatus.overdue,
        HubStatus.dueSoon,
      ]..sort(HubStatus.compare);

      expect(statuses, [
        HubStatus.overdue,
        HubStatus.dueSoon,
        HubStatus.upcoming,
        HubStatus.ok,
        HubStatus.unknown,
      ]);
    });
  });
}
