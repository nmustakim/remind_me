class AppConstants {
  static const String notificationChannelId = 'remind_me_channel';
  static const String notificationChannelName = 'Break Reminders';
  static const String notificationChannelDesc =
      'Full-screen animated break reminders';
  static const int reminderNotificationId = 1001;

  static const String settingsBoxName = 'settings_box';

  static const String onboardingKey = 'onboarding_complete';
  static const String themeIdKey = 'selected_theme_id';
  static const String messageKey = 'selected_message';
  static const String scheduleModeKey = 'schedule_mode';
  static const String intervalMinutesKey = 'interval_minutes';
  static const String fixedTimesKey = 'fixed_times';
  static const String soundEnabledKey = 'sound_enabled';
  static const String smartBreaksKey = 'smart_breaks_enabled';
  static const String streakKey = 'streak_count';
  static const String lastAcknowledgedKey = 'last_acknowledged_date';
  static const String customMessagesKey = 'custom_messages';

  static const List<int> intervalOptions = [
    15, 30, 45, 60, 75, 90, 105, 120, 135, 150, 165, 180
  ];

  static const List<String> defaultMessages = [
    'Time to take a break.',
    'Pause. Breathe. Rest.',
    'Step away for a moment.',
    'Your eyes need rest.',
    'Close your eyes briefly.',
    'Hydrate and stretch.',
    'Look away from the screen.',
  ];
}
