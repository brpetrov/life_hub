import '../../hub/domain/hub_item.dart';
import '../../settings/domain/app_settings.dart';

abstract interface class ReminderNotificationScheduler {
  Future<bool> requestPermissions();

  Future<void> syncDailySummary({
    required AppSettings settings,
    required List<HubItem> items,
  });

  Future<void> cancelDailySummary();
}
