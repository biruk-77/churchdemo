import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:church/app/theme.dart';
import 'package:church/l10n/app_localizations.dart';

class ContributeScreen extends ConsumerWidget {
  const ContributeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    final contributionItems = [
      _ContributeOption(type: 'asrat', label: l10n.asrat, icon: Icons.percent, color: AppTheme.primaryGold),
      _ContributeOption(type: 'bekuart', label: l10n.bekuart, icon: Icons.card_giftcard, color: AppTheme.primaryBlue),
      _ContributeOption(type: 'monthly', label: l10n.monthly, icon: Icons.calendar_month, color: Colors.teal),
      _ContributeOption(type: 'buildingFund', label: l10n.buildingFund, icon: Icons.build_circle, color: Colors.indigo),
      _ContributeOption(type: 'charity', label: l10n.charity, icon: Icons.favorite, color: Colors.red),
      _ContributeOption(type: 'festival', label: l10n.festival, icon: Icons.celebration, color: Colors.orange),
      _ContributeOption(type: 'candle', label: l10n.candle, icon: Icons.light, color: Colors.amber),
      _ContributeOption(type: 'memorial', label: l10n.memorial, icon: Icons.history, color: Colors.grey),
      _ContributeOption(type: 'monastery', label: l10n.monastery, icon: Icons.castle, color: Colors.orangeAccent),
      _ContributeOption(type: 'priest', label: l10n.priest, icon: Icons.person_pin, color: Colors.brown),
      _ContributeOption(type: 'sundaySchool', label: l10n.sundaySchool, icon: Icons.school, color: Colors.green),
      _ContributeOption(type: 'youth', label: l10n.youth, icon: Icons.groups, color: Colors.blue),
      _ContributeOption(type: 'women', label: l10n.women, icon: Icons.woman, color: Colors.pink),
      _ContributeOption(type: 'development', label: l10n.development, icon: Icons.developer_mode, color: Colors.cyan),
      _ContributeOption(type: 'emergency', label: l10n.emergency, icon: Icons.warning_amber, color: Colors.redAccent),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.selectContributionType),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Text(
              l10n.selectContributionType,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryBlue,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.25,
                ),
                itemCount: contributionItems.length,
                itemBuilder: (context, index) {
                  final item = contributionItems[index];
                  return InkWell(
                    onTap: () {
                      context.push('/contribute/amount', extra: item.type);
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Card(
                      margin: EdgeInsets.zero,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: item.color.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(item.icon, color: item.color, size: 24),
                            ),
                            Text(
                              item.label,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
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
}

class _ContributeOption {
  final String type;
  final String label;
  final IconData icon;
  final Color color;

  _ContributeOption({
    required this.type,
    required this.label,
    required this.icon,
    required this.color,
  });
}
