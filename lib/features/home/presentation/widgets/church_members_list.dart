import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:church/app/theme.dart';
import 'package:church/features/auth/presentation/providers/auth_provider.dart';

class ChurchMembersList extends ConsumerWidget {
  const ChurchMembersList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).user;

    if (user?.churchId == null) {
      return const SizedBox.shrink();
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('churchId', isEqualTo: user!.churchId)
          .where('role', isEqualTo: 'member')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _MembersListSkeleton();
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const SizedBox.shrink();
        }

        final members = snapshot.data!.docs;
        final displayMembers = members.take(6).toList();
        final showMore = members.length > 6;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Church Members',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.royalEmerald,
                    ),
                  ),
                  Text(
                    '${members.length} members',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 90,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: displayMembers.length + (showMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (showMore && index == displayMembers.length) {
                    return _buildMoreCard(members.length - 6);
                  }
                  return _buildMemberCard(displayMembers[index]);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMemberCard(DocumentSnapshot member) {
    final data = member.data() as Map<String, dynamic>;
    final displayName = data['displayName'] ?? 'Unknown';
    final initials = displayName
        .split(' ')
        .map((s) => s[0])
        .join()
        .toUpperCase()
        .substring(0, 2.clamp(0, displayName.length));

    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Container(
        width: 75,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.royalEmerald.withValues(alpha: 0.8),
              AppTheme.imperialGold.withValues(alpha: 0.2),
            ],
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.imperialGold.withValues(alpha: 0.2), width: 0.8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppTheme.imperialGold,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Flexible(
              child: Text(
                displayName.split(' ').first,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoreCard(int count) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Container(
        width: 75,
        decoration: BoxDecoration(
          color: AppTheme.royalEmerald.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.royalEmerald.withValues(alpha: 0.3), width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '+$count',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.royalEmerald,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'More',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppTheme.royalEmerald,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MembersListSkeleton extends StatelessWidget {
  const _MembersListSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        height: 90,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: 4,
          itemBuilder: (_, __) => Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Container(
              width: 75,
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
