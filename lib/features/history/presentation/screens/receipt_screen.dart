import 'package:flutter/material.dart';
import 'package:church/app/theme.dart';
import 'package:church/core/widgets/primary_button.dart';
import 'package:church/core/widgets/ethiopian_cross_divider.dart';
import 'package:church/core/animations/typewriter_text.dart';
import 'package:church/core/widgets/animated_count_text.dart';
import 'package:church/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class ReceiptScreen extends StatefulWidget {
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

  @override
  State<ReceiptScreen> createState() => _ReceiptScreenState();
}

class _ReceiptScreenState extends State<ReceiptScreen>
    with TickerProviderStateMixin {
  late final AnimationController _cardController;
  late final AnimationController _stampController;

  static const _rowDelays = [400, 650, 900, 1150, 1400];

  @override
  void initState() {
    super.initState();

    _cardController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();

    _stampController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );
    Future.delayed(const Duration(milliseconds: 1900), () {
      if (mounted) _stampController.forward();
    });
  }

  @override
  void dispose() {
    _cardController.dispose();
    _stampController.dispose();
    super.dispose();
  }

  Future<void> _printReceipt(BuildContext context, AppLocalizations l10n) async {
    final doc = pw.Document();
    doc.addPage(pw.Page(
      pageFormat: PdfPageFormat.roll80,
      build: (pw.Context c) => pw.Container(
        padding: const pw.EdgeInsets.all(10),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.Text('EOTC DIGITAL CONTRIBUTION', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
            pw.Text('RECEIPT / ደረሰኝ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
            pw.Divider(),
            pw.SizedBox(height: 10),
            pw.Text('Receipt No: ${widget.receiptNo}'),
            pw.Text('Date: ${DateFormat.yMMMd().format(widget.date)}'),
            pw.Text('Type: ${widget.type}'),
            pw.SizedBox(height: 10),
            pw.Divider(),
            pw.Text('AMOUNT: ${widget.amount.toStringAsFixed(2)} ETB', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
            pw.Divider(),
            pw.SizedBox(height: 15),
            pw.Text('Thank you for your contribution!'),
            pw.Text('እግዚአብሔር ይመስገን!'),
          ],
        ),
      ),
    ));
    await Printing.layoutPdf(onLayout: (_) async => doc.save());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final typeLabel = _getTypeLabel(widget.type, l10n);

    final cardSlide = Tween<Offset>(
      begin: const Offset(0, 0.6),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _cardController, curve: Curves.easeOutCubic));

    final cardFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _cardController, curve: const Interval(0, 0.5, curve: Curves.easeOut)),
    );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.downloadReceipt)),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 12),

            // Receipt card slides up like paper from a printer
            Expanded(
              child: SlideTransition(
                position: cardSlide,
                child: FadeTransition(
                  opacity: cardFade,
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 20,
                              offset: const Offset(0, 6),
                            ),
                          ],
                          border: Border.all(
                            color: AppTheme.primaryGold.withValues(alpha: 0.2),
                          ),
                        ),
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            children: [
                              // Header
                              const _PulsingIcon(),
                              const SizedBox(height: 14),
                              TypewriterText(
                                text: 'EOTC CONTRIBUTION RECEIPT',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: AppTheme.primaryBlue,
                                  letterSpacing: 1.1,
                                ),
                                textAlign: TextAlign.center,
                                perChar: const Duration(milliseconds: 22),
                              ),
                              const EthiopianCrossDivider(height: 28),

                              // Rows print one by one
                              _PrintRow(
                                label: l10n.receiptNumber,
                                value: widget.receiptNo,
                                delay: _rowDelays[0],
                              ),
                              const _Dashed(),
                              _PrintRow(
                                label: 'Transaction ID',
                                value: widget.txId.substring(0, 12).toUpperCase(),
                                delay: _rowDelays[1],
                              ),
                              const _Dashed(),
                              _PrintRow(
                                label: 'Date',
                                value: DateFormat.yMMMd().add_jm().format(widget.date),
                                delay: _rowDelays[2],
                              ),
                              const _Dashed(),
                              _PrintRow(
                                label: l10n.contribute,
                                value: typeLabel,
                                delay: _rowDelays[3],
                              ),
                              const _Dashed(),

                              // Amount — counts up, large
                              _DelayedReveal(
                                delay: _rowDelays[4],
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  child: Column(
                                    children: [
                                      const Text(
                                        'TOTAL AMOUNT',
                                        style: TextStyle(color: Colors.black38, fontSize: 11, letterSpacing: 1),
                                      ),
                                      const SizedBox(height: 6),
                                      AnimatedCountText(
                                        end: widget.amount,
                                        prefix: 'ETB ',
                                        currency: true,
                                        duration: const Duration(milliseconds: 1200),
                                        style: const TextStyle(
                                          fontSize: 26,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.primaryGold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(height: 12),
                              const Text(
                                'እግዚአብሔር ይመስገን! • God bless you!',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.black45, fontSize: 12, fontStyle: FontStyle.italic),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // "PAID" stamp slaps in at the end
                      Positioned(
                        right: 20,
                        top: 80,
                        child: _StampWidget(controller: _stampController),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
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

// Pulsing church icon at the top of the receipt
class _PulsingIcon extends StatefulWidget {
  const _PulsingIcon();

  @override
  State<_PulsingIcon> createState() => _PulsingIconState();
}

class _PulsingIconState extends State<_PulsingIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))
      ..repeat(reverse: true);
    _scale = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.primaryGold.withValues(alpha: 0.12),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: AppTheme.primaryGold.withValues(alpha: 0.2), blurRadius: 14),
          ],
        ),
        child: const Icon(Icons.church_rounded, color: AppTheme.primaryGold, size: 34),
      ),
    );
  }
}

