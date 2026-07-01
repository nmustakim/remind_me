import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest_all.dart' as tz;

import 'core/notifications/notification_service.dart';
import 'core/scheduling/boot_recovery_service.dart';
import 'core/storage/hive_storage.dart';
import 'core/theme/app_theme.dart';
import 'router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
    ),
  );

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  tz.initializeTimeZones();
  await HiveStorage.init();
  await NotificationService.instance.initialize();
  await BootRecoveryService.recoverIfNeeded();

  // Created explicitly (instead of letting ProviderScope create it
  // implicitly) so we have a handle to read appRouterProvider from here
  // in main(), before/outside the widget tree — needed to navigate to
  // the overlay in response to notification taps.
  final container = ProviderContainer();

  // --- Warm tap: app is running (foreground or backgrounded) when the
  // notification is tapped. NotificationTapBus fires immediately. ---
  NotificationTapBus.instance.addListener((payload) {
    final parsed = ReminderPayload.tryParse(payload);
    if (parsed == null) return;
    container.read(appRouterProvider).go(
      '/reminder',
      extra: {'themeId': parsed.themeId, 'message': parsed.message},
    );
  });

  // --- Cold tap: app was fully killed; this launch *is* the tap.
  // NotificationTapBus never fired for it (nothing was listening yet),
  // so check launch details once and navigate directly. ---
  final launchDetails = await NotificationService.instance.getLaunchDetails();
  if (launchDetails != null && launchDetails.didNotificationLaunchApp) {
    final parsed = ReminderPayload.tryParse(
      launchDetails.notificationResponse?.payload,
    );
    if (parsed != null) {
      // Router isn't attached to a live Navigator yet on this first
      // frame, so defer the navigation to just after the first frame
      // renders (still lands before the user sees the home screen).
      WidgetsBinding.instance.addPostFrameCallback((_) {
        container.read(appRouterProvider).go(
          '/reminder',
          extra: {'themeId': parsed.themeId, 'message': parsed.message},
        );
      });
    }
  }

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const RemindMeApp(),
    ),
  );
}

class RemindMeApp extends ConsumerWidget {
  const RemindMeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'Remind Me',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}