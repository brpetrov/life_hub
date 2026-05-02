import 'package:flutter_test/flutter_test.dart';
import 'package:life_hub/features/hub/domain/hub_category.dart';

void main() {
  group('HubCategory parsing', () {
    test('parses stored enum values and display labels', () {
      expect(HubCategory.fromValue('car'), HubCategory.car);
      expect(HubCategory.fromValue('Home'), HubCategory.home);
      expect(HubCategory.fromValue('health'), HubCategory.health);
      expect(HubCategory.fromValue('Tech'), HubCategory.tech);
      expect(HubCategory.fromValue('Pets'), HubCategory.pets);
      expect(HubCategory.fromValue('documents'), HubCategory.documents);
      expect(HubCategory.fromValue('Seasonal'), HubCategory.seasonal);
    });

    test('parses simple aliases', () {
      expect(HubCategory.fromValue('vehicle'), HubCategory.car);
      expect(HubCategory.fromValue('paperwork'), HubCategory.documents);
      expect(HubCategory.fromValue('technology'), HubCategory.tech);
      expect(HubCategory.fromValue('other'), HubCategory.custom);
    });

    test('falls back to custom for unknown values', () {
      expect(HubCategory.fromValue(null), HubCategory.custom);
      expect(HubCategory.fromValue(''), HubCategory.custom);
      expect(HubCategory.fromValue('not-a-real-category'), HubCategory.custom);
    });
  });
}
