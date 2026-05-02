import 'package:flutter_test/flutter_test.dart';
import 'package:life_hub/features/hub/data/firestore_hub_item_repository.dart';

void main() {
  group('FirestoreHubItemRepository', () {
    test('requires a non-empty user id', () {
      expect(
        () => FirestoreHubItemRepository(userId: ' '),
        throwsArgumentError,
      );
    });
  });
}
