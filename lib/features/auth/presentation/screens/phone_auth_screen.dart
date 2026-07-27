import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:church/app/theme.dart';
import 'package:church/core/widgets/primary_button.dart';
import 'package:church/core/widgets/loading_overlay.dart';
import 'package:church/core/animations/particle_field.dart';
import 'package:church/features/auth/presentation/providers/auth_provider.dart';
import 'package:church/l10n/app_localizations.dart';

class PhoneAuthScreen extends ConsumerStatefulWidget {
  const PhoneAuthScreen({super.key});

  @override
  ConsumerState<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends ConsumerState<PhoneAuthScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();

  late final AnimationController _headerCtrl;
  late final AnimationController _cardCtrl;

  // Header elements (icon, title, subtitle) stagger in
  late final List<Animation<double>> _headerFades;
  late final List<Animation<Offset>> _headerSlides;
  // Card elements (label, field, button) stagger in after card appears
  late final List<Animation<double>> _cardFades;
  late final List<Animation<Offset>> _cardSlides;
  late final Animation<Offset> _cardEntrance;

  @override
  void initState() {
    super.initState();

    _headerCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))
      ..forward();
    _cardCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));

    _headerFades = List.generate(3, (i) {
      final s = i * 0.12;
      return Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _headerCtrl, curve: Interval(s, (s + 0.45).clamp(0, 1.0), curve: Curves.easeOut)),
      );
    });
    _headerSlides = List.generate(3, (i) {
      final s = i * 0.12;
      return Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero).animate(
        CurvedAnimation(parent: _headerCtrl, curve: Interval(s, (s + 0.55).clamp(0, 1.0), curve: Curves.easeOutCubic)),
      );
    });

    _cardEntrance = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _cardCtrl, curve: Curves.easeOutCubic),
    );
    _cardFades = List.generate(3, (i) {
      final s = i * 0.14;
      return Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _cardCtrl, curve: Interval(s, (s + 0.5).clamp(0, 1.0), curve: Curves.easeOut)),
      );
    });
    _cardSlides = List.generate(3, (i) {
      final s = i * 0.14;
      return Tween<Offset>(begin: const Offset(0, 0.25), end: Offset.zero).animate(
        CurvedAnimation(parent: _cardCtrl, curve: Interval(s, (s + 0.55).clamp(0, 1.0), curve: Curves.easeOutBack)),
      );
    });

    // Start card animation slightly after header
    Future.delayed(const Duration(milliseconds: 450), () {
      if (mounted) _cardCtrl.forward();
    });

    // Pre-fill with last used phone number
    _prefillPhone();
  }

  Future<void> _prefillPhone() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString('session_phone');
      if (saved != null && saved.isNotEmpty && mounted) {
        // Show in local format (strip +251 → 09xx)
        String display = saved;
        if (display.startsWith('+251')) {
          display = '0${display.substring(4)}';
        }
        _phoneController.text = display;
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _headerCtrl.dispose();
    _cardCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      var phone = _phoneController.text.trim();
      if (!phone.startsWith('+')) {
        if (phone.startsWith('0')) {
          phone = '+251${phone.substring(1)}';
        } else if (phone.startsWith('9') || phone.startsWith('7')) {
          phone = '+251$phone';
        }
      }
      ref.read(authStateProvider.notifier).sendOtp(phone);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final authState = ref.watch(authStateProvider);

    ref.listen(authStateProvider, (_, next) {
      if (next.status == AuthStatus.codeSent) {
        context.push('/auth/otp', extra: _phoneController.text.trim());
      } else if (next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    });

    final size = MediaQuery.of(context).size;

    return LoadingOverlay(
      isLoading: authState.isLoading,
      message: l10n.sendOtp,
      child: Scaffold(
        backgroundColor: AppTheme.primaryBlue,
        body: Stack(
          children: [
            // Gold dust particles on the dark background
            const Positioned.fill(
              child: ParticleField(
                count: 30,
                colors: [Color(0x55C9A227), Color(0x33FFD700)],
              ),
            ),

            Column(
              children: [
                // ── HEADER (dark blue, 42% of screen) ─────────────────────
                SizedBox(
                  height: size.height * 0.42,
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Cross icon
                          FadeTransition(
                            opacity: _headerFades[0],
                            child: SlideTransition(
                              position: _headerSlides[0],
                              child: Container(
                                width: 76,
                                height: 76,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppTheme.primaryGold.withValues(alpha: 0.15),
                                  border: Border.all(color: AppTheme.primaryGold.withValues(alpha: 0.5), width: 1.5),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.primaryGold.withValues(alpha: 0.25),
                                      blurRadius: 20,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: const Icon(Icons.church_rounded, color: AppTheme.primaryGold, size: 36),
                              ),
                            ),
                          ),

                          const SizedBox(height: 22),

                          // Title
                          FadeTransition(
                            opacity: _headerFades[1],
                            child: SlideTransition(
                              position: _headerSlides[1],
                              child: Text(
                                l10n.welcomeTitle,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 8),

                          // Subtitle
                          FadeTransition(
                            opacity: _headerFades[2],
                            child: SlideTransition(
                              position: _headerSlides[2],
                              child: Text(
                                l10n.welcomeSubtitle,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white.withValues(alpha: 0.72),
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // ── WHITE CARD (58% of screen) ─────────────────────────────
                Expanded(
                  child: SlideTransition(
                    position: _cardEntrance,
                    child: FadeTransition(
                      opacity: _cardFades[0],
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0x22000000),
                              blurRadius: 24,
                              offset: Offset(0, -4),
                            ),
                          ],
                        ),
                        child: SafeArea(
                          top: false,
                          child: Form(
                            key: _formKey,
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.fromLTRB(28, 36, 28, 28),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // "Sign In" label
                                  FadeTransition(
                                    opacity: _cardFades[0],
                                    child: const Text(
                                      'Sign In',
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.primaryBlue,
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 6),

                                  FadeTransition(
                                    opacity: _cardFades[0],
                                    child: Text(
                                      'Enter your Ethiopian phone number to continue',
                                      style: TextStyle(fontSize: 14, color: Colors.black.withValues(alpha: 0.45)),
                                    ),
                                  ),

                                  const SizedBox(height: 32),

                                  // Phone field
                                  FadeTransition(
                                    opacity: _cardFades[1],
                                    child: SlideTransition(
                                      position: _cardSlides[1],
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            l10n.phoneNumber,
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w700,
                                              color: AppTheme.primaryBlue,
                                              letterSpacing: 0.2,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          TextFormField(
                                            controller: _phoneController,
                                            keyboardType: TextInputType.phone,
                                            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
                                            decoration: InputDecoration(
                                              hintText: l10n.phoneHint,
                                              prefixIcon: Container(
                                                margin: const EdgeInsets.only(right: 1),
                                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                                decoration: BoxDecoration(
                                                  color: AppTheme.primaryBlue.withValues(alpha: 0.07),
                                                  borderRadius: const BorderRadius.only(
                                                    topLeft: Radius.circular(14),
                                                    bottomLeft: Radius.circular(14),
                                                  ),
                                                ),
                                                child: const Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Text('🇪🇹', style: TextStyle(fontSize: 18)),
                                                    SizedBox(width: 6),
                                                    Text(
                                                      '+251',
                                                      style: TextStyle(
                                                        fontSize: 15,
                                                        fontWeight: FontWeight.bold,
                                                        color: AppTheme.primaryBlue,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                                            ),
                                            validator: (value) {
                                              if (value == null || value.trim().isEmpty) return l10n.requiredField;
                                              final clean = value.trim().replaceAll(' ', '').replaceAll('-', '');
                                              // Accepts: +251[97]XXXXXXXX  |  0[97]XXXXXXXX  |  [97]XXXXXXXX
                                              if (!RegExp(r'^(\+251|0)?[97]\d{8}$').hasMatch(clean)) {
                                                return 'Use: 0928211778 or +251928211778';
                                              }
                                              return null;
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 32),

                                  // Send OTP button — blue background, white text, clearly visible
                                  FadeTransition(
                                    opacity: _cardFades[2],
                                    child: SlideTransition(
                                      position: _cardSlides[2],
                                      child: PrimaryButton(
                                        text: l10n.sendOtp,
                                        // Explicit blue so white text has 7:1 contrast ratio
                                        color: AppTheme.primaryBlue,
                                        onPressed: _submit,
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 20),

                                  Center(
                                    child: FadeTransition(
                                      opacity: _cardFades[2],
                                      child: Text(
                                        'By continuing you agree to our Terms & Privacy Policy',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.black.withValues(alpha: 0.35),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
