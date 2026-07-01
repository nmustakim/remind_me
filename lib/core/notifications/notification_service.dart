import 'dart:convert';
import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tzdata;
import '../constants/app_constants.dart';
import '../storage/hive_storage.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
  FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    tzdata.initializeTimeZones();
    try {
      final timezoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timezoneName));
    } catch (_) {
      tz.setLocalLocation(tz.getLocation('UTC'));
    }

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
      onDidReceiveBackgroundNotificationResponse: _onBackgroundNotificationResponse,
    );

    if (Platform.isAndroid) {
      await _createAndroidChannel();
    }

    _initialized = true;
  }

  Future<void> _createAndroidChannel() async {
    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        AppConstants.notificationChannelId,
        AppConstants.notificationChannelName,
        description: AppConstants.notificationChannelDesc,
        importance: Importance.high,
        playSound: true,
        showBadge: true,
      ),
    );
  }

  Future<bool> requestPermissions() async {
    if (Platform.isIOS) {
      final iosPlugin = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      final result = await iosPlugin?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return result ?? false;
    } else if (Platform.isAndroid) {
      final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      final granted = await androidPlugin?.requestNotificationsPermission();
      final exactAlarm = await androidPlugin?.requestExactAlarmsPermission();
      return (granted ?? false) && (exactAlarm ?? true);
    }
    return false;
  }

  Future<bool> hasPermission() async {
    if (Platform.isAndroid) {
      final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      final result = await androidPlugin?.areNotificationsEnabled();
      return result ?? false;
    } else if (Platform.isIOS) {
      final iosPlugin = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      final perms = await iosPlugin?.checkPermissions();
      return perms?.isEnabled ?? false;
    }
    return false;
  }

  AndroidNotificationDetails _androidDetails() {
    return const AndroidNotificationDetails(
      AppConstants.notificationChannelId,
      AppConstants.notificationChannelName,
      channelDescription: AppConstants.notificationChannelDesc,
      importance: Importance.high,
      priority: Priority.high,
      fullScreenIntent: true,
      category: AndroidNotificationCategory.alarm,
      visibility: NotificationVisibility.public,
      autoCancel: false,
      ongoing: false,
      playSound: true,
      enableVibration: true,
      ticker: 'Time to take a break',
    );
  }

  DarwinNotificationDetails _iosDetails() {
    return const DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      interruptionLevel: InterruptionLevel.timeSensitive,
      categoryIdentifier: 'BREAK_REMINDER',
    );
  }

  NotificationDetails get _notificationDetails => NotificationDetails(
    android: _androidDetails(),
    iOS: _iosDetails(),
  );

  Future<void> scheduleOneShot(tz.TZDateTime scheduledDate) async {
    final themeId = HiveStorage.getThemeId();
    final message = HiveStorage.getMessage();

    // JSON-encoded payload instead of a hand-rolled "key=value|key=value"
    // string — the old format breaks the moment a custom message contains
    // a "|" or "=" character, which free-text entry allows.
    final payload = jsonEncode({
      'themeId': themeId,
      'message': message,
    });

    await _plugin.zonedSchedule(
      AppConstants.reminderNotificationId,
      'Time for a break ✦',
      message,
      scheduledDate,
      _notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  Future<void> cancel(int id) async {
    await _plugin.cancel(id);
  }

  Future<List<PendingNotificationRequest>> getPending() =>
      _plugin.pendingNotificationRequests();

  Future<NotificationAppLaunchDetails?> getLaunchDetails() =>
      _plugin.getNotificationAppLaunchDetails();
}

/// Parses a notification payload back into (themeId, message).
/// Falls back to app defaults if the payload is missing/malformed, so a
/// bad payload never crashes the tap-to-overlay flow.
class ReminderPayload {
  final String themeId;
  final String message;

  const ReminderPayload({required this.themeId, required this.message});

  static ReminderPayload? tryParse(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return ReminderPayload(
        themeId: map['themeId'] as String? ?? HiveStorage.getThemeId(),
        message: map['message'] as String? ?? HiveStorage.getMessage(),
      );
    } catch (_) {
      return null;
    }
  }
}

@pragma('vm:entry-point')
void _onBackgroundNotificationResponse(NotificationResponse response) {
  // Fires when the notification is tapped while the app is fully
  // terminated (not just backgrounded). By the time this isolate runs,
  // the main app isolate is not guaranteed to be alive yet, so we can't
  // reliably route from here. Cold-start routing is instead handled in
  // main.dart via NotificationService.instance.getLaunchDetails(), which
  // reads the same tap event once the app isolate is fully up.
}

void _onNotificationResponse(NotificationResponse response) {
  NotificationTapBus.instance.emit(response.payload);
}

/// Simple broadcast bus so the UI layer (router/provider) can react
/// to a notification tap without coupling NotificationService to widgets.
class NotificationTapBus {
  NotificationTapBus._();
  static final NotificationTapBus instance = NotificationTapBus._();

  final List<void Function(String?)> _listeners = [];

  void addListener(void Function(String?) listener) {
    _listeners.add(listener);
  }

  void removeListener(void Function(String?) listener) {
    _listeners.remove(listener);
  }

  void emit(String? payload) {
    for (final l in List.of(_listeners)) {
      l(payload);
    }
  }
}