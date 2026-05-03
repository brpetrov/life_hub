import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_hub/features/settings/domain/app_settings.dart';

void main() {
  group('AppSettings', () {
    test('uses defaults when the settings document is missing', () {
      final settings = AppSettings.fromFirestore(null);

      expect(settings.onboardingComplete, isFalse);
      expect(settings.themeMode, AppThemePreference.system);
      expect(settings.notificationsEnabled, isFalse);
      expect(settings.notificationHour, 9);
      expect(settings.notificationDueSoonDays, 7);
      expect(settings.quietHoursStartHour, 22);
      expect(settings.quietHoursEndHour, 7);
    });

    test('parses stored settings', () {
      final settings = AppSettings.fromFirestore({
        'onboardingComplete': true,
        'themeMode': 'light',
        'notificationsEnabled': true,
        'notificationHour': 8,
        'notificationDueSoonDays': 14,
        'quietHoursStartHour': 21,
        'quietHoursEndHour': 6,
        'createdAt': Timestamp.fromDate(DateTime(2026, 5, 2)),
      });

      expect(settings.onboardingComplete, isTrue);
      expect(settings.themeMode, AppThemePreference.light);
      expect(settings.notificationsEnabled, isTrue);
      expect(settings.notificationHour, 8);
      expect(settings.notificationDueSoonDays, 14);
      expect(settings.quietHoursStartHour, 21);
      expect(settings.quietHoursEndHour, 6);
      expect(settings.createdAt, DateTime(2026, 5, 2));
    });

    test('falls back to system theme for unknown stored values', () {
      final settings = AppSettings.fromFirestore({'themeMode': 'neon'});

      expect(settings.themeMode, AppThemePreference.system);
    });

    test('falls back to notification defaults for invalid stored values', () {
      final settings = AppSettings.fromFirestore({
        'notificationHour': 24,
        'notificationDueSoonDays': 0,
        'quietHoursStartHour': -1,
        'quietHoursEndHour': 'late',
      });

      expect(settings.notificationHour, 9);
      expect(settings.notificationDueSoonDays, 7);
      expect(settings.quietHoursStartHour, 22);
      expect(settings.quietHoursEndHour, 7);
    });
  });
}
