import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/scheduling/schedule_engine.dart';
import '../../../core/storage/hive_storage.dart';

class HomeDashboardState {
  final Duration countdown;
  final String themeId;
  final String message;
  final String scheduleMode;
  final int intervalMinutes;
  final int streak;

  const HomeDashboardState({
    required this.countdown,
    required this.themeId,
    required this.message,
    required this.scheduleMode,
    required this.intervalMinutes,
    required this.streak,
  });
}

/// Drives the home screen's "next reminder" countdown display.
/// This is a UI-only ticker — actual scheduling is OS-level via
/// ScheduleEngine + flutter_local_notifications zonedSchedule.
class HomeDashboardNotifier extends StateNotifier<HomeDashboardState> {
  Timer? _ticker;

  HomeDashboardNotifier()
      : super(HomeDashboardState(
          countdown: ScheduleEngine.instance.estimateNextCountdown(),
          themeId: HiveStorage.getThemeId(),
          message: HiveStorage.getMessage(),
          scheduleMode: HiveStorage.getScheduleMode(),
          intervalMinutes: HiveStorage.getIntervalMinutes(),
          streak: HiveStorage.getStreak(),
        )) {
    _ticker = Timer.periodic(const Duration(seconds: 30), (_) => refresh());
  }

  void refresh() {
    state = HomeDashboardState(
      countdown: ScheduleEngine.instance.estimateNextCountdown(),
      themeId: HiveStorage.getThemeId(),
      message: HiveStorage.getMessage(),
      scheduleMode: HiveStorage.getScheduleMode(),
      intervalMinutes: HiveStorage.getIntervalMinutes(),
      streak: HiveStorage.getStreak(),
    );
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}

final homeDashboardProvider =
    StateNotifierProvider<HomeDashboardNotifier, HomeDashboardState>((ref) {
  return HomeDashboardNotifier();
});
