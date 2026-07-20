import 'package:flutter/material.dart';
import 'package:church/app/theme.dart';
import 'package:church/l10n/app_localizations.dart';
import 'package:intl/intl.dart';

class RecentTransactionsList extends StatelessWidget {
  const RecentTransactionsList({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final currencyFormat = NumberFormat.currency(symbol: 'ETB ', decimalDigits: 2);

    // Mock data for initial rendering
    final mockTransactions = [
      _Transaction(
        type: 'asrat',
        amount: 2500.0,
        date: DateTime.now().subtract(const Duration(days: 1)),
        method: 'Telebirr',
        status: 'success',
      ),
      _Transaction(
        type: 'monastery',
        amount: 1000.0,
        date: DateTime.now().subtract(const Duration(days: 3)),
        method: 'Chapa (CBE)',
        status: 'success',
      ),
      _Transaction(
        type: 'bekuart',
        amount: 500.0,
        date: DateTime.now().subtract(const Duration(days: 5)),
        method: 'Telebirr',
        status: 'success',
      ),
    ];

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: mockTransactions.length,
      itemBuilder: (context, index) {
        final tx = mockTransactions[index];
        final typeLabel = _getTypeLabel(tx.type, l10n);

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
              typeLabel,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              '${DateFormat.yMMMd().format(tx.date)} • ${tx.method}',
              style: const TextStyle(fontSize: 12, color: Colors.black54),
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
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Success',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
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

class _Transaction {
  final String type;
  final double amount;
  final DateTime date;
  final String method;
  final String status;

  _Transaction({
    required this.type,
    required this.amount,
    required this.date,
    required this.method,
    required this.status,
  });
}
