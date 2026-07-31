import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Draws an Ethiopian Orthodox cross that animates itself stroke-by-stroke.
class EthiopianCrossPainter extends CustomPainter {
  final double drawProgress; // 0 → 1
  final double glowProgress; // 0 → 1

  const EthiopianCrossPainter({
    required this.drawProgress,
    this.glowProgress = 0.0,
  });

  static const _gold = Colors.white;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = math.min(size.width, size.height) * 0.42;
    final path = _crossPath(cx, cy, r);

    if (glowProgress > 0) {
      canvas.drawPath(
        path,
        Paint()
          ..color = _gold.withValues(alpha: 0.18 * glowProgress)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 14
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
      );
    }

    final linePaint = Paint()
      ..color = _gold
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final metrics = path.computeMetrics().toList();
    final totalLen = metrics.fold(0.0, (s, m) => s + m.length);
    var drawn = 0.0;
    final target = totalLen * drawProgress.clamp(0.0, 1.0);

    for (final m in metrics) {
      if (drawn >= target) break;
      final seg = math.min(m.length, target - drawn);
      canvas.drawPath(m.extractPath(0, seg), linePaint);

      // Glowing tip traces the drawing head
      if (seg < m.length && drawProgress < 1.0) {
        final tan = m.getTangentForOffset(seg);
        if (tan != null) {
          canvas.drawCircle(
            tan.position,
            3.5,
            Paint()
              ..color = Colors.white.withValues(alpha: 0.9)
              ..style = PaintingStyle.fill
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5),
          );
        }
      }
      drawn += m.length;
    }
  }

  Path _crossPath(double cx, double cy, double r) {
    final p = Path();
    // Vertical bar
    p.moveTo(cx, cy - r);
    p.lineTo(cx, cy + r);
    // Main horizontal bar (slightly above center)
    final hy = cy - r * 0.18;
    p.moveTo(cx - r * 0.72, hy);
    p.lineTo(cx + r * 0.72, hy);
    // Top small crossbar
    p.moveTo(cx - r * 0.28, cy - r);
    p.lineTo(cx + r * 0.28, cy - r);
    // Left arm vertical crossbar
    p.moveTo(cx - r * 0.72, hy - r * 0.12);
    p.lineTo(cx - r * 0.72, hy + r * 0.12);
    // Right arm vertical crossbar
    p.moveTo(cx + r * 0.72, hy - r * 0.12);
    p.lineTo(cx + r * 0.72, hy + r * 0.12);
    // Bottom triple base bars (Trinity)
    p.moveTo(cx - r * 0.42, cy + r * 0.60);
    p.lineTo(cx + r * 0.42, cy + r * 0.60);
    p.moveTo(cx - r * 0.30, cy + r * 0.76);
    p.lineTo(cx + r * 0.30, cy + r * 0.76);
    p.moveTo(cx - r * 0.18, cy + r * 0.90);
    p.lineTo(cx + r * 0.18, cy + r * 0.90);
    // Diamond ornaments at arm tips
    _diamond(p, cx, cy - r, r * 0.065);
    _diamond(p, cx - r * 0.72, hy, r * 0.065);
    _diamond(p, cx + r * 0.72, hy, r * 0.065);
    return p;
  }

  void _diamond(Path p, double x, double y, double s) {
    p.moveTo(x, y - s);
    p.lineTo(x + s, y);
    p.lineTo(x, y + s);
    p.lineTo(x - s, y);
    p.close();
  }

  @override
  bool shouldRepaint(covariant EthiopianCrossPainter old) =>
      old.drawProgress != drawProgress || old.glowProgress != glowProgress;
}

/// Concentric rings that pulse outward from center — like waves of blessing.
class PulsingRingPainter extends CustomPainter {
  final double phase; // 0 → 1, repeating
  final Color color;

  const PulsingRingPainter({
    required this.phase,
    this.color = const Color(0xFFC9A227),
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final maxR = math.min(size.width, size.height) * 0.5;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    for (int i = 0; i < 4; i++) {
      final t = ((phase + i / 4.0) % 1.0);
      final r = maxR * t;
      paint.color = color.withValues(alpha: (1.0 - t) * 0.32);
      canvas.drawCircle(Offset(cx, cy), r, paint);
    }
  }

  @override
  bool shouldRepaint(covariant PulsingRingPainter old) => old.phase != phase;
}
