import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:church/app/theme.dart';
import 'package:church/core/widgets/primary_button.dart';
import 'package:church/core/widgets/loading_overlay.dart';
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

class _PaymentMethodScreenState extends ConsumerState<PaymentMethodScreen> {
  String _selectedMethod = 'chapa';
  bool _isProcessing = false;

  Future<void> _processPayment() async {
    setState(() {
      _isProcessing = true;
    });

    final user = ref.read(authStateProvider).user;
    final userId = user?.uid ?? 'mock_user_${DateTime.now().millisecondsSinceEpoch}';
    final churchId = user?.churchId ?? 'default_church';

    final methodTitle = _selectedMethod == 'chapa' ? 'Chapa' : 'Telebirr';
    final txRef = 'TX-${const Uuid().v4()}';
    final receiptNo = 'EOTC-REC-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';

    log.i('PaymentMethodScreen', '💳 Processing mock payment: $methodTitle — ETB ${widget.amount} ($txRef)');

    // Smooth 600ms loading overlay so user sees quick feedback
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

    // Save contribution asynchronously in background — NEVER block UI navigation
    ref.read(contributionRepositoryProvider).createContribution(contribution).catchError((e) {
      log.w('PaymentMethodScreen', '⚠️ Firestore save background note: $e');
    });

    if (mounted) {
      setState(() => _isProcessing = false);
      log.i('PaymentMethodScreen', '🎉 Navigating to payment success screen! Receipt: $receiptNo');
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
        appBar: AppBar(
          title: Text(l10n.selectPaymentMethod),
          elevation: 0,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Text(
                  l10n.selectPaymentMethod,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryBlue,
                  ),
                ),
                const SizedBox(height: 30),
                // Payment Method Cards — RadioGroup owns groupValue/onChanged
                RadioGroup<String>(
                  groupValue: _selectedMethod,
                  onChanged: (val) => setState(() => _selectedMethod = val ?? _selectedMethod),
                  child: Column(
                    children: [
                      _PaymentCard(
                        value: 'chapa',
                        selected: _selectedMethod == 'chapa',
                        icon: Icons.payment,
                        iconColor: Colors.blue,
                        title: l10n.chapa,
                        subtitle: l10n.chapaDesc,
                      ),
                      const SizedBox(height: 16),
                      _PaymentCard(
                        value: 'telebirr',
                        selected: _selectedMethod == 'telebirr',
                        icon: Icons.phone_android,
                        iconColor: Colors.green,
                        title: l10n.telebirr,
                        subtitle: l10n.telebirrDesc,
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                PrimaryButton(
                  text: l10n.pay(widget.amount.toStringAsFixed(2)),
                  onPressed: _processPayment,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PaymentCard extends StatelessWidget {
  const _PaymentCard({
    required this.value,
    required this.selected,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
  });

  final String value;
  final bool selected;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: selected ? AppTheme.primaryGold : AppTheme.borderLight,
          width: selected ? 2 : 0.5,
        ),
      ),
      child: RadioListTile<String>(
        value: value,
        secondary: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
      ),
    );
  }
}
