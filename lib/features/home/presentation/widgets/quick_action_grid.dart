import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:church/app/theme.dart';
import 'package:church/l10n/app_localizations.dart';

class QuickActionGrid extends StatelessWidget {
  const QuickActionGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final actions = [
      _ActionItem(
        title: l10n.asrat,
        icon: Icons.percent,
        color: AppTheme.primaryGold,
        type: 'asrat',
      ),
      _ActionItem(
        title: l10n.bekuart,
        icon: Icons.card_giftcard,
        color: AppTheme.primaryBlue,
        type: 'bekuart',
      ),
      _ActionItem(
        title: l10n.monthly,
        icon: Icons.calendar_month,
        color: Colors.teal,
        type: 'monthly',
      ),
      _ActionItem(
        title: l10n.monastery,
        icon: Icons.castle,
        color: Colors.orange,
        type: 'monastery',
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.4,
      ),
      itemCount: actions.length,
      itemBuilder: (context, index) {
        final action = actions[index];
        return InkWell(
          onTap: () {
            context.push('/contribute/amount', extra: action.type);
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
                      color: action.color.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(action.icon, color: action.color, size: 24),
                  ),
                  Text(
                    action.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ActionItem {
  final String title;
  final IconData icon;
  final Color color;
  final String type;

  _ActionItem({
    required this.title,
    required this.icon,
    required this.color,
    required this.type,
  });
}
