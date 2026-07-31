import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:church/app/theme.dart';

/// Diagonal golden shimmer sweep — wrap any widget to make it look holographic.
class HolographicShimmer extends StatefulWidget {
  final Widget child;
  final Duration period;

  const HolographicShimmer({
    super.key,
    required this.child,
    this.period = const Duration(milliseconds: 3000),
  });

  @override
  State<HolographicShimmer> createState() => _HolographicShimmerState();
}

class _HolographicShimmerState extends State<HolographicShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.period)..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, child) {
        final t = _ctrl.value;
        return ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            begin: Alignment(-2.5 + t * 6, -0.5),
            end: Alignment(-1.0 + t * 6, 0.5),
            colors: const [
              Colors.transparent,
              Color(0x44006A4E),
              Color(0x33FFFFFF),
              Colors.transparent,
            ],
            stops: const [0.0, 0.42, 0.58, 1.0],
          ).createShader(bounds),
          blendMode: BlendMode.srcOver,
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

/// A sine wave that animates continuously — decorative bottom element.
class AnimatedWaveBackground extends StatefulWidget {
  final Color color;
  final double height;
  final double amplitude;

  const AnimatedWaveBackground({
    super.key,
    this.color = AppTheme.royalEmerald,
    this.height = 100,
    this.amplitude = 10,
  });

  @override
  State<AnimatedWaveBackground> createState() => _AnimatedWaveBgState();
}

class _AnimatedWaveBgState extends State<AnimatedWaveBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 4))
      ..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      width: double.infinity,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, _) => CustomPaint(
          size: Size.infinite,
          painter: _WavePainter(
            phase: _ctrl.value * 2 * math.pi,
            color: widget.color,
            amplitude: widget.amplitude,
          ),
        ),
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  final double phase;
  final Color color;
  final double amplitude;

  const _WavePainter({
    required this.phase,
    required this.color,
    required this.amplitude,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    const steps = 180;
    for (int i = 0; i <= steps; i++) {
      final x = size.width * i / steps;
      final y = size.height * 0.3 +
          amplitude * math.sin(2 * math.pi * i / steps + phase) +
          amplitude * 0.5 * math.sin(3 * math.pi * i / steps + phase * 1.3);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _WavePainter old) => old.phase != phase;
}

/// Spinning dashed-arc ring — used around icons/avatars.
class SpinningRing extends StatefulWidget {
  final Widget child;
  final double size;
  final Color color;
  final Duration period;

  const SpinningRing({
    super.key,
    required this.child,
    this.size = 72,
    this.color = AppTheme.imperialGold,
    this.period = const Duration(seconds: 7),
  });

  @override
  State<SpinningRing> createState() => _SpinningRingState();
}

class _SpinningRingState extends State<SpinningRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.period)..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, child) => Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(
              size: Size(widget.size, widget.size),
              painter: _DashedRingPainter(
                angle: _ctrl.value * 2 * math.pi,
                color: widget.color,
              ),
            ),
            child!,
          ],
        ),
        child: widget.child,
      ),
    );
  }
}

class _DashedRingPainter extends CustomPainter {
  final double angle;
  final Color color;

  const _DashedRingPainter({required this.angle, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2 - 2;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;

    const dashCount = 10;
    const dashLen = math.pi / 14;
    for (int i = 0; i < dashCount; i++) {
      final start = angle + (i / dashCount) * 2 * math.pi;
      final alpha = (math.sin(start) * 0.4 + 0.6).clamp(0.0, 1.0);
      paint.color = color.withValues(alpha: alpha);
      canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: r),
        start,
        dashLen,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRingPainter old) => old.angle != angle;
}
