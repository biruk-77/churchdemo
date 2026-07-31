import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:church/app/theme.dart';
import 'package:church/features/church/data/church_repository.dart';

class WoredaSelectionScreen extends ConsumerStatefulWidget {
  final String dioceseId;

  const WoredaSelectionScreen({required this.dioceseId, super.key});

  @override
  ConsumerState<WoredaSelectionScreen> createState() => _WoredaSelectionScreenState();
}

class _WoredaSelectionScreenState extends ConsumerState<WoredaSelectionScreen> {
  String? selectedWoreda;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.parchmentBg,
      appBar: AppBar(
        title: const Text('ምረጥ ወረዳ'),
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
              'ወረዳዎን ይምረጡ',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppTheme.royalEmerald,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'በሚመለከተው ወረዳ ውስጥ ቤተ ክርስቲያናት ይታያሉ',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 32),
            FutureBuilder(
              future: ref.read(churchRepositoryProvider).getWoredas(widget.dioceseId),
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
                    child: Text(
                      'ወረዳ አልተገኘም',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  );
                }

                final woredas = snapshot.data!;
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: woredas.length,
                  itemBuilder: (context, index) {
                    final woreda = woredas[index];
                    final isSelected = selectedWoreda == woreda.id;

                    return GestureDetector(
                      onTap: () {
                        setState(() => selectedWoreda = woreda.id);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? AppTheme.imperialGold : AppTheme.borderLight,
                            width: isSelected ? 2.5 : 1.5,
                          ),
                          color: isSelected
                              ? AppTheme.royalEmerald.withValues(alpha: 0.08)
                              : Colors.white,
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: AppTheme.royalEmerald.withValues(alpha: 0.15),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  )
                                ]
                              : [],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppTheme.imperialGold.withValues(alpha: 0.2),
                              ),
                              child: Icon(
                                Icons.location_on,
                                color: AppTheme.royalEmerald,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                woreda.name,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.royalEmerald,
                                    ),
                              ),
                            ),
                            if (isSelected)
                              Container(
                                width: 28,
                                height: 28,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppTheme.imperialGold,
                                ),
                                child: const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: selectedWoreda == null
                  ? null
                  : () {
                      context.push(
                        '/church-selection/${widget.dioceseId}/$selectedWoreda',
                      );
                    },
              icon: const Icon(Icons.arrow_forward),
              label: const Text('ቀጥል'),
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
