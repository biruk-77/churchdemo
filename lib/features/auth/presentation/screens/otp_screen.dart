import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';
import 'package:church/app/theme.dart';
import 'package:church/core/widgets/primary_button.dart';
import 'package:church/core/widgets/loading_overlay.dart';
import 'package:church/features/auth/presentation/providers/auth_provider.dart';
import 'package:church/l10n/app_localizations.dart';

class OtpScreen extends ConsumerStatefulWidget {
  final String phoneNumber;
  const OtpScreen({super.key, required this.phoneNumber});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen>
    with TickerProviderStateMixin {
  final _pinController = TextEditingController();
  final _focusNode = FocusNode();
  int _timerSeconds = 60;
  Timer? _timer;

  late final AnimationController _entrance;
  late final AnimationController _pinBounce;
  late final List<Animation<double>> _fades;
  late final List<Animation<Offset>> _slides;

  @override
  void initState() {
    super.initState();
    _startTimer();

    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..forward();

    _pinBounce = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _fades = List.generate(4, (i) {
      final s = i * 0.12;
      return Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _entrance, curve: Interval(s, (s + 0.4).clamp(0, 1.0), curve: Curves.easeOut)),
      );
    });
    _slides = List.generate(4, (i) {
      final s = i * 0.12;
      return Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero).animate(
        CurvedAnimation(parent: _entrance, curve: Interval(s, (s + 0.5).clamp(0, 1.0), curve: Curves.easeOutBack)),
      );
    });
  }

  void _startTimer() {
    _timerSeconds = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() {
        if (_timerSeconds > 0) _timerSeconds--;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pinController.dispose();
    _focusNode.dispose();
    _entrance.dispose();
    _pinBounce.dispose();
    super.dispose();
  }

  void _verify(String code) {
    if (code.length == 6) {
      _pinBounce.forward(from: 0);
      ref.read(authStateProvider.notifier).verifyOtp(code);
    }
  }

  Widget _animated(int i, Widget child) => FadeTransition(
        opacity: _fades[i],
        child: SlideTransition(position: _slides[i], child: child),
      );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final authState = ref.watch(authStateProvider);

    ref.listen(authStateProvider, (_, next) {
      if (next.status == AuthStatus.authenticated) {
        if (next.user?.churchId == null) {
          context.go('/church-select');
        } else {
          context.go('/home');
        }
      } else if (next.status == AuthStatus.needsProfileSetup) {
        context.go('/auth/setup');
      } else if (next.errorMessage != null && next.status != AuthStatus.codeSent) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.errorMessage!), backgroundColor: Theme.of(context).colorScheme.error),
        );
      }
    });

    final pinScaleAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.12), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.12, end: 1.0), weight: 60),
    ]).animate(CurvedAnimation(parent: _pinBounce, curve: Curves.easeInOut));

    final defaultPinTheme = PinTheme(
      width: 52,
      height: 58,
      textStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.royalEmerald),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderLight, width: 1.5),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
    );

    return LoadingOverlay(
      isLoading: authState.isLoading,
      message: l10n.loading,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.otpTitle),
          backgroundColor: Colors.transparent,
          foregroundColor: Theme.of(context).colorScheme.onSurface,
          elevation: 0,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom -
                    kToolbarHeight,
              ),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    const SizedBox(height: 24),

                    // Phone icon
                    _animated(
                      0,
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.royalEmerald.withValues(alpha: 0.08),
                        ),
                        child: const Icon(Icons.sms_rounded, color: AppTheme.royalEmerald, size: 36),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Subtitle
                    _animated(
                      1,
                      Text(
                        l10n.otpSubtitle(widget.phoneNumber),
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16, color: Colors.black54),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // PIN input with bounce
                    _animated(
                      2,
                      ScaleTransition(
                        scale: pinScaleAnim,
                        child: Pinput(
                          length: 6,
                          controller: _pinController,
                          focusNode: _focusNode,
                          defaultPinTheme: defaultPinTheme,
                          focusedPinTheme: defaultPinTheme.copyWith(
                            decoration: defaultPinTheme.decoration!.copyWith(
                              border: Border.all(color: AppTheme.imperialGold, width: 2.5),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.imperialGold.withValues(alpha: 0.25),
                                  blurRadius: 12,
                                ),
                              ],
                            ),
                          ),
                          submittedPinTheme: defaultPinTheme.copyWith(
                            decoration: defaultPinTheme.decoration!.copyWith(
                              color: AppTheme.royalEmerald.withValues(alpha: 0.08),
                              border: Border.all(color: AppTheme.royalEmerald, width: 1.5),
                            ),
                          ),
                          onCompleted: _verify,
                          autofocus: true,
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Circular countdown
                    _animated(
                      3,
                      _timerSeconds > 0
                          ? Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  width: 62,
                                  height: 62,
                                  child: CustomPaint(
                                    painter: _CountdownRingPainter(_timerSeconds / 60.0),
                                  ),
                                ),
                                Text(
                                  '$_timerSeconds',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.royalEmerald,
                                  ),
                                ),
                              ],
                            )
                          : TextButton(
                              onPressed: () {
                                ref.read(authStateProvider.notifier).sendOtp(widget.phoneNumber);
                                _startTimer();
                              },
                              child: Text(
                                l10n.resendOtp,
                                style: const TextStyle(
                                  color: AppTheme.imperialGold,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                    ),

                    const Spacer(),

                    PrimaryButton(
                      text: l10n.verifyOtp,
                      onPressed: () => _verify(_pinController.text),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),

      ),
    );
  }
}

class _CountdownRingPainter extends CustomPainter {
  final double fraction; // 1.0 = full, 0.0 = empty

  const _CountdownRingPainter(this.fraction);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2 - 3;

    canvas.drawCircle(
      Offset(cx, cy),
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..color = AppTheme.imperialGold.withValues(alpha: 0.15),
    );

    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r),
      -math.pi / 2,
      2 * math.pi * fraction,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round
        ..color = AppTheme.imperialGold,
    );
  }

  @override
  bool shouldRepaint(covariant _CountdownRingPainter old) => old.fraction != fraction;
}
