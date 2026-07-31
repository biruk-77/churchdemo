import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:church/app/theme.dart';
import 'package:church/features/church/data/church_repository.dart';

class DioceseSelectionScreen extends ConsumerStatefulWidget {
  const DioceseSelectionScreen({super.key});

  @override
  ConsumerState<DioceseSelectionScreen> createState() => _DioceseSelectionScreenState();
}

class _DioceseSelectionScreenState extends ConsumerState<DioceseSelectionScreen> {
  String? selectedDiocese;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.parchmentBg,
      appBar: AppBar(
        title: const Text('ምረጥ ሰፈርዎትን'),
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
              'የሚያገለግሉት ሰፈር',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppTheme.royalEmerald,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'አገልግሎቱን ለማገኝት ሰፈርዎትን ይምረጡ',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 32),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: ref.read(churchRepositoryProvider).getDioceses(),
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
                      'ሰፈር አልተገኘም',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  );
                }

                final dioceses = snapshot.data!;
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 1,
                    mainAxisExtent: 100,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: dioceses.length,
                  itemBuilder: (context, index) {
                    final diocese = dioceses[index];
                    final isSelected = selectedDiocese == diocese['id'];

                    return GestureDetector(
                      onTap: () {
                        setState(() => selectedDiocese = diocese['id']);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
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
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppTheme.imperialGold.withValues(alpha: 0.2),
                                ),
                                child: Icon(
                                  Icons.church,
                                  color: AppTheme.royalEmerald,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      diocese['name'] ?? 'Unknown',
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.royalEmerald,
                                          ),
                                    ),
                                    Text(
                                      '${diocese['churchCount'] ?? 0} ቤተ ክርስቲያናት',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            color: Colors.grey[600],
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppTheme.imperialGold,
                                  ),
                                  child: const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 18,
                                  ),
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
              onPressed: selectedDiocese == null
                  ? null
                  : () {
                      context.push('/woreda-selection/$selectedDiocese');
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
