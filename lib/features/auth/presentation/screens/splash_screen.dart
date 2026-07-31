import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:church/app/theme.dart';
import 'package:church/features/auth/presentation/providers/auth_provider.dart';
import 'package:church/core/animations/particle_field.dart';
import 'package:church/core/animations/cross_painter.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _masterController;
  late final AnimationController _ringsController;

  late final Animation<double> _crossDraw;
  late final Animation<double> _glow;
  late final Animation<double> _textOpacity;
  late final Animation<Offset> _textSlide;
  late final Animation<double> _subOpacity;
  late final Animation<Offset> _subSlide;
  late final Animation<double> _loaderOpacity;

  @override
  void initState() {
    super.initState();

    _masterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3400),
    )..forward();

    _ringsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();

    _crossDraw = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _masterController,
        curve: const Interval(0.12, 0.59, curve: Curves.easeInOut),
      ),
    );

    _glow = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _masterController,
        curve: const Interval(0.52, 0.68, curve: Curves.easeOut),
      ),
    );

    _textOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _masterController,
        curve: const Interval(0.58, 0.76, curve: Curves.easeOut),
      ),
    );
    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _masterController,
      curve: const Interval(0.58, 0.78, curve: Curves.easeOutCubic),
    ));

    _subOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _masterController,
        curve: const Interval(0.68, 0.84, curve: Curves.easeOut),
      ),
    );
    _subSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _masterController,
      curve: const Interval(0.68, 0.86, curve: Curves.easeOut),
    ));

    _loaderOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _masterController,
        curve: const Interval(0.82, 1.0, curve: Curves.easeIn),
      ),
    );

    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(milliseconds: 2800));
    if (!mounted) return;

    final deadline = DateTime.now().add(const Duration(seconds: 3));
    while (mounted &&
        ref.read(authStateProvider).status == AuthStatus.initial &&
        DateTime.now().isBefore(deadline)) {
      await Future.delayed(const Duration(milliseconds: 100));
    }

    if (!mounted) return;
    final authState = ref.read(authStateProvider);
    if (authState.status == AuthStatus.authenticated) {
      if (authState.user?.churchId == null) {
        context.go('/church-select');
      } else {
        context.go('/home');
      }
    } else if (authState.status == AuthStatus.needsProfileSetup) {
      context.go('/auth/setup');
    } else {
      context.go('/auth');
    }
  }

  @override
  void dispose() {
    _masterController.dispose();
    _ringsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF003827), AppTheme.royalEmerald, Color(0xFF002419)],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Layer 1 — floating crisp white & mint particles
            const Positioned.fill(
              child: ParticleField(
                count: 50,
                colors: [Colors.white, Color(0xFFA5D6A7), Color(0xFFE8F5E9)],
              ),
            ),

            // Layer 2 — pulsing concentric rings
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _ringsController,
                builder: (_, _) => CustomPaint(
                  painter: PulsingRingPainter(
                    phase: _ringsController.value,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            // Layer 3 — main content
            SafeArea(
              child: Column(
                children: [
                  const Spacer(flex: 2),

                  // Animated Ethiopian cross
                  SizedBox(
                    width: 190,
                    height: 190,
                    child: AnimatedBuilder(
                      animation: _masterController,
                      builder: (_, _) => CustomPaint(
                        painter: EthiopianCrossPainter(
                          drawProgress: _crossDraw.value,
                          glowProgress: _glow.value,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 36),

                  // Amharic title
                  FadeTransition(
                    opacity: _textOpacity,
                    child: SlideTransition(
                      position: _textSlide,
                      child: const Text(
                        'የኢትዮጵያ ኦርቶዶክስ\nተዋሕዶ ቤተ ክርስቲያን',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          height: 1.45,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // White shimmer divider
                  FadeTransition(
                    opacity: _textOpacity,
                    child: Container(
                      width: 70,
                      height: 1.5,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [
                          Colors.transparent,
                          Colors.white,
                          Colors.transparent,
                        ]),
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // English subtitle
                  FadeTransition(
                    opacity: _subOpacity,
                    child: SlideTransition(
                      position: _subSlide,
                      child: const Text(
                        'Ethiopian Orthodox Tewahedo Church',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 6),

                  FadeTransition(
                    opacity: _subOpacity,
                    child: SlideTransition(
                      position: _subSlide,
                      child: const Text(
                        'ዲጂታል የአስራትና በኩራት ማሰባሰቢያ',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),

                  const Spacer(flex: 2),

                  // Custom white arc loader
                  FadeTransition(
                    opacity: _loaderOpacity,
                    child: const _GoldenLoader(),
                  ),

                  const SizedBox(height: 52),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoldenLoader extends StatefulWidget {
  const _GoldenLoader();

  @override
  State<_GoldenLoader> createState() => _GoldenLoaderState();
}

class _GoldenLoaderState extends State<_GoldenLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
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
      builder: (_, _) => CustomPaint(
        size: const Size(36, 36),
        painter: _ArcLoaderPainter(_ctrl.value),
      ),
    );
  }
}

class _ArcLoaderPainter extends CustomPainter {
  final double t;
  _ArcLoaderPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2 - 2;
    final rect = Rect.fromCircle(center: Offset(cx, cy), radius: r);

    // Track ring
    canvas.drawCircle(
      Offset(cx, cy),
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = Colors.white.withValues(alpha: 0.2),
    );

    // Animated arc
    canvas.drawArc(
      rect,
      t * 2 * math.pi - math.pi / 2,
      math.pi * 1.2,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(covariant _ArcLoaderPainter old) => old.t != t;
}
