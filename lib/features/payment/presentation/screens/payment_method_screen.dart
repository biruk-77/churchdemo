import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:church/app/theme.dart';
import 'package:church/core/widgets/primary_button.dart';
import 'package:church/core/widgets/loading_overlay.dart';
import 'package:church/features/auth/presentation/providers/auth_provider.dart';
import 'package:church/features/contributions/data/contribution_model.dart';
import 'package:church/features/contributions/presentation/providers/contribution_provider.dart';
import 'package:church/features/payment/data/telebirr_service.dart';
import 'package:church/l10n/app_localizations.dart';
import 'package:church/core/logger/app_logger.dart';
import 'package:uuid/uuid.dart';

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
  String _selectedMethod = 'telebirr';
  bool _isProcessing = false;
  late double _currentAmount;
  late final TextEditingController _amountController;
  final FocusNode _amountFocusNode = FocusNode();

  late final AnimationController _entrance;
  late final Animation<double> _headerFade;
  late final Animation<Offset> _headerSlide;
  late final Animation<double> _cardsFade;
  late final Animation<Offset> _cardsSlide;
  late final Animation<double> _btnFade;

  @override
  void initState() {
    super.initState();
    _currentAmount = widget.amount;
    _amountController = TextEditingController(
      text: widget.amount > 0 ? widget.amount.toStringAsFixed(0) : '',
    );

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
    _amountController.dispose();
    _amountFocusNode.dispose();
    _entrance.dispose();
    super.dispose();
  }

  void _updateAmount(double newAmount) {
    setState(() {
      _currentAmount = newAmount;
      _amountController.text = newAmount > 0 ? newAmount.toStringAsFixed(0) : '';
    });
  }

  Future<void> _processPayment() async {
    if (_currentAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('እባክዎ ትክክለኛ የመዋጮ መጠን በብር ያስገቡ'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
      _amountFocusNode.requestFocus();
      return;
    }

    final methodNames = {
      'telebirr': 'Telebirr',
      'cbebirr': 'CBE Birr',
      'amoole': 'Amoole / Dashen',
      'boa': 'Bank of Abyssinia',
      'stripe': 'Stripe (Card)',
      'awash': 'Awash Birr',
    };

    if (_selectedMethod == 'stripe') {
      _showStripeMockSheet(methodNames['stripe']!);
      return;
    }

    _executePaymentFlow(methodNames[_selectedMethod] ?? 'Telebirr');
  }

  Future<void> _executePaymentFlow(String methodTitle) async {
    setState(() => _isProcessing = true);

    final user = ref.read(authStateProvider).user;
    final userId = user?.uid ?? 'mock_user_${DateTime.now().millisecondsSinceEpoch}';
    final churchId = user?.churchId ?? 'default_church';

    final txRef = 'TX-${const Uuid().v4()}';
    final receiptNo = 'EOTC-REC-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';

    log.i('PaymentMethodScreen', '💳 Processing: $methodTitle — ETB $_currentAmount');
    await Future.delayed(const Duration(milliseconds: 1000));

    final contribution = ContributionModel(
      id: txRef,
      userId: userId,
      churchId: churchId,
      type: widget.type,
      amount: _currentAmount,
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
        'amount': _currentAmount,
        'type': widget.type,
      });
    }
  }

  void _showStripeMockSheet(String methodTitle) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.asset(
                          'assets/icons/stripe.png',
                          width: 28,
                          height: 28,
                          errorBuilder: (_, __, ___) => const Icon(Icons.credit_card, color: AppTheme.royalEmerald),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'የስትራይፕ ካርድ ክፍያ',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.royalEmerald),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  )
                ],
              ),
              const SizedBox(height: 12),
              const Text('Enter Card details (Mock Integration)', style: TextStyle(fontSize: 12, color: Colors.black54)),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: '4242 •••• •••• 4242',
                decoration: InputDecoration(
                  labelText: 'የካርድ ቁጥር',
                  prefixIcon: const Icon(Icons.credit_card_rounded, color: AppTheme.royalEmerald),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: '12 / 28',
                      decoration: InputDecoration(
                        labelText: 'MM / YY',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      initialValue: '888',
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'CVC',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              PrimaryButton(
                text: 'Pay ETB ${_currentAmount.toStringAsFixed(2)} with Stripe',
                color: AppTheme.royalEmerald,
                onPressed: () {
                  Navigator.pop(ctx);
                  _executePaymentFlow('Stripe (Card)');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final methods = [
      _MethodItem('telebirr', 'ቴሌብር', 'የኢትዮ ቴሌኮም ዋሌት', 'assets/icons/telebirr.png', Icons.phone_android_rounded),
      _MethodItem('cbebirr', 'ሲቢኢ ብር', 'የኢትዮጵያ ንግድ ባንክ', 'assets/icons/cbe_birr.png', Icons.account_balance_rounded),
      _MethodItem('amoole', 'አሙሌ', 'የዳሸን ባንክ ሞባይል', 'assets/icons/amoole.png', Icons.credit_card_rounded),
      _MethodItem('boa', 'የአቢሲንያ ባንክ', 'BOA ቀጥታ / ኢ-ብር', 'assets/icons/boa.png', Icons.account_balance_wallet_rounded),
      _MethodItem('stripe', 'ስትራይፕ ካርድ', 'ቪዛ / ማስተርካርድ / ድያስፖራ', 'assets/icons/stripe.png', Icons.payment_rounded),
      _MethodItem('awash', 'አዋሽ ብር', 'የአዋሽ ባንክ ቀጥታ', 'assets/icons/awash.png', Icons.domain_rounded),
    ];

    return LoadingOverlay(
      isLoading: _isProcessing,
      message: 'Processing Payment...',
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.selectPaymentMethod), elevation: 0),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Interactive Editable Amount Card
                FadeTransition(
                  opacity: _headerFade,
                  child: SlideTransition(
                    position: _headerSlide,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppTheme.royalEmerald, Color(0xFF004D38)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.royalEmerald.withValues(alpha: 0.35),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.edit_note_rounded, color: AppTheme.imperialGold, size: 18),
                              SizedBox(width: 6),
                              Text(
                                'TOTAL CONTRIBUTION AMOUNT',
                                style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Editable Money Textfield
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: AppTheme.imperialGold.withValues(alpha: 0.6),
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Text(
                                  'ETB ',
                                  style: TextStyle(
                                    color: AppTheme.imperialGold,
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Flexible(
                                  child: TextField(
                                    controller: _amountController,
                                    focusNode: _amountFocusNode,
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    textAlign: TextAlign.center,
                                    cursorColor: AppTheme.imperialGold,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    decoration: const InputDecoration(
                                      hintText: '0.00',
                                      hintStyle: TextStyle(color: Colors.white38, fontSize: 32, fontWeight: FontWeight.bold),
                                      border: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                      filled: false,
                                      isDense: true,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                    onChanged: (val) {
                                      final parsed = double.tryParse(val) ?? 0.0;
                                      setState(() {
                                        _currentAmount = parsed;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 14),

                          // Quick Preset Amount Chips
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [100.0, 500.0, 1000.0, 5000.0].map((amt) {
                                final isSelected = _currentAmount == amt;
                                return Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                  child: GestureDetector(
                                    onTap: () => _updateAmount(amt),
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? AppTheme.imperialGold
                                            : Colors.white.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: isSelected
                                              ? AppTheme.imperialGold
                                              : Colors.white30,
                                        ),
                                      ),
                                      child: Text(
                                        '+${amt.toStringAsFixed(0)} ETB',
                                        style: TextStyle(
                                          color: isSelected ? Colors.black87 : Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                FadeTransition(
                  opacity: _cardsFade,
                  child: Text(
                    l10n.selectPaymentMethod,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.royalEmerald),
                  ),
                ),

                const SizedBox(height: 12),

                // Grid of Payment Methods (ShrinkWrapped inside SingleChildScrollView to prevent overflow)
                FadeTransition(
                  opacity: _cardsFade,
                  child: SlideTransition(
                    position: _cardsSlide,
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.85,
                      ),
                      itemCount: methods.length,
                      itemBuilder: (context, i) {
                        final m = methods[i];
                        final isSelected = _selectedMethod == m.id;
                        return TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: 1),
                          duration: Duration(milliseconds: 300 + (i * 50)),
                          curve: Curves.elasticOut,
                          builder: (context, scale, child) {
                            return Transform.scale(
                              scale: scale,
                              child: _PaymentGridCard(
                                item: m,
                                selected: isSelected,
                                onTap: () => setState(() => _selectedMethod = m.id),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                FadeTransition(
                  opacity: _btnFade,
                  child: PrimaryButton(
                    text: _currentAmount > 0
                        ? 'Pay ${_currentAmount.toStringAsFixed(2)} ETB'
                        : 'የመዋጮ መጠን ያስገቡ',
                    color: AppTheme.royalEmerald,
                    onPressed: _processPayment,
                  ),
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MethodItem {
  final String id;
  final String title;
  final String subtitle;
  final String assetPath;
  final IconData fallbackIcon;
  const _MethodItem(this.id, this.title, this.subtitle, this.assetPath, this.fallbackIcon);
}

/// Smooth, polished payment method selector (4-per-row)
class _PaymentGridCard extends StatefulWidget {
  final _MethodItem item;
  final bool selected;
  final VoidCallback onTap;

  const _PaymentGridCard({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  @override
  State<_PaymentGridCard> createState() => _PaymentGridCardState();
}

class _PaymentGridCardState extends State<_PaymentGridCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _scaleAnim = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
    );
  }

  @override
  void didUpdateWidget(_PaymentGridCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selected && !oldWidget.selected) {
      _controller.forward();
    } else if (!widget.selected && oldWidget.selected) {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.onTap();
        _controller.forward().then((_) => _controller.reverse());
      },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            decoration: BoxDecoration(
              color: widget.selected
                  ? AppTheme.royalEmerald.withValues(alpha: 0.12)
                  : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: widget.selected
                    ? AppTheme.royalEmerald
                    : Colors.grey.shade200,
                width: widget.selected ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.selected
                      ? AppTheme.royalEmerald.withValues(alpha: 0.18)
                      : Colors.black.withValues(alpha: 0.04),
                  blurRadius: widget.selected ? 12 : 4,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Animated Image Container
                Transform.scale(
                  scale: _scaleAnim.value,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Main image circle
                      Container(
                        width: 46,
                        height: 46,
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border: Border.all(
                            color: widget.selected
                                ? AppTheme.royalEmerald
                                : Colors.grey.shade300,
                            width: 1.5,
                          ),
                        ),
                        child: Image.asset(
                          widget.item.assetPath,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, _) => Icon(
                            widget.item.fallbackIcon,
                            color: AppTheme.royalEmerald,
                            size: 24,
                          ),
                        ),
                      ),
                      // Animated Checkmark
                      if (widget.selected)
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Container(
                            width: 18,
                            height: 18,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppTheme.royalEmerald,
                            ),
                            child: const Icon(
                              Icons.check_rounded,
                              color: Colors.white,
                              size: 11,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                // Title
                Text(
                  widget.item.title,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: widget.selected ? FontWeight.bold : FontWeight.w600,
                    color: widget.selected ? AppTheme.royalEmerald : Colors.black87,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
