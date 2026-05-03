import '../domain/app_settings.dart';

abstract interface class AppSettingsRepository {
  Stream<AppSettings> watchSettings();

  Future<void> completeOnboarding();

  Future<void> updateThemeMode(AppThemePreference themeMode);

  Future<void> deleteSettings();
}
