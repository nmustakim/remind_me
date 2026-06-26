import 'dart:math' as math;
import 'package:flutter/material.dart';

abstract class BaseThemePainter extends CustomPainter {
  final double t;
  const BaseThemePainter(this.t);

  @override
  bool shouldRepaint(covariant BaseThemePainter old) => true;
}

// ───────── Shared particle model (used by Particle Field theme) ─────────
class Particle {
  double x, y, vx, vy, r, hue;
  Particle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.r,
    required this.hue,
  });

  factory Particle.random(Size size, math.Random rng) => Particle(
        x: rng.nextDouble() * size.width,
        y: rng.nextDouble() * size.height,
        vx: (rng.nextDouble() - 0.5) * 0.6,
        vy: (rng.nextDouble() - 0.5) * 0.6,
        r: rng.nextDouble() * 2 + 0.5,
        hue: 200 + rng.nextDouble() * 80,
      );

  void update(Size size) {
    x += vx;
    y += vy;
    if (x < 0 || x > size.width) vx = -vx;
    if (y < 0 || y > size.height) vy = -vy;
  }
}

List<Particle> createParticles(Size size) {
  final rng = math.Random(1234);
  return List.generate(80, (_) => Particle.random(size, rng));
}

// ───────── 1. Aurora Waves ─────────
class AuroraPainter extends BaseThemePainter {
  const AuroraPainter(super.t);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFF040812));

    final bands = [
      const _Band(0xFF1a3a6a, 0xFF0d2b4e, 0.2, 60, 0.008, 0),
      const _Band(0xFF1e5c3a, 0xFF0a3d28, 0.4, 80, 0.006, 1.2),
      const _Band(0xFF3d1e6e, 0xFF1a0a3d, 0.6, 50, 0.010, 2.4),
      const _Band(0xFF1a5c6e, 0xFF0a3d4e, 0.35, 70, 0.007, 3.6),
    ];

    for (final b in bands) {
      final yc = size.height * b.yFactor + math.sin(t * b.speed + b.phase) * b.amplitude;
      final shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.transparent,
          Color(b.color1).withAlpha(120),
          Color(b.color2).withAlpha(180),
          Color(b.color1).withAlpha(80),
          Colors.transparent,
        ],
        stops: const [0.0, 0.3, 0.5, 0.7, 1.0],
      ).createShader(Rect.fromLTWH(0, yc - 120, size.width, 240));
      canvas.drawRect(Offset.zero & size, Paint()..shader = shader);
    }

    final starPaint = Paint()..style = PaintingStyle.fill;
    for (int i = 0; i < 80; i++) {
      final sx = math.sin(i * 2.3 + t * 0.002) * size.width * 0.5 + size.width * 0.5;
      final sy = math.cos(i * 1.7 + t * 0.003) * size.height * 0.5 + size.height * 0.5;
      final a = (0.3 + 0.3 * math.sin(t * 0.05 + i)).clamp(0.0, 1.0);
      starPaint.color = Color.fromRGBO(200, 220, 255, a);
      canvas.drawCircle(Offset(sx, sy), 0.7, starPaint);
    }
  }
}

class _Band {
  final int color1, color2;
  final double yFactor, amplitude, speed, phase;
  const _Band(this.color1, this.color2, this.yFactor, this.amplitude, this.speed, this.phase);
}

