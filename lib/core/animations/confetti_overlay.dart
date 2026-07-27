import 'dart:math' as math;
import 'package:flutter/material.dart';

class _Piece {
  final double x;
  final double startY;
  final double vx;
  final double vy;
  final double rot;
  final double rotV;
  final Color color;
  final double size;
  final int shape; // 0=rect 1=circle 2=star

  const _Piece({
    required this.x,
    required this.startY,
    required this.vx,
    required this.vy,
    required this.rot,
    required this.rotV,
    required this.color,
    required this.size,
    required this.shape,
  });
}

class _ConfettiPainter extends CustomPainter {
  final List<_Piece> pieces;
  final double t; // 0 → 1

  const _ConfettiPainter(this.pieces, this.t);

  static const _gravity = 0.22;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    for (final p in pieces) {
      final px = (p.x + p.vx * t) * size.width;
      final py = (p.startY + p.vy * t + _gravity * t * t) * size.height;
      if (py > size.height * 1.1) continue;
      final fade = t < 0.6 ? 1.0 : (1.0 - (t - 0.6) / 0.4).clamp(0.0, 1.0);
      paint.color = p.color.withValues(alpha: fade);
      canvas.save();
      canvas.translate(px, py);
      canvas.rotate(p.rot + p.rotV * t * 8);
      switch (p.shape) {
        case 0:
          canvas.drawRect(
            Rect.fromCenter(
              center: Offset.zero,
              width: p.size * 1.6,
              height: p.size * 0.5,
            ),
            paint,
          );
          break;
        case 1:
          canvas.drawCircle(Offset.zero, p.size * 0.45, paint);
          break;
        default:
          _star(canvas, p.size * 0.55, paint);
      }
      canvas.restore();
    }
  }

  void _star(Canvas canvas, double r, Paint paint) {
    final path = Path();
    for (int i = 0; i < 5; i++) {
      final a1 = -math.pi / 2 + 2 * math.pi * i / 5;
      final a2 = a1 + math.pi / 5;
      final outer = Offset(math.cos(a1) * r, math.sin(a1) * r);
      final inner = Offset(math.cos(a2) * r * 0.4, math.sin(a2) * r * 0.4);
      if (i == 0) {
        path.moveTo(outer.dx, outer.dy);
      } else {
        path.lineTo(outer.dx, outer.dy);
      }
      path.lineTo(inner.dx, inner.dy);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter old) => old.t != t;
}

/// Ethiopian Orthodox colored confetti burst — plays once on construction.
class ConfettiOverlay extends StatefulWidget {
  const ConfettiOverlay({super.key});

  @override
  State<ConfettiOverlay> createState() => _ConfettiOverlayState();
}

class _ConfettiOverlayState extends State<ConfettiOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_Piece> _pieces;

  static const _colors = [
    Color(0xFFC9A227), // Ethiopian gold
    Color(0xFF1A237E), // Orthodox blue
    Color(0xFF2E7D32), // Ethiopian green
    Color(0xFFB71C1C), // Ethiopian red
    Colors.white,
    Color(0xFFFFEB3B), // bright yellow
    Color(0xFF66BB6A), // light green
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..forward();

    final rng = math.Random();
    _pieces = List.generate(75, (_) {
      return _Piece(
        x: rng.nextDouble() * 0.8 + 0.1,
        startY: -rng.nextDouble() * 0.15,
        vx: (rng.nextDouble() - 0.5) * 0.3,
        vy: rng.nextDouble() * 0.25 + 0.1,
        rot: rng.nextDouble() * 2 * math.pi,
        rotV: (rng.nextDouble() - 0.5) * 3.5,
        color: _colors[rng.nextInt(_colors.length)],
        size: rng.nextDouble() * 10 + 5,
        shape: rng.nextInt(3),
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
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, _) => CustomPaint(
          painter: _ConfettiPainter(_pieces, _controller.value),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}
