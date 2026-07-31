import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:church/app/theme.dart';
import 'package:church/features/auth/presentation/providers/auth_provider.dart';
import 'package:church/features/church/presentation/screens/church_selection_screen.dart';
import 'package:church/features/contributions/presentation/screens/funds_screen.dart';
import 'package:church/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:church/features/profile/presentation/screens/profile_screen.dart';
import 'package:church/core/animations/shimmer_overlay.dart';
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

  // Hierarchy state
  String? _selectedJurisdiction;
  String? _selectedDioceseId;
  String? _selectedDioceseName;
  String? _selectedWoredaId;

  // Search
  String _searchQuery = '';

  late final AnimationController _headerEntrance;
  late final Animation<double> _headerFade;
  late final Animation<Offset> _headerSlide;

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
  }

  Future<void> _loadChurchName() async {
    final user = ref.read(authStateProvider).user;
    if (user?.churchId != null) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('churches')
            .doc(user!.churchId)
            .get();
        if (doc.exists && mounted) {
          setState(() => _churchName = ((doc.data() as Map<String, dynamic>?)?['name'] ?? 'Church') as String);
        }
      } catch (e) {
        // ignore
      }
    }
  }

  Future<void> _switchChurch(String churchId) async {
    try {
      await ref.read(authStateProvider.notifier).selectChurch(churchId);
      if (mounted) {
        await _loadChurchName();
        setState(() {
          _selectedJurisdiction = null;
          _selectedDioceseId = null;
          _selectedDioceseName = null;
          _selectedWoredaId = null;
          _searchQuery = '';
        });
        // Route to contribution types after switching church
        await context.push('/contribute-types');
      }
    } catch (e) {
      // error handling
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
      const FundsScreen(),
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
        labels: [l10n.home, 'Funds', l10n.notifications, l10n.profile],
        icons: const [
          Icons.dashboard_rounded,
          Icons.volunteer_activism_rounded,
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

              // Header
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
                            user?.displayName ?? 'የተባረከ አባል',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.royalEmerald,
                            ),
                          ),
                        ],
                      ),
                      SpinningRing(
                        size: 46,
                        color: AppTheme.imperialGold,
                        period: const Duration(seconds: 8),
                        child: const Icon(Icons.church_rounded, color: AppTheme.imperialGold, size: 22),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // My Church Card — Tappable to Contribute
              FadeTransition(
                opacity: _headerFade,
                child: GestureDetector(
                  onTap: () => context.push('/contribute-types'),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppTheme.royalEmerald, AppTheme.royalEmerald.withValues(alpha: 0.8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.royalEmerald.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.church_rounded, color: Colors.white, size: 26),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'የእኔ ቤተ ክርስቲያን',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.white60,
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    _churchName.isNotEmpty ? _churchName : l10n.appName,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 24),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                          decoration: BoxDecoration(
                            color: AppTheme.imperialGold,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.volunteer_activism_rounded, color: Colors.white, size: 14),
                              SizedBox(width: 6),
                              Text(
                                'ለመዋጮ ይንኩ',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Search
              TextField(
                style: const TextStyle(color: Colors.black87, fontSize: 14),
                onChanged: (value) => setState(() => _searchQuery = value),
                decoration: InputDecoration(
                  hintText: 'ቤተ ክርስቲያናት፣ ወረዳዎች፣ ሀገረ ስብከቶች ይፈልጉ...',
                  hintStyle: TextStyle(color: Colors.black38, fontSize: 14),
                  prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.royalEmerald),
                  filled: true,
                  fillColor: const Color(0xFFF0F7F4),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppTheme.royalEmerald.withValues(alpha: 0.25)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppTheme.royalEmerald.withValues(alpha: 0.25)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.royalEmerald, width: 1.5),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),

              const SizedBox(height: 24),

              // Jurisdiction Selection
              if (_selectedJurisdiction == null) _buildJurisdictionGrid(),

              // Diocese Selection
              if (_selectedJurisdiction != null && _selectedDioceseId == null)
                _buildDioceseGrid(),

              // Woreda Selection
              if (_selectedDioceseId != null && _selectedWoredaId == null)
                _buildWoredaGrid(),

              // Church Selection
              if (_selectedWoredaId != null) _buildChurchGrid(),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildJurisdictionGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('ግዛት ይምረጡ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.royalEmerald)),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedJurisdiction = 'national'),
                child: _JurisdictionCard(icon: '👑', label: 'ብሔራዊ', subtitle: 'የኢትዮጵያ አብያተ ክርስቲያናት'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedJurisdiction = 'diaspora'),
                child: _JurisdictionCard(icon: '🌍', label: 'ድያስፖራ', subtitle: 'የውጭ ሀገር'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDioceseGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('ሀገረ ስብከት ይምረጡ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.royalEmerald)),
            GestureDetector(
              onTap: () => setState(() => _selectedJurisdiction = null),
              child: const Text('ተመለስ', style: TextStyle(color: AppTheme.imperialGold, fontSize: 12, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('dioceses')
              .where('jurisdiction', isEqualTo: _selectedJurisdiction)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const SizedBox.shrink();
            final dioceses = snapshot.data!.docs
                .where((d) => _searchQuery.isEmpty || ((d.data() as Map<String, dynamic>?)?['name'] ?? '').toString().toLowerCase().contains(_searchQuery.toLowerCase()))
                .toList();

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 1.1, mainAxisSpacing: 12, crossAxisSpacing: 12),
              itemCount: dioceses.length,
              itemBuilder: (_, i) {
                final d = dioceses[i];
                final dName = ((d.data() as Map<String, dynamic>?)?['name'] ?? 'Diocese') as String;
                return GestureDetector(
                  onTap: () => setState(() {
                    _selectedDioceseId = d.id;
                    _selectedDioceseName = dName;
                  }),
                  child: _EntityCard(icon: '🏛️', name: dName, subtitle: ((d.data() as Map<String, dynamic>?)?['archbishop'] ?? '') as String),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildWoredaGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('በ${_selectedDioceseName ?? "ሀገረ ስብከት"} ስር ያሉ ወረዳዎች',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.royalEmerald)),
            GestureDetector(
              onTap: () => setState(() { _selectedDioceseId = null; _selectedDioceseName = null; }),
              child: const Text('← ተመለስ', style: TextStyle(color: AppTheme.imperialGold, fontSize: 12, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        StreamBuilder<QuerySnapshot>(
          // First try with dioceseId field
          stream: FirebaseFirestore.instance
              .collection('woredas')
              .where('dioceseId', isEqualTo: _selectedDioceseId)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(color: AppTheme.royalEmerald, strokeWidth: 2),
              ));
            }
            var woredas = snapshot.data!.docs;

            // Fallback: if no results by dioceseId, show all woredas and filter client-side by diocese name
            return StreamBuilder<QuerySnapshot>(
              stream: woredas.isEmpty
                  ? FirebaseFirestore.instance.collection('woredas').snapshots()
                  : null,
              builder: (context, fallbackSnap) {
                List<QueryDocumentSnapshot> items = woredas.isNotEmpty
                    ? woredas
                    : (fallbackSnap.data?.docs ?? []).where((w) {
                        final data = w.data() as Map<String, dynamic>?;
                        final wDiocese = (data?['dioceseName'] ?? data?['diocese'] ?? '').toString().toLowerCase();
                        final selName = (_selectedDioceseName ?? '').toLowerCase();
                        return selName.isEmpty || wDiocese.contains(selName.split(' ').first);
                      }).toList();

                if (_searchQuery.isNotEmpty) {
                  items = items.where((w) =>
                    ((w.data() as Map<String, dynamic>?)?['name'] ?? '').toString().toLowerCase().contains(_searchQuery.toLowerCase())
                  ).toList();
                }

                if (items.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F7F4),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.map_outlined, color: AppTheme.royalEmerald, size: 36),
                        const SizedBox(height: 8),
                        const Text('ምንም ወረዳ አልተገኘም', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.royalEmerald)),
                        Text('No woredas registered under ${_selectedDioceseName ?? "this Diocese"} yet.',
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 12, color: Colors.black54)),
                      ],
                    ),
                  );
                }

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 1.1, mainAxisSpacing: 12, crossAxisSpacing: 12),
                  itemCount: items.length,
                  itemBuilder: (_, i) {
                    final w = items[i];
                    return GestureDetector(
                      onTap: () => setState(() => _selectedWoredaId = w.id),
                      child: _EntityCard(icon: '🗺️', name: ((w.data() as Map<String, dynamic>?)?['name'] ?? 'Woreda') as String, subtitle: ''),
                    );
                  },
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildChurchGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('ቤተ ክርስቲያን ይምረጡ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.royalEmerald)),
            GestureDetector(
              onTap: () => setState(() => _selectedWoredaId = null),
              child: const Text('ተመለስ', style: TextStyle(color: AppTheme.imperialGold, fontSize: 12, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('churches')
              .where('woredaId', isEqualTo: _selectedWoredaId)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const SizedBox.shrink();
            final churches = snapshot.data!.docs
                .where((c) => _searchQuery.isEmpty || ((c.data() as Map<String, dynamic>?)?['name'] ?? '').toString().toLowerCase().contains(_searchQuery.toLowerCase()))
                .toList();

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 1.1, mainAxisSpacing: 12, crossAxisSpacing: 12),
              itemCount: churches.length,
              itemBuilder: (_, i) {
                final c = churches[i];
                final type = (c.data() as Map<String, dynamic>?)?['type'] as String? ?? 'church';
                return GestureDetector(
                  onTap: () => _switchChurch(c.id),
                  child: _EntityCard(
                    icon: type == 'monastery' ? '🏰' : '⛪',
                    name: ((c.data() as Map<String, dynamic>?)?['name'] ?? 'Church') as String,
                    subtitle: ((c.data() as Map<String, dynamic>?)?['clergy'] ?? '') as String,
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}

class _JurisdictionCard extends StatelessWidget {
  final String icon, label, subtitle;
  const _JurisdictionCard({required this.icon, required this.label, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: const Color(0xFFF0F7F4), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.royalEmerald.withValues(alpha: 0.2))),
      padding: const EdgeInsets.all(16),
      child: Column(children: [Text(icon, style: const TextStyle(fontSize: 32)), const SizedBox(height: 8), Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.royalEmerald)), const SizedBox(height: 4), Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.black54))]),
    );
  }
}

class _EntityCard extends StatelessWidget {
  final String icon, name, subtitle;
  const _EntityCard({required this.icon, required this.name, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: const Color(0xFFF0F7F4), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.royalEmerald.withValues(alpha: 0.2))),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: [Text(icon, style: const TextStyle(fontSize: 28)), const SizedBox(height: 8), Text(name, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.royalEmerald), maxLines: 2, overflow: TextOverflow.ellipsis), if (subtitle.isNotEmpty) ...[const SizedBox(height: 4), Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(fontSize: 10, color: Colors.black38), maxLines: 1, overflow: TextOverflow.ellipsis)]]),
    );
  }
}

