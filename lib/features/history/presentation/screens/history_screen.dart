import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:church/app/theme.dart';
import 'package:church/core/widgets/ethiopian_cross_divider.dart';
import 'package:church/l10n/app_localizations.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final currencyFormat = NumberFormat.currency(symbol: 'ETB ', decimalDigits: 2);

    final mockHistory = [
      _Tx(
        id: 'tx_001',
        type: 'asrat',
        amount: 2500.0,
        date: DateTime.now().subtract(const Duration(days: 1)),
        method: 'Telebirr',
        receiptNo: 'REC-2026-0719',
      ),
      _Tx(
        id: 'tx_002',
        type: 'monastery',
        amount: 1000.0,
        date: DateTime.now().subtract(const Duration(days: 3)),
        method: 'Chapa (CBE)',
        receiptNo: 'REC-2026-0717',
      ),
      _Tx(
        id: 'tx_003',
        type: 'bekuart',
        amount: 500.0,
        date: DateTime.now().subtract(const Duration(days: 5)),
        method: 'Telebirr',
        receiptNo: 'REC-2026-0715',
      ),
      _Tx(
        id: 'tx_004',
        type: 'monthly',
        amount: 200.0,
        date: DateTime.now().subtract(const Duration(days: 10)),
        method: 'Telebirr',
        receiptNo: 'REC-2026-0710',
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.transactionHistory),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Text(
              l10n.transactionHistory,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryBlue,
              ),
            ),
            const EthiopianCrossDivider(height: 30),
            Expanded(
              child: ListView.builder(
                itemCount: mockHistory.length,
                itemBuilder: (context, index) {
                  final tx = mockHistory[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryGold.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.receipt_long_rounded,
                          color: AppTheme.primaryGold,
                        ),
                      ),
                      title: Text(
                        _getTypeLabel(tx.type, l10n),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        '${DateFormat.yMMMd().format(tx.date)} • ${tx.method}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            currencyFormat.format(tx.amount),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryBlue,
                            ),
                          ),
                          const Icon(Icons.chevron_right, size: 16),
                        ],
                      ),
                      onTap: () {
                        context.push('/history/receipt', extra: {
                          'txId': tx.id,
                          'amount': tx.amount,
                          'type': tx.type,
                          'receiptNo': tx.receiptNo,
                          'date': tx.date,
                        });
                      },
                    ),
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

class _Tx {
  final String id;
  final String type;
  final double amount;
  final DateTime date;
  final String method;
  final String receiptNo;

  _Tx({
    required this.id,
    required this.type,
    required this.amount,
    required this.date,
    required this.method,
    required this.receiptNo,
  });
}