// Each receipt row slides in from the right after a delay
class _PrintRow extends StatefulWidget {
  final String label;
  final String value;
  final int delay; // ms

  const _PrintRow({required this.label, required this.value, required this.delay});

  @override
  State<_PrintRow> createState() => _PrintRowState();
}

class _PrintRowState extends State<_PrintRow> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 350));
    _fade = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _slide = Tween<Offset>(begin: const Offset(0.2, 0), end: Offset.zero).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic),
    );
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(widget.label, style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w500, fontSize: 13)),
              Text(widget.value, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryBlue, fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }
}

class _DelayedReveal extends StatefulWidget {
  final Widget child;
  final int delay;
  const _DelayedReveal({required this.child, required this.delay});

  @override
  State<_DelayedReveal> createState() => _DelayedRevealState();
}

class _DelayedRevealState extends State<_DelayedReveal> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _fade = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _scale = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack),
    );
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
        opacity: _fade,
        child: ScaleTransition(scale: _scale, child: widget.child),
      );
}

// The "PAID" stamp that slaps in
class _StampWidget extends StatelessWidget {
  final AnimationController controller;
  const _StampWidget({required this.controller});

  @override
  Widget build(BuildContext context) {
    final scale = Tween<double>(begin: 2.2, end: 1.0).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeOutBack),
    );
    final rotate = Tween<double>(begin: -0.35, end: -0.12).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeOutBack),
    );
    final fade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: controller, curve: const Interval(0, 0.25, curve: Curves.easeIn)),
    );

    return AnimatedBuilder(
      animation: controller,
      builder: (_, _) => FadeTransition(
        opacity: fade,
        child: Transform.rotate(
          angle: rotate.value,
          child: Transform.scale(
            scale: scale.value,
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.green.withValues(alpha: 0.7), width: 2.5),
                color: Colors.green.withValues(alpha: 0.07),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_rounded, color: Colors.green, size: 22),
                  Text(
                    'PAID',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Dashed extends StatelessWidget {
  const _Dashed();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: List.generate(
          30,
          (i) => Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 1),
              height: 1,
              color: i.isEven ? AppTheme.primaryGold.withValues(alpha: 0.2) : Colors.transparent,
            ),
          ),
        ),
      ),
    );
  }
}

