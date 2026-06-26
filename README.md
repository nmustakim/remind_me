# Remind Me

Production Flutter wellness break reminder app.

## Stack
- Flutter (stable, Dart >=3.3.0)
- Riverpod (state management)
- go_router (navigation)
- flutter_local_notifications + timezone (OS-level scheduling, no Dart timers)
- Hive (local persistence)

## Setup

```bash
flutter pub get
flutter run
```

## Architecture

```
lib/
  core/
    constants/        # AppConstants
    notifications/     # NotificationService - channels, permissions, zonedSchedule
    scheduling/         # ScheduleEngine - interval/fixed-time logic, BootRecoveryService
    storage/             # HiveStorage - typed persistence wrapper
    theme/                 # AppTheme (Material 3), VisualThemeRegistry
  features/
    onboarding/presentation/    # 5-step onboarding flow
    reminder/
      application/               # HomeDashboardNotifier (UI countdown ticker)
      presentation/               # HomeScreen, ReminderOverlayScreen
    settings/
      application/                # SettingsNotifier (interval/fixed mode, fixed times)
      presentation/                 # SettingsScreen
    themes/
      application/                  # ThemeSelectionNotifier
      presentation/                   # ThemesScreen (live animated grid)
    messages/
      application/                    # MessagesNotifier (default + custom messages)
      presentation/                     # MessagesScreen
  shared/
    painters/        # 10 CustomPainter animated themes (60fps, canvas-based)
    widgets/           # AnimatedThemeCanvas (Ticker-driven)
    presentation/        # MainShell (bottom nav)
  router.dart
  main.dart
```

## Scheduling model

All scheduling is OS-level via `flutter_local_notifications.zonedSchedule` with
`AndroidScheduleMode.exactAllowWhileIdle` and a high-priority, full-screen-intent
Android notification channel. No Dart `Timer`/`Future.delayed` is used to drive
reminders — `Timer.periodic` in `HomeDashboardNotifier` is UI-only (updates the
countdown label) and never fires the reminder itself.

- **Interval mode**: schedules exactly one notification `N` minutes out. On
  acknowledgment (`ScheduleEngine.onReminderAcknowledged`), the next one is
  re-armed for `N` minutes from that moment.
- **Fixed-time mode**: up to 5 daily times; the engine computes the soonest
  upcoming occurrence (rolling to tomorrow if all times today have passed) and
  schedules exactly one notification. Re-armed the same way after acknowledgment.
- **Reboot / app-restart recovery**: `BootRecoveryService.recoverIfNeeded()` runs
  on every cold start and re-arms the schedule if no pending notification is
  found. `ScheduledNotificationBootReceiver` (declared in `AndroidManifest.xml`)
  additionally restores OS-level alarms directly after `BOOT_COMPLETED`.

## Android permissions required

- `POST_NOTIFICATIONS` (Android 13+)
- `SCHEDULE_EXACT_ALARM` / `USE_EXACT_ALARM`
- `USE_FULL_SCREEN_INTENT`
- `RECEIVE_BOOT_COMPLETED`

## iOS capabilities required

- Enable **Push Notifications** and **Background Modes → Background fetch /
  Background processing** in Xcode signing & capabilities.
- Notifications use `InterruptionLevel.timeSensitive`, which requires the
  Time Sensitive Notifications entitlement for full effect on physical devices.

## Known platform follow-ups before App Store / Play Store submission

- Add real app icons (`android/app/src/main/res/mipmap-*`, iOS `Assets.xcassets`).
- Add a `LaunchScreen.storyboard` (iOS) — currently references the default name.
- Generate a release keystore for Android (`android/key.properties` + signing
  config) — debug signing is wired by default in `build.gradle` for local runs.
