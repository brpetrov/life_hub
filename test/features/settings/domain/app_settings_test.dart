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
    });

    test('parses stored settings', () {
      final settings = AppSettings.fromFirestore({
        'onboardingComplete': true,
        'themeMode': 'light',
        'notificationsEnabled': true,
        'createdAt': Timestamp.fromDate(DateTime(2026, 5, 2)),
      });

      expect(settings.onboardingComplete, isTrue);
      expect(settings.themeMode, AppThemePreference.light);
      expect(settings.notificationsEnabled, isTrue);
      expect(settings.createdAt, DateTime(2026, 5, 2));
    });

    test('falls back to system theme for unknown stored values', () {
      final settings = AppSettings.fromFirestore({'themeMode': 'neon'});

      expect(settings.themeMode, AppThemePreference.system);
    });
  });
}