class _AnimatedBottomNav extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<String> labels;
  final List<IconData> icons;

  const _AnimatedBottomNav({required this.currentIndex, required this.onTap, required this.labels, required this.icons});

  @override
  State<_AnimatedBottomNav> createState() => _AnimatedBottomNavState();
}

class _AnimatedBottomNavState extends State<_AnimatedBottomNav> {
  @override
  Widget build(BuildContext context) {
    final count = widget.icons.length;
    return Container(
      height: 66,
      decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 16, offset: const Offset(0, -2))]),
      child: Stack(children: [
        AnimatedAlign(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          alignment: Alignment(-1.0 + (widget.currentIndex / (count - 1)) * 2.0, 0),
          child: FractionallySizedBox(widthFactor: 1 / count, child: Container(height: 3, decoration: BoxDecoration(color: AppTheme.imperialGold, borderRadius: const BorderRadius.vertical(bottom: Radius.circular(2))))),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(count, (i) => Expanded(child: GestureDetector(onTap: () => widget.onTap(i), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(widget.icons[i], color: widget.currentIndex == i ? AppTheme.royalEmerald : Colors.black26, size: 24), const SizedBox(height: 4), Text(widget.labels[i], style: TextStyle(fontSize: 10, color: widget.currentIndex == i ? AppTheme.royalEmerald : Colors.black26, fontWeight: FontWeight.w500))])))),
        ),
      ]),
    );
  }
}
