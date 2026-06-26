import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/visual_theme.dart';
import '../../../shared/widgets/animated_theme_canvas.dart';
import '../application/home_dashboard_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  String _formatCountdown(Duration d) {
    if (d.inMinutes < 1) return 'less than a minute';
    if (d.inMinutes < 60) return '${d.inMinutes} min';
    final h = d.inHours;
    final m = d.inMinutes % 60;
    return m == 0 ? '$h hr' : '$h hr $m min';
  }

  String _formatClock(DateTime t) {
    final h = t.hour % 12 == 0 ? 12 : t.hour % 12;
    final m = t.minute.toString().padLeft(2, '0');
    final period = t.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $period';
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeDashboardProvider);
    final theme = Theme.of(context);
    final visualTheme = VisualThemeRegistry.byId(state.themeId);
    final nextTime = DateTime.now().add(state.countdown);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _greeting().toUpperCase(),
                      style: theme.textTheme.labelSmall?.copyWith(letterSpacing: 0.5),
                    ),
                    const SizedBox(height: 4),
                    Text('Take it easy\ntoday.', style: theme.textTheme.displaySmall),
                  ],
                ),
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.secondary.withAlpha(60),
                        blurRadius: 6,
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _NextReminderCard(
              themeId: state.themeId,
              themeName: visualTheme.name,
              timeLabel: _formatClock(nextTime),
              subLabel: 'in ${_formatCountdown(state.countdown)} · ${visualTheme.name}',
              badgeLabel: state.scheduleMode == 'interval'
                  ? 'Every ${state.intervalMinutes} min'
                  : 'Fixed schedule',
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.4,
              children: [
                _QuickCard(
                  icon: Icons.play_circle_outline,
                  iconColor: theme.colorScheme.primary,
                  label: 'Preview',
                  value: 'See reminder',
                  onTap: () => context.push('/reminder', extra: {
                    'themeId': state.themeId,
                    'message': state.message,
                  }),
                ),
                _QuickCard(
                  icon: Icons.palette_outlined,
                  iconColor: theme.colorScheme.secondary,
                  label: 'Theme',
                  value: visualTheme.name,
                  onTap: () => context.go('/themes'),
                ),
                _QuickCard(
                  icon: Icons.chat_bubble_outline,
                  iconColor: const Color(0xFFFFB347),
                  label: 'Message',
                  value: state.message,
                  onTap: () => context.go('/messages'),
                ),
                _QuickCard(
                  icon: Icons.tune,
                  iconColor: theme.colorScheme.tertiary,
                  label: 'Schedule',
                  value: state.scheduleMode == 'interval' ? 'Interval mode' : 'Fixed times',
                  onTap: () => context.go('/settings'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _StreakCard(streak: state.streak),
          ],
        ),
      ),
    );
  }
}

class _NextReminderCard extends StatelessWidget {
  final String themeId;
  final String themeName;
  final String timeLabel;
  final String subLabel;
  final String badgeLabel;

  const _NextReminderCard({
    required this.themeId,
    required this.themeName,
    required this.timeLabel,
    required this.subLabel,
    required this.badgeLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.colorScheme.outline.withAlpha(60)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'NEXT REMINDER',
                  style: theme.textTheme.labelSmall?.copyWith(letterSpacing: 0.8),
                ),
                const SizedBox(height: 8),
                Text(timeLabel, style: theme.textTheme.displayLarge?.copyWith(fontSize: 40)),
                const SizedBox(height: 4),
                Text(subLabel, style: theme.textTheme.bodyMedium),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withAlpha(25),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: theme.colorScheme.primary.withAlpha(60)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.schedule, size: 12, color: theme.colorScheme.primary),
                      const SizedBox(width: 6),
                      Text(
                        badgeLabel,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 56,
            height: 56,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: AnimatedThemeCanvas(themeId: themeId),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final VoidCallback onTap;

  const _QuickCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.cardTheme.color,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: theme.colorScheme.outline.withAlpha(60)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconColor.withAlpha(30),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: iconColor),
              ),
              const SizedBox(height: 10),
              Text(label, style: theme.textTheme.titleSmall),
              const SizedBox(height: 2),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StreakCard extends StatelessWidget {
  final int streak;
  const _StreakCard({required this.streak});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const dotsCount = 10;
    final filled = streak.clamp(0, dotsCount);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.colorScheme.outline.withAlpha(60)),
      ),
      child: Row(
        children: [
          Text(
            '$streak',
            style: theme.textTheme.displayMedium?.copyWith(color: const Color(0xFFFFB347)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Day streak', style: theme.textTheme.titleMedium),
                const SizedBox(height: 2),
                Text('Keep it up — you\'re on a roll', style: theme.textTheme.bodySmall),
                const SizedBox(height: 10),
                Row(
                  children: List.generate(dotsCount, (i) {
                    final done = i < filled;
                    return Expanded(
                      child: Container(
                        margin: EdgeInsets.only(right: i == dotsCount - 1 ? 0 : 5),
                        height: 6,
                        decoration: BoxDecoration(
                          color: done
                              ? const Color(0xFFFFB347)
                              : theme.colorScheme.outline.withAlpha(60),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
