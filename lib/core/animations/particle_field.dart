import 'dart:math' as math;
import 'package:flutter/material.dart';

class _Particle {
  final double x;
  final double startT;
  final double size;
  final double speed;
  final double opacity;
  final Color color;

  const _Particle({
    required this.x,
    required this.startT,
    required this.size,
    required this.speed,
    required this.opacity,
    required this.color,
  });
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double t;

  const _ParticlePainter(this.particles, this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    for (final p in particles) {
      final phase = (p.startT + t * p.speed) % 1.0;
      final y = size.height * (1.0 - phase);
      final fade = math.sin(phase * math.pi).clamp(0.0, 1.0);
      paint.color = p.color.withValues(alpha: p.opacity * fade);
      canvas.drawCircle(Offset(p.x * size.width, y), p.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter old) => old.t != t;
}

/// Renders floating particles that rise from bottom to top in a loop.
class ParticleField extends StatefulWidget {
  final int count;
  final List<Color> colors;
  final Widget? child;

  const ParticleField({
    super.key,
    this.count = 45,
    this.colors = const [Color(0xFFC9A227)],
    this.child,
  });

  @override
  State<ParticleField> createState() => _ParticleFieldState();
}

class _ParticleFieldState extends State<ParticleField>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_Particle> _particles;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    final rng = math.Random(42);
    _particles = List.generate(widget.count, (_) {
      final c = widget.colors[rng.nextInt(widget.colors.length)];
      return _Particle(
        x: rng.nextDouble(),
        startT: rng.nextDouble(),
        size: rng.nextDouble() * 2.2 + 0.6,
        speed: rng.nextDouble() * 0.35 + 0.12,
        opacity: rng.nextDouble() * 0.45 + 0.15,
        color: c,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, child) => CustomPaint(
        painter: _ParticlePainter(_particles, _controller.value),
        child: child,
      ),
      child: widget.child,
    );
  }
}
