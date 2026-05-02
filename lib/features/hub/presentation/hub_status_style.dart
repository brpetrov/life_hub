import 'package:flutter/material.dart';

import '../domain/hub_status.dart';

class HubStatusStyle {
  const HubStatusStyle({required this.background, required this.foreground});

  final Color background;
  final Color foreground;

  static HubStatusStyle of(BuildContext context, HubStatus status) {
    final scheme = Theme.of(context).colorScheme;

    return switch (status) {
      HubStatus.overdue => HubStatusStyle(
        background: scheme.errorContainer,
        foreground: scheme.onErrorContainer,
      ),
      HubStatus.dueSoon => HubStatusStyle(
        background: scheme.tertiaryContainer,
        foreground: scheme.onTertiaryContainer,
      ),
      HubStatus.upcoming => HubStatusStyle(
        background: scheme.secondaryContainer,
        foreground: scheme.onSecondaryContainer,
      ),
      HubStatus.ok => HubStatusStyle(
        background: scheme.primaryContainer,
        foreground: scheme.onPrimaryContainer,
      ),
      HubStatus.unknown => HubStatusStyle(
        background: scheme.surfaceContainerHighest,
        foreground: scheme.onSurfaceVariant,
      ),
    };
  }
}
