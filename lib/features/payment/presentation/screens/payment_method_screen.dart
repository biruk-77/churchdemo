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
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not authenticated')),
      );
      setState(() {
        _isProcessing = false;
      });
      return;
    }

    final txRef = 'TX-${const Uuid().v4()}';
    bool paymentVerified = false;

    if (_selectedMethod == 'chapa') {
      final chapa = ref.read(chapaServiceProvider);
      final names = user.displayName.split(' ');
      final firstName = names.isNotEmpty ? names[0] : 'Member';
      final lastName = names.length > 1 ? names[1] : 'EOTC';

      final res = await chapa.initializePayment(
        txRef: txRef,
        amount: widget.amount,
        email: user.email ?? 'member@eotc.org',
        firstName: firstName,
        lastName: lastName,
        phone: user.phone,
        title: 'EOTC Contribution',
        description: widget.type,
      );

      if (res['success'] == true) {
        // In a real app, you would launch checkout url in Webview or browser.
        // We will simulate a quick success check after launching
        await Future.delayed(const Duration(seconds: 3));
        paymentVerified = await chapa.verifyPayment(txRef);
      }
    } else {
      // Telebirr
      final telebirr = ref.read(telebirrServiceProvider);
      final res = await telebirr.sendPaymentRequest(
        outTradeNo: txRef,
        amount: widget.amount,
        subject: 'EOTC Contribution: ${widget.type}',
      );

      if (res['success'] == true) {
        await Future.delayed(const Duration(seconds: 3));
        paymentVerified = await telebirr.checkTransactionStatus(res['tradeNo'] as String);
      }
    }

    if (paymentVerified && mounted) {
      final receiptNo = 'EOTC-REC-${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}';
      
      // Save contribution to Firestore
      final contribution = ContributionModel(
        id: txRef,
        userId: user.uid,
        churchId: user.churchId ?? 'default_church',
        type: widget.type,
        amount: widget.amount,
        paymentMethod: _selectedMethod == 'chapa' ? 'Chapa' : 'Telebirr',
        paymentRef: txRef,
        status: 'success',
        receiptNo: receiptNo,
        note: widget.note,
        createdAt: DateTime.now(),
      );

      await ref.read(contributionRepositoryProvider).createContribution(contribution);

      if (mounted) {
        context.go('/payment/success', extra: {
          'receiptNo': receiptNo,
          'amount': widget.amount,
          'type': widget.type,
        });
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment verification failed. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    if (mounted) {
      setState(() {
        _isProcessing = false;
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
                // Payment Method Cards
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: _selectedMethod == 'chapa' ? AppTheme.primaryGold : AppTheme.borderLight,
                      width: _selectedMethod == 'chapa' ? 2 : 0.5,
                    ),
                  ),
                  child: RadioListTile<String>(
                    value: 'chapa',
                    groupValue: _selectedMethod,
                    onChanged: (val) {
                      setState(() {
                        _selectedMethod = val!;
                      });
                    },
                    secondary: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.payment, color: Colors.blue),
                    ),
                    title: Text(
                      l10n.chapa,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(l10n.chapaDesc),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: _selectedMethod == 'telebirr' ? AppTheme.primaryGold : AppTheme.borderLight,
                      width: _selectedMethod == 'telebirr' ? 2 : 0.5,
                    ),
                  ),
                  child: RadioListTile<String>(
                    value: 'telebirr',
                    groupValue: _selectedMethod,
                    onChanged: (val) {
                      setState(() {
                        _selectedMethod = val!;
                      });
                    },
                    secondary: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.phone_android, color: Colors.green),
                    ),
                    title: Text(
                      l10n.telebirr,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(l10n.telebirrDesc),
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
