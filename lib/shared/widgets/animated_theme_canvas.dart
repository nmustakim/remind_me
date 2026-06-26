import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../painters/theme_painters.dart';

class AnimatedThemeCanvas extends StatefulWidget {
  final String themeId;
  final BorderRadius? borderRadius;

  const AnimatedThemeCanvas({
    super.key,
    required this.themeId,
    this.borderRadius,
  });

  @override
  State<AnimatedThemeCanvas> createState() => _AnimatedThemeCanvasState();
}

class _AnimatedThemeCanvasState extends State<AnimatedThemeCanvas>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  double _t = 0;
  List<Particle>? _particles;
  Size? _lastSize;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((elapsed) {
      if (!mounted) return;
      setState(() => _t = elapsed.inMilliseconds.toDouble());
    });
    _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final content = LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        if (_lastSize != size && widget.themeId == 'particleField') {
          _lastSize = size;
          _particles = createParticles(size);
        }
        return RepaintBoundary(
          child: CustomPaint(
            size: size,
            painter: buildThemePainter(widget.themeId, _t, _particles),
          ),
        );
      },
    );

    if (widget.borderRadius != null) {
      return ClipRRect(borderRadius: widget.borderRadius!, child: content);
    }
    return content;
  }
}