// ───────── 2. Glowing Orb ─────────
class GlowingOrbPainter extends BaseThemePainter {
  const GlowingOrbPainter(super.t);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFF060610));

    final cx = size.width / 2;
    final cy = size.height / 2 - 20;
    final p = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < 5; i++) {
      final r = (120 - i * 18) * (1 + 0.06 * math.sin(t * 0.04 + i));
      p.color = const Color(0xFF7C6FFF).withAlpha((10 + i * 8).clamp(0, 255));
      canvas.drawCircle(Offset(cx, cy), r, p);
    }

    final g = const RadialGradient(
      center: Alignment(-0.2, -0.2),
      colors: [Color(0xFFDDD7FF), Color(0xFF9D8FFF), Color(0x6650B4E0)],
    ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: 50));
    canvas.drawCircle(Offset(cx, cy), 50, Paint()..shader = g);

    for (int j = 0; j < 6; j++) {
      final angle = t * 0.015 + j * (math.pi * 2 / 6);
      final r2 = 85 + 10 * math.sin(t * 0.02 + j);
      final px = cx + math.cos(angle) * r2;
      final py = cy + math.sin(angle) * r2;
      final a = (0.4 + 0.4 * math.sin(t * 0.03 + j)).clamp(0.0, 1.0);
      p.color = Color.fromRGBO(180, 170, 255, a);
      canvas.drawCircle(Offset(px, py), 3 + math.sin(t * 0.03 + j) * 2, p);
    }
  }
}

// ───────── 3. Ripple Water ─────────
class RippleWaterPainter extends BaseThemePainter {
  const RippleWaterPainter(super.t);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFF020C14));

    final cx = size.width / 2;
    final cy = size.height / 2;
    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    for (int i = 0; i < 8; i++) {
      final r = ((t * 1.5 + i * 60) % 320).toDouble();
      final a = (0.5 - r / 320).clamp(0.0, 1.0);
      strokePaint.color = Color.fromRGBO(61, 217, 164, a);
      canvas.drawCircle(Offset(cx, cy), r, strokePaint);
    }

    final p = Paint()..style = PaintingStyle.fill;
    for (int j = 0; j < 40; j++) {
      final bx = math.sin(j * 1.9 + t * 0.008) * size.width * 0.45 + cx;
      final by = math.cos(j * 2.3 + t * 0.006) * size.height * 0.45 + cy;
      final a = (0.15 + 0.2 * math.sin(t * 0.04 + j)).clamp(0.0, 1.0);
      p.color = Color.fromRGBO(100, 230, 200, a);
      canvas.drawCircle(Offset(bx, by), 1.5, p);
    }
  }
}

// ───────── 4. Particle Field ─────────
class ParticleFieldPainter extends BaseThemePainter {
  final List<Particle> particles;
  const ParticleFieldPainter(super.t, this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFF040410).withAlpha(48));

    final p = Paint()..style = PaintingStyle.fill;
    final lp = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    for (final pt in particles) {
      pt.update(size);
      final a = (0.4 + 0.4 * math.sin(t * 0.03 + pt.hue)).clamp(0.0, 1.0);
      p.color = HSVColor.fromAHSV(a, pt.hue, 0.8, 0.85).toColor();
      canvas.drawCircle(Offset(pt.x, pt.y), pt.r, p);
    }

    for (int i = 0; i < particles.length; i++) {
      for (int j = i + 1; j < particles.length; j++) {
        final a = particles[i];
        final b = particles[j];
        final d = math.sqrt(math.pow(a.x - b.x, 2) + math.pow(a.y - b.y, 2));
        if (d < 60) {
          lp.color = Color.fromRGBO(150, 180, 255, 0.12 * (1 - d / 60));
          canvas.drawLine(Offset(a.x, a.y), Offset(b.x, b.y), lp);
        }
      }
    }
  }
}

