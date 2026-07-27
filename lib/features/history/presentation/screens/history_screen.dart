import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:church/app/theme.dart';
import 'package:church/core/widgets/ethiopian_cross_divider.dart';
import 'package:church/l10n/app_localizations.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _stagger;
  late final List<Animation<double>> _fades;
  late final List<Animation<Offset>> _slides;

  final _mockHistory = [
    _Tx(id: 'tx_001', type: 'asrat', amount: 2500.0, date: DateTime.now().subtract(const Duration(days: 1)), method: 'Telebirr', receiptNo: 'REC-2026-0719'),
    _Tx(id: 'tx_002', type: 'monastery', amount: 1000.0, date: DateTime.now().subtract(const Duration(days: 3)), method: 'Chapa (CBE)', receiptNo: 'REC-2026-0717'),
    _Tx(id: 'tx_003', type: 'bekuart', amount: 500.0, date: DateTime.now().subtract(const Duration(days: 5)), method: 'Telebirr', receiptNo: 'REC-2026-0715'),
    _Tx(id: 'tx_004', type: 'monthly', amount: 200.0, date: DateTime.now().subtract(const Duration(days: 10)), method: 'Telebirr', receiptNo: 'REC-2026-0710'),
  ];

  @override
  void initState() {
    super.initState();
    _stagger = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();

    _fades = List.generate(_mockHistory.length, (i) {
      final s = i * 0.12;
      return Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _stagger, curve: Interval(s, (s + 0.4).clamp(0, 1.0), curve: Curves.easeOut)),
      );
    });
    _slides = List.generate(_mockHistory.length, (i) {
      final s = i * 0.12;
      return Tween<Offset>(begin: const Offset(0.25, 0), end: Offset.zero).animate(
        CurvedAnimation(parent: _stagger, curve: Interval(s, (s + 0.5).clamp(0, 1.0), curve: Curves.easeOutCubic)),
      );
    });
  }

  @override
  void dispose() {
    _stagger.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final currencyFormat = NumberFormat.currency(symbol: 'ETB ', decimalDigits: 2);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.transactionHistory), elevation: 0),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Text(
              l10n.transactionHistory,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
            ),
            const EthiopianCrossDivider(height: 30),
            Expanded(
              child: AnimatedBuilder(
                animation: _stagger,
                builder: (context, _) {
                  return ListView.builder(
                    itemCount: _mockHistory.length,
                    itemBuilder: (context, index) {
                      final tx = _mockHistory[index];
                      return FadeTransition(
                        opacity: _fades[index],
                        child: SlideTransition(
                          position: _slides[index],
                          child: _TxCard(
                            tx: tx,
                            label: _getTypeLabel(tx.type, l10n),
                            formatted: currencyFormat.format(tx.amount),
                            onTap: () => context.push('/history/receipt', extra: {
                              'txId': tx.id,
                              'amount': tx.amount,
                              'type': tx.type,
                              'receiptNo': tx.receiptNo,
                              'date': tx.date,
                            }),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
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
      default: return type;
    }
  }
}

class _TxCard extends StatefulWidget {
  final _Tx tx;
  final String label;
  final String formatted;
  final VoidCallback onTap;

  const _TxCard({
    required this.tx,
    required this.label,
    required this.formatted,
    required this.onTap,
  });

  @override
  State<_TxCard> createState() => _TxCardState();
}

class _TxCardState extends State<_TxCard> with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 2800))
      ..repeat(reverse: true);
    _scale = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _pulse, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.primaryGold.withValues(alpha: 0.15)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            leading: ScaleTransition(
              scale: _scale,
              child: Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppTheme.primaryGold.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.receipt_long_rounded, color: AppTheme.primaryGold, size: 22),
              ),
            ),
            title: Text(widget.label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            subtitle: Text(
              '${DateFormat.yMMMd().format(widget.tx.date)} • ${widget.tx.method}',
              style: const TextStyle(fontSize: 12, color: Colors.black45),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  widget.formatted,
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryBlue, fontSize: 13),
                ),
                const Icon(Icons.chevron_right, size: 16, color: Colors.black26),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Tx {
  final String id, type, method, receiptNo;
  final double amount;
  final DateTime date;
  const _Tx({required this.id, required this.type, required this.amount, required this.date, required this.method, required this.receiptNo});
}
