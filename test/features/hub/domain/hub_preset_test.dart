import 'package:flutter_test/flutter_test.dart';
import 'package:life_hub/features/hub/domain/hub_category.dart';
import 'package:life_hub/features/hub/domain/hub_item.dart';
import 'package:life_hub/features/hub/domain/hub_preset.dart';

void main() {
  group('HubPreset', () {
    test('uses stable unique ids', () {
      final ids = HubPreset.all.map((preset) => preset.id).toList();

      expect(ids.toSet(), hasLength(ids.length));
      expect(ids, everyElement(isNot(isEmpty)));
    });

    test('groups presets by category', () {
      final grouped = HubPreset.groupedByCategory();

      expect(grouped[HubCategory.car], hasLength(7));
      expect(grouped[HubCategory.home], hasLength(15));
      expect(grouped[HubCategory.health], hasLength(6));
      expect(grouped[HubCategory.tech], hasLength(6));
      expect(grouped[HubCategory.pets], hasLength(5));
      expect(grouped[HubCategory.documents], hasLength(7));
      expect(grouped[HubCategory.seasonal], hasLength(4));
      expect(grouped[HubCategory.custom], isEmpty);
    });

    test('includes the core preset coverage from the plan', () {
      final names = HubPreset.all.map((preset) => preset.name).toSet();

      expect(names, contains('MOT'));
      expect(names, contains('Road Tax'));
      expect(names, contains('Windscreen Washer Fluid'));
      expect(names, contains('Energy Tariff Review'));
      expect(names, contains('Smoke Alarm / CO Detector Check'));
      expect(names, contains('NHS Prescription Prepayment Certificate'));
      expect(names, contains('Phone Contract Renewal'));
      expect(names, contains('Pet Vaccinations / Boosters'));
      expect(names, contains('Driving Licence Photo Renewal'));
      expect(names, contains('Pressure Wash Driveway / Patio'));
      expect(names, contains('Declutter & Charity Shop Run'));
      expect(names, contains('Washing Machine Clean'));
      expect(names, contains('Stopcock / Water Shutoff Check'));
      expect(names, contains('Medication / Repeat Prescription Review'));
      expect(names, contains('Microchip Details Check'));
      expect(names, contains('Emergency Contacts & Key Documents'));
    });

    test('keeps a focused preset list', () {
      expect(HubPreset.all, hasLength(50));
    });

    test('converts a preset into a hub item', () {
      final preset = HubPreset.all.first;
      final item = preset.toHubItem(itemId: 'item-1');

      expect(item.id, 'item-1');
      expect(item.name, preset.name);
      expect(item.source, HubItemSource.preset);
      expect(item.presetId, preset.id);
    });
  });
}
