import 'package:flutter/material.dart';
import 'package:church/app/theme.dart';

/// Horizontal divider with an animated pulsing Ethiopian cross in the center.
class EthiopianCrossDivider extends StatefulWidget {
  final double height;
  final Color? color;

  const EthiopianCrossDivider({
    super.key,
    this.height = 40,
    this.color,
  });

  @override
  State<EthiopianCrossDivider> createState() => _EthiopianCrossDividerState();
}

class _EthiopianCrossDividerState extends State<EthiopianCrossDivider>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final Animation<double> _glow;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _scale = Tween<double>(begin: 1.0, end: 1.18).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
    _glow = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dividerColor = widget.color ?? AppTheme.imperialGold;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      height: widget.height,
      child: Row(
        children: [
          Expanded(
            child: Divider(
              color: dividerColor.withValues(alpha: 0.3),
              thickness: 1,
              endIndent: 10,
            ),
          ),
          AnimatedBuilder(
            animation: _ctrl,
            builder: (_, _) => Transform.scale(
              scale: _scale.value,
              child: Container(
                decoration: _glow.value > 0.1
                    ? BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: dividerColor.withValues(alpha: 0.28 * _glow.value),
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                        ],
                      )
                    : null,
                child: CustomPaint(
                  size: Size(widget.height * 0.7, widget.height),
                  painter: LalibelaCrossPainter(color: dividerColor),
                ),
              ),
            ),
          ),
          Expanded(
            child: Divider(
              color: dividerColor.withValues(alpha: 0.3),
              thickness: 1,
              indent: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class LalibelaCrossPainter extends CustomPainter {
  final Color color;

  LalibelaCrossPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 4;

    path.moveTo(cx - r, cy - size.height / 2);
    path.lineTo(cx + r, cy - size.height / 2);
    path.lineTo(cx + r, cy - r);
    path.lineTo(cx + size.width / 2, cy - r);
    path.lineTo(cx + size.width / 2, cy + r);
    path.lineTo(cx + r, cy + r);
    path.lineTo(cx + r, cy + size.height / 2);
    path.lineTo(cx - r, cy + size.height / 2);
    path.lineTo(cx - r, cy + r);
    path.lineTo(cx - size.width / 2, cy + r);
    path.lineTo(cx - size.width / 2, cy - r);
    path.lineTo(cx - r, cy - r);
    path.close();

    canvas.drawPath(path, paint);

    canvas.drawLine(
      Offset(cx, cy - size.height / 3),
      Offset(cx, cy + size.height / 3),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    canvas.drawLine(
      Offset(cx - size.width / 3, cy),
      Offset(cx + size.width / 3, cy),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
