import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/app_settings.dart';
import 'app_settings_repository.dart';

class FirestoreAppSettingsRepository implements AppSettingsRepository {
  factory FirestoreAppSettingsRepository({
    required String userId,
    FirebaseFirestore? firestore,
  }) {
    final trimmedUserId = userId.trim();

    if (trimmedUserId.isEmpty) {
      throw ArgumentError.value(userId, 'userId', 'Must not be empty.');
    }

    return FirestoreAppSettingsRepository._(
      firestore: firestore ?? FirebaseFirestore.instance,
      userId: trimmedUserId,
    );
  }

  FirestoreAppSettingsRepository._({
    required FirebaseFirestore firestore,
    required String userId,
  }) : _firestore = firestore,
       _userId = userId;

  static const _usersCollection = 'users';
  static const _settingsCollection = 'settings';
  static const _appDocument = 'app';

  final FirebaseFirestore _firestore;
  final String _userId;

  DocumentReference<Map<String, dynamic>> get _document {
    return _firestore
        .collection(_usersCollection)
        .doc(_userId)
        .collection(_settingsCollection)
        .doc(_appDocument);
  }

  @override
  Stream<AppSettings> watchSettings() {
    return _document.snapshots().map((snapshot) {
      return AppSettings.fromFirestore(snapshot.data());
    });
  }

  @override
  Future<void> completeOnboarding() async {
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(_document);
      final data = <String, dynamic>{
        'onboardingComplete': true,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (!snapshot.exists) {
        data['createdAt'] = FieldValue.serverTimestamp();
        data['themeMode'] = AppThemePreference.system.value;
        data['notificationsEnabled'] = false;
        data['notificationHour'] = AppSettings.defaultNotificationHour;
        data['notificationDueSoonDays'] =
            AppSettings.defaultNotificationDueSoonDays;
        data['quietHoursStartHour'] = AppSettings.defaultQuietHoursStartHour;
        data['quietHoursEndHour'] = AppSettings.defaultQuietHoursEndHour;
      }

      transaction.set(_document, data, SetOptions(merge: true));
    });
  }

  @override
  Future<void> updateThemeMode(AppThemePreference themeMode) async {
    await _document.set({
      'themeMode': themeMode.value,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  @override
  Future<void> updateNotificationPreferences({
    required bool notificationsEnabled,
    required int notificationHour,
    required int notificationDueSoonDays,
    required int quietHoursStartHour,
    required int quietHoursEndHour,
  }) async {
    await _document.set({
      'notificationsEnabled': notificationsEnabled,
      'notificationHour': notificationHour,
      'notificationDueSoonDays': notificationDueSoonDays,
      'quietHoursStartHour': quietHoursStartHour,
      'quietHoursEndHour': quietHoursEndHour,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  @override
  Future<void> deleteSettings() => _document.delete();
}
