import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:church/app/theme.dart';
import 'package:church/core/widgets/primary_button.dart';
import 'package:church/features/contributions/presentation/providers/contribution_provider.dart';
import 'package:church/l10n/app_localizations.dart';

class AmountEntryScreen extends ConsumerStatefulWidget {
  final String contributionType;

  const AmountEntryScreen({super.key, required this.contributionType});

  @override
  ConsumerState<AmountEntryScreen> createState() => _AmountEntryScreenState();
}

class _AmountEntryScreenState extends ConsumerState<AmountEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _proceed() {
    if (_formKey.currentState!.validate()) {
      final amount = double.tryParse(_amountController.text) ?? 0.0;
      final note = _noteController.text.trim();

      ref.read(activeContributionProvider.notifier).state = ActiveContribution(
        type: widget.contributionType,
        amount: amount,
        note: note.isEmpty ? null : note,
      );

      context.push('/payment/method', extra: {
        'amount': amount,
        'type': widget.contributionType,
        'note': note.isEmpty ? null : note,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final typeLabel = _getTypeLabel(widget.contributionType, l10n);

    return Scaffold(
      appBar: AppBar(
        title: Text(typeLabel),
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Text(
                  '${l10n.contribute} - $typeLabel',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryBlue,
                  ),
                ),
                const SizedBox(height: 30),
                Text(
                  l10n.enterAmount,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryBlue,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    hintText: l10n.amountHint,
                    suffixText: l10n.currency,
                    suffixStyle: const TextStyle(fontSize: 18, color: AppTheme.primaryBlue),
                    prefixIcon: const Icon(Icons.monetization_on, color: AppTheme.primaryBlue),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.requiredField;
                    }
                    final amount = double.tryParse(value);
                    if (amount == null || amount <= 0) {
                      return l10n.invalidAmount;
                    }
                    if (amount < 5.0) {
                      return l10n.minAmount('5');
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                Text(
                  l10n.note,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryBlue,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _noteController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: l10n.noteHint,
                  ),
                ),
                const Spacer(),
                PrimaryButton(
                  text: l10n.proceedToPayment,
                  onPressed: _proceed,
                ),
              ],
            ),
          ),
        ),
      ),
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
