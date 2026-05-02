import 'package:flutter/material.dart';

import '../domain/hub_item.dart';
import '../domain/hub_status.dart';
import 'hub_date_format.dart';
import 'hub_status_style.dart';

class HubItemCard extends StatelessWidget {
  const HubItemCard({required this.item, required this.onTap, super.key});

  final HubItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final status = item.status();
    final dueDate = item.nextDueDate;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _Pill(label: item.category.label),
                  const Spacer(),
                  _StatusPill(status: status),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                item.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                item.description.isEmpty ? 'No description' : item.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  const Icon(Icons.event_outlined, size: 18),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      dueDate == null
                          ? 'No due date'
                          : 'Due ${HubDateFormat.short(dueDate)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    item.frequency.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Text(label, style: theme.textTheme.labelMedium),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});

  final HubStatus status;

  @override
  Widget build(BuildContext context) {
    final style = HubStatusStyle.of(context, status);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: style.background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Text(
          status.label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: style.foreground,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
