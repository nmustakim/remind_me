import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/notifications/notification_service.dart';
import '../application/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  String _formatInterval(int minutes) {
    if (minutes < 60) return '$minutes min';
    final hours = minutes / 60;
    return hours == hours.roundToDouble()
        ? '${hours.round()} hr'
        : '${hours.toStringAsFixed(1)} hr';
  }

  Future<void> _pickTime(BuildContext context, WidgetRef ref, {int? editIndex}) async {
    final initial = editIndex != null
        ? _parseTime(ref.read(settingsProvider).fixedTimes[editIndex])
        : TimeOfDay.now();

    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked == null) return;

    final hhmm =
        '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';

    final notifier = ref.read(settingsProvider.notifier);
    if (editIndex != null) {
      await notifier.updateFixedTime(editIndex, hhmm);
    } else {
      await notifier.addFixedTime(hhmm);
    }
  }

  TimeOfDay _parseTime(String hhmm) {
    final parts = hhmm.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  String _displayTime(String hhmm) {
    final t = _parseTime(hhmm);
    final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final m = t.minute.toString().padLeft(2, '0');
    final period = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '$h:$m $period';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          Text('Schedule mode', style: theme.textTheme.labelMedium),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _ModeTab(
                  label: 'Interval',
                  sublabel: 'Every N minutes',
                  selected: state.scheduleMode == 'interval',
                  onTap: () => notifier.setScheduleMode('interval'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ModeTab(
                  label: 'Fixed times',
                  sublabel: 'Up to 5 daily',
                  selected: state.scheduleMode == 'fixed',
                  onTap: () => notifier.setScheduleMode('fixed'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (state.scheduleMode == 'interval') ...[
            Text('Interval', style: theme.textTheme.labelMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: AppConstants.intervalOptions.map((m) {
                final selected = state.intervalMinutes == m;
                return ChoiceChip(
                  label: Text(_formatInterval(m)),
                  selected: selected,
                  onSelected: (_) => notifier.setIntervalMinutes(m),
                  selectedColor: theme.colorScheme.primary.withAlpha(35),
                  labelStyle: TextStyle(
                    color: selected ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  ),
                  side: BorderSide(
                    color: selected
                        ? theme.colorScheme.primary.withAlpha(90)
                        : theme.colorScheme.outline.withAlpha(60),
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                );
              }).toList(),
            ),
          ] else ...[
            Text('Daily times', style: theme.textTheme.labelMedium),
            const SizedBox(height: 8),
            ...state.fixedTimes.asMap().entries.map((entry) {
              final index = entry.key;
              final time = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Material(
                  color: theme.cardTheme.color,
                  borderRadius: BorderRadius.circular(14),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () => _pickTime(context, ref, editIndex: index),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: theme.colorScheme.outline.withAlpha(60)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.access_time, size: 18, color: theme.colorScheme.primary),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(_displayTime(time), style: theme.textTheme.bodyLarge),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, size: 16),
                            color: theme.colorScheme.outline,
                            onPressed: () => notifier.removeFixedTime(index),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
            if (state.fixedTimes.length < SettingsNotifier.maxFixedTimes)
              OutlinedButton.icon(
                onPressed: () => _pickTime(context, ref),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add time'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
          ],
          const SizedBox(height: 24),
          Text('Preferences', style: theme.textTheme.labelMedium),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Smart breaks'),
                  subtitle: const Text('Skip during focus sessions'),
                  value: state.smartBreaksEnabled,
                  onChanged: notifier.setSmartBreaks,
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                SwitchListTile(
                  title: const Text('Sound'),
                  subtitle: const Text('Soft chime on reminder'),
                  value: state.soundEnabled,
                  onChanged: notifier.setSoundEnabled,
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                ListTile(
                  leading: const Icon(Icons.notifications_outlined),
                  title: const Text('Notification permission'),
                  subtitle: const Text('Required for reminders to appear'),
                  trailing: const Icon(Icons.chevron_right, size: 18),
                  onTap: () => NotificationService.instance.requestPermissions(),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                ListTile(
                  leading: const Icon(Icons.replay_outlined),
                  title: const Text('View onboarding'),
                  subtitle: const Text('Replay intro flow'),
                  trailing: const Icon(Icons.chevron_right, size: 18),
                  onTap: () => context.push('/onboarding'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeTab extends StatelessWidget {
  final String label;
  final String sublabel;
  final bool selected;
  final VoidCallback onTap;

  const _ModeTab({
    required this.label,
    required this.sublabel,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: selected ? theme.colorScheme.primary.withAlpha(25) : theme.cardTheme.color,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? theme.colorScheme.primary.withAlpha(90)
                : theme.colorScheme.outline.withAlpha(60),
          ),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: theme.textTheme.titleSmall?.copyWith(
                color: selected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 2),
            Text(sublabel, style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
