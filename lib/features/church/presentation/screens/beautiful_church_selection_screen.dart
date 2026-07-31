import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:church/app/theme.dart';
import 'package:church/features/church/data/church_model.dart';
import 'package:church/features/church/data/church_repository.dart';
import 'package:church/features/auth/presentation/providers/auth_provider.dart' as auth;

class BeautifulChurchSelectionScreen extends ConsumerStatefulWidget {
  final String dioceseId;
  final String woredaId;

  const BeautifulChurchSelectionScreen({
    required this.dioceseId,
    required this.woredaId,
    super.key,
  });

  @override
  ConsumerState<BeautifulChurchSelectionScreen> createState() =>
      _BeautifulChurchSelectionScreenState();
}

class _BeautifulChurchSelectionScreenState extends ConsumerState<BeautifulChurchSelectionScreen>
    with TickerProviderStateMixin {
  String? selectedChurchId;
  late AnimationController _animCtrl;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.parchmentBg,
      appBar: AppBar(
        title: const Text('ቤተ ክርስቲያን ይምረጡ'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ጠቆም ሆነዋል',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppTheme.royalEmerald,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'ከሚከተሏቸው ቤተ ክርስቲያናት ውስጥ ይምረጡ',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 32),
            FutureBuilder<List<ChurchModel>>(
              future: ref.read(churchRepositoryProvider).getChurchesByWoreda(
                    widget.dioceseId,
                    widget.woredaId,
                  ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.royalEmerald,
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        children: [
                          Icon(
                            Icons.church,
                            size: 64,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'ቤተ ክርስቲያን አልተገኘም',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final churches = snapshot.data!;
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: churches.length,
                  itemBuilder: (context, index) {
                    final church = churches[index];
                    final isSelected = selectedChurchId == church.id;
                    final delay = index * 50;

                    return ScaleTransition(
                      scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                        CurvedAnimation(
                          parent: _animCtrl,
                          curve: Interval(
                            (delay / 1000).clamp(0.0, 1.0),
                            ((delay + 500) / 1000).clamp(0.0, 1.0),
                            curve: Curves.easeOutBack,
                          ),
                        ),
                      ),
                      child: GestureDetector(
                        onTap: () {
                          setState(() => selectedChurchId = church.id);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                  ? AppTheme.imperialGold
                                  : AppTheme.borderLight,
                              width: isSelected ? 2.5 : 1.5,
                            ),
                            color: isSelected
                                ? AppTheme.royalEmerald.withValues(alpha: 0.08)
                                : Colors.white,
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: AppTheme.royalEmerald
                                          .withValues(alpha: 0.2),
                                      blurRadius: 16,
                                      offset: const Offset(0, 8),
                                    )
                                  ]
                                : [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.05),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    )
                                  ],
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        colors: [
                                          AppTheme.royalEmerald
                                              .withValues(alpha: 0.3),
                                          AppTheme.imperialGold
                                              .withValues(alpha: 0.2),
                                        ],
                                      ),
                                    ),
                                    child: Icon(
                                      church.isMonastery
                                          ? Icons.temple_buddhist
                                          : Icons.church,
                                      color: AppTheme.royalEmerald,
                                      size: 32,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          church.name,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: AppTheme.royalEmerald,
                                              ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.location_on,
                                              size: 14,
                                              color: Colors.grey[600],
                                            ),
                                            const SizedBox(width: 4),
                                            Expanded(
                                              child: Text(
                                                church.location,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall
                                                    ?.copyWith(
                                                      color: Colors.grey[600],
                                                    ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (isSelected)
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: AppTheme.imperialGold,
                                      ),
                                      child: const Icon(
                                        Icons.check,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.people,
                                          size: 16,
                                          color: AppTheme.royalEmerald,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          '${church.memberCount} አባላት',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color: AppTheme.royalEmerald,
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color: AppTheme.imperialGold
                                          .withValues(alpha: 0.15),
                                    ),
                                    child: Text(
                                      church.status,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: AppTheme.royalEmerald,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: selectedChurchId == null
                  ? null
                  : () async {
                      await ref
                          .read(auth.authStateProvider.notifier)
                          .selectChurch(selectedChurchId!);
                      if (mounted) {
                        context.go('/home');
                      }
                    },
              icon: const Icon(Icons.check_circle),
              label: const Text('ይህ ቤተ ክርስቲያናት ይምረጡ'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                backgroundColor: AppTheme.royalEmerald,
                disabledBackgroundColor: Colors.grey[300],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