// ───────── 5. Geometric Motion ─────────
class GeometricPainter extends BaseThemePainter {
  const GeometricPainter(super.t);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFF060612));

    final cx = size.width / 2;
    final cy = size.height / 2;
    final sp = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    canvas.save();
    canvas.translate(cx, cy);

    for (int k = 0; k < 6; k++) {
      canvas.save();
      canvas.rotate(t * 0.005 * (k % 2 == 0 ? 1 : -1) + k * math.pi / 3);
      final sz = (60 + k * 35).toDouble();
      sp.color = const Color(0xFF7C6FFF).withAlpha((20 + k * 10).clamp(0, 255));
      final path = Path();
      for (int s = 0; s < 6; s++) {
        final a = s * math.pi / 3 - math.pi / 2;
        final px = math.cos(a) * sz;
        final py = math.sin(a) * sz;
        if (s == 0) {
          path.moveTo(px, py);
        } else {
          path.lineTo(px, py);
        }
      }
      path.close();
      canvas.drawPath(path, sp);
      canvas.restore();
    }
    canvas.restore();

    final pp = Paint()..style = PaintingStyle.fill;
    for (int p = 0; p < 30; p++) {
      final px = math.sin(p * 2.1 + t * 0.005) * size.width * 0.4 + cx;
      final py = math.cos(p * 1.8 + t * 0.004) * size.height * 0.4 + cy;
      final a = (0.2 + 0.3 * math.sin(t * 0.04 + p)).clamp(0.0, 1.0);
      pp.color = Color.fromRGBO(180, 160, 255, a);
      canvas.drawRect(Rect.fromLTWH(px - 1, py - 1, 2, 2), pp);
    }
  }
}

// ───────── 6. Sunrise Gradient ─────────
class SunrisePainter extends BaseThemePainter {
  const SunrisePainter(super.t);

  @override
  void paint(Canvas canvas, Size size) {
    final shift = math.sin(t * 0.005) * 0.1;
    final bg = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: const [
        Color(0xFF0A0414),
        Color(0xFF1A0A2E),
        Color(0xFF4A1520),
        Color(0xFF8A3010),
        Color(0xFFCC5520),
        Color(0xFFFF8840),
      ],
      stops: [0.0, 0.3 + shift, 0.55 + shift, 0.75 + shift, 0.9, 1.0],
    ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, Paint()..shader = bg);

    final sy = size.height * (0.62 + shift);
    final sunGlow = const RadialGradient(
      colors: [Color(0xE5FFB43C), Color(0x66FF6414), Colors.transparent],
      stops: [0.0, 0.3, 1.0],
    ).createShader(Rect.fromCircle(center: Offset(size.width / 2, sy), radius: size.width * 0.6));
    canvas.drawRect(Offset.zero & size, Paint()..shader = sunGlow);

    final arc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    for (int r = 1; r <= 4; r++) {
      final rr = r * 18 * (1 + 0.05 * math.sin(t * 0.04));
      arc.color = const Color(0xFFFFC850).withAlpha((76 - r * 12).clamp(0, 255));
      canvas.drawArc(
        Rect.fromCircle(center: Offset(size.width / 2, sy), radius: rr),
        math.pi,
        math.pi,
        false,
        arc,
      );
    }

    final sp = Paint()..style = PaintingStyle.fill;
    for (int s = 0; s < 50; s++) {
      final sx = math.sin(s * 2.7 + t * 0.003) * size.width * 0.5 + size.width / 2;
      final sy2 = sy - 20 - math.cos(s * 1.9 + t * 0.002) * 60 - s * 1.5;
      if (sy2 < 0) continue;
      final a = (0.2 + 0.3 * math.sin(t * 0.04 + s)).clamp(0.0, 1.0);
      sp.color = Color.fromRGBO(255, 220, 150, a);
      canvas.drawCircle(Offset(sx, sy2), 0.8, sp);
    }
  }
}

