import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/scheduling/schedule_engine.dart';
import '../../../core/storage/hive_storage.dart';

class SettingsState {
  final String scheduleMode; // 'interval' | 'fixed'
  final int intervalMinutes;
  final List<String> fixedTimes;
  final bool soundEnabled;
  final bool smartBreaksEnabled;

  const SettingsState({
    required this.scheduleMode,
    required this.intervalMinutes,
    required this.fixedTimes,
    required this.soundEnabled,
    required this.smartBreaksEnabled,
  });

  SettingsState copyWith({
    String? scheduleMode,
    int? intervalMinutes,
    List<String>? fixedTimes,
    bool? soundEnabled,
    bool? smartBreaksEnabled,
  }) {
    return SettingsState(
      scheduleMode: scheduleMode ?? this.scheduleMode,
      intervalMinutes: intervalMinutes ?? this.intervalMinutes,
      fixedTimes: fixedTimes ?? this.fixedTimes,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      smartBreaksEnabled: smartBreaksEnabled ?? this.smartBreaksEnabled,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier()
      : super(SettingsState(
          scheduleMode: HiveStorage.getScheduleMode(),
          intervalMinutes: HiveStorage.getIntervalMinutes(),
          fixedTimes: HiveStorage.getFixedTimes(),
          soundEnabled: HiveStorage.getSoundEnabled(),
          smartBreaksEnabled: HiveStorage.getSmartBreaks(),
        ));

  static const int maxFixedTimes = 5;

  Future<void> setScheduleMode(String mode) async {
    await HiveStorage.setScheduleMode(mode);
    state = state.copyWith(scheduleMode: mode);
    await ScheduleEngine.instance.reschedule();
  }

  Future<void> setIntervalMinutes(int minutes) async {
    await HiveStorage.setIntervalMinutes(minutes);
    state = state.copyWith(intervalMinutes: minutes);
    if (state.scheduleMode == 'interval') {
      await ScheduleEngine.instance.reschedule();
    }
  }

  Future<void> addFixedTime(String hhmm) async {
    if (state.fixedTimes.length >= maxFixedTimes) return;
    if (state.fixedTimes.contains(hhmm)) return;
    final updated = [...state.fixedTimes, hhmm]..sort();
    await HiveStorage.setFixedTimes(updated);
    state = state.copyWith(fixedTimes: updated);
    if (state.scheduleMode == 'fixed') {
      await ScheduleEngine.instance.reschedule();
    }
  }

  Future<void> updateFixedTime(int index, String hhmm) async {
    if (index < 0 || index >= state.fixedTimes.length) return;
    final updated = [...state.fixedTimes];
    updated[index] = hhmm;
    updated.sort();
    await HiveStorage.setFixedTimes(updated);
    state = state.copyWith(fixedTimes: updated);
    if (state.scheduleMode == 'fixed') {
      await ScheduleEngine.instance.reschedule();
    }
  }

  Future<void> removeFixedTime(int index) async {
    if (index < 0 || index >= state.fixedTimes.length) return;
    final updated = [...state.fixedTimes]..removeAt(index);
    await HiveStorage.setFixedTimes(updated);
    state = state.copyWith(fixedTimes: updated);
    if (state.scheduleMode == 'fixed') {
      await ScheduleEngine.instance.reschedule();
    }
  }

  Future<void> setSoundEnabled(bool value) async {
    await HiveStorage.setSoundEnabled(value);
    state = state.copyWith(soundEnabled: value);
  }

  Future<void> setSmartBreaks(bool value) async {
    await HiveStorage.setSmartBreaks(value);
    state = state.copyWith(smartBreaksEnabled: value);
  }
}

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier();
});
