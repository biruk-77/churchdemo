import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:church/app/theme.dart';
import 'package:church/core/widgets/primary_button.dart';
import 'package:church/core/widgets/loading_overlay.dart';
import 'package:church/core/logger/app_logger.dart';
import 'package:church/features/auth/presentation/providers/auth_provider.dart';
import 'package:church/l10n/app_localizations.dart';

const _tag = 'ProfileSetupScreen';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  late final AnimationController _entrance;
  late final List<Animation<double>> _fades;
  late final List<Animation<Offset>> _slides;

  @override
  void initState() {
    super.initState();
    log.i(_tag, '🖥️  Screen opened — user is setting up their profile');
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..forward();

    // 4 elements: avatar, title, name field, email field + button
    _fades = List.generate(4, (i) {
      final s = i * 0.12;
      return Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _entrance, curve: Interval(s, (s + 0.4).clamp(0, 1.0), curve: Curves.easeOut)),
      );
    });
    _slides = List.generate(4, (i) {
      final s = i * 0.12;
      return Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero).animate(
        CurvedAnimation(parent: _entrance, curve: Interval(s, (s + 0.5).clamp(0, 1.0), curve: Curves.easeOutCubic)),
      );
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _entrance.dispose();
    super.dispose();
  }

  void _save() {
    final name  = _nameController.text.trim();
    final email = _emailController.text.trim();

    if (!_formKey.currentState!.validate()) {
      log.d(_tag, '🚫  Validation failed — name="$name" email="$email"');
      return;
    }

    log.i(_tag, '💾  Saving profile → name="$name" email="${email.isEmpty ? '(none)' : email}"');
    ref.read(authStateProvider.notifier).completeProfile(
          name,
          email.isEmpty ? null : email,
        );
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
        final dest = next.user?.churchId == null ? '/church-select' : '/home';
        log.i(_tag, '✅  Profile saved → navigating to $dest  uid=${next.user?.uid}');
        if (next.user?.churchId == null) {
          context.go('/church-select');
        } else {
          context.go('/home');
        }
      } else if (next.errorMessage != null) {
        log.e(
          _tag,
          '🔴  Profile save failed',
          error: next.errorMessage!,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    });

    return LoadingOverlay(
      isLoading: authState.isLoading,
      message: l10n.loading,
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.profileSetup), elevation: 0),
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 32),

                  // Animated avatar with pulsing rings
                  _animated(
                    0,
                    Center(
                      child: _PulsingAvatar(),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Title
                  _animated(
                    1,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.profileSetup,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.royalEmerald,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Tell us your name to get started',
                          style: TextStyle(fontSize: 14, color: Colors.black.withValues(alpha: 0.45)),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 36),

                  // Name field
                  _animated(
                    2,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.fullName,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.royalEmerald,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _nameController,
                          keyboardType: TextInputType.name,
                          textCapitalization: TextCapitalization.words,
                          decoration: InputDecoration(
                            hintText: l10n.fullNameHint,
                            prefixIcon: const Icon(Icons.person_rounded, color: AppTheme.royalEmerald),
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty) ? l10n.requiredField : null,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          l10n.email,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.royalEmerald,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            hintText: l10n.emailHint,
                            prefixIcon: const Icon(Icons.email_rounded, color: AppTheme.royalEmerald),
                          ),
                          validator: (v) {
                            if (v != null && v.trim().isNotEmpty) {
                              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v.trim())) {
                                return l10n.invalidEmail;
                              }
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Button
                  _animated(
                    3,
                    PrimaryButton(text: l10n.continueBtn, onPressed: _save),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Avatar circle with three pulsing rings expanding outward.
class _PulsingAvatar extends StatefulWidget {
  @override
  State<_PulsingAvatar> createState() => _PulsingAvatarState();
}

class _PulsingAvatarState extends State<_PulsingAvatar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      height: 120,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Pulsing rings
          AnimatedBuilder(
            animation: _ctrl,
            builder: (_, _) => CustomPaint(
              size: const Size(120, 120),
              painter: _RingsPainter(_ctrl.value),
            ),
          ),
          // Avatar circle
          Container(
            width: 78,
            height: 78,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.royalEmerald,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.royalEmerald.withValues(alpha: 0.35),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Icon(Icons.person_rounded, color: Colors.white, size: 40),
          ),
        ],
      ),
    );
  }
}

class _RingsPainter extends CustomPainter {
  final double phase;
  const _RingsPainter(this.phase);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final maxR = size.width / 2;
    final paint = Paint()..style = PaintingStyle.stroke..strokeWidth = 1.5;

    for (int i = 0; i < 3; i++) {
      final t = ((phase + i / 3.0) % 1.0);
      final r = maxR * t;
      paint.color = AppTheme.imperialGold.withValues(alpha: (1 - t) * 0.5);
      canvas.drawCircle(Offset(cx, cy), r, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _RingsPainter old) => old.phase != phase;
}
