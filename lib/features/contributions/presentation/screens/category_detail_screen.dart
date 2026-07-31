import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:church/app/theme.dart';
import 'package:church/features/contributions/presentation/screens/funds_screen.dart';

class CategoryDetailScreen extends StatefulWidget {
  final String categoryTitle;
  final String categoryIcon;
  final List<FundItem> categoryFunds;

  const CategoryDetailScreen({
    super.key,
    required this.categoryTitle,
    required this.categoryIcon,
    required this.categoryFunds,
  });

  @override
  State<CategoryDetailScreen> createState() => _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends State<CategoryDetailScreen> {
  String _selectedScope = 'all';
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    // Filter category funds by search & scope
    final filtered = widget.categoryFunds.where((fund) {
      final matchesSearch = _searchQuery.isEmpty ||
          fund.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          fund.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          fund.jurisdictionName.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesScope = _selectedScope == 'all' || fund.scopeLevel == _selectedScope;

      return matchesSearch && matchesScope;
    }).toList();

    final double totalRaised = widget.categoryFunds.fold(0.0, (sum, item) => sum + item.raisedAmount);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F7),
      appBar: AppBar(
        backgroundColor: AppTheme.royalEmerald,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Text(widget.categoryIcon, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Text(
              widget.categoryTitle,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Top Hero Header
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.all(22),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF004D38), AppTheme.royalEmerald],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                          child: Text(
                            '${widget.categoryFunds.length} ACTIVE CAUSES',
                            style: const TextStyle(
                              color: AppTheme.imperialGold,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ),
                        Text(
                          'ETB ${_formatAmount(totalRaised)} Raised',
                          style: const TextStyle(
                            color: AppTheme.imperialGold,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      '${widget.categoryTitle} Directory',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Browse all verified diocese and woreda funds dedicated to ${widget.categoryTitle}.',
                      style: const TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    const SizedBox(height: 18),

                    // Search input within category
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: TextField(
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        onChanged: (val) => setState(() => _searchQuery = val),
                        decoration: const InputDecoration(
                          hintText: 'በዚህ ምድብ ውስጥ ፈንዶችን ይፈልጉ…',
                          hintStyle: TextStyle(color: Colors.white60, fontSize: 13),
                          prefixIcon: Icon(Icons.search_rounded, color: AppTheme.imperialGold),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Jurisdiction Scope Filter Tabs
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14.0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      {'id': 'all', 'label': 'ሁሉም ስልጣን ክልሎች', 'icon': '🌟'},
                      {'id': 'diocese', 'label': 'ሀገረ ስብከት', 'icon': '🏛️'},
                      {'id': 'woreda', 'label': 'ወረዳ ቤተ ክህነት', 'icon': '🗺️'},
                      {'id': 'church', 'label': 'ደብሮች', 'icon': '⛪'},
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
                          onSelected: (_) => setState(() => _selectedScope = tab['id']!),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),

            // Section Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4.0),
                child: Text(
                  'Matching ${widget.categoryTitle} Funds (${filtered.length})',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.royalEmerald,
                  ),
                ),
              ),
            ),

            // List of Fund Cards
            if (filtered.isEmpty)
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
                        'በዚህ ምድብ ውስጥ ምንም ፈንድ አልተገኘም',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Try switching jurisdiction filter or clearing search.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final fund = filtered[index];
                      return _CategoryFundCard(fund: fund);
                    },
                    childCount: filtered.length,
                  ),
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }

  static String _formatAmount(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}k';
    }
    return amount.toStringAsFixed(0);
  }
}

class _CategoryFundCard extends StatelessWidget {
  final FundItem fund;

  const _CategoryFundCard({required this.fund});

  @override
  Widget build(BuildContext context) {
    final double progress = fund.hasGoal && fund.targetAmount > 0
        ? (fund.raisedAmount / fund.targetAmount).clamp(0.0, 1.0)
        : 1.0;
    final int percentage = (progress * 100).toInt();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.royalEmerald.withValues(alpha: 0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            decoration: BoxDecoration(
              color: AppTheme.royalEmerald.withValues(alpha: 0.06),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              border: Border(bottom: BorderSide(color: AppTheme.royalEmerald.withValues(alpha: 0.08))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(fund.icon, style: const TextStyle(fontSize: 18)),
                    const SizedBox(width: 8),
                    Text(
                      fund.jurisdictionName.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.royalEmerald,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.imperialGold.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.imperialGold.withValues(alpha: 0.5)),
                  ),
                  child: Text(
                    fund.scopeLabel,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.royalEmerald,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Body Content
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fund.title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E2923),
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  fund.description,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 16),

                // Metrics
                if (fund.hasGoal) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Raised: ETB ${_formatAmount(fund.raisedAmount)}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.royalEmerald,
                        ),
                      ),
                      Text(
                        'Goal: ETB ${_formatAmount(fund.targetAmount)} ($percentage%)',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      backgroundColor: AppTheme.royalEmerald.withValues(alpha: 0.1),
                      valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.royalEmerald),
                    ),
                  ),
                ] else ...[
                  Text(
                    'Total Raised: ETB ${_formatAmount(fund.raisedAmount)} • Ongoing Fund',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.royalEmerald),
                  ),
                ],

                const SizedBox(height: 18),

                // Contribute Action Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      context.push('/payment/method', extra: {
                        'amount': 500.0,
                        'type': fund.category,
                        'note': 'Contribution to ${fund.title}',
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.royalEmerald,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 2,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.volunteer_activism_rounded, size: 18, color: AppTheme.imperialGold),
                        SizedBox(width: 8),
                        Text(
                          'ለፈንዱ አስተዋፅዖ ያድርጉ',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.arrow_forward_rounded, size: 16),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _formatAmount(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}k';
    }
    return amount.toStringAsFixed(0);
  }
}
