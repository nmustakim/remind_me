import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/scheduling/schedule_engine.dart';
import '../../../shared/widgets/animated_theme_canvas.dart';

class ReminderOverlayScreen extends ConsumerStatefulWidget {
  final String themeId;
  final String message;

  const ReminderOverlayScreen({
    super.key,
    required this.themeId,
    required this.message,
  });

  @override
  ConsumerState<ReminderOverlayScreen> createState() => _ReminderOverlayScreenState();
}

class _ReminderOverlayScreenState extends ConsumerState<ReminderOverlayScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entryController;

  // Backdrop: scales up from slightly behind the screen, like a curtain
  // expanding into place. Leads the rest of the entrance.
  late final Animation<double> _backdropScale;
  late final Animation<double> _backdropFade;

  // Character: rises from below the bottom edge with a slight overshoot,
  // so it feels like it's popping up to say hello rather than sliding in
  // flatly. Starts partway through the backdrop's motion.
  late final Animation<Offset> _characterSlide;
  late final Animation<double> _characterFade;

  // Text + button: settle in last, after the character has mostly arrived.
  late final Animation<double> _textFade;
  late final Animation<Offset> _textSlide;

  bool _dismissing = false;
  bool _exiting = false;

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 950),
    );

    _backdropScale = Tween<double>(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.0, 0.55, curve: Curves.easeOutCubic),
      ),
    );
    _backdropFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.0, 0.35, curve: Curves.easeOut),
      ),
    );

    _characterSlide = Tween<Offset>(
      begin: const Offset(0, 1.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.15, 0.95, curve: Curves.easeOutBack),
      ),
    );
    _characterFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.15, 0.5, curve: Curves.easeOut),
      ),
    );

    _textFade = CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
    );
    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _entryController.forward();
  }

  @override
  void dispose() {
    _entryController.dispose();
    super.dispose();
  }

  Future<void> _onAcknowledge() async {
    if (_dismissing) return;
    setState(() {
      _dismissing = true;
      _exiting = true;
    });

    // Play a quick reverse (sink back down) before navigating away so the
    // dismissal doesn't feel like an abrupt cut.
    await _entryController.reverse(from: 1.0)
        .then((_) => Future<void>.value());

    await ScheduleEngine.instance.onReminderAcknowledged();
    if (!mounted) return;
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: AnimatedBuilder(
          animation: _entryController,
          builder: (context, _) {
            return Stack(
              fit: StackFit.expand,
              children: [
                // Layer 1: backdrop rising/expanding into place
                Opacity(
                  opacity: _backdropFade.value,
                  child: Transform.scale(
                    scale: _backdropScale.value,
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xFF10141C), Color(0xFF05070B)],
                        ),
                      ),
                    ),
                  ),
                ),

                // Layer 2: character canvas rising up from below with overshoot
                Opacity(
                  opacity: _characterFade.value,
                  child: FractionalTranslation(
                    translation: _characterSlide.value,
                    child: AnimatedThemeCanvas(themeId: widget.themeId),
                  ),
                ),

                // Layer 3: message + Thanks button, settling in last
                FadeTransition(
                  opacity: _textFade,
                  child: SlideTransition(
                    position: _textSlide,
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 40,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'REMIND ME',
                              style: TextStyle(
                                color: Colors.white.withAlpha(130),
                                fontSize: 11,
                                letterSpacing: 2,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 32),
                            Text(
                              widget.message,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.w600,
                                height: 1.25,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Step away. Breathe.\nYou\'ve earned this moment.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white.withAlpha(140),
                                fontSize: 15,
                                height: 1.6,
                              ),
                            ),
                            const SizedBox(height: 48),
                            _ThanksButton(
                              loading: _dismissing,
                              onPressed: _onAcknowledge,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ThanksButton extends StatelessWidget {
  final bool loading;
  final VoidCallback onPressed;

  const _ThanksButton({required this.loading, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withAlpha(30),
      borderRadius: BorderRadius.circular(50),
      child: InkWell(
        borderRadius: BorderRadius.circular(50),
        onTap: loading ? null : onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            border: Border.all(color: Colors.white.withAlpha(60)),
          ),
          child: loading
              ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
          )
              : const Text(
            'Thanks ✦',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}