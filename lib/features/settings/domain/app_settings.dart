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
    required this.notificationHour,
    required this.notificationDueSoonDays,
    required this.quietHoursStartHour,
    required this.quietHoursEndHour,
    this.createdAt,
    this.updatedAt,
  });

  static const defaultNotificationHour = 9;
  static const defaultNotificationDueSoonDays = 7;
  static const defaultQuietHoursStartHour = 22;
  static const defaultQuietHoursEndHour = 7;

  factory AppSettings.defaults() {
    return const AppSettings(
      onboardingComplete: false,
      themeMode: AppThemePreference.system,
      notificationsEnabled: false,
      notificationHour: defaultNotificationHour,
      notificationDueSoonDays: defaultNotificationDueSoonDays,
      quietHoursStartHour: defaultQuietHoursStartHour,
      quietHoursEndHour: defaultQuietHoursEndHour,
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
      notificationHour: _intInRange(
        data['notificationHour'],
        min: 0,
        max: 23,
        fallback: defaultNotificationHour,
      ),
      notificationDueSoonDays: _intInRange(
        data['notificationDueSoonDays'],
        min: 1,
        max: 30,
        fallback: defaultNotificationDueSoonDays,
      ),
      quietHoursStartHour: _intInRange(
        data['quietHoursStartHour'],
        min: 0,
        max: 23,
        fallback: defaultQuietHoursStartHour,
      ),
      quietHoursEndHour: _intInRange(
        data['quietHoursEndHour'],
        min: 0,
        max: 23,
        fallback: defaultQuietHoursEndHour,
      ),
      createdAt: _dateFromFirestore(data['createdAt']),
      updatedAt: _dateFromFirestore(data['updatedAt']),
    );
  }

  final bool onboardingComplete;
  final AppThemePreference themeMode;
  final bool notificationsEnabled;
  final int notificationHour;
  final int notificationDueSoonDays;
  final int quietHoursStartHour;
  final int quietHoursEndHour;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  AppSettings copyWith({
    bool? onboardingComplete,
    AppThemePreference? themeMode,
    bool? notificationsEnabled,
    int? notificationHour,
    int? notificationDueSoonDays,
    int? quietHoursStartHour,
    int? quietHoursEndHour,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AppSettings(
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
      themeMode: themeMode ?? this.themeMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      notificationHour: notificationHour ?? this.notificationHour,
      notificationDueSoonDays:
          notificationDueSoonDays ?? this.notificationDueSoonDays,
      quietHoursStartHour: quietHoursStartHour ?? this.quietHoursStartHour,
      quietHoursEndHour: quietHoursEndHour ?? this.quietHoursEndHour,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static DateTime? _dateFromFirestore(Object? value) {
    return switch (value) {
      Timestamp() => value.toDate(),
      DateTime() => value,
      String() => DateTime.tryParse(value),
      _ => null,
    };
  }

  static int _intInRange(
    Object? value, {
    required int min,
    required int max,
    required int fallback,
  }) {
    final parsed = switch (value) {
      int() => value,
      num() => value.round(),
      String() => int.tryParse(value.trim()),
      _ => null,
    };

    if (parsed == null || parsed < min || parsed > max) {
      return fallback;
    }

    return parsed;
  }
}
