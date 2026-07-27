import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:church/app/theme.dart';
import 'package:church/core/widgets/primary_button.dart';
import 'package:church/core/animations/confetti_overlay.dart';
import 'package:church/core/animations/radial_rays_painter.dart';
import 'package:church/l10n/app_localizations.dart';

class PaymentSuccessScreen extends StatefulWidget {
  final String receiptNo;
  final double amount;
  final String type;

  const PaymentSuccessScreen({
    super.key,
    required this.receiptNo,
    required this.amount,
    required this.type,
  });

  @override
  State<PaymentSuccessScreen> createState() => _PaymentSuccessScreenState();
}

class _PaymentSuccessScreenState extends State<PaymentSuccessScreen>
    with TickerProviderStateMixin {
  late final AnimationController _burstController;
  late final AnimationController _checkController;
  late final AnimationController _cardController;
  late final AnimationController _textController;

  @override
  void initState() {
    super.initState();

    _burstController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();

    _checkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _cardController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) _checkController.forward();
    });
    Future.delayed(const Duration(milliseconds: 350), () {
      if (mounted) _textController.forward();
    });
    Future.delayed(const Duration(milliseconds: 650), () {
      if (mounted) _cardController.forward();
    });
  }

  @override
  void dispose() {
    _burstController.dispose();
    _checkController.dispose();
    _textController.dispose();
    _cardController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final typeLabel = _getTypeLabel(widget.type, l10n);

    final cardSlide = Tween<Offset>(
      begin: const Offset(0, 0.7),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _cardController, curve: Curves.easeOutCubic));

    final textScale = Tween<double>(begin: 0.65, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOutBack),
    );

    return Scaffold(
      body: Stack(
        children: [
          // Confetti burst (plays once, fades out)
          const Positioned.fill(child: ConfettiOverlay()),

          // Radial holy-light rays
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _burstController,
              builder: (_, _) => CustomPaint(
                painter: RadialRaysPainter(
                  progress: _burstController.value,
                  color: AppTheme.primaryGold,
                ),
              ),
            ),
          ),

          // Main content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  const Spacer(),

                  // Animated circle + checkmark
                  SizedBox(
                    width: 104,
                    height: 104,
                    child: AnimatedBuilder(
                      animation: _checkController,
                      builder: (_, _) => CustomPaint(
                        painter: CheckmarkPainter(_checkController.value),
                      ),
                    ),
                  ),

                  const SizedBox(height: 22),

                  // "Payment Successful" — bounces in
                  ScaleTransition(
                    scale: textScale,
                    child: FadeTransition(
                      opacity: _textController,
                      child: Text(
                        l10n.paymentSuccess,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 6),

                  FadeTransition(
                    opacity: _textController,
                    child: Text(
                      typeLabel,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Receipt card — slides up
                  SlideTransition(
                    position: cardSlide,
                    child: FadeTransition(
                      opacity: _cardController,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.white,
                          border: Border.all(
                            color: AppTheme.primaryGold.withValues(alpha: 0.25),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryGold.withValues(alpha: 0.10),
                              blurRadius: 20,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(22),
                        child: Column(
                          children: [
                            _buildRow(l10n.receiptNumber, widget.receiptNo),
                            _buildDivider(),
                            _buildRow(
                              l10n.enterAmount,
                              '${widget.amount.toStringAsFixed(2)} ETB',
                              valueStyle: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: AppTheme.primaryBlue,
                              ),
                            ),
                            _buildDivider(),
                            _buildRow(l10n.contribute, typeLabel),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const Spacer(),

                  FadeTransition(
                    opacity: _cardController,
                    child: PrimaryButton(
                      text: l10n.done,
                      onPressed: () => context.go('/home'),
                    ),
                  ),
                  const SizedBox(height: 14),
                  FadeTransition(
                    opacity: _cardController,
                    child: PrimaryButton(
                      text: l10n.downloadReceipt,
                      isOutlined: true,
                      onPressed: () => context.push('/history'),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() => Divider(
        height: 22,
        color: AppTheme.primaryGold.withValues(alpha: 0.15),
      );

  Widget _buildRow(String label, String value, {TextStyle? valueStyle}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.black54,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: valueStyle ??
              const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryBlue,
              ),
        ),
      ],
    );
  }

  String _getTypeLabel(String type, AppLocalizations l10n) {
    switch (type) {
      case 'asrat': return l10n.asrat;
      case 'bekuart': return l10n.bekuart;
      case 'monthly': return l10n.monthly;
      case 'buildingFund': return l10n.buildingFund;
      case 'charity': return l10n.charity;
      case 'festival': return l10n.festival;
      case 'candle': return l10n.candle;
      case 'memorial': return l10n.memorial;
      case 'monastery': return l10n.monastery;
      case 'priest': return l10n.priest;
      case 'sundaySchool': return l10n.sundaySchool;
      case 'youth': return l10n.youth;
      case 'women': return l10n.women;
      case 'development': return l10n.development;
      case 'emergency': return l10n.emergency;
      case 'specialCollection': return l10n.specialCollection;
      default: return type;
    }
  }
}
