import 'package:flutter/material.dart';
import 'package:church/app/theme.dart';

class EthiopianCrossDivider extends StatelessWidget {
  final double height;
  final Color? color;

  const EthiopianCrossDivider({
    super.key,
    this.height = 40,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final dividerColor = color ?? AppTheme.primaryGold;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      height: height,
      child: Row(
        children: [
          Expanded(
            child: Divider(
              color: dividerColor.withValues(alpha: 0.3),
              thickness: 1,
              endIndent: 10,
            ),
          ),
          CustomPaint(
            size: Size(height * 0.7, height),
            painter: LalibelaCrossPainter(color: dividerColor),
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
      ..style = PaintingStyle.fill
      ..strokeWidth = 2;

    final path = Path();
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 4; // cross arm thickness

    // Stylized cross shape
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

    // Draw detail line in center
    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawLine(Offset(cx, cy - size.height / 3), Offset(cx, cy + size.height / 3), linePaint);
    canvas.drawLine(Offset(cx - size.width / 3, cy), Offset(cx + size.width / 3, cy), linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
