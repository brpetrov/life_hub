import 'package:flutter/material.dart';

import '../domain/hub_item.dart';
import 'hub_date_format.dart';

class HubItemDetailsSheet extends StatelessWidget {
  const HubItemDetailsSheet({
    required this.item,
    required this.onEdit,
    required this.onSetDueDate,
    required this.onMarkDone,
    required this.onToggleNotificationsMuted,
    required this.onDelete,
    super.key,
  });

  final HubItem item;
  final VoidCallback onEdit;
  final VoidCallback onSetDueDate;
  final VoidCallback onMarkDone;
  final VoidCallback onToggleNotificationsMuted;
  final VoidCallback onDelete;

  static Future<void> show(
    BuildContext context, {
    required HubItem item,
    required VoidCallback onEdit,
    required VoidCallback onSetDueDate,
    required VoidCallback onMarkDone,
    required VoidCallback onToggleNotificationsMuted,
    required VoidCallback onDelete,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) {
        return HubItemDetailsSheet(
          item: item,
          onEdit: () {
            Navigator.of(sheetContext).pop();
            onEdit();
          },
          onSetDueDate: () {
            Navigator.of(sheetContext).pop();
            onSetDueDate();
          },
          onMarkDone: () {
            Navigator.of(sheetContext).pop();
            onMarkDone();
          },
          onToggleNotificationsMuted: () {
            Navigator.of(sheetContext).pop();
            onToggleNotificationsMuted();
          },
          onDelete: () {
            Navigator.of(sheetContext).pop();
            onDelete();
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          0,
          24,
          24 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.name,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              item.description.isEmpty ? 'No description' : item.description,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            _DetailRow(label: 'Status', value: item.status().label),
            _DetailRow(label: 'Category', value: item.category.label),
            _DetailRow(label: 'Frequency', value: item.frequency.label),
            _DetailRow(
              label: 'Next due',
              value: _formatOptionalDate(item.nextDueDate),
            ),
            _DetailRow(
              label: 'Last done',
              value: _formatOptionalDate(item.lastDoneDate),
            ),
            _DetailRow(
              label: 'Alerts',
              value: item.notificationsMuted ? 'Muted' : 'Enabled',
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.end,
              children: [
                FilledButton.icon(
                  onPressed: onMarkDone,
                  icon: const Icon(Icons.check),
                  label: const Text('Mark done'),
                ),
                OutlinedButton.icon(
                  onPressed: onSetDueDate,
                  icon: const Icon(Icons.event_outlined),
                  label: const Text('Due date'),
                ),
                OutlinedButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Edit'),
                ),
                OutlinedButton.icon(
                  onPressed: onToggleNotificationsMuted,
                  icon: Icon(
                    item.notificationsMuted
                        ? Icons.notifications_active_outlined
                        : Icons.notifications_off_outlined,
                  ),
                  label: Text(item.notificationsMuted ? 'Unmute' : 'Mute'),
                ),
                TextButton.icon(
                  style: TextButton.styleFrom(
                    foregroundColor: theme.colorScheme.error,
                  ),
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Delete'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatOptionalDate(DateTime? date) {
    return date == null ? 'Not set' : HubDateFormat.short(date);
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 96,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
