import 'package:flutter/material.dart';
import 'package:church/app/theme.dart';
import 'package:church/core/widgets/primary_button.dart';
import 'package:church/core/widgets/ethiopian_cross_divider.dart';
import 'package:church/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class ReceiptScreen extends StatelessWidget {
  final String txId;
  final double amount;
  final String type;
  final String receiptNo;
  final DateTime date;

  const ReceiptScreen({
    super.key,
    required this.txId,
    required this.amount,
    required this.type,
    required this.receiptNo,
    required this.date,
  });

  Future<void> _printReceipt(BuildContext context, AppLocalizations l10n) async {
    final doc = pw.Document();

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80,
        build: (pw.Context pwContext) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(10),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Text(
                  'EOTC DIGITAL CONTRIBUTION',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
                ),
                pw.Text(
                  'RECEIPT / ደረሰኝ',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
                ),
                pw.Divider(),
                pw.SizedBox(height: 10),
                pw.Text('Receipt No: $receiptNo'),
                pw.Text('Date: ${DateFormat.yMMMd().format(date)}'),
                pw.Text('Type: $type'),
                pw.SizedBox(height: 10),
                pw.Divider(),
                pw.Text(
                  'AMOUNT: ${amount.toStringAsFixed(2)} ETB',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
                ),
                pw.Divider(),
                pw.SizedBox(height: 15),
                pw.Text('Thank you for your contribution!'),
                pw.Text('እግዚአብሔር ይመስገን!'),
              ],
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => doc.save(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final typeLabel = _getTypeLabel(type, l10n);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.downloadReceipt),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    const Icon(
                      Icons.church_rounded,
                      color: AppTheme.primaryGold,
                      size: 40,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'EOTC CONTRIBUTION RECEIPT',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppTheme.primaryBlue,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const EthiopianCrossDivider(height: 30),
                    _buildRow(l10n.receiptNumber, receiptNo),
                    const Divider(height: 24),
                    _buildRow('Transaction ID', txId.substring(0, 12).toUpperCase()),
                    const Divider(height: 24),
                    _buildRow('Date', DateFormat.yMMMd().add_jm().format(date)),
                    const Divider(height: 24),
                    _buildRow(l10n.contribute, typeLabel),
                    const Divider(height: 24),
                    _buildRow(l10n.enterAmount, '${amount.toStringAsFixed(2)} ETB', isBold: true),
                  ],
                ),
              ),
            ),
            const Spacer(),
            PrimaryButton(
              text: l10n.shareReceipt,
              onPressed: () => _printReceipt(context, l10n),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w500),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: isBold ? AppTheme.primaryGold : AppTheme.primaryBlue,
            fontSize: isBold ? 18 : 14,
          ),
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
