import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:church/app/theme.dart';
import 'package:church/core/widgets/primary_button.dart';
import 'package:church/core/widgets/ethiopian_cross_divider.dart';
import 'package:church/l10n/app_localizations.dart';

class PaymentSuccessScreen extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final typeLabel = _getTypeLabel(type, l10n);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: Colors.green,
                  size: 80,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                l10n.paymentSuccess,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 10),
              const EthiopianCrossDivider(height: 40),
              const SizedBox(height: 10),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      _buildRow(l10n.receiptNumber, receiptNo),
                      const Divider(height: 24),
                      _buildRow(l10n.enterAmount, '${amount.toStringAsFixed(2)} ETB'),
                      const Divider(height: 24),
                      _buildRow(l10n.contribute, typeLabel),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              PrimaryButton(
                text: l10n.done,
                onPressed: () {
                  context.go('/home');
                },
              ),
              const SizedBox(height: 16),
              PrimaryButton(
                text: l10n.downloadReceipt,
                isOutlined: true,
                onPressed: () {
                  // Direct receipt view in history
                  context.push('/history');
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w500),
        ),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
        ),
      ],
    );
  }

  String _getTypeLabel(String type, AppLocalizations l10n) {
    switch (type) {
      case 'asrat':
        return l10n.asrat;
      case 'bekuart':
        return l10n.bekuart;
      case 'monthly':
        return l10n.monthly;
      case 'buildingFund':
        return l10n.buildingFund;
      case 'charity':
        return l10n.charity;
      case 'festival':
        return l10n.festival;
      case 'candle':
        return l10n.candle;
      case 'memorial':
        return l10n.memorial;
      case 'monastery':
        return l10n.monastery;
      case 'priest':
        return l10n.priest;
      case 'sundaySchool':
        return l10n.sundaySchool;
      case 'youth':
        return l10n.youth;
      case 'women':
        return l10n.women;
      case 'development':
        return l10n.development;
      case 'emergency':
        return l10n.emergency;
      default:
        return type;
    }
  }
}
