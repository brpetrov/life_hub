import 'dart:async';

import 'package:flutter/material.dart';

import '../../hub/data/hub_item_repository.dart';
import '../../hub/domain/hub_item.dart';
import '../../settings/domain/app_settings.dart';
import '../data/reminder_notification_scheduler.dart';

class ReminderNotificationSync extends StatefulWidget {
  const ReminderNotificationSync({
    required this.settings,
    required this.itemRepository,
    required this.scheduler,
    required this.child,
    super.key,
  });

  final AppSettings settings;
  final HubItemRepository itemRepository;
  final ReminderNotificationScheduler scheduler;
  final Widget child;

  @override
  State<ReminderNotificationSync> createState() =>
      _ReminderNotificationSyncState();
}

class _ReminderNotificationSyncState extends State<ReminderNotificationSync> {
  late Stream<List<HubItem>> _itemsStream;
  String? _lastSyncKey;

  @override
  void initState() {
    super.initState();
    _itemsStream = widget.itemRepository.watchItems();
  }

  @override
  void didUpdateWidget(covariant ReminderNotificationSync oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.itemRepository != widget.itemRepository) {
      _itemsStream = widget.itemRepository.watchItems();
      _lastSyncKey = null;
    }

    if (oldWidget.settings != widget.settings) {
      _lastSyncKey = null;
    }
  }

  void _queueSync(List<HubItem> items) {
    final syncKey = _syncKey(items);

    if (syncKey == _lastSyncKey) {
      return;
    }

    _lastSyncKey = syncKey;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      unawaited(
        widget.scheduler
            .syncDailySummary(settings: widget.settings, items: items)
            .catchError((Object _) {}),
      );
    });
  }

  String _syncKey(List<HubItem> items) {
    final itemParts = items
        .map((item) {
          return [
            item.id,
            item.nextDueDate?.millisecondsSinceEpoch,
            item.notificationsMuted,
          ].join(':');
        })
        .join('|');

    return [
      widget.settings.notificationsEnabled,
      widget.settings.notificationHour,
      widget.settings.notificationDueSoonDays,
      widget.settings.quietHoursStartHour,
      widget.settings.quietHoursEndHour,
      itemParts,
    ].join('|');
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<HubItem>>(
      stream: _itemsStream,
      builder: (context, snapshot) {
        final items = snapshot.data;

        if (items != null) {
          _queueSync(items);
        }

        return widget.child;
      },
    );
  }
}
