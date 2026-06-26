import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/notifications/notification_service.dart';
import '../../../core/scheduling/schedule_engine.dart';
import '../../../core/storage/hive_storage.dart';
import '../../../shared/widgets/animated_theme_canvas.dart';

class _OnboardingStep {
  final String eyebrow;
  final String title;
  final String desc;
  final String buttonLabel;
  final String themeId;

  const _OnboardingStep({
    required this.eyebrow,
    required this.title,
    required this.desc,
    required this.buttonLabel,
    required this.themeId,
  });
}

const _steps = [
  _OnboardingStep(
    eyebrow: 'WELCOME',
    title: 'Your screen\ndeserves breaks.',
    desc: 'Remind Me gently nudges you to step away with beautiful full-screen moments of calm.',
    buttonLabel: 'Get started',
    themeId: 'aurora',
  ),
  _OnboardingStep(
    eyebrow: 'HOW IT WORKS',
    title: 'Gentle nudges,\nnot interruptions.',
    desc: 'A full-screen animated scene appears at your chosen interval or fixed times. One tap dismisses it.',
    buttonLabel: 'Sounds good',
    themeId: 'glowingOrb',
  ),
  _OnboardingStep(
    eyebrow: 'THEMES',
    title: '10 beautiful\nanimated themes.',
    desc: 'From aurora waves to floating crystals — each reminder is a tiny visual escape.',
    buttonLabel: 'Love it',
    themeId: 'floatingCrystal',
  ),
  _OnboardingStep(
    eyebrow: 'PERMISSIONS',
    title: 'One permission,\nthat\'s all.',
    desc: 'We\'ll ask for notification access so reminders can appear even when the app is in the background.',
    buttonLabel: 'Allow & continue',
    themeId: 'neonRings',
  ),
  _OnboardingStep(
    eyebrow: 'ALL SET',
    title: 'You\'re ready\nto breathe.',
    desc: 'Your first reminder is scheduled. Tap preview anytime to see what it looks like.',
    buttonLabel: 'Open app',
    themeId: 'sunrise',
  ),
];

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  int _step = 0;
  bool _busy = false;

  Future<void> _next() async {
    if (_step < _steps.length - 1) {
      if (_step == 2) {
        // Permissions step is next — request now as user proceeds into it.
      }
      if (_step == 3) {
        setState(() => _busy = true);
        await NotificationService.instance.requestPermissions();
        if (!mounted) return;
        setState(() => _busy = false);
      }
      setState(() => _step++);
      return;
    }

    // Final step — complete onboarding.
    setState(() => _busy = true);
    await HiveStorage.setOnboardingComplete(true);
    await ScheduleEngine.instance.reschedule();
    if (!mounted) return;
    context.go('/home');
  }

  void _back() {
    if (_step == 0) return;
    setState(() => _step--);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final step = _steps[_step];

    return Scaffold(
      body: Column(
        children: [
          SizedBox(
            height: 320,
            width: double.infinity,
            child: AnimatedThemeCanvas(themeId: step.themeId),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(28, 28, 28, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: List.generate(_steps.length, (i) {
                      final active = i == _step;
                      final done = i < _step;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(right: 6),
                        height: 6,
                        width: active ? 20 : 6,
                        decoration: BoxDecoration(
                          color: active
                              ? theme.colorScheme.primary
                              : done
                                  ? theme.colorScheme.primary.withAlpha(150)
                                  : theme.colorScheme.outline.withAlpha(80),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    step.eyebrow,
                    style: theme.textTheme.labelSmall?.copyWith(letterSpacing: 1.5),
                  ),
                  const SizedBox(height: 10),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: Text(
                      step.title,
                      key: ValueKey(step.title),
                      style: theme.textTheme.displaySmall?.copyWith(height: 1.2),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: Text(
                      step.desc,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.65,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
            child: Row(
              children: [
                if (_step > 0) ...[
                  OutlinedButton(
                    onPressed: _busy ? null : _back,
                    style: OutlinedButton.styleFrom(minimumSize: const Size(0, 56)),
                    child: const Text('Back'),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: FilledButton(
                    onPressed: _busy ? null : _next,
                    child: _busy
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : Text(step.buttonLabel),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
