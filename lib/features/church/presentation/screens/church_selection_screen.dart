import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:church/app/theme.dart';
import 'package:church/core/widgets/primary_button.dart';
import 'package:church/features/auth/presentation/providers/auth_provider.dart';
import 'package:church/features/church/data/church_model.dart';
import 'package:church/features/church/data/church_repository.dart';
import 'package:church/l10n/app_localizations.dart';

final churchRepositoryProvider = Provider<ChurchRepository>((ref) {
  return ChurchRepository();
});

final churchesFutureProvider = FutureProvider<List<ChurchModel>>((ref) async {
  return ref.watch(churchRepositoryProvider).getChurches();
});

class ChurchSelectionScreen extends ConsumerStatefulWidget {
  const ChurchSelectionScreen({super.key});

  @override
  ConsumerState<ChurchSelectionScreen> createState() => _ChurchSelectionScreenState();
}

class _ChurchSelectionScreenState extends ConsumerState<ChurchSelectionScreen> {
  String _searchQuery = '';
  ChurchModel? _selectedChurch;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final churchesAsync = ref.watch(churchesFutureProvider);
    final authState = ref.watch(authStateProvider);

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
              // Search field
              TextField(
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val;
                  });
                },
                decoration: InputDecoration(
                  hintText: l10n.searchChurch,
                  prefixIcon: const Icon(Icons.search, color: AppTheme.primaryBlue),
                ),
              ),
              const SizedBox(height: 20),
              // Church List
              Expanded(
                child: churchesAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Center(child: Text(l10n.error)),
                  data: (churches) {
                    final filtered = churches.where((c) {
                      return c.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                          c.location.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                          c.diocese.toLowerCase().contains(_searchQuery.toLowerCase());
                    }).toList();

                    if (filtered.isEmpty) {
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
                        final church = filtered[index];
                        final isSelected = _selectedChurch?.id == church.id;

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          color: isSelected ? AppTheme.primaryBlue.withValues(alpha: 0.05) : null,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                              color: isSelected ? AppTheme.primaryGold : AppTheme.borderLight,
                              width: isSelected ? 2 : 0.5,
                            ),
                          ),
                          child: ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: (church.isMonastery ? Colors.orange : AppTheme.primaryBlue)
                                    .withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                church.isMonastery ? Icons.castle : Icons.church,
                                color: church.isMonastery ? Colors.orange : AppTheme.primaryBlue,
                              ),
                            ),
                            title: Text(
                              church.name,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${l10n.location}: ${church.location}'),
                                Text('${l10n.diocese}: ${church.diocese}'),
                              ],
                            ),
                            onTap: () {
                              setState(() {
                                _selectedChurch = church;
                              });
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              PrimaryButton(
                text: l10n.joinChurch,
                isLoading: authState.isLoading,
                onPressed: _selectedChurch == null
                    ? null
                    : () async {
                        await ref
                            .read(authStateProvider.notifier)
                            .selectChurch(_selectedChurch!.id);
                        if (mounted) {
                          context.go('/home');
                        }
                      },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
