import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../animations/cross_painter.dart';

class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
  });

  final bool isLoading;
  final Widget child;
  final String? message;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black.withValues(alpha: 0.48),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 28),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.14),
                      blurRadius: 28,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const _CrossSpinner(),
                    if (message != null) ...[
                      const SizedBox(height: 18),
                      Text(
                        message!,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Ethiopian cross that draws itself, holds, then erases — on repeat.
class _CrossSpinner extends StatefulWidget {
  const _CrossSpinner();

  @override
  State<_CrossSpinner> createState() => _CrossSpinnerState();
}

class _CrossSpinnerState extends State<_CrossSpinner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _draw;
  late final Animation<double> _glow;
  late final Animation<double> _rings;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    // Phase 1: draw (0→55%), Phase 2: hold (55→75%), Phase 3: erase (75→100%)
    _draw = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 55),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 25),
    ]).animate(_ctrl);

    _glow = TweenSequence([
      TweenSequenceItem(tween: ConstantTween(0.0), weight: 45),
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 35),
    ]).animate(_ctrl);

    _rings = _ctrl; // rings use raw controller value as phase
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
        width: 72,
        height: 72,
        child: Stack(
          children: [
            // Pulsing rings underneath
            CustomPaint(
              size: const Size(72, 72),
              painter: PulsingRingPainter(
                phase: _rings.value,
                color: AppColors.primaryGold,
              ),
            ),
            // Animated cross on top
            CustomPaint(
              size: const Size(72, 72),
              painter: EthiopianCrossPainter(
                drawProgress: _draw.value,
                glowProgress: _glow.value,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
