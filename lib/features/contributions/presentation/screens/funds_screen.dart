import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:church/app/theme.dart';
import 'package:church/core/animations/shimmer_overlay.dart';
import 'package:church/l10n/app_localizations.dart';

class FundItem {
  final String id;
  final String title;
  final String description;
  final String category;
  final String categoryLabel;
  final String scopeLevel;
  final String scopeLabel;
  final String jurisdictionName;
  final double raisedAmount;
  final double targetAmount;
  final bool hasGoal;
  final String icon;
  final bool isFeatured;

  const FundItem({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.categoryLabel,
    required this.scopeLevel,
    required this.scopeLabel,
    required this.jurisdictionName,
    required this.raisedAmount,
    required this.targetAmount,
    this.hasGoal = true,
    required this.icon,
    this.isFeatured = false,
  });
}

class FundsScreen extends ConsumerStatefulWidget {
  const FundsScreen({super.key});

  @override
  ConsumerState<FundsScreen> createState() => _FundsScreenState();
}

class _FundsScreenState extends ConsumerState<FundsScreen> {
  String _searchQuery = '';
  String _selectedScope = 'all';

  List<FundItem> _getCuratedFunds() {
    return const [
      FundItem(
        id: 'fund_addis_asrat',
        title: 'ማዕከላዊ አስራትና የካህናት ደህንነት ፈንድ',
        description: 'በአዲስ አበባ ሀገረ ስብከት ውስጥ ለካህናት ደህንነትና ለሥነ መለኮት ትምህርት ቤቶች የተመደበ ዓመታዊ የአስራት እና የካህናት ድጋፍ ፈንድ።',
        category: 'አስራት',
        categoryLabel: 'አስራት',
        scopeLevel: 'diocese',
        scopeLabel: 'ሀገረ ስብከት',
        jurisdictionName: 'አዲስ አበባ ሀገረ ስብከት',
        raisedAmount: 2820000.0,
        targetAmount: 0,
        hasGoal: false,
        icon: '📜',
        isFeatured: true,
      ),
      FundItem(
        id: 'fund_adama_cathedral',
        title: 'የቅድስት ሥላሴ ካቴድራል የቤተ መቅደስ ማስፋፊያ',
        description: 'በአዳማ ሀገረ ስብከት ዋና ካቴድራል ውስጥ የቤተ መቅደስ ማስፋፊያና የሥዕላት ንድፍ ፕሮጀክት።',
        category: 'ግንባታ ፈንድ',
        categoryLabel: 'ግንባታ ፈንድ',
        scopeLevel: 'diocese',
        scopeLabel: 'ሀገረ ስብከት',
        jurisdictionName: 'አዳማ ሀገረ ስብከት',
        raisedAmount: 1450000.0,
        targetAmount: 2500000.0,
        hasGoal: true,
        icon: '🏛️',
        isFeatured: true,
      ),
      FundItem(
        id: 'fund_hawassa_woreda_bekuart',
        title: 'ወረዳ 01 የበኩራት ቤተ መቅደስ መባ',
        description: 'በሐዋሳ 01 አጥቢያ አብያተ ክርስቲያናት ውስጥ ለቅዱሳት ዕቃዎች፣ ልብሰ ተክህኖና ለቅዳሴ ዝግጅት የተመደበ የወረዳ ደረጃ ፈንድ።',
        category: 'በኩራት',
        categoryLabel: 'የበኩራት መባ',
        scopeLevel: 'woreda',
        scopeLabel: 'ወረዳ ቤተ ክህነት',
        jurisdictionName: 'ሐዋሳ ወረዳ ቤተ ክህነት 01',
        raisedAmount: 480000.0,
        targetAmount: 0,
        hasGoal: false,
        icon: '🕯️',
        isFeatured: false,
      ),
      FundItem(
        id: 'fund_hawassa_diocese_cathedral',
        title: 'የሐዋሳ ካቴድራል እድሳት ዘመቻ',
        description: 'ለሐዋሳ ማዕከላዊ ካቴድራል ትልቅ የጣሪያ እድሳት፣ የድምጽ ማጉያ ተከላና የግቢ ንጣፍ ስራ።',
        category: 'ግንባታ ፈንድ',
        categoryLabel: 'ግንባታ ፈንድ',
        scopeLevel: 'diocese',
        scopeLabel: 'ሀገረ ስብከት',
        jurisdictionName: 'ሐዋሳ ሀገረ ስብከት',
        raisedAmount: 1850000.0,
        targetAmount: 3000000.0,
        hasGoal: true,
        icon: '⛪',
        isFeatured: true,
      ),
      FundItem(
        id: 'fund_hawassa_diocese_youth',
        title: 'የሰንበት ትምህርት ቤትና የወጣቶች መንፈሳዊ ማዕከል',
        description: 'ለመንፈሳዊ ትምህርት፣ ቤተ መጻሕፍትና ለሰንበት ትምህርት ቤት ስብሰባዎች የሚያገለግል ባለብዙ አገልግሎት የወጣቶች ማዕከል ግንባታ።',
        category: 'ሰንበት ትምህርት ቤት',
        categoryLabel: 'ሰንበት ትምህርት ቤት',
        scopeLevel: 'diocese',
        scopeLabel: 'ሀገረ ስብከት',
        jurisdictionName: 'ሐዋሳ ሀገረ ስብከት',
        raisedAmount: 890000.0,
        targetAmount: 1200000.0,
        hasGoal: true,
        icon: '📖',
        isFeatured: false,
      ),
      FundItem(
        id: 'fund_debre_libanos_restoration',
        title: 'ቅዱስ ቅርስና የግዕዝ ጽሑፍ ጥበቃ',
        description: 'በደብረ ሊባኖስ ውስጥ ጥንታዊ የግዕዝ ጽሑፎችን፣ የመነኮሳት መኖሪያንና የምዕመናን ማረፊያ አዳራሾችን መጠበቅ።',
        category: 'የገዳም ድጋፍ',
        categoryLabel: 'የገዳም ድጋፍ',
        scopeLevel: 'church',
        scopeLabel: 'ገዳም',
        jurisdictionName: 'ደብረ ሊባኖስ ገዳም',
        raisedAmount: 2100000.0,
        targetAmount: 3000000.0,
        hasGoal: true,
        icon: '🏔️',
        isFeatured: true,
      ),
      FundItem(
        id: 'fund_emergency_drought_relief',
        title: 'የመንበረ ፓትርያርክ ብሔራዊ የአስቸኳይ ጊዜ እርዳታ ፈንድ',
        description: 'ለድርቅና ለቀውስ ለተጎዱ የገጠር ማህበረሰቦች የሰብዓዊ ድጋፍ፣ የምግብ ስርጭትና የአስቸኳይ ጊዜ ድጋፍ።',
        category: 'የአስቸኳይ ጊዜ እርዳታ',
        categoryLabel: 'የአስቸኳይ ጊዜ እርዳታ',
        scopeLevel: 'national',
        scopeLabel: 'ቅዱስ ሲኖዶስ (መንበረ ፓትርያርክ)',
        jurisdictionName: 'የኢ.ኦ.ተ.ቤ.ክ ቅዱስ ሲኖዶስ ፓትርያርክ',
        raisedAmount: 4150000.0,
        targetAmount: 6000000.0,
        hasGoal: true,
        icon: '🆘',
        isFeatured: true,
      ),
    ];
  }

