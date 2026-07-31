import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:church/app/theme.dart';

/// Animated circular progress ring showing contribution progress toward a goal.
class ContributionProgressRing extends StatefulWidget {
  final double current;
  final double goal;
  final String label;

  const ContributionProgressRing({
    super.key,
    required this.current,
    required this.goal,
    this.label = 'Annual Goal',
  });

  @override
  State<ContributionProgressRing> createState() => _ContributionProgressRingState();
}

class _ContributionProgressRingState extends State<ContributionProgressRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _progress;
  late final Animation<double> _glowPulse;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..forward();

    _progress = Tween<double>(begin: 0, end: (widget.current / widget.goal).clamp(0, 1)).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0, 0.8, curve: Curves.easeOutCubic)),
    );
    _glowPulse = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0.7, 1.0, curve: Curves.easeInOut)),
    );
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
      builder: (_, _) => SizedBox(
        width: 140,
        height: 140,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(
              size: const Size(140, 140),
              painter: _ProgressRingPainter(
                progress: _progress.value,
                glowIntensity: _glowPulse.value,
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${(_progress.value * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.royalEmerald,
                  ),
                ),
                Text(
                  widget.label,
                  style: const TextStyle(fontSize: 10, color: Colors.black45, letterSpacing: 0.3),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressRingPainter extends CustomPainter {
  final double progress;
  final double glowIntensity;

  const _ProgressRingPainter({required this.progress, required this.glowIntensity});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2 - 10;
    final rect = Rect.fromCircle(center: Offset(cx, cy), radius: r);
    final sweepAngle = 2 * math.pi * progress;

    // Track ring
    canvas.drawCircle(
      Offset(cx, cy),
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10
        ..color = AppTheme.imperialGold.withValues(alpha: 0.1),
    );

    if (progress > 0) {
      // Glow shadow under the arc
      canvas.drawArc(
        rect,
        -math.pi / 2,
        sweepAngle,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 16
          ..strokeCap = StrokeCap.round
          ..color = AppTheme.imperialGold.withValues(alpha: 0.18 * glowIntensity)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );

      // Main arc with sweep gradient
      canvas.drawArc(
        rect,
        -math.pi / 2,
        sweepAngle,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 10
          ..strokeCap = StrokeCap.round
          ..shader = SweepGradient(
            center: Alignment.center,
            startAngle: -math.pi / 2,
            endAngle: -math.pi / 2 + sweepAngle,
            colors: const [Color(0xFF004D38), Color(0xFF006A4E), Color(0xFF00A877)],
          ).createShader(rect),
      );

      // Glowing tip dot
      final tipAngle = -math.pi / 2 + sweepAngle;
      final tx = cx + math.cos(tipAngle) * r;
      final ty = cy + math.sin(tipAngle) * r;

      canvas.drawCircle(
        Offset(tx, ty),
        8,
        Paint()
          ..color = AppTheme.imperialGold.withValues(alpha: 0.4 * glowIntensity)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
      );
      canvas.drawCircle(
        Offset(tx, ty),
        4,
        Paint()..color = Colors.white,
      );
      canvas.drawCircle(
        Offset(tx, ty),
        2.5,
        Paint()..color = AppTheme.imperialGold,
      );
    }

    // Milestone marker dots at 25 %, 50 %, 75 %
    for (final milestone in [0.25, 0.5, 0.75]) {
      final angle = -math.pi / 2 + 2 * math.pi * milestone;
      final mx = cx + math.cos(angle) * r;
      final my = cy + math.sin(angle) * r;
      final achieved = progress >= milestone;
      canvas.drawCircle(
        Offset(mx, my),
        5,
        Paint()..color = achieved ? AppTheme.royalEmerald : Colors.grey.withValues(alpha: 0.25),
      );
      if (achieved) {
        canvas.drawCircle(
          Offset(mx, my),
          2.5,
          Paint()..color = Colors.white,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ProgressRingPainter old) =>
      old.progress != progress || old.glowIntensity != glowIntensity;
}
