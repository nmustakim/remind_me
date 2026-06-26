import 'package:hive_flutter/hive_flutter.dart';
import '../constants/app_constants.dart';

class HiveStorage {
  static late Box _box;

  static Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox(AppConstants.settingsBoxName);
  }

  static bool isOnboardingComplete() =>
      _box.get(AppConstants.onboardingKey, defaultValue: false) as bool;

  static Future<void> setOnboardingComplete(bool value) =>
      _box.put(AppConstants.onboardingKey, value);

  static String getThemeId() =>
      _box.get(AppConstants.themeIdKey, defaultValue: 'aurora') as String;

  static Future<void> setThemeId(String id) =>
      _box.put(AppConstants.themeIdKey, id);

  static String getMessage() => _box.get(
        AppConstants.messageKey,
        defaultValue: AppConstants.defaultMessages.first,
      ) as String;

  static Future<void> setMessage(String msg) =>
      _box.put(AppConstants.messageKey, msg);

  static String getScheduleMode() =>
      _box.get(AppConstants.scheduleModeKey, defaultValue: 'interval') as String;

  static Future<void> setScheduleMode(String mode) =>
      _box.put(AppConstants.scheduleModeKey, mode);

  static int getIntervalMinutes() =>
      _box.get(AppConstants.intervalMinutesKey, defaultValue: 30) as int;

  static Future<void> setIntervalMinutes(int minutes) =>
      _box.put(AppConstants.intervalMinutesKey, minutes);

  static List<String> getFixedTimes() {
    final raw = _box.get(AppConstants.fixedTimesKey, defaultValue: <String>['09:00']);
    return (raw as List).cast<String>();
  }

  static Future<void> setFixedTimes(List<String> times) =>
      _box.put(AppConstants.fixedTimesKey, times);

  static bool getSoundEnabled() =>
      _box.get(AppConstants.soundEnabledKey, defaultValue: true) as bool;

  static Future<void> setSoundEnabled(bool value) =>
      _box.put(AppConstants.soundEnabledKey, value);

  static bool getSmartBreaks() =>
      _box.get(AppConstants.smartBreaksKey, defaultValue: false) as bool;

  static Future<void> setSmartBreaks(bool value) =>
      _box.put(AppConstants.smartBreaksKey, value);

  static int getStreak() =>
      _box.get(AppConstants.streakKey, defaultValue: 0) as int;

  static Future<void> setStreak(int count) =>
      _box.put(AppConstants.streakKey, count);

  static String getLastAcknowledgedDate() =>
      _box.get(AppConstants.lastAcknowledgedKey, defaultValue: '') as String;

  static Future<void> setLastAcknowledgedDate(String date) =>
      _box.put(AppConstants.lastAcknowledgedKey, date);

  static List<String> getCustomMessages() {
    final raw = _box.get(AppConstants.customMessagesKey, defaultValue: <String>[]);
    return (raw as List).cast<String>();
  }

  static Future<void> setCustomMessages(List<String> msgs) =>
      _box.put(AppConstants.customMessagesKey, msgs);
}
