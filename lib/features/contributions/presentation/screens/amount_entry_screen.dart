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

class _AmountEntryScreenState extends ConsumerState<AmountEntryScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  late final AnimationController _entrance;
  late final List<Animation<double>> _chipFades;
  late final List<Animation<double>> _chipScales;

  static const _quickAmounts = [100.0, 500.0, 1000.0, 2000.0, 5000.0];

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();

    // Chips stagger in after a short delay
    _chipFades = List.generate(_quickAmounts.length, (i) {
      final s = 0.25 + i * 0.09;
      return Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _entrance, curve: Interval(s, (s + 0.3).clamp(0, 1.0), curve: Curves.easeOut)),
      );
    });
    _chipScales = List.generate(_quickAmounts.length, (i) {
      final s = 0.25 + i * 0.09;
      return Tween<double>(begin: 0.6, end: 1.0).animate(
        CurvedAnimation(parent: _entrance, curve: Interval(s, (s + 0.4).clamp(0, 1.0), curve: Curves.easeOutBack)),
      );
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    _entrance.dispose();
    super.dispose();
  }

  void _proceed() {
    if (_formKey.currentState!.validate()) {
      final amount = double.tryParse(_amountController.text) ?? 0.0;
      final note = _noteController.text.trim();
      ref.read(activeContributionProvider.notifier).set(ActiveContribution(
        type: widget.contributionType,
        amount: amount,
        note: note.isEmpty ? null : note,
      ));
      context.push('/payment/method', extra: {
        'amount': amount,
        'type': widget.contributionType,
        'note': note.isEmpty ? null : note,
      });
    }
  }

  void _selectQuick(double amount) {
    setState(() {
      _amountController.text = amount.toStringAsFixed(0);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final typeLabel = _getTypeLabel(widget.contributionType, l10n);

    final headerFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _entrance, curve: const Interval(0.0, 0.4, curve: Curves.easeOut)),
    );
    final headerSlide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _entrance, curve: const Interval(0.0, 0.45, curve: Curves.easeOutCubic)),
    );
    final fieldFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _entrance, curve: const Interval(0.12, 0.50, curve: Curves.easeOut)),
    );

    return Scaffold(
      appBar: AppBar(title: Text(typeLabel), elevation: 0),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _entrance,
          builder: (context, _) {
            return Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),

                          // Header
                          FadeTransition(
                            opacity: headerFade,
                            child: SlideTransition(
                              position: headerSlide,
                              child: Text(
                                typeLabel,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.royalEmerald,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 28),

                          // Amount field
                          FadeTransition(
                            opacity: fieldFade,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.enterAmount,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.royalEmerald,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _amountController,
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                                  decoration: InputDecoration(
                                    hintText: l10n.amountHint,
                                    suffixText: l10n.currency,
                                    suffixStyle: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.imperialGold,
                                    ),
                                    prefixIcon: const Icon(Icons.monetization_on_rounded, color: AppTheme.imperialGold),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) return l10n.requiredField;
                                    final amount = double.tryParse(value);
                                    if (amount == null || amount <= 0) return l10n.invalidAmount;
                                    if (amount < 5.0) return l10n.minAmount('5');
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Quick-pick chips
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: List.generate(_quickAmounts.length, (i) {
                              final amount = _quickAmounts[i];
                              final selected = _amountController.text == amount.toStringAsFixed(0);
                              return FadeTransition(
                                opacity: _chipFades[i],
                                child: ScaleTransition(
                                  scale: _chipScales[i],
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    child: GestureDetector(
                                      onTap: () => _selectQuick(amount),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: selected
                                              ? AppTheme.imperialGold.withValues(alpha: 0.18)
                                              : Colors.white,
                                          borderRadius: BorderRadius.circular(24),
                                          border: Border.all(
                                            color: selected ? AppTheme.imperialGold : AppTheme.royalEmerald.withValues(alpha: 0.2),
                                            width: selected ? 2 : 1,
                                          ),
                                          boxShadow: selected
                                              ? [BoxShadow(color: AppTheme.imperialGold.withValues(alpha: 0.2), blurRadius: 8)]
                                              : null,
                                        ),
                                        child: Text(
                                          'ETB ${amount.toInt()}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                            color: selected ? AppTheme.royalEmerald : Colors.black54,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),

                          const SizedBox(height: 28),

                          // Note field
                          FadeTransition(
                            opacity: fieldFade,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.note,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.royalEmerald,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _noteController,
                                  maxLines: 3,
                                  decoration: InputDecoration(hintText: l10n.noteHint),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Proceed button pinned at bottom
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    child: FadeTransition(
                      opacity: fieldFade,
                      child: PrimaryButton(text: l10n.proceedToPayment, onPressed: _proceed),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
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
