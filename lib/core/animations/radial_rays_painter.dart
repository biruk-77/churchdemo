import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Holy-light burst of radiating rays that expand then fade.
class RadialRaysPainter extends CustomPainter {
  final double progress; // 0 → 1
  final Color color;
  final int rayCount;

  const RadialRaysPainter({
    required this.progress,
    this.color = const Color(0xFFC9A227),
    this.rayCount = 12,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;
    final cx = size.width / 2;
    final cy = size.height / 2;
    final maxLen = math.min(size.width, size.height) * 0.52;

    // First half: expand. Second half: fade out.
    final expand = math.min(progress * 2.0, 1.0);
    final fade = progress < 0.5 ? 1.0 : (1.0 - (progress - 0.5) * 2.0);

    final paint = Paint()
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < rayCount; i++) {
      final angle = (i / rayCount) * 2 * math.pi;
      final len = maxLen * expand;
      final inner = len * 0.22;

      // Multi-layer glow (widest layer drawn first = underneath)
      for (int layer = 3; layer >= 0; layer--) {
        final alpha = (0.45 - layer * 0.09) * fade;
        paint
          ..color = color.withValues(alpha: alpha.clamp(0.0, 1.0))
          ..strokeWidth = (layer + 1) * 2.5;
        canvas.drawLine(
          Offset(cx + math.cos(angle) * inner, cy + math.sin(angle) * inner),
          Offset(cx + math.cos(angle) * len, cy + math.sin(angle) * len),
          paint,
        );
      }
    }

    // Center bloom
    canvas.drawCircle(
      Offset(cx, cy),
      42 * expand,
      Paint()
        ..color = color.withValues(alpha: 0.22 * fade)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20),
    );
  }

  @override
  bool shouldRepaint(covariant RadialRaysPainter old) =>
      old.progress != progress;
}

/// Animated circle + checkmark that draws itself progressively.
class CheckmarkPainter extends CustomPainter {
  final double progress; // 0 → 1

  const CheckmarkPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = math.min(size.width, size.height) / 2 - 4;

    // Circle draws for the first 66 %
    final circleP = (progress * 1.5).clamp(0.0, 1.0);
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r),
      -math.pi / 2,
      2 * math.pi * circleP,
      false,
      Paint()
        ..color = Colors.green
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.5
        ..strokeCap = StrokeCap.round,
    );

    // Checkmark appears in the second half
    if (progress > 0.5) {
      final cp = ((progress - 0.5) * 2).clamp(0.0, 1.0);
      final p1 = Offset(cx - r * 0.40, cy);
      final p2 = Offset(cx - r * 0.08, cy + r * 0.38);
      final p3 = Offset(cx + r * 0.47, cy - r * 0.32);

      final checkPath = Path()
        ..moveTo(p1.dx, p1.dy)
        ..lineTo(p2.dx, p2.dy)
        ..lineTo(p3.dx, p3.dy);

      final metrics = checkPath.computeMetrics().toList();
      final totalLen = metrics.fold(0.0, (s, m) => s + m.length);
      final target = totalLen * cp;
      var drawn = 0.0;

      final checkPaint = Paint()
        ..color = Colors.green
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      for (final m in metrics) {
        if (drawn >= target) break;
        final seg = math.min(m.length, target - drawn);
        canvas.drawPath(m.extractPath(0, seg), checkPaint);
        drawn += m.length;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CheckmarkPainter old) =>
      old.progress != progress;
}
