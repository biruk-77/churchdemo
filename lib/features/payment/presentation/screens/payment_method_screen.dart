import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:church/app/theme.dart';
import 'package:church/core/widgets/primary_button.dart';
import 'package:church/core/widgets/loading_overlay.dart';
import 'package:church/core/widgets/animated_count_text.dart';
import 'package:church/features/auth/presentation/providers/auth_provider.dart';
import 'package:church/features/contributions/data/contribution_model.dart';
import 'package:church/features/contributions/presentation/providers/contribution_provider.dart';
import 'package:church/features/payment/data/chapa_service.dart';
import 'package:church/features/payment/data/telebirr_service.dart';
import 'package:church/l10n/app_localizations.dart';
import 'package:church/core/logger/app_logger.dart';
import 'package:uuid/uuid.dart';

final chapaServiceProvider = Provider<ChapaService>((ref) => ChapaService());
final telebirrServiceProvider = Provider<TelebirrService>((ref) => TelebirrService());

class PaymentMethodScreen extends ConsumerStatefulWidget {
  final double amount;
  final String type;
  final String? note;

  const PaymentMethodScreen({
    super.key,
    required this.amount,
    required this.type,
    this.note,
  });

  @override
  ConsumerState<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends ConsumerState<PaymentMethodScreen>
    with SingleTickerProviderStateMixin {
  String _selectedMethod = 'chapa';
  bool _isProcessing = false;

  late final AnimationController _entrance;
  late final Animation<double> _headerFade;
  late final Animation<Offset> _headerSlide;
  late final Animation<double> _cardsFade;
  late final Animation<Offset> _cardsSlide;
  late final Animation<double> _btnFade;

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();

    _headerFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _entrance, curve: const Interval(0, 0.45, curve: Curves.easeOut)),
    );
    _headerSlide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _entrance, curve: const Interval(0, 0.5, curve: Curves.easeOutCubic)),
    );
    _cardsFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _entrance, curve: const Interval(0.2, 0.65, curve: Curves.easeOut)),
    );
    _cardsSlide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _entrance, curve: const Interval(0.2, 0.7, curve: Curves.easeOutCubic)),
    );
    _btnFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _entrance, curve: const Interval(0.45, 0.85, curve: Curves.easeOut)),
    );
  }

  @override
  void dispose() {
    _entrance.dispose();
    super.dispose();
  }

  Future<void> _processPayment() async {
    setState(() => _isProcessing = true);

    final user = ref.read(authStateProvider).user;
    final userId = user?.uid ?? 'mock_user_${DateTime.now().millisecondsSinceEpoch}';
    final churchId = user?.churchId ?? 'default_church';
    final methodTitle = _selectedMethod == 'chapa' ? 'Chapa' : 'Telebirr';
    final txRef = 'TX-${const Uuid().v4()}';
    final receiptNo = 'EOTC-REC-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';

    log.i('PaymentMethodScreen', '💳 Processing: $methodTitle — ETB ${widget.amount}');
    await Future.delayed(const Duration(milliseconds: 600));

    final contribution = ContributionModel(
      id: txRef,
      userId: userId,
      churchId: churchId,
      type: widget.type,
      amount: widget.amount,
      paymentMethod: methodTitle,
      paymentRef: txRef,
      status: 'success',
      receiptNo: receiptNo,
      note: widget.note,
      createdAt: DateTime.now(),
    );

    ref.read(contributionRepositoryProvider).createContribution(contribution).catchError((e) {
      log.w('PaymentMethodScreen', '⚠️ Firestore save: $e');
    });

    if (mounted) {
      setState(() => _isProcessing = false);
      context.go('/payment/success', extra: {
        'receiptNo': receiptNo,
        'amount': widget.amount,
        'type': widget.type,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return LoadingOverlay(
      isLoading: _isProcessing,
      message: 'Processing Payment...',
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.selectPaymentMethod), elevation: 0),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),

                // Amount display — counts up
                FadeTransition(
                  opacity: _headerFade,
                  child: SlideTransition(
                    position: _headerSlide,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppTheme.primaryBlue, AppTheme.primaryBlue.withValues(alpha: 0.85)],
                        ),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryBlue.withValues(alpha: 0.3),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'TOTAL TO PAY',
                            style: TextStyle(color: Colors.white60, fontSize: 12, letterSpacing: 1.5),
                          ),
                          const SizedBox(height: 8),
                          AnimatedCountText(
                            end: widget.amount,
                            prefix: 'ETB ',
                            currency: true,
                            duration: const Duration(milliseconds: 1400),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                FadeTransition(
                  opacity: _cardsFade,
                  child: Text(
                    l10n.selectPaymentMethod,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
                  ),
                ),

                const SizedBox(height: 14),

                // Payment method cards
                FadeTransition(
                  opacity: _cardsFade,
                  child: SlideTransition(
                    position: _cardsSlide,
                    child: Column(
                      children: [
                        _AnimatedPaymentCard(
                          value: 'chapa',
                          selected: _selectedMethod == 'chapa',
                          icon: Icons.payment_rounded,
                          iconColor: Colors.blue,
                          title: l10n.chapa,
                          subtitle: l10n.chapaDesc,
                          onTap: () => setState(() => _selectedMethod = 'chapa'),
                        ),
                        const SizedBox(height: 14),
                        _AnimatedPaymentCard(
                          value: 'telebirr',
                          selected: _selectedMethod == 'telebirr',
                          icon: Icons.phone_android_rounded,
                          iconColor: Colors.green,
                          title: l10n.telebirr,
                          subtitle: l10n.telebirrDesc,
                          onTap: () => setState(() => _selectedMethod = 'telebirr'),
                        ),
                      ],
                    ),
                  ),
                ),

                const Spacer(),

                FadeTransition(
                  opacity: _btnFade,
                  child: PrimaryButton(
                    text: l10n.pay(widget.amount.toStringAsFixed(2)),
                    onPressed: _processPayment,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Payment card with animated border glow and shimmer on selection.
class _AnimatedPaymentCard extends StatefulWidget {
  final String value;
  final bool selected;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _AnimatedPaymentCard({
    required this.value,
    required this.selected,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  State<_AnimatedPaymentCard> createState() => _AnimatedPaymentCardState();
}

class _AnimatedPaymentCardState extends State<_AnimatedPaymentCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _selectCtrl;
  late final Animation<double> _selectScale;
  late final Animation<double> _glowOpacity;

  @override
  void initState() {
    super.initState();
    _selectCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _selectScale = Tween<double>(begin: 1.0, end: 1.025).animate(
      CurvedAnimation(parent: _selectCtrl, curve: Curves.easeOutBack),
    );
    _glowOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _selectCtrl, curve: Curves.easeOut),
    );
  }

  @override
  void didUpdateWidget(covariant _AnimatedPaymentCard old) {
    super.didUpdateWidget(old);
    if (widget.selected && !old.selected) {
      _selectCtrl.forward(from: 0);
    } else if (!widget.selected && old.selected) {
      _selectCtrl.reverse();
    }
  }

  @override
  void dispose() {
    _selectCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _selectCtrl,
      builder: (_, _) => Transform.scale(
        scale: _selectScale.value,
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              color: widget.selected
                  ? AppTheme.primaryGold.withValues(alpha: 0.05)
                  : Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: widget.selected ? AppTheme.primaryGold : AppTheme.primaryBlue.withValues(alpha: 0.12),
                width: widget.selected ? 2 : 1,
              ),
              boxShadow: [
                if (widget.selected)
                  BoxShadow(
                    color: AppTheme.primaryGold.withValues(alpha: 0.22 * _glowOpacity.value),
                    blurRadius: 18,
                    offset: const Offset(0, 4),
                  ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 280),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: widget.iconColor.withValues(alpha: widget.selected ? 0.18 : 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(widget.icon, color: widget.iconColor, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: widget.selected ? AppTheme.primaryBlue : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        widget.subtitle,
                        style: const TextStyle(fontSize: 12, color: Colors.black45),
                      ),
                    ],
                  ),
                ),
                AnimatedOpacity(
                  opacity: widget.selected ? 1 : 0,
                  duration: const Duration(milliseconds: 250),
                  child: const Icon(Icons.radio_button_checked_rounded, color: AppTheme.primaryGold),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
