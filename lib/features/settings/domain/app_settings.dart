import 'package:cloud_firestore/cloud_firestore.dart';

enum AppThemePreference {
  system('system', 'System'),
  light('light', 'Light'),
  dark('dark', 'Dark');

  const AppThemePreference(this.value, this.label);

  final String value;
  final String label;

  static AppThemePreference fromValue(Object? value) {
    return switch (value?.toString().trim().toLowerCase()) {
      'light' => AppThemePreference.light,
      'dark' => AppThemePreference.dark,
      _ => AppThemePreference.system,
    };
  }
}

class AppSettings {
  const AppSettings({
    required this.onboardingComplete,
    required this.themeMode,
    required this.notificationsEnabled,
    this.createdAt,
    this.updatedAt,
  });

  factory AppSettings.defaults() {
    return const AppSettings(
      onboardingComplete: false,
      themeMode: AppThemePreference.system,
      notificationsEnabled: false,
    );
  }

  factory AppSettings.fromFirestore(Map<String, dynamic>? data) {
    if (data == null) {
      return AppSettings.defaults();
    }

    return AppSettings(
      onboardingComplete: data['onboardingComplete'] == true,
      themeMode: AppThemePreference.fromValue(data['themeMode']),
      notificationsEnabled: data['notificationsEnabled'] == true,
      createdAt: _dateFromFirestore(data['createdAt']),
      updatedAt: _dateFromFirestore(data['updatedAt']),
    );
  }

  final bool onboardingComplete;
  final AppThemePreference themeMode;
  final bool notificationsEnabled;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  static DateTime? _dateFromFirestore(Object? value) {
    return switch (value) {
      Timestamp() => value.toDate(),
      DateTime() => value,
      String() => DateTime.tryParse(value),
      _ => null,
    };
  }
}
