import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:church/app/theme.dart';
import 'package:church/core/widgets/primary_button.dart';
import 'package:church/core/animations/shimmer_overlay.dart';
import 'package:church/features/auth/presentation/providers/auth_provider.dart';
import 'package:church/l10n/app_localizations.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entrance;
  late final Animation<double> _cardFade;
  late final Animation<Offset> _cardSlide;
  late final Animation<double> _listFade;

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
      ..forward();

    _cardFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _entrance, curve: const Interval(0.0, 0.5, curve: Curves.easeOut)),
    );
    _cardSlide = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _entrance, curve: const Interval(0.0, 0.55, curve: Curves.easeOutCubic)),
    );
    _listFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _entrance, curve: const Interval(0.35, 0.75, curve: Curves.easeOut)),
    );
  }

  @override
  void dispose() {
    _entrance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final user = ref.watch(authStateProvider).user;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.myProfile), elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: AnimatedBuilder(
          animation: _entrance,
          builder: (context, _) => Column(
            children: [
              // Membership card with holographic shimmer + spinning ring
              FadeTransition(
                opacity: _cardFade,
                child: SlideTransition(
                  position: _cardSlide,
                  child: HolographicShimmer(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppTheme.royalEmerald,
                        borderRadius: BorderRadius.circular(22),
                        border: const Border.fromBorderSide(
                          BorderSide(color: AppTheme.imperialGold, width: 2),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.royalEmerald.withValues(alpha: 0.4),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'EOTC MEMBER CARD',
                                style: TextStyle(
                                  color: AppTheme.imperialGold,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              SpinningRing(
                                size: 44,
                                color: AppTheme.imperialGold,
                                period: const Duration(seconds: 6),
                                child: const Icon(Icons.church_rounded, color: AppTheme.imperialGold, size: 22),
                              ),
                            ],
                          ),
                          const SizedBox(height: 28),
                          Text(
                            user?.displayName ?? 'እንግዳ አባል',
                            style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          Text(user?.phone ?? '', style: const TextStyle(color: Colors.white70, fontSize: 14)),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('የአባልነት መታወቂያ', style: TextStyle(color: Colors.white38, fontSize: 10)),
                                  const SizedBox(height: 4),
                                  Text(
                                    user != null ? 'EOTC-${user.uid.substring(0, 8).toUpperCase()}' : 'N/A',
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Text('ሚና', style: TextStyle(color: Colors.white38, fontSize: 10)),
                                  const SizedBox(height: 4),
                                  Text(
                                    (user?.role ?? 'member').toUpperCase(),
                                    style: const TextStyle(color: AppTheme.imperialGold, fontWeight: FontWeight.bold, fontSize: 13),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Details list
              FadeTransition(
                opacity: _listFade,
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    children: [
                      // Transaction History Navigation Tile
                      ListTile(
                        onTap: () => context.push('/history'),
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.royalEmerald.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.receipt_long_rounded, color: AppTheme.royalEmerald, size: 22),
                        ),
                        title: Text(
                          l10n.transactionHistory,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        subtitle: const Text('ደረሰኞችንና ያለፉ መዋጮዎችን ይመልከቱ'),
                        trailing: const Icon(Icons.chevron_right_rounded, color: AppTheme.royalEmerald),
                      ),
                      const Divider(height: 1, indent: 56),
                      ListTile(
                        leading: const Icon(Icons.email, color: AppTheme.royalEmerald),
                        title: Text(l10n.email),
                        subtitle: Text(user?.email ?? 'አልገባም'),
                      ),
                      const Divider(height: 1, indent: 56),
                      ListTile(
                        leading: const Icon(Icons.church_rounded, color: AppTheme.royalEmerald),
                        title: Text(l10n.myChurch),
                        subtitle: Text(
                          user?.churchId != null
                              ? 'ID: ${user!.churchId!.substring(0, 8).toUpperCase()}...'
                              : 'ምንም ቤተ ክርስቲያን አልተመረጠም',
                        ),
                        trailing: TextButton.icon(
                          onPressed: () => context.push('/church-select'),
                          icon: const Icon(Icons.swap_horiz, size: 18),
                          label: Text(l10n.changeChurch),
                        ),
                      ),
                      const Divider(height: 1, indent: 56),
                      ListTile(
                        leading: const Icon(Icons.language, color: AppTheme.royalEmerald),
                        title: Text(l10n.language),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextButton(onPressed: () {}, child: const Text('አማርኛ')),
                            const Text('|'),
                            TextButton(onPressed: () {}, child: const Text('English')),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 40),

              FadeTransition(
                opacity: _listFade,
                child: PrimaryButton(
                  text: l10n.signOut,
                  isOutlined: true,
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Text(l10n.signOut),
                        content: Text(l10n.signOutConfirm),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.cancel)),
                          TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l10n.confirm)),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      await ref.read(authStateProvider.notifier).signOut();
                      if (context.mounted) context.go('/auth');
                    }
                  },
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
