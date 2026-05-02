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
        'themeMode': 'system',
        'notificationsEnabled': false,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (!snapshot.exists) {
        data['createdAt'] = FieldValue.serverTimestamp();
      }

      transaction.set(_document, data, SetOptions(merge: true));
    });
  }
}