// ───────── 7. Floating Crystal ─────────
class FloatingCrystalPainter extends BaseThemePainter {
  const FloatingCrystalPainter(super.t);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFF04080F));

    final cx = size.width / 2;
    final cy = size.height * 0.43;
    final pulse = 1 + 0.04 * math.sin(t * 0.04);

    canvas.save();
    canvas.translate(cx, cy);
    canvas.scale(pulse, pulse);
    canvas.translate(-cx, -cy);

    final top = Offset(cx, size.height * 0.15);
    final right = Offset(cx * 1.44, size.height * 0.38);
    final left = Offset(cx * 0.56, size.height * 0.38);
    final bottomRight = Offset(cx * 1.3, size.height * 0.62);
    final bottomLeft = Offset(cx * 0.7, size.height * 0.62);
    final bottom = Offset(cx, size.height * 0.70);
    final center = Offset(cx, cy);

    final shards = [
      _Shard([top, right, center], 0xFF1A3A6A, 0x28),
      _Shard([top, left, center], 0xFF2A4A8A, 0x20),
      _Shard([right, bottomRight, center], 0xFF1450F0, 0x2E),
      _Shard([left, bottomLeft, center], 0xFF1878FF, 0x22),
      _Shard([bottomRight, bottom, center], 0xFF1464C8, 0x28),
      _Shard([bottomLeft, bottom, center], 0xFF1A50A0, 0x1A),
    ];

    final fillPaint = Paint()..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5
      ..color = const Color(0xFFB4DCFF).withAlpha(76);

    for (final s in shards) {
      final path = Path()
        ..moveTo(s.pts[0].dx, s.pts[0].dy)
        ..lineTo(s.pts[1].dx, s.pts[1].dy)
        ..lineTo(s.pts[2].dx, s.pts[2].dy)
        ..close();
      fillPaint.color = Color(s.color).withAlpha(s.alpha);
      canvas.drawPath(path, fillPaint);
      canvas.drawPath(path, strokePaint);
    }

    canvas.restore();

    final gp = Paint()..style = PaintingStyle.fill;
    for (int i = 0; i < 20; i++) {
      final gx = math.sin(i * 3.1 + t * 0.006) * size.width * 0.4 + cx;
      final gy = math.cos(i * 2.3 + t * 0.005) * size.height * 0.35 + cy;
      final a = (0.2 + 0.4 * math.sin(t * 0.05 + i)).clamp(0.0, 1.0);
      gp.color = Color.fromRGBO(180, 220, 255, a);
      canvas.drawRect(Rect.fromLTWH(gx - 0.8, gy - 0.8, 1.6, 1.6), gp);
    }
  }
}

class _Shard {
  final List<Offset> pts;
  final int color, alpha;
  const _Shard(this.pts, this.color, this.alpha);
}

// ───────── 8. Neon Rings ─────────
class NeonRingsPainter extends BaseThemePainter {
  const NeonRingsPainter(super.t);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFF030308));

    final cx = size.width / 2;
    final cy = size.height / 2 - 10;
    const colors = [
      Color(0xFFFF6BBD),
      Color(0xFF7C6FFF),
      Color(0xFF3DD9A4),
      Color(0xFFFFB347),
      Color(0xFFFF7E6B),
    ];

    final sp = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 5; i++) {
      final r = 30.0 + i * 38 + math.sin(t * 0.02 + i * 0.8) * 8;
      final angle = t * 0.01 * (i % 2 == 0 ? 1 : -1);
      final sweep = math.pi * 2 * (0.6 + 0.3 * math.sin(t * 0.015 + i));
      final a = (0.5 + 0.4 * math.sin(t * 0.025 + i)).clamp(0.0, 1.0);

      canvas.save();
      canvas.translate(cx, cy);
      canvas.rotate(angle);
      sp.color = colors[i].withAlpha((a * 255).round());
      canvas.drawArc(Rect.fromCircle(center: Offset.zero, radius: r), 0, sweep, false, sp);
      canvas.restore();
    }

    canvas.drawCircle(
      Offset(cx, cy),
      8,
      Paint()
        ..style = PaintingStyle.fill
        ..color = const Color(0xD9FFFFFF),
    );
  }
}

// ───────── 9. Sand Flow ─────────
class SandFlowPainter extends BaseThemePainter {
  const SandFlowPainter(super.t);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFF0D0806));

    final bg = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.transparent,
        const Color(0xFF281805).withAlpha(76),
        const Color(0xFF784614).withAlpha(128),
      ],
    ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, Paint()..shader = bg);

    final sp = Paint()..style = PaintingStyle.fill;
    for (int i = 0; i < 120; i++) {
      final prog = ((t * 0.4 + i * 60) % (size.height + 40)) - 20;
      final sx = math.sin(i * 2.3 + t * 0.01) * 40 + size.width * (i / 120);
      final sz = 0.8 + math.sin(i * 3.1) * 0.4;
      final a = (0.2 + 0.4 * (math.sin(i * 1.7 + t * 0.02)).abs()).clamp(0.0, 1.0);
      sp.color = Color.fromRGBO(200, 140, 60, a);
      canvas.drawCircle(Offset(sx, prog), sz, sp);
    }

    final ly = size.height * 0.45 + math.sin(t * 0.008) * 30;
    final lg = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Colors.transparent, const Color(0xFFB47832).withAlpha(38), Colors.transparent],
    ).createShader(Rect.fromLTWH(0, ly - 30, size.width, 60));
    canvas.drawRect(Offset.zero & size, Paint()..shader = lg);
  }
}

