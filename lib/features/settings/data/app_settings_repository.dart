import '../domain/app_settings.dart';

abstract interface class AppSettingsRepository {
  Stream<AppSettings> watchSettings();

  Future<void> completeOnboarding();

  Future<void> updateThemeMode(AppThemePreference themeMode);

  Future<void> updateNotificationPreferences({
    required bool notificationsEnabled,
    required int notificationHour,
    required int notificationDueSoonDays,
    required int quietHoursStartHour,
    required int quietHoursEndHour,
  });

  Future<void> deleteSettings();
}
