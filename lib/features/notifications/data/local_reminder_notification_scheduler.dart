import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as timezone_data;
import 'package:timezone/timezone.dart' as timezone;

import '../../hub/domain/hub_item.dart';
import '../../settings/domain/app_settings.dart';
import '../domain/reminder_notification_summary.dart';
import 'reminder_notification_scheduler.dart';

class LocalReminderNotificationScheduler
    implements ReminderNotificationScheduler {
  LocalReminderNotificationScheduler({
    FlutterLocalNotificationsPlugin? plugin,
    DateTime Function()? now,
  }) : _plugin = plugin ?? FlutterLocalNotificationsPlugin(),
       _now = now ?? DateTime.now;

  static const _dailySummaryId = 8100;
  static const _channelId = 'life_hub_reminders';
  static const _channelName = 'Life Hub reminders';
  static const _channelDescription = 'Due reminder summaries from Life Hub.';

  final FlutterLocalNotificationsPlugin _plugin;
  final DateTime Function() _now;

  var _initialized = false;

  @override
  Future<bool> requestPermissions() async {
    if (!_supportsScheduledNotifications) {
      return false;
    }

    await _initialize();

    if (defaultTargetPlatform == TargetPlatform.android) {
      final android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      return await android?.requestNotificationsPermission() ?? true;
    }

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final ios = _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();

      return await ios?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          false;
    }

    if (defaultTargetPlatform == TargetPlatform.macOS) {
      final macOS = _plugin
          .resolvePlatformSpecificImplementation<
            MacOSFlutterLocalNotificationsPlugin
          >();

      return await macOS?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          false;
    }

    return true;
  }

  @override
  Future<void> syncDailySummary({
    required AppSettings settings,
    required List<HubItem> items,
  }) async {
    if (!_supportsScheduledNotifications) {
      return;
    }

    await _initialize();
    await cancelDailySummary();

    if (!settings.notificationsEnabled) {
      return;
    }

    final summary = ReminderNotificationSummary.fromItems(
      items,
      now: _now(),
      dueSoonDays: settings.notificationDueSoonDays,
    );

    if (!summary.hasItems) {
      return;
    }

    await _plugin.zonedSchedule(
      id: _dailySummaryId,
      title: summary.title,
      body: summary.body,
      scheduledDate: _nextAllowedNotificationTime(settings, _now()),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: DarwinNotificationDetails(),
        macOS: DarwinNotificationDetails(),
        windows: WindowsNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'life-hub-daily-summary',
    );
  }

  @override
  Future<void> cancelDailySummary() async {
    if (!_supportsScheduledNotifications) {
      return;
    }

    await _initialize();
    await _plugin.cancel(id: _dailySummaryId);
  }

  Future<void> _initialize() async {
    if (_initialized) {
      return;
    }

    timezone_data.initializeTimeZones();
    await _configureLocalTimezone();

    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
        macOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
        linux: LinuxInitializationSettings(defaultActionName: 'Open'),
        windows: WindowsInitializationSettings(
          appName: 'Life Hub',
          appUserModelId: 'LifeHub.App',
          guid: '4eb7e5fe-2580-4ef5-a68d-b3cf2c7f96f2',
        ),
      ),
    );

    _initialized = true;
  }

  Future<void> _configureLocalTimezone() async {
    try {
      final localTimezone = await FlutterTimezone.getLocalTimezone();
      timezone.setLocalLocation(timezone.getLocation(localTimezone.identifier));
    } catch (_) {
      timezone.setLocalLocation(timezone.UTC);
    }
  }

  timezone.TZDateTime _nextAllowedNotificationTime(
    AppSettings settings,
    DateTime now,
  ) {
    var scheduled = DateTime(
      now.year,
      now.month,
      now.day,
      settings.notificationHour,
    );

    if (!scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    scheduled = _moveOutOfQuietHours(
      scheduled,
      quietStartHour: settings.quietHoursStartHour,
      quietEndHour: settings.quietHoursEndHour,
    );

    var zoned = timezone.TZDateTime.from(scheduled, timezone.local);
    final zonedNow = timezone.TZDateTime.from(now, timezone.local);

    if (!zoned.isAfter(zonedNow)) {
      zoned = zoned.add(const Duration(days: 1));
    }

    return zoned;
  }

  DateTime _moveOutOfQuietHours(
    DateTime scheduled, {
    required int quietStartHour,
    required int quietEndHour,
  }) {
    if (!_isInsideQuietHours(
      scheduled.hour,
      startHour: quietStartHour,
      endHour: quietEndHour,
    )) {
      return scheduled;
    }

    var adjusted = DateTime(
      scheduled.year,
      scheduled.month,
      scheduled.day,
      quietEndHour,
    );

    if (!adjusted.isAfter(scheduled)) {
      adjusted = adjusted.add(const Duration(days: 1));
    }

    return adjusted;
  }

  bool _isInsideQuietHours(
    int hour, {
    required int startHour,
    required int endHour,
  }) {
    if (startHour == endHour) {
      return false;
    }

    if (startHour < endHour) {
      return hour >= startHour && hour < endHour;
    }

    return hour >= startHour || hour < endHour;
  }

  bool get _supportsScheduledNotifications {
    if (kIsWeb) {
      return false;
    }

    return switch (defaultTargetPlatform) {
      TargetPlatform.android ||
      TargetPlatform.iOS ||
      TargetPlatform.macOS ||
      TargetPlatform.windows => true,
      TargetPlatform.fuchsia || TargetPlatform.linux => false,
    };
  }
}
