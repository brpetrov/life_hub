import 'package:flutter/material.dart';

import '../domain/hub_category.dart';
import '../domain/hub_item.dart';

class HubCategoryFilterBar extends StatelessWidget {
  const HubCategoryFilterBar({
    required this.items,
    required this.selectedCategory,
    required this.onSelected,
    super.key,
  });

  final List<HubItem> items;
  final HubCategory? selectedCategory;
  final ValueChanged<HubCategory?> onSelected;

  @override
  Widget build(BuildContext context) {
    final counts = {
      for (final category in HubCategory.values)
        category: items.where((item) => item.category == category).length,
    };

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text('All ${items.length}'),
              selected: selectedCategory == null,
              onSelected: (_) => onSelected(null),
            ),
          ),
          for (final category in HubCategory.values)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text('${category.label} ${counts[category]}'),
                selected: selectedCategory == category,
                onSelected: (_) => onSelected(category),
              ),
            ),
        ],
      ),
    );
  }
}
