import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:church/app/theme.dart';
import 'package:church/core/logger/app_logger.dart';
import 'package:church/core/widgets/primary_button.dart';
import 'package:church/features/auth/presentation/providers/auth_provider.dart';
import 'package:church/features/church/data/church_model.dart';
import 'package:church/features/church/data/church_repository.dart';
import 'package:church/l10n/app_localizations.dart';

const _tag = 'ChurchSelectionScreen';

final churchRepositoryProvider = Provider<ChurchRepository>((ref) => ChurchRepository());

final churchesFutureProvider = FutureProvider<List<ChurchModel>>((ref) async {
  log.i(_tag, '⛪  Fetching church list…');
  final churches = await ref.watch(churchRepositoryProvider).getChurches();
  log.i(_tag, '✅  Loaded ${churches.length} churches');
  return churches;
});

class ChurchSelectionScreen extends ConsumerStatefulWidget {
  const ChurchSelectionScreen({super.key});

  @override
  ConsumerState<ChurchSelectionScreen> createState() => _ChurchSelectionScreenState();
}

class _ChurchSelectionScreenState extends ConsumerState<ChurchSelectionScreen>
    with SingleTickerProviderStateMixin {
  String _searchQuery = '';
  String? _selectedDiocese;
  ChurchModel? _selectedChurch;

  late final AnimationController _entrance;
  late final Animation<double> _headerFade;
  late final Animation<Offset> _headerSlide;
  late final Animation<double> _searchFade;

  @override
  void initState() {
    super.initState();
    log.i(_tag, '🖥️  Screen opened');

    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    _headerFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _entrance, curve: const Interval(0, 0.5, curve: Curves.easeOut)),
    );
    _headerSlide = Tween<Offset>(begin: const Offset(0, -0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _entrance, curve: const Interval(0, 0.55, curve: Curves.easeOutCubic)),
    );
    _searchFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _entrance, curve: const Interval(0.2, 0.65, curve: Curves.easeOut)),
    );
  }

  @override
  void dispose() {
    _entrance.dispose();
    log.d(_tag, '🗑️  Screen disposed');
    super.dispose();
  }

  void _onChurchTapped(ChurchModel church) {
    log.i(_tag, '🤚  Church tapped → "${church.name}"');
    setState(() => _selectedChurch = church);
  }

  Future<void> _onJoinPressed() async {
    final church = _selectedChurch!;
    final isChanging = ref.read(authStateProvider).user?.churchId != null;
    log.i(_tag, '🙏  JOIN → ${church.id}  isChanging=$isChanging');
    try {
      await ref.read(authStateProvider.notifier).selectChurch(church.id);
      if (!mounted) return;
      if (isChanging) {
        context.pop();
      } else {
        context.go('/home');
      }
    } catch (e, s) {
      log.e(_tag, '🔴  Failed to join', error: e, stack: s);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final churchesAsync = ref.watch(churchesFutureProvider);
    final authState = ref.watch(authStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedDiocese == null ? 'Select Diocese (ሀገረ ስብከት)' : l10n.selectChurch),
        elevation: 0,
        actions: [
          if (_selectedDiocese != null)
            TextButton.icon(
              onPressed: () => setState(() {
                _selectedDiocese = null;
                _selectedChurch = null;
              }),
              icon: const Icon(Icons.swap_horiz_rounded, size: 18, color: AppTheme.primaryGold),
              label: const Text('Change Diocese', style: TextStyle(color: AppTheme.primaryGold, fontSize: 12)),
            ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // Animated header
              FadeTransition(
                opacity: _headerFade,
                child: SlideTransition(
                  position: _headerSlide,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedDiocese == null
                            ? 'Step 1: Select Diocese (ሀገረ ስብከት)'
                            : 'Step 2: Select Parish in $_selectedDiocese',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _selectedDiocese == null
                            ? 'Choose your regional archdiocese first to view local churches.'
                            : 'Tap on your home church or monastery to join.',
                        style: TextStyle(fontSize: 13, color: Colors.black.withValues(alpha: 0.5)),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // Animated search bar
              FadeTransition(
                opacity: _searchFade,
                child: TextField(
                  onChanged: (v) => setState(() => _searchQuery = v),
                  decoration: InputDecoration(
                    hintText: _selectedDiocese == null ? 'Search Diocese (e.g. Hawassa, Addis Ababa)' : l10n.searchChurch,
                    prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.primaryBlue),
                    filled: true,
                    fillColor: AppTheme.primaryBlue.withValues(alpha: 0.04),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppTheme.primaryGold, width: 1.5),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Content List (Dioceses list in Step 1, Churches list in Step 2)
              Expanded(
                child: churchesAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text(l10n.error)),
                  data: (churches) {
                    if (_selectedDiocese == null) {
                      // ── STEP 1: Show Unique Dioceses ──────────────────────
                      final allDioceses = churches.map((c) => c.diocese).toSet().toList();
                      final filteredDioceses = allDioceses.where((d) {
                        final q = _searchQuery.toLowerCase();
                        return d.toLowerCase().contains(q);
                      }).toList();

                      if (filteredDioceses.isEmpty) {
                        return Center(
                          child: Text('No matching diocese found', style: TextStyle(color: Colors.black.withValues(alpha: 0.4))),
                        );
                      }

                      return ListView.builder(
                        itemCount: filteredDioceses.length,
                        itemBuilder: (context, i) {
                          final dio = filteredDioceses[i];
                          final count = churches.where((c) => c.diocese == dio).length;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppTheme.primaryBlue.withValues(alpha: 0.12)),
                              boxShadow: [
                                BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2)),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(16),
                              clipBehavior: Clip.antiAlias,
                              child: ListTile(
                                leading: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryGold.withValues(alpha: 0.15),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.account_balance_rounded, color: AppTheme.primaryGold, size: 22),
                                ),
                                title: Text(dio, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryBlue)),
                                subtitle: Text('$count Parish Churches & Monasteries', style: const TextStyle(fontSize: 12)),
                                trailing: const Icon(Icons.chevron_right_rounded, color: AppTheme.primaryBlue),
                                onTap: () => setState(() {
                                  _selectedDiocese = dio;
                                  _searchQuery = '';
                                }),
                              ),
                            ),
                          );
                        },
                      );
                    } else {
                      // ── STEP 2: Show Churches inside selected Diocese ────
                      final dioceseChurches = churches.where((c) => c.diocese == _selectedDiocese).toList();
                      final filtered = dioceseChurches.where((c) {
                        final q = _searchQuery.toLowerCase();
                        return c.name.toLowerCase().contains(q) || c.location.toLowerCase().contains(q);
                      }).toList();

                      if (filtered.isEmpty) {
                        return Center(
                          child: Text('No churches match in $_selectedDiocese', style: TextStyle(color: Colors.black.withValues(alpha: 0.4))),
                        );
                      }

                      return ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (context, i) {
                          final church = filtered[i];
                          final isSelected = _selectedChurch?.id == church.id;
                          return _AnimatedChurchCard(
                            church: church,
                            isSelected: isSelected,
                            index: i,
                            l10n: l10n,
                            onTap: () => _onChurchTapped(church),
                          );
                        },
                      );
                    }
                  },
                ),
              ),

              const SizedBox(height: 16),

              // Join button — visible in Step 2 when a church is selected
              if (_selectedDiocese != null)
                _PulsingJoinButton(
                  label: l10n.joinChurch,
                  isLoading: authState.isLoading,
                  isActive: _selectedChurch != null,
                  onPressed: _selectedChurch == null ? null : _onJoinPressed,
                ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

/// Church card with staggered entrance + animated selection glow.
class _AnimatedChurchCard extends StatefulWidget {
  final ChurchModel church;
  final bool isSelected;
  final int index;
  final AppLocalizations l10n;
  final VoidCallback onTap;

  const _AnimatedChurchCard({
    required this.church,
    required this.isSelected,
    required this.index,
    required this.l10n,
    required this.onTap,
  });

  @override
  State<_AnimatedChurchCard> createState() => _AnimatedChurchCardState();
}

class _AnimatedChurchCardState extends State<_AnimatedChurchCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _in;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _in = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _fade = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _in, curve: Curves.easeOut));
    _slide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _in, curve: Curves.easeOutCubic),
    );
    Future.delayed(Duration(milliseconds: 200 + widget.index * 70), () {
      if (mounted) _in.forward();
    });
  }

  @override
  void dispose() {
    _in.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final church = widget.church;
    final iconColor = church.isMonastery ? Colors.orange : AppTheme.primaryBlue;

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: widget.isSelected ? AppTheme.primaryBlue.withValues(alpha: 0.05) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: widget.isSelected ? AppTheme.primaryGold : AppTheme.primaryBlue.withValues(alpha: 0.12),
                width: widget.isSelected ? 2 : 1,
              ),
              boxShadow: widget.isSelected
                  ? [BoxShadow(color: AppTheme.primaryGold.withValues(alpha: 0.2), blurRadius: 14, offset: const Offset(0, 4))]
                  : [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              clipBehavior: Clip.antiAlias,
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                leading: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: widget.isSelected ? 0.18 : 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    church.isMonastery ? Icons.castle_rounded : Icons.church_rounded,
                    color: iconColor,
                    size: 22,
                  ),
                ),
                title: Text(church.name, style: TextStyle(fontWeight: FontWeight.bold, color: widget.isSelected ? AppTheme.primaryBlue : Colors.black87)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${widget.l10n.location}: ${church.location}', style: const TextStyle(fontSize: 12)),
                    Text('${widget.l10n.diocese}: ${church.diocese}', style: const TextStyle(fontSize: 12)),
                  ],
                ),
                trailing: AnimatedOpacity(
                  opacity: widget.isSelected ? 1 : 0,
                  duration: const Duration(milliseconds: 250),
                  child: const Icon(Icons.check_circle_rounded, color: AppTheme.primaryGold, size: 22),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Join button that pulses when a church is selected.
class _PulsingJoinButton extends StatefulWidget {
  final String label;
  final bool isLoading;
  final bool isActive;
  final VoidCallback? onPressed;

  const _PulsingJoinButton({
    required this.label,
    required this.isLoading,
    required this.isActive,
    required this.onPressed,
  });

  @override
  State<_PulsingJoinButton> createState() => _PulsingJoinButtonState();
}

class _PulsingJoinButtonState extends State<_PulsingJoinButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
    _scale = Tween<double>(begin: 1.0, end: 1.025).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scale,
      builder: (_, child) => Transform.scale(
        scale: widget.isActive ? _scale.value : 1.0,
        child: child,
      ),
      child: PrimaryButton(
        text: widget.label,
        isLoading: widget.isLoading,
        onPressed: widget.onPressed,
      ),
    );
  }
}
