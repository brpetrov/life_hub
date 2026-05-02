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

      expect(grouped[HubCategory.car], isNotEmpty);
      expect(grouped[HubCategory.home], isNotEmpty);
      expect(grouped[HubCategory.health], isNotEmpty);
      expect(grouped[HubCategory.tech], isNotEmpty);
      expect(grouped[HubCategory.pets], isNotEmpty);
      expect(grouped[HubCategory.documents], isNotEmpty);
      expect(grouped[HubCategory.seasonal], isNotEmpty);
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