  void _showFundDetailModal(BuildContext context, FundItem fund) {
    final double progress = fund.hasGoal && fund.targetAmount > 0
        ? (fund.raisedAmount / fund.targetAmount).clamp(0.0, 1.0)
        : 1.0;
    final int percentage = (progress * 100).toInt();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(ctx).size.height * 0.84,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          children: [
            // Hero Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF003828), AppTheme.royalEmerald],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 5,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white30,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.imperialGold.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppTheme.imperialGold),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(fund.icon, style: const TextStyle(fontSize: 14)),
                            const SizedBox(width: 6),
                            Text(
                              fund.categoryLabel,
                              style: const TextStyle(
                                color: AppTheme.imperialGold,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(ctx),
                        icon: const Icon(Icons.close_rounded, color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    fund.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.account_balance_rounded, color: AppTheme.imperialGold, size: 14),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Created by: ${fund.jurisdictionName} • ${fund.scopeLabel}',
                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Governing Jurisdiction Info Box
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.royalEmerald.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppTheme.royalEmerald.withValues(alpha: 0.15)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppTheme.royalEmerald.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.verified_user_rounded, color: AppTheme.royalEmerald, size: 24),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'የሚያስተዳድር ስልጣን ክልል',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.royalEmerald,
                                    letterSpacing: 1,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  fund.jurisdictionName,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1E2923),
                                  ),
                                ),
                                Text(
                                  'በቅዱስ ሲኖዶስ የተረጋገጠ አስተዳደራዊ ጉባኤ',
                                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Metrics Box
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey.shade200),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    fund.hasGoal ? 'እስካሁን የተሰበሰበ ጠቅላላ' : 'ድምር መዋጮዎች',
                                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey.shade500),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'ETB ${fund.raisedAmount.toStringAsFixed(0)}',
                                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.royalEmerald),
                                  ),
                                ],
                              ),
                              if (fund.hasGoal)
                                Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    SizedBox(
                                      width: 56,
                                      height: 56,
                                      child: CircularProgressIndicator(
                                        value: progress,
                                        strokeWidth: 6,
                                        backgroundColor: AppTheme.royalEmerald.withValues(alpha: 0.1),
                                        valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.royalEmerald),
                                      ),
                                    ),
                                    Text(
                                      '$percentage%',
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.royalEmerald),
                                    ),
                                  ],
                                )
                              else
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: AppTheme.royalEmerald.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: AppTheme.royalEmerald.withValues(alpha: 0.3)),
                                  ),
                                  child: const Row(
                                    children: [
                                      Icon(Icons.all_inclusive_rounded, size: 16, color: AppTheme.royalEmerald),
                                      SizedBox(width: 4),
                                      Text(
                                        'ቀጣይ ፈንድ',
                                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.royalEmerald),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          if (fund.hasGoal) ...[
                            const SizedBox(height: 14),
                            Divider(color: Colors.grey.shade200),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Target Fundraising Goal:', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                                Text('ETB ${fund.targetAmount.toStringAsFixed(0)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    const Text(
                      'Fund Purpose & Sacred Impact',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.royalEmerald),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      fund.description,
                      style: TextStyle(fontSize: 14, color: Colors.grey.shade800, height: 1.5),
                    ),

                    const SizedBox(height: 24),

                    // Payment Methods Banner
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.lock_outline_rounded, size: 18, color: AppTheme.royalEmerald),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Direct Bank Transfer, Telebirr, CBE Birr & Chapa Active.',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.black87),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Direct Contribute Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          _showQuickPaymentSheet(context, fund);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.royalEmerald,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 4,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.volunteer_activism_rounded, color: AppTheme.imperialGold),
                            SizedBox(width: 8),
                            Text(
                              'ለዚህ ዓላማ አስተዋፅዖ ያድርጉ',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showQuickPaymentSheet(BuildContext context, FundItem fund) {
    double selectedAmount = 500.0;
    String selectedMethod = 'telebirr';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          final amountTextController = TextEditingController(text: selectedAmount.toStringAsFixed(0));

          return Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Drag Handle & Title Header
                  Center(
                    child: Container(
                      width: 44,
                      height: 5,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppTheme.royalEmerald.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Text(fund.icon, style: const TextStyle(fontSize: 18)),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'ፈጣን መዋጮ',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.royalEmerald,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                  Text(
                                    fund.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1E2923),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(ctx),
                        icon: const Icon(Icons.close_rounded, color: Colors.grey),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                  Divider(color: Colors.grey.shade200),
                  const SizedBox(height: 14),

                  // Preset Amount Selection Section
                  const Text(
                    '1. የመዋጮ መጠን ይምረጡ (ብር)',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.royalEmerald,
                    ),
                  ),
                  const SizedBox(height: 10),

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [100.0, 250.0, 500.0, 1000.0, 2500.0, 5000.0].map((amt) {
                      final isSelected = selectedAmount == amt;
                      return ChoiceChip(
                        label: Text(
                          'ETB ${amt.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: isSelected ? Colors.white : AppTheme.royalEmerald,
                          ),
                        ),
                        selected: isSelected,
                        selectedColor: AppTheme.royalEmerald,
                        backgroundColor: AppTheme.royalEmerald.withValues(alpha: 0.05),
                        side: BorderSide(
                          color: isSelected ? AppTheme.royalEmerald : AppTheme.royalEmerald.withValues(alpha: 0.2),
                        ),
                        onSelected: (_) {
                          setModalState(() {
                            selectedAmount = amt;
                          });
                        },
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 18),

                  // Custom Amount Input
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.royalEmerald.withValues(alpha: 0.3)),
                    ),
                    child: TextField(
                      keyboardType: TextInputType.number,
                      controller: amountTextController,
                      onChanged: (val) {
                        final parsed = double.tryParse(val);
                        if (parsed != null && parsed > 0) {
                          setModalState(() => selectedAmount = parsed);
                        }
                      },
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.royalEmerald),
                      decoration: const InputDecoration(
                        prefixText: 'ETB ',
                        prefixStyle: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.royalEmerald, fontSize: 16),
                        labelText: 'የተለየ የመዋጮ መጠን',
                        labelStyle: TextStyle(fontSize: 12, color: Colors.grey),
                        border: InputBorder.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 22),

                  // Gateway Selector Section
                  const Text(
                    '2. የክፍያ ዘዴ ይምረጡ',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.royalEmerald,
                    ),
                  ),
                  const SizedBox(height: 10),

                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 2.3,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    children: [
                      {'id': 'telebirr', 'title': 'ቴሌብር', 'sub': 'የኢትዮ ቴሌኮም ገንዘብ', 'icon': '📱'},
                      {'id': 'cbe', 'title': 'ሲቢኢ ብር', 'sub': 'የንግድ ባንክ', 'icon': '🏦'},
                      {'id': 'chapa', 'title': 'ቻፓ መግቢያ', 'sub': 'የአካባቢ ካርዶችና ባንክ', 'icon': '💳'},
                      {'id': 'stripe', 'title': 'Stripe', 'sub': 'Visa / Mastercard', 'icon': '🌐'},
                    ].map((method) {
                      final isSelected = selectedMethod == method['id'];
                      return InkWell(
                        onTap: () => setModalState(() => selectedMethod = method['id']!),
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isSelected ? AppTheme.royalEmerald.withValues(alpha: 0.08) : Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected ? AppTheme.royalEmerald : Colors.grey.shade300,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Text(method['icon']!, style: const TextStyle(fontSize: 20)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      method['title']!,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: isSelected ? AppTheme.royalEmerald : const Color(0xFF1E2923),
                                      ),
                                    ),
                                    Text(
                                      method['sub']!,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(fontSize: 9.5, color: Colors.grey.shade600),
                                    ),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                const Icon(Icons.check_circle_rounded, color: AppTheme.royalEmerald, size: 18),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),

                  // Confirm & Pay Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);

                        // Route to payment screen with selected amount & method!
                        context.push('/payment/method', extra: {
                          'amount': selectedAmount,
                          'type': fund.category,
                          'note': 'Contribution to ${fund.title}',
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.royalEmerald,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.lock_rounded, color: AppTheme.imperialGold, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            'አረጋግጥና ${selectedAmount.toStringAsFixed(0)} ብር ክፈል',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F5),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('contributionTypes').snapshots(),
          builder: (context, snapshot) {
            List<FundItem> allFunds = _getCuratedFunds();

            // Real-time Firestore document mapping
            if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
              final firestoreFunds = snapshot.data!.docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final bool hasGoal = (data['hasGoal'] as bool?) ??
                    ((data['targetAmount'] as num?) != null && (data['targetAmount'] as num) > 0);

                final String iconStr = (data['icon'] as String?)?.trim() ?? '';
                final String rawCategory = (data['category'] as String?)?.trim() ?? 'አጠቃላይ ፈንድ';

                return FundItem(
                  id: doc.id,
                  title: (data['name'] ?? 'ቅዱስ ፈንድ') as String,
                  description: (data['description'] ?? 'Diocese/Woreda verified contribution fund.') as String,
                  category: rawCategory,
                  categoryLabel: rawCategory.toUpperCase(),
                  scopeLevel: (data['scopeLevel'] ?? 'diocese') as String,
                  scopeLabel: data['scopeLevel'] == 'woreda' ? 'Woreda (ወረዳ)' : 'Hager Sibket (ሀገረ ስብከት)',
                  jurisdictionName: (data['jurisdictionName'] ?? data['dioceseName'] ?? 'የሀገረ ስብከት ስልጣን ክልል') as String,
                  raisedAmount: (data['raisedAmount'] as num? ?? 0.0).toDouble(),
                  targetAmount: (data['targetAmount'] as num? ?? 0.0).toDouble(),
                  hasGoal: hasGoal,
                  icon: iconStr.isNotEmpty ? iconStr : '⛪',
                  isFeatured: true,
                );
              }).toList();

              allFunds = [...firestoreFunds, ...allFunds];
            }

            // Search and Scope Filtering
            final filteredFunds = allFunds.where((fund) {
              final matchesScope = _selectedScope == 'all' || fund.scopeLevel == _selectedScope;
              if (!matchesScope) return false;

              if (_searchQuery.isEmpty) return true;
              final q = _searchQuery.toLowerCase();
              return fund.title.toLowerCase().contains(q) ||
                  fund.description.toLowerCase().contains(q) ||
                  fund.jurisdictionName.toLowerCase().contains(q) ||
                  fund.category.toLowerCase().contains(q);
            }).toList();

            // Group funds by Jurisdiction Entity Name!
            final Map<String, List<FundItem>> groupedByJurisdiction = {};
            for (final fund in filteredFunds) {
              groupedByJurisdiction.putIfAbsent(fund.jurisdictionName, () => []).add(fund);
            }

            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Top Header + Search Bar
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'Diocese & Woreda Funds',
                                  style: TextStyle(
                                    fontSize: 23,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.royalEmerald,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Hager Sibket & Woreda Contribution Hierarchy',
                                  style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppTheme.royalEmerald.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: SpinningRing(
                                size: 24,
                                color: AppTheme.royalEmerald,
                                period: const Duration(seconds: 8),
                                child: const Icon(Icons.church_rounded, color: AppTheme.royalEmerald, size: 16),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Standalone Clean Search Bar
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppTheme.royalEmerald.withValues(alpha: 0.2), width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: TextField(
                            style: const TextStyle(
                              color: Color(0xFF1E2923),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                            onChanged: (val) => setState(() => _searchQuery = val),
                            decoration: InputDecoration(
                              hintText: 'በሀገረ ስብከት፣ ወረዳ ወይም ዓላማ ይፈልጉ…',
                              hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 13, fontWeight: FontWeight.normal),
                              prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.royalEmerald, size: 22),
                              suffixIcon: _searchQuery.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear_rounded, color: Colors.grey, size: 20),
                                      onPressed: () => setState(() => _searchQuery = ''),
                                    )
                                  : null,
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Jurisdiction Scope Filter Tabs
                SliverToBoxAdapter(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    child: Row(
                      children: [
                        {'id': 'all', 'label': 'ሁሉም ስልጣን ክልሎች', 'icon': '🌟'},
                        {'id': 'diocese', 'label': 'ሀገረ ስብከት', 'icon': '🏛️'},
                        {'id': 'woreda', 'label': 'ወረዳ ቤተ ክህነት', 'icon': '🗺️'},
                        {'id': 'church', 'label': 'ደብሮችና ገዳማት', 'icon': '⛪'},
                        {'id': 'national', 'label': 'ቅዱስ ሲኖዶስ', 'icon': '👑'},
                      ].map((tab) {
                        final isSelected = _selectedScope == tab['id'];
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: FilterChip(
                            selected: isSelected,
                            showCheckmark: false,
                            avatar: Text(tab['icon']!, style: const TextStyle(fontSize: 12)),
                            label: Text(
                              tab['label']!,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: isSelected ? Colors.white : AppTheme.royalEmerald,
                              ),
                            ),
                            selectedColor: AppTheme.royalEmerald,
                            backgroundColor: Colors.white,
                            side: BorderSide(
                              color: isSelected ? AppTheme.royalEmerald : AppTheme.royalEmerald.withValues(alpha: 0.2),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            onSelected: (_) => setState(() => _selectedScope = tab['id']!),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 12)),

                // Jurisdiction Entity Cards System
                if (groupedByJurisdiction.isEmpty)
                  SliverToBoxAdapter(
                    child: Container(
                      margin: const EdgeInsets.all(20),
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.black12),
                      ),
                      child: Column(
                        children: const [
                          Icon(Icons.search_off_rounded, size: 48, color: Colors.grey),
                          SizedBox(height: 12),
                          Text(
                            'ከዚህ ስልጣን ክልል ጋር የሚዛመድ ፈንድ አልተገኘም',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Try adjusting your search query or jurisdiction filter.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final jurisdictionName = groupedByJurisdiction.keys.elementAt(index);
                          final funds = groupedByJurisdiction[jurisdictionName]!;
                          final firstFund = funds.first;

                          return _JurisdictionEntityCard(
                            jurisdictionName: jurisdictionName,
                            scopeLabel: firstFund.scopeLabel,
                            scopeLevel: firstFund.scopeLevel,
                            funds: funds,
                            onFundTap: (fund) => _showFundDetailModal(context, fund),
                            onQuickPay: (fund) => _showQuickPaymentSheet(context, fund),
                          );
                        },
                        childCount: groupedByJurisdiction.length,
                      ),
                    ),
                  ),

                const SliverToBoxAdapter(child: SizedBox(height: 40)),
              ],
            );
          },
        ),
      ),
    );
  }
}

