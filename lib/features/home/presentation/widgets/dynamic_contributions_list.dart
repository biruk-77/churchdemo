import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:church/app/theme.dart';
import 'package:church/features/auth/presentation/providers/auth_provider.dart';

class DynamicContributionsList extends ConsumerWidget {
  const DynamicContributionsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).user;

    if (user?.churchId == null) {
      return const SizedBox.shrink();
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('contributions')
          .where('churchId', isEqualTo: user!.churchId)
          .orderBy('createdAt', descending: true)
          .limit(8)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _ContributionsSkeletons();
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const SizedBox.shrink();
        }

        final contributions = snapshot.data!.docs;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Recent Contributions',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.royalEmerald,
                ),
              ),
            ),
            const SizedBox(height: 12),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: contributions.length,
              itemBuilder: (context, index) {
                return _ContributionCard(
                  data: contributions[index].data() as Map<String, dynamic>,
                  index: index,
                );
              },
            ),
          ],
        );
      },
    );
  }
}

class _ContributionCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final int index;

  const _ContributionCard({
    required this.data,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final type = data['type'] ?? 'donation';
    final amount = data['amount'] ?? 0;
    final paymentMethod = data['paymentMethod'] ?? 'Cash';
    final createdAt = data['createdAt'] as Timestamp?;
    final status = data['status'] ?? 'pending';

    final style = _getContributionStyle(type);
    final formattedDate = createdAt != null
        ? _formatDate(createdAt.toDate())
        : 'Unknown';

    return Padding(
      padding: EdgeInsets.only(bottom: index < 7 ? 12 : 0),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              style['bgColor'] as Color,
              (style['bgColor'] as Color).withValues(alpha: 0.6),
            ],
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: (style['accentColor'] as Color).withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            // Icon
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: (style['accentColor'] as Color).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                style['icon'] as IconData,
                color: style['accentColor'] as Color,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    style['label'] as String,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: style['textColor'] as Color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        paymentMethod,
                        style: TextStyle(
                          fontSize: 11,
                          color: (style['textColor'] as Color).withValues(alpha: 0.7),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: (style['accentColor'] as Color).withValues(alpha: 0.5),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        formattedDate,
                        style: TextStyle(
                          fontSize: 11,
                          color: (style['textColor'] as Color).withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Amount
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'ETB $amount',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: style['accentColor'] as Color,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: _getStatusColor(status),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> _getContributionStyle(String type) {
    switch (type.toLowerCase()) {
      case 'tithe':
        return {
          'label': 'Tithe',
          'icon': Icons.favorite_rounded,
          'bgColor': const Color(0xFFF0E6D2),
          'accentColor': AppTheme.imperialGold,
          'textColor': AppTheme.royalEmerald,
        };
      case 'donation':
        return {
          'label': 'Donation',
          'icon': Icons.volunteer_activism_rounded,
          'bgColor': const Color(0xFFE8F5E9),
          'accentColor': Colors.green,
          'textColor': const Color(0xFF2E7D32),
        };
      case 'offering':
        return {
          'label': 'Offering',
          'icon': Icons.card_giftcard_rounded,
          'bgColor': const Color(0xFFFFE0B2),
          'accentColor': Colors.orange,
          'textColor': const Color(0xFFE65100),
        };
      case 'special':
        return {
          'label': 'Special Fund',
          'icon': Icons.campaign_rounded,
          'bgColor': const Color(0xFFE1F5FE),
          'accentColor': Colors.blue,
          'textColor': const Color(0xFF01579B),
        };
      case 'emergency':
        return {
          'label': 'Emergency Fund',
          'icon': Icons.warning_rounded,
          'bgColor': const Color(0xFFFFEBEE),
          'accentColor': Colors.red,
          'textColor': const Color(0xFFB71C1C),
        };
      case 'building':
        return {
          'label': 'Building Fund',
          'icon': Icons.construction_rounded,
          'bgColor': const Color(0xFFF3E5F5),
          'accentColor': Colors.purple,
          'textColor': const Color(0xFF4A148C),
        };
      default:
        return {
          'label': 'Contribution',
          'icon': Icons.attach_money_rounded,
          'bgColor': const Color(0xFFF5F5F5),
          'accentColor': AppTheme.royalEmerald,
          'textColor': Colors.black87,
        };
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'success':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'failed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return 'Today';
    } else if (dateOnly == yesterday) {
      return 'Yesterday';
    } else {
      return '${date.month}/${date.day}/${date.year}';
    }
  }
}

class _ContributionsSkeletons extends StatelessWidget {
  const _ContributionsSkeletons();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: List.generate(
          4,
          (_) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              height: 70,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
