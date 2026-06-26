import 'package:timezone/timezone.dart' as tz;
import '../notifications/notification_service.dart';
import '../storage/hive_storage.dart';

enum ScheduleMode { interval, fixedTime }

class ScheduleEngine {
  static final ScheduleEngine instance = ScheduleEngine._();
  ScheduleEngine._();

  /// Cancels any pending notification and arms the next one.
  /// Call this after settings change, app launch, and reboot recovery.
  Future<void> reschedule() async {
    await NotificationService.instance.cancelAll();
    final mode = currentMode();
    if (mode == ScheduleMode.interval) {
      await _scheduleInterval();
    } else {
      await _scheduleFixedTimes();
    }
  }

  ScheduleMode currentMode() {
    final raw = HiveStorage.getScheduleMode();
    return raw == 'interval' ? ScheduleMode.interval : ScheduleMode.fixedTime;
  }

  Future<void> _scheduleInterval() async {
    final minutes = HiveStorage.getIntervalMinutes();
    final next = tz.TZDateTime.now(tz.local).add(Duration(minutes: minutes));
    await NotificationService.instance.scheduleOneShot(next);
  }

  Future<void> _scheduleFixedTimes() async {
    final times = HiveStorage.getFixedTimes();
    if (times.isEmpty) return;

    final now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime? next;

    for (final t in times) {
      final candidate = _nextOccurrence(now, t);
      if (candidate == null) continue;
      if (next == null || candidate.isBefore(next)) {
        next = candidate;
      }
    }

    if (next != null) {
      await NotificationService.instance.scheduleOneShot(next);
    }
  }

  tz.TZDateTime? _nextOccurrence(tz.TZDateTime now, String hhmm) {
    final parts = hhmm.split(':');
    if (parts.length != 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;

    var candidate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (candidate.isBefore(now)) {
      candidate = candidate.add(const Duration(days: 1));
    }
    return candidate;
  }

  /// Called after the user dismisses the full-screen reminder.
  /// Re-arms the next notification and updates the streak.
  Future<void> onReminderAcknowledged() async {
    await reschedule();
    await _updateStreak();
  }

  Future<void> _updateStreak() async {
    final today = DateTime.now();
    final todayStr = _dateKey(today);
    final last = HiveStorage.getLastAcknowledgedDate();

    if (last == todayStr) return;

    final yesterday = today.subtract(const Duration(days: 1));
    final yesterdayStr = _dateKey(yesterday);

    int streak = HiveStorage.getStreak();
    streak = (last == yesterdayStr) ? streak + 1 : 1;

    await HiveStorage.setStreak(streak);
    await HiveStorage.setLastAcknowledgedDate(todayStr);
  }

  String _dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  /// Best-effort estimate of time remaining until the next reminder,
  /// used for the home screen countdown display only — not used for
  /// scheduling itself (which is OS-level via zonedSchedule).
  Duration estimateNextCountdown() {
    final mode = currentMode();
    if (mode == ScheduleMode.interval) {
      return Duration(minutes: HiveStorage.getIntervalMinutes());
    }
    final times = HiveStorage.getFixedTimes();
    if (times.isEmpty) return const Duration(hours: 1);
    final now = tz.TZDateTime.now(tz.local);
    Duration? shortest;
    for (final t in times) {
      final next = _nextOccurrence(now, t);
      if (next == null) continue;
      final diff = next.difference(now);
      if (shortest == null || diff < shortest) shortest = diff;
    }
    return shortest ?? const Duration(hours: 1);
  }
}
