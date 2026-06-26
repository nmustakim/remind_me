import 'dart:io';
import '../notifications/notification_service.dart';
import '../scheduling/schedule_engine.dart';
import '../storage/hive_storage.dart';

/// Re-arms the notification schedule after:
/// - app cold start
/// - device reboot (Android: handled via RECEIVE_BOOT_COMPLETED +
///   this being invoked again on next app launch as a safety net)
/// - any time the pending notification queue might be empty/stale
class BootRecoveryService {
  static Future<void> recoverIfNeeded() async {
    if (!HiveStorage.isOnboardingComplete()) return;

    final pending = await NotificationService.instance.getPending();
    final hasReminderScheduled =
        pending.any((p) => p.id == 1001 /* AppConstants.reminderNotificationId */);

    if (!hasReminderScheduled) {
      await ScheduleEngine.instance.reschedule();
    }
  }

  static bool get isAndroid => Platform.isAndroid;
}