// ───────── 10. Drifting Clouds ─────────
class DriftingCloudsPainter extends BaseThemePainter {
  const DriftingCloudsPainter(super.t);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFF06080E));

    final clouds = [
      const _Cloud(0.2, 0.3, 60, 0.8, 0.00006),
      const _Cloud(0.6, 0.2, 80, 0.6, 0.00004),
      const _Cloud(0.1, 0.55, 50, 0.5, 0.00005),
      const _Cloud(0.5, 0.45, 70, 0.7, 0.00007),
    ];

    for (final c in clouds) {
      final x = (c.xFactor * size.width + t * c.speed * size.width) % size.width;
      final y = c.yFactor * size.height;
      _drawCloud(canvas, size, x, y, c.sz, c.alpha);
      if (x > size.width - 80) _drawCloud(canvas, size, x - size.width, y, c.sz, c.alpha);
    }

    final sp = Paint()..style = PaintingStyle.fill;
    for (int s = 0; s < 60; s++) {
      final sx = math.sin(s * 3.7 + t * 0.004) * size.width * 0.5 + size.width / 2;
      final sy = math.cos(s * 2.1 + t * 0.003) * size.height * 0.45 + size.height / 2;
      final a = (0.25 + 0.25 * math.sin(t * 0.04 + s)).clamp(0.0, 1.0);
      sp.color = Color.fromRGBO(220, 230, 255, a);
      canvas.drawCircle(Offset(sx, sy), 0.6, sp);
    }
  }

  void _drawCloud(Canvas canvas, Size size, double x, double y, double sz, double alpha) {
    final offsets = [
      const Offset(0, 0),
      Offset(sz * 0.4, -sz * 0.2),
      Offset(sz * 0.8, 0),
      Offset(-sz * 0.3, -sz * 0.1),
      Offset(sz * 1.1, -sz * 0.15),
    ];
    for (final o in offsets) {
      final center = Offset(x + o.dx, y + o.dy);
      final g = RadialGradient(
        colors: [
          const Color(0xFFC8D2F0).withAlpha((alpha * 0.3 * 255).round()),
          const Color(0xFF96AADC).withAlpha((alpha * 0.15 * 255).round()),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: sz * 0.7));
      canvas.drawRect(Offset.zero & size, Paint()..shader = g);
    }
  }
}

class _Cloud {
  final double xFactor, yFactor, sz, alpha, speed;
  const _Cloud(this.xFactor, this.yFactor, this.sz, this.alpha, this.speed);
}

// ───────── Factory ─────────
CustomPainter buildThemePainter(String themeId, double t, List<Particle>? particles) {
  switch (themeId) {
    case 'aurora':
      return AuroraPainter(t);
    case 'glowingOrb':
      return GlowingOrbPainter(t);
    case 'rippleWater':
      return RippleWaterPainter(t);
    case 'particleField':
      return ParticleFieldPainter(t, particles ?? const []);
    case 'geometric':
      return GeometricPainter(t);
    case 'sunrise':
      return SunrisePainter(t);
    case 'floatingCrystal':
      return FloatingCrystalPainter(t);
    case 'neonRings':
      return NeonRingsPainter(t);
    case 'sandFlow':
      return SandFlowPainter(t);
    case 'driftingClouds':
      return DriftingCloudsPainter(t);
    default:
      return AuroraPainter(t);
  }
}
