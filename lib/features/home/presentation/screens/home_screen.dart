import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:church/app/theme.dart';
import 'package:church/features/auth/presentation/providers/auth_provider.dart';
import 'package:church/features/church/presentation/screens/church_selection_screen.dart';
import 'package:church/features/home/presentation/widgets/quick_action_grid.dart';
import 'package:church/features/home/presentation/widgets/recent_transactions_list.dart';
import 'package:church/features/history/presentation/screens/history_screen.dart';
import 'package:church/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:church/features/profile/presentation/screens/profile_screen.dart';
import 'package:church/core/widgets/ethiopian_cross_divider.dart';
import 'package:church/l10n/app_localizations.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;
  String _churchName = '';

  @override
  void initState() {
    super.initState();
    _loadChurchName();
  }

  Future<void> _loadChurchName() async {
    final user = ref.read(authStateProvider).user;
    if (user?.churchId != null) {
      final repo = ref.read(churchRepositoryProvider);
      final church = await repo.getChurchById(user!.churchId!);
      if (church != null && mounted) {
        setState(() {
          _churchName = church.name;
        });
      }
    }
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
      body: screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.primaryGold,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.dashboard),
            label: l10n.home,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.receipt_long),
            label: l10n.history,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.notifications),
            label: l10n.notifications,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person),
            label: l10n.profile,
          ),
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
        onRefresh: () async {
          await _loadChurchName();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$greeting,',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
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
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryGold.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.church_rounded,
                        color: AppTheme.primaryGold,
                        size: 28,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _churchName.isNotEmpty ? _churchName : l10n.appName,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.primaryGold,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                // Premium Card for Total Contributions
                Card(
                  color: AppTheme.primaryBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: const BorderSide(color: AppTheme.primaryGold, width: 1.5),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              l10n.totalContributions,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Icon(
                              Icons.favorite,
                              color: AppTheme.primaryGold,
                              size: 20,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'ETB 4,200.00',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            const Icon(
                              Icons.verified_user,
                              color: Colors.greenAccent,
                              size: 14,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              l10n.memberSince(DateTime.now().year.toString()),
                              style: const TextStyle(
                                color: Colors.white60,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Text(
                  l10n.contribute,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryBlue,
                  ),
                ),
                const SizedBox(height: 16),
                const QuickActionGrid(),
                const EthiopianCrossDivider(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.recentActivity,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _currentIndex = 1; // Switch to History tab
                        });
                      },
                      child: Text(
                        l10n.viewAll,
                        style: const TextStyle(color: AppTheme.primaryGold),
                      ),
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
      ),
    );
  }
}