// Card representing a Jurisdiction Entity with a 4-in-a-row mini card grid of funds
class _JurisdictionEntityCard extends StatefulWidget {
  final String jurisdictionName;
  final String scopeLabel;
  final String scopeLevel;
  final List<FundItem> funds;
  final Function(FundItem) onFundTap;
  final Function(FundItem) onQuickPay;

  const _JurisdictionEntityCard({
    required this.jurisdictionName,
    required this.scopeLabel,
    required this.scopeLevel,
    required this.funds,
    required this.onFundTap,
    required this.onQuickPay,
  });

  @override
  State<_JurisdictionEntityCard> createState() => _JurisdictionEntityCardState();
}

class _JurisdictionEntityCardState extends State<_JurisdictionEntityCard> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    IconData getJurisdictionIcon() {
      if (widget.scopeLevel == 'woreda') return Icons.map_rounded;
      if (widget.scopeLevel == 'church') return Icons.church_rounded;
      if (widget.scopeLevel == 'national') return Icons.stars_rounded;
      return Icons.account_balance_rounded;
    }

    final double totalRaisedInEntity = widget.funds.fold(0.0, (sum, f) => sum + f.raisedAmount);

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppTheme.royalEmerald.withValues(alpha: 0.18),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.royalEmerald.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Jurisdiction Header Banner — tap toggles open/close
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF003828), AppTheme.royalEmerald],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.imperialGold.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.imperialGold),
                    ),
                    child: Icon(getJurisdictionIcon(), color: AppTheme.imperialGold, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.jurisdictionName,
                          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${widget.scopeLabel} • ETB ${_fmt(totalRaisedInEntity)} Total',
                          style: const TextStyle(color: Colors.white70, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.imperialGold,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${widget.funds.length} ${widget.funds.length == 1 ? 'Fund' : 'Funds'}',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.royalEmerald),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    _isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ],
              ),
            ),
          ),

          // 4-in-a-row mini fund cards grid
          if (_isExpanded)
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 2, bottom: 10),
                    child: Row(
                      children: [
                        Text(
                          'CAUSES',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade500,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: AppTheme.royalEmerald.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'TAP → PAY  •  HOLD → DETAILS',
                            style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.bold, color: Colors.grey.shade600),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 4-column grid
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 0.68,
                    ),
                    itemCount: widget.funds.length,
                    itemBuilder: (ctx, i) {
                      final fund = widget.funds[i];
                      final double progress = fund.hasGoal && fund.targetAmount > 0
                          ? (fund.raisedAmount / fund.targetAmount).clamp(0.0, 1.0)
                          : 1.0;
                      final int pct = (progress * 100).toInt();

                      return GestureDetector(
                        onTap: () => widget.onQuickPay(fund),
                        onLongPress: () => widget.onFundTap(fund),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppTheme.royalEmerald.withValues(alpha: 0.2),
                              width: 1.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.royalEmerald.withValues(alpha: 0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Icon bubble
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: AppTheme.royalEmerald.withValues(alpha: 0.08),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppTheme.imperialGold.withValues(alpha: 0.5),
                                    width: 1.2,
                                  ),
                                ),
                                child: Center(
                                  child: Text(fund.icon, style: const TextStyle(fontSize: 16)),
                                ),
                              ),
                              const SizedBox(height: 6),

                              // Title
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                child: Text(
                                  fund.title,
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1E2923),
                                    height: 1.2,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),

                              // Progress or ongoing badge
                              if (fund.hasGoal) ...[
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 6),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: progress,
                                      minHeight: 3.5,
                                      backgroundColor: AppTheme.royalEmerald.withValues(alpha: 0.1),
                                      valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.royalEmerald),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  '$pct%',
                                  style: const TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.royalEmerald,
                                  ),
                                ),
                              ] else ...[
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppTheme.imperialGold.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text(
                                    'ቀጣይ',
                                    style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.bold, color: AppTheme.royalEmerald),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  static String _fmt(double amount) {
    if (amount >= 1000000) return '${(amount / 1000000).toStringAsFixed(1)}M';
    if (amount >= 1000) return '${(amount / 1000).toStringAsFixed(0)}k';
    return amount.toStringAsFixed(0);
  }
}
