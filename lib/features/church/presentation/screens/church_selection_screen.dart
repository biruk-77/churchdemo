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

// ── Providers ─────────────────────────────────────────────────────────────────

final churchRepositoryProvider = Provider<ChurchRepository>((ref) {
  return ChurchRepository();
});

final churchesFutureProvider = FutureProvider<List<ChurchModel>>((ref) async {
  log.i(_tag, '⛪  Fetching church list from repository…');
  final churches = await ref.watch(churchRepositoryProvider).getChurches();
  log.i(_tag, '✅  Loaded ${churches.length} churches from Firestore');
  return churches;
});

// ── Screen ────────────────────────────────────────────────────────────────────

class ChurchSelectionScreen extends ConsumerStatefulWidget {
  const ChurchSelectionScreen({super.key});

  @override
  ConsumerState<ChurchSelectionScreen> createState() =>
      _ChurchSelectionScreenState();
}

class _ChurchSelectionScreenState
    extends ConsumerState<ChurchSelectionScreen> {
  String      _searchQuery   = '';
  ChurchModel? _selectedChurch;

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    log.i(_tag, '🖥️  Screen opened — user is picking a church');
  }

  @override
  void dispose() {
    log.d(_tag, '🗑️  Screen disposed');
    super.dispose();
  }

  // ── Handlers ───────────────────────────────────────────────────────────────

  void _onSearchChanged(String val) {
    log.v(_tag, '🔍  Search query changed → "$val"');
    setState(() => _searchQuery = val);
  }

  void _onChurchTapped(ChurchModel church) {
    log.i(
      _tag,
      '🤚  Church tapped → "${church.name}" '
      '(id=${church.id}, diocese=${church.diocese}, '
      'monastery=${church.isMonastery})',
    );
    setState(() => _selectedChurch = church);
  }

  Future<void> _onJoinPressed() async {
    final church = _selectedChurch!;
    // If the user already had a church, they're changing — go back to profile.
    // If first-time, go to home.
    final isChanging = ref.read(authStateProvider).user?.churchId != null;

    log.i(_tag, '🙏  JOIN pressed → churchId=${church.id} name="${church.name}" isChanging=$isChanging');

    try {
      await ref.read(authStateProvider.notifier).selectChurch(church.id);

      if (!mounted) return;
      if (isChanging) {
        log.i(_tag, '🔄  Church changed → popping back to profile');
        context.pop();
      } else {
        log.i(_tag, '🎉  Church joined → navigating to /home');
        context.go('/home');
      }
    } catch (e, stack) {
      log.e(
        _tag,
        '🔴  Failed to join church "${church.name}" (id=${church.id})',
        error: e,
        stack: stack,
      );
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l10n         = AppLocalizations.of(context);
    final churchesAsync = ref.watch(churchesFutureProvider);
    final authState    = ref.watch(authStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.selectChurch),
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                l10n.selectChurch,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryBlue,
                ),
              ),
              const SizedBox(height: 16),

              // ── Search field ─────────────────────────────────────────────
              TextField(
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  hintText: l10n.searchChurch,
                  prefixIcon:
                      const Icon(Icons.search, color: AppTheme.primaryBlue),
                ),
              ),
              const SizedBox(height: 20),

              // ── Church list ───────────────────────────────────────────────
              Expanded(
                child: churchesAsync.when(
                  loading: () {
                    log.d(_tag, '⏳  Church list loading…');
                    return const Center(child: CircularProgressIndicator());
                  },
                  error: (err, stack) {
                    log.e(
                      _tag,
                      '🔴  churchesFutureProvider error',
                      error: err,
                      stack: stack,
                    );
                    return Center(child: Text(l10n.error));
                  },
                  data: (churches) {
                    final filtered = churches.where((c) {
                      final q = _searchQuery.toLowerCase();
                      return c.name.toLowerCase().contains(q) ||
                          c.location.toLowerCase().contains(q) ||
                          c.diocese.toLowerCase().contains(q);
                    }).toList();

                    if (_searchQuery.isNotEmpty) {
                      log.v(
                        _tag,
                        '🔍  Filter applied → '
                        '"$_searchQuery" matched ${filtered.length}/'
                        '${churches.length} churches',
                      );
                    }

                    if (filtered.isEmpty) {
                      log.d(
                        _tag,
                        '😶  No churches match query "$_searchQuery"',
                      );
                      return const Center(
                        child: Text(
                          'No matching churches found',
                          style: TextStyle(color: Colors.black54),
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final church    = filtered[index];
                        final isSelected = _selectedChurch?.id == church.id;

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          color: isSelected
                              ? AppTheme.primaryBlue.withValues(alpha: 0.05)
                              : null,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                              color: isSelected
                                  ? AppTheme.primaryGold
                                  : AppTheme.borderLight,
                              width: isSelected ? 2 : 0.5,
                            ),
                          ),
                          child: ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: (church.isMonastery
                                            ? Colors.orange
                                            : AppTheme.primaryBlue)
                                        .withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                church.isMonastery
                                    ? Icons.castle
                                    : Icons.church,
                                color: church.isMonastery
                                    ? Colors.orange
                                    : AppTheme.primaryBlue,
                              ),
                            ),
                            title: Text(
                              church.name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    '${l10n.location}: ${church.location}'),
                                Text(
                                    '${l10n.diocese}: ${church.diocese}'),
                              ],
                            ),
                            onTap: () => _onChurchTapped(church),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),

              // ── Join button ───────────────────────────────────────────────
              PrimaryButton(
                text: l10n.joinChurch,
                isLoading: authState.isLoading,
                onPressed:
                    _selectedChurch == null ? null : _onJoinPressed,
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
