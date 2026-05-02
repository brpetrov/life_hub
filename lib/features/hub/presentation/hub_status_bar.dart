import 'package:flutter/material.dart';

import '../domain/hub_item.dart';
import '../domain/hub_status.dart';
import 'hub_status_style.dart';

class HubStatusBar extends StatelessWidget {
  const HubStatusBar({required this.items, super.key});

  final List<HubItem> items;

  @override
  Widget build(BuildContext context) {
    final counts = {
      for (final status in HubStatus.values)
        status: items.where((item) => item.status() == status).length,
    };

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final status in HubStatus.values)
          _StatusSummaryPill(status: status, count: counts[status] ?? 0),
      ],
    );
  }
}

class _StatusSummaryPill extends StatelessWidget {
  const _StatusSummaryPill({required this.status, required this.count});

  final HubStatus status;
  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = HubStatusStyle.of(context, status);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: style.background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Text(
          '${status.label} $count',
          style: theme.textTheme.labelLarge?.copyWith(
            color: style.foreground,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
