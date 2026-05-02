import 'package:cloud_firestore/cloud_firestore.dart';

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
      themeMode: 'system',
      notificationsEnabled: false,
    );
  }

  factory AppSettings.fromFirestore(Map<String, dynamic>? data) {
    if (data == null) {
      return AppSettings.defaults();
    }

    return AppSettings(
      onboardingComplete: data['onboardingComplete'] == true,
      themeMode: data['themeMode']?.toString() ?? 'system',
      notificationsEnabled: data['notificationsEnabled'] == true,
      createdAt: _dateFromFirestore(data['createdAt']),
      updatedAt: _dateFromFirestore(data['updatedAt']),
    );
  }

  final bool onboardingComplete;
  final String themeMode;
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
