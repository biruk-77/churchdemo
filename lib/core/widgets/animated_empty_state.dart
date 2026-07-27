import 'package:flutter/material.dart';
import 'package:church/app/theme.dart';
import 'package:church/core/animations/cross_painter.dart';
import 'package:church/core/animations/typewriter_text.dart';

/// Shown when a list has no data. The cross draws itself, then text types in.
class AnimatedEmptyState extends StatefulWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;

  const AnimatedEmptyState({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
  });

  @override
  State<AnimatedEmptyState> createState() => _AnimatedEmptyStateState();
}

class _AnimatedEmptyStateState extends State<AnimatedEmptyState>
    with TickerProviderStateMixin {
  late final AnimationController _crossCtrl;
  late final AnimationController _floatCtrl;
  late final Animation<double> _crossDraw;
  late final Animation<double> _crossGlow;
  late final Animation<double> _crossFade;
  late final Animation<Offset> _float;

  @override
  void initState() {
    super.initState();

    _crossCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..forward();

    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);

    _crossDraw = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _crossCtrl, curve: const Interval(0, 0.6, curve: Curves.easeInOut)),
    );
    _crossGlow = Tween<double>(begin: 0, end: 0.7).animate(
      CurvedAnimation(parent: _crossCtrl, curve: const Interval(0.55, 0.85, curve: Curves.easeOut)),
    );
    _crossFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _crossCtrl, curve: const Interval(0, 0.25, curve: Curves.easeIn)),
    );
    _float = Tween<Offset>(
      begin: const Offset(0, 0.012),
      end: const Offset(0, -0.012),
    ).animate(CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _crossCtrl.dispose();
    _floatCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Floating animated cross
            AnimatedBuilder(
              animation: Listenable.merge([_crossCtrl, _floatCtrl]),
              builder: (_, _) => FadeTransition(
                opacity: _crossFade,
                child: SlideTransition(
                  position: _float,
                  child: SizedBox(
                    width: 100,
                    height: 100,
                    child: CustomPaint(
                      painter: EthiopianCrossPainter(
                        drawProgress: _crossDraw.value,
                        glowProgress: _crossGlow.value,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Typewriter title — starts after cross is halfway drawn
            TypewriterText(
              text: widget.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryBlue,
              ),
              textAlign: TextAlign.center,
              startDelay: const Duration(milliseconds: 800),
              showCursor: false,
            ),

            if (widget.subtitle != null) ...[
              const SizedBox(height: 10),
              TypewriterText(
                text: widget.subtitle!,
                style: const TextStyle(fontSize: 13, color: Colors.black45, height: 1.5),
                textAlign: TextAlign.center,
                startDelay: const Duration(milliseconds: 1400),
                showCursor: false,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
