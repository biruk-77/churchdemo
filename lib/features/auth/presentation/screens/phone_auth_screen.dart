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

enum AuthView { phone, signIn, signUp }

class _PhoneAuthScreenState extends ConsumerState<PhoneAuthScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  AuthView _authView = AuthView.signIn;

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
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _headerCtrl.dispose();
    _cardCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      if (_authView == AuthView.signUp) {
        ref.read(authStateProvider.notifier).signUpWithEmail(
          _nameController.text.trim(),
          _emailController.text.trim(),
          _passwordController.text,
        );
      } else if (_authView == AuthView.signIn) {
        ref.read(authStateProvider.notifier).signInWithEmail(
          _emailController.text.trim(),
          _passwordController.text,
        );
      } else {
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
  }

  Widget _buildTabItem(String text, AuthView view) {
    final isSelected = _authView == view;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _authView = view;
            _formKey.currentState?.reset();
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? AppTheme.royalEmerald : Colors.black54,
            ),
          ),
        ),
      ),
    );
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
        backgroundColor: AppTheme.royalEmerald,
        body: Stack(
          children: [
            // White & mint particles on emerald background
            const Positioned.fill(
              child: ParticleField(
                count: 30,
                colors: [Color(0x44FFFFFF), Color(0x3381C784)],
              ),
            ),

            Column(
              children: [
                // ── HEADER (42% of screen) ─────────────────────
                SizedBox(
                  height: size.height * 0.42,
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Cross / Church logo icon
                          FadeTransition(
                            opacity: _headerFades[0],
                            child: SlideTransition(
                              position: _headerSlides[0],
                              child: Container(
                                width: 76,
                                height: 76,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                  border: Border.all(color: Colors.white, width: 2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.15),
                                      blurRadius: 20,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: const Icon(Icons.church_rounded, color: AppTheme.royalEmerald, size: 38),
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
                              padding: const EdgeInsets.fromLTRB(28, 32, 28, 28),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Tab selector bar
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.all(4),
                                    child: Row(
                                      children: [
                                        _buildTabItem('Sign In', AuthView.signIn),
                                        _buildTabItem('Sign Up', AuthView.signUp),
                                        _buildTabItem('Phone/OTP', AuthView.phone),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(height: 16),

                                  Text(
                                    _authView == AuthView.signUp
                                        ? 'Fill in details to start your journey'
                                        : _authView == AuthView.signIn
                                            ? 'Enter your email & password to continue'
                                            : 'Enter your Ethiopian phone number to continue',
                                    style: TextStyle(fontSize: 13, color: Colors.black.withValues(alpha: 0.45)),
                                  ),

                                  const SizedBox(height: 24),

                                  if (_authView == AuthView.phone) ...[
                                    // Phone field
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          l10n.phoneNumber,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            color: AppTheme.royalEmerald,
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
                                                color: AppTheme.royalEmerald.withValues(alpha: 0.07),
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
                                                      color: AppTheme.royalEmerald,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                                          ),
                                          validator: (value) {
                                            if (_authView != AuthView.phone) return null;
                                            if (value == null || value.trim().isEmpty) return l10n.requiredField;
                                            final clean = value.trim().replaceAll(' ', '').replaceAll('-', '');
                                            if (!RegExp(r'^(\+251|0)?[97]\d{8}$').hasMatch(clean)) {
                                              return 'Use: 0928211778 or +251928211778';
                                            }
                                            return null;
                                          },
                                        ),
                                      ],
                                    ),
                                  ] else ...[
                                    if (_authView == AuthView.signUp) ...[
                                      // Full Name field
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'ሙሉ ስም',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w700,
                                              color: AppTheme.royalEmerald,
                                              letterSpacing: 0.2,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          TextFormField(
                                            controller: _nameController,
                                            keyboardType: TextInputType.name,
                                            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
                                            decoration: InputDecoration(
                                              hintText: 'ሙሉ ስምዎን ያስገቡ',
                                              prefixIcon: const Icon(Icons.person_outline, color: AppTheme.royalEmerald),
                                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                                            ),
                                            validator: (value) {
                                              if (_authView != AuthView.signUp) return null;
                                              if (value == null || value.trim().isEmpty) return 'ሙሉ ስም ያስፈልጋል';
                                              return null;
                                            },
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                    ],

                                    // Email field
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'የኢሜይል አድራሻ',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            color: AppTheme.royalEmerald,
                                            letterSpacing: 0.2,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        TextFormField(
                                          controller: _emailController,
                                          keyboardType: TextInputType.emailAddress,
                                          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
                                          decoration: InputDecoration(
                                            hintText: 'የኢሜይል አድራሻዎን ያስገቡ',
                                            prefixIcon: const Icon(Icons.email_outlined, color: AppTheme.royalEmerald),
                                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                                          ),
                                          validator: (value) {
                                            if (_authView == AuthView.phone) return null;
                                            if (value == null || value.trim().isEmpty) return 'ኢሜይል ያስፈልጋል';
                                            if (!value.contains('@') || !value.contains('.')) return 'ትክክለኛ ኢሜይል አድራሻ ያስገቡ';
                                            return null;
                                          },
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),

                                    // Password field
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'የይለፍ ቃል',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            color: AppTheme.royalEmerald,
                                            letterSpacing: 0.2,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        TextFormField(
                                          controller: _passwordController,
                                          obscureText: true,
                                          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
                                          decoration: InputDecoration(
                                            hintText: 'የይለፍ ቃልዎን ያስገቡ',
                                            prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.royalEmerald),
                                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                                          ),
                                          validator: (value) {
                                            if (_authView == AuthView.phone) return null;
                                            if (value == null || value.isEmpty) return 'የይለፍ ቃል ያስፈልጋል';
                                            if (value.length < 6) return 'የይለፍ ቃል ቢያንስ 6 ፊደላት ሊኖረው ይገባል';
                                            return null;
                                          },
                                        ),
                                      ],
                                    ),
                                  ],

                                  const SizedBox(height: 24),

                                  PrimaryButton(
                                    text: _authView == AuthView.signUp
                                        ? 'Sign Up'
                                        : _authView == AuthView.signIn
                                            ? 'Sign In'
                                            : l10n.sendOtp,
                                    color: AppTheme.royalEmerald,
                                    onPressed: _submit,
                                  ),

                                  if (_authView != AuthView.phone) ...[
                                    const SizedBox(height: 12),
                                    Center(
                                      child: TextButton(
                                        onPressed: () {
                                          setState(() {
                                            if (_authView == AuthView.signIn) {
                                              _authView = AuthView.signUp;
                                            } else {
                                              _authView = AuthView.signIn;
                                            }
                                          });
                                        },
                                        child: Text(
                                          _authView == AuthView.signIn
                                              ? "Don't have an account? Sign Up"
                                              : "Already have an account? Sign In",
                                          style: const TextStyle(
                                            color: AppTheme.imperialGold,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],

                                  const SizedBox(height: 20),

                                  Row(
                                    children: [
                                      Expanded(child: Divider(color: Colors.black.withValues(alpha: 0.1))),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 16),
                                        child: Text(
                                          'Or Sign In With',
                                          style: TextStyle(fontSize: 12, color: Colors.black.withValues(alpha: 0.38), fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                      Expanded(child: Divider(color: Colors.black.withValues(alpha: 0.1))),
                                    ],
                                  ),

                                  const SizedBox(height: 16),

                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      // Google Button
                                      Expanded(
                                        child: OutlinedButton.icon(
                                          onPressed: () {
                                            ref.read(authStateProvider.notifier).signInWithGoogle();
                                          },
                                          style: OutlinedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(vertical: 14),
                                            side: BorderSide(color: Colors.black.withValues(alpha: 0.12)),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                          ),
                                          icon: Image.network(
                                            'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/1024px-Google_%22G%22_logo.svg.png',
                                            height: 20,
                                            width: 20,
                                            errorBuilder: (ctx, _, __) => const Icon(Icons.g_mobiledata, color: Colors.red, size: 24),
                                          ),
                                          label: const Text(
                                            'Google',
                                            style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 14),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      // Facebook Button
                                      Expanded(
                                        child: OutlinedButton.icon(
                                          onPressed: () {
                                            ref.read(authStateProvider.notifier).signInWithFacebook();
                                          },
                                          style: OutlinedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(vertical: 14),
                                            side: BorderSide(color: Colors.black.withValues(alpha: 0.12)),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                          ),
                                          icon: Image.network(
                                            'https://upload.wikimedia.org/wikipedia/commons/thumb/0/05/Facebook_Logo_%282019%29.png/1024px-Facebook_Logo_%282019%29.png',
                                            height: 20,
                                            width: 20,
                                            errorBuilder: (ctx, _, __) => const Icon(Icons.facebook, color: Colors.blue, size: 20),
                                          ),
                                          label: const Text(
                                            'Facebook',
                                            style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 14),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 24),

                                  Center(
                                    child: Text(
                                      'By continuing you agree to our Terms & Privacy Policy',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.black.withValues(alpha: 0.35),
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
