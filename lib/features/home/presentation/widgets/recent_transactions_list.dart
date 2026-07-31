import 'package:flutter/material.dart';
import 'package:church/app/theme.dart';
import 'package:church/core/widgets/animated_count_text.dart';
import 'package:church/l10n/app_localizations.dart';
import 'package:intl/intl.dart';

class RecentTransactionsList extends StatefulWidget {
  const RecentTransactionsList({super.key});

  @override
  State<RecentTransactionsList> createState() => _RecentTransactionsListState();
}

class _RecentTransactionsListState extends State<RecentTransactionsList>
    with SingleTickerProviderStateMixin {
  late final AnimationController _stagger;
  late final List<Animation<double>> _fades;
  late final List<Animation<double>> _scales;

  static final _mockTransactions = [
    _Transaction(type: 'asrat', amount: 2500.0, date: DateTime.now().subtract(const Duration(days: 1)), method: 'Telebirr', status: 'success'),
    _Transaction(type: 'monastery', amount: 1000.0, date: DateTime.now().subtract(const Duration(days: 3)), method: 'Chapa (CBE)', status: 'success'),
    _Transaction(type: 'bekuart', amount: 500.0, date: DateTime.now().subtract(const Duration(days: 5)), method: 'Telebirr', status: 'success'),
  ];

  @override
  void initState() {
    super.initState();
    _stagger = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();

    _fades = List.generate(_mockTransactions.length, (i) {
      final s = i * 0.18;
      return Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _stagger, curve: Interval(s, (s + 0.4).clamp(0, 1.0), curve: Curves.easeOut)),
      );
    });
    _scales = List.generate(_mockTransactions.length, (i) {
      final s = i * 0.18;
      return Tween<double>(begin: 0.88, end: 1.0).animate(
        CurvedAnimation(parent: _stagger, curve: Interval(s, (s + 0.5).clamp(0, 1.0), curve: Curves.easeOutBack)),
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

    return AnimatedBuilder(
      animation: _stagger,
      builder: (context, _) => ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _mockTransactions.length,
        itemBuilder: (context, i) {
          final tx = _mockTransactions[i];
          return FadeTransition(
            opacity: _fades[i],
            child: ScaleTransition(
              scale: _scales[i],
              child: _TxRow(tx: tx, label: _getTypeLabel(tx.type, l10n), index: i),
            ),
          );
        },
      ),
    );
  }

  String _getTypeLabel(String type, AppLocalizations l10n) {
    switch (type) {
      case 'asrat': return l10n.asrat;
      case 'bekuart': return l10n.bekuart;
      case 'monthly': return l10n.monthly;
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

class _TxRow extends StatefulWidget {
  final _Transaction tx;
  final String label;
  final int index;

  const _TxRow({required this.tx, required this.label, required this.index});

  @override
  State<_TxRow> createState() => _TxRowState();
}

class _TxRowState extends State<_TxRow> with SingleTickerProviderStateMixin {
  late final AnimationController _badge;
  late final Animation<double> _badgeScale;

  @override
  void initState() {
    super.initState();
    _badge = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    Future.delayed(Duration(milliseconds: 500 + widget.index * 180), () {
      if (mounted) _badge.forward();
    });
    _badgeScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _badge, curve: Curves.easeOutBack),
    );
  }

  @override
  void dispose() {
    _badge.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.imperialGold.withValues(alpha: 0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppTheme.imperialGold.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.receipt_long_rounded, color: AppTheme.imperialGold, size: 20),
        ),
        title: Text(widget.label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        subtitle: Text(
          '${DateFormat.yMMMd().format(widget.tx.date)} • ${widget.tx.method}',
          style: const TextStyle(fontSize: 11, color: Colors.black45),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            AnimatedCountText(
              end: widget.tx.amount,
              prefix: 'ETB ',
              currency: true,
              duration: Duration(milliseconds: 900 + widget.index * 100),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppTheme.royalEmerald,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 4),
            ScaleTransition(
              scale: _badgeScale,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Success',
                  style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Transaction {
  final String type, method, status;
  final double amount;
  final DateTime date;

  const _Transaction({
    required this.type,
    required this.amount,
    required this.date,
    required this.method,
    required this.status,
  });
}
