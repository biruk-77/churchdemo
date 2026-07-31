import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:church/app/theme.dart';
import 'package:church/features/church/data/church_model.dart';
import 'package:church/features/auth/presentation/providers/auth_provider.dart';
import 'package:church/features/church/data/church_repository.dart';

class ChurchInfoCard extends ConsumerWidget {
  const ChurchInfoCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).user;

    if (user?.churchId == null) {
      return const SizedBox.shrink();
    }

    final churchFuture = ref.watch(
      churchByIdProvider(user!.churchId!),
    );

    return churchFuture.when(
      data: (church) => _buildCard(church),
      loading: () => const _ChurchCardSkeleton(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildCard(ChurchModel? church) {
    if (church == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.royalEmerald,
            AppTheme.royalEmerald.withValues(alpha: 0.85),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.imperialGold.withValues(alpha: 0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: AppTheme.royalEmerald.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          // Church icon
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.church_rounded,
              color: AppTheme.imperialGold,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          // Church info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Church',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  church.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.person_rounded,
                      size: 12,
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Clergy: ${church.clergy ?? "N/A"}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Status indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.greenAccent.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.4), width: 0.8),
            ),
            child: const Text(
              'Active',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Colors.greenAccent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChurchCardSkeleton extends StatelessWidget {
  const _ChurchCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.all(18),
      height: 86,
    );
  }
}

final churchByIdProvider = FutureProvider.family<ChurchModel?, String>((ref, churchId) async {
  final repo = ref.watch(churchRepositoryProvider);
  return repo.getChurchById(churchId);
});
