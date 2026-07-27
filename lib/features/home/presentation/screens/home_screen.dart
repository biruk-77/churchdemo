import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:church/app/theme.dart';
import 'package:church/features/auth/presentation/providers/auth_provider.dart';
import 'package:church/features/church/presentation/screens/church_selection_screen.dart';
import 'package:church/features/home/presentation/widgets/quick_action_grid.dart';
import 'package:church/features/home/presentation/widgets/recent_transactions_list.dart';
import 'package:church/features/history/presentation/screens/history_screen.dart';
import 'package:church/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:church/features/profile/presentation/screens/profile_screen.dart';
import 'package:church/core/widgets/ethiopian_cross_divider.dart';
import 'package:church/core/animations/shimmer_overlay.dart';
import 'package:church/core/widgets/animated_count_text.dart';
import 'package:church/core/widgets/contribution_progress_ring.dart';
import 'package:church/l10n/app_localizations.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  String _churchName = '';

  late final AnimationController _headerEntrance;
  late final Animation<double> _headerFade;
  late final Animation<Offset> _headerSlide;
  late final Animation<double> _cardFade;
  late final Animation<Offset> _cardSlide;

  @override
  void initState() {
    super.initState();
    _loadChurchName();

    _headerEntrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();

    _headerFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _headerEntrance, curve: const Interval(0.0, 0.5, curve: Curves.easeOut)),
    );
    _headerSlide = Tween<Offset>(begin: const Offset(0, -0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _headerEntrance, curve: const Interval(0.0, 0.55, curve: Curves.easeOutCubic)),
    );
    _cardFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _headerEntrance, curve: const Interval(0.2, 0.65, curve: Curves.easeOut)),
    );
    _cardSlide = Tween<Offset>(begin: const Offset(0, 0.25), end: Offset.zero).animate(
      CurvedAnimation(parent: _headerEntrance, curve: const Interval(0.2, 0.7, curve: Curves.easeOutCubic)),
    );
  }

  Future<void> _loadChurchName() async {
    final user = ref.read(authStateProvider).user;
    if (user?.churchId != null) {
      final repo = ref.read(churchRepositoryProvider);
      final church = await repo.getChurchById(user!.churchId!);
      if (church != null && mounted) {
        setState(() => _churchName = church.name);
      }
    }
  }

  @override
  void dispose() {
    _headerEntrance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final user = ref.watch(authStateProvider).user;

    final List<Widget> screens = [
      _buildDashboard(user, l10n),
      const HistoryScreen(),
      const NotificationsScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: KeyedSubtree(key: ValueKey(_currentIndex), child: screens[_currentIndex]),
      ),
      bottomNavigationBar: _AnimatedBottomNav(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        labels: [l10n.home, l10n.history, l10n.notifications, l10n.profile],
        icons: const [
          Icons.dashboard_rounded,
          Icons.receipt_long_rounded,
          Icons.notifications_rounded,
          Icons.person_rounded,
        ],
      ),
    );
  }

  Widget _buildDashboard(dynamic user, AppLocalizations l10n) {
    final hour = DateTime.now().hour;
    String greeting = l10n.goodMorning;
    if (hour >= 12 && hour < 17) {
      greeting = l10n.goodAfternoon;
    } else if (hour >= 17) {
      greeting = l10n.goodEvening;
    }

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async => _loadChurchName(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),

              // Header — slides down
              FadeTransition(
                opacity: _headerFade,
                child: SlideTransition(
                  position: _headerSlide,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$greeting,',
                            style: const TextStyle(fontSize: 14, color: Colors.black54),
                          ),
                          Text(
                            user?.displayName ?? 'Blessed Member',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryBlue,
                            ),
                          ),
                        ],
                      ),
                      SpinningRing(
                        size: 46,
                        color: AppTheme.primaryGold,
                        period: const Duration(seconds: 8),
                        child: const Icon(Icons.church_rounded, color: AppTheme.primaryGold, size: 22),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 6),

              FadeTransition(
                opacity: _headerFade,
                child: GestureDetector(
                  onTap: () async {
                    await context.push('/church-select');
                    _loadChurchName();
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _churchName.isNotEmpty ? _churchName : l10n.appName,
                        style: const TextStyle(fontSize: 13, color: AppTheme.primaryGold, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryGold.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppTheme.primaryGold.withValues(alpha: 0.4), width: 0.8),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.swap_horiz_rounded, size: 12, color: AppTheme.primaryGold),
                            SizedBox(width: 2),
                            Text('Change', style: TextStyle(fontSize: 10, color: AppTheme.primaryGold, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 22),

              // Stats card with holographic shimmer + animated counter
              FadeTransition(
                opacity: _cardFade,
                child: SlideTransition(
                  position: _cardSlide,
                  child: HolographicShimmer(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBlue,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: AppTheme.primaryGold, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryBlue.withValues(alpha: 0.35),
                            blurRadius: 22,
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
                              Text(
                                l10n.totalContributions,
                                style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
                              ),
                              const Icon(Icons.favorite_rounded, color: AppTheme.primaryGold, size: 20),
                            ],
                          ),
                          const SizedBox(height: 12),
                          AnimatedCountText(
                            end: 4200.0,
                            prefix: 'ETB ',
                            currency: true,
                            duration: const Duration(milliseconds: 1800),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              const Icon(Icons.verified_user_rounded, color: Colors.greenAccent, size: 14),
                              const SizedBox(width: 6),
                              Text(
                                l10n.memberSince(DateTime.now().year.toString()),
                                style: const TextStyle(color: Colors.white60, fontSize: 11),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Annual contribution progress ring
              FadeTransition(
                opacity: _cardFade,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.primaryGold.withValues(alpha: 0.18)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const ContributionProgressRing(
                        current: 4200,
                        goal: 12000,
                        label: 'Annual Goal',
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Annual Progress',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: AppTheme.primaryBlue,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'ETB 4,200 of 12,000',
                              style: TextStyle(fontSize: 13, color: Colors.black.withValues(alpha: 0.5)),
                            ),
                            const SizedBox(height: 14),
                            _MilestoneChip(label: '25%', achieved: true),
                            const SizedBox(height: 6),
                            _MilestoneChip(label: '50%', achieved: false),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              Text(
                l10n.contribute,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
              ),
              const SizedBox(height: 14),
              const QuickActionGrid(),
              const EthiopianCrossDivider(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.recentActivity,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
                  ),
                  TextButton(
                    onPressed: () => setState(() => _currentIndex = 1),
                    child: Text(l10n.viewAll, style: const TextStyle(color: AppTheme.primaryGold)),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const RecentTransactionsList(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _MilestoneChip extends StatelessWidget {
  final String label;
  final bool achieved;

  const _MilestoneChip({required this.label, required this.achieved});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: achieved ? AppTheme.primaryGold : Colors.grey.withValues(alpha: 0.2),
            border: Border.all(
              color: achieved ? AppTheme.primaryGold : Colors.grey.withValues(alpha: 0.3),
            ),
          ),
          child: achieved
              ? const Icon(Icons.check, size: 9, color: Colors.white)
              : null,
        ),
        const SizedBox(width: 8),
        Text(
          '$label milestone',
          style: TextStyle(
            fontSize: 12,
            color: achieved ? AppTheme.primaryBlue : Colors.black38,
            fontWeight: achieved ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}

/// Custom bottom nav with a sliding gold indicator pill.
class _AnimatedBottomNav extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<String> labels;
  final List<IconData> icons;

  const _AnimatedBottomNav({
    required this.currentIndex,
    required this.onTap,
    required this.labels,
    required this.icons,
  });

  @override
  State<_AnimatedBottomNav> createState() => _AnimatedBottomNavState();
}

class _AnimatedBottomNavState extends State<_AnimatedBottomNav> {
  @override
  Widget build(BuildContext context) {
    final count = widget.icons.length;

    return Container(
      height: 66,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 16, offset: const Offset(0, -2)),
        ],
      ),
      child: Stack(
        children: [
          // Sliding indicator
          AnimatedAlign(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            alignment: Alignment(
              -1.0 + (widget.currentIndex / (count - 1)) * 2.0,
              0,
            ),
            child: FractionallySizedBox(
              widthFactor: 1 / count,
              child: Container(
                height: 3,
                decoration: BoxDecoration(
                  color: AppTheme.primaryGold,
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(2)),
                ),
              ),
            ),
          ),

          // Nav items
          Row(
            children: List.generate(count, (i) {
              final selected = widget.currentIndex == i;
              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => widget.onTap(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    padding: const EdgeInsets.only(top: 8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedScale(
                          scale: selected ? 1.22 : 1.0,
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeOutBack,
                          child: Icon(
                            widget.icons[i],
                            color: selected ? AppTheme.primaryGold : Colors.grey,
                            size: 24,
                          ),
                        ),
                        const SizedBox(height: 4),
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 200),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                            color: selected ? AppTheme.primaryGold : Colors.grey,
                          ),
                          child: Text(widget.labels[i]),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
