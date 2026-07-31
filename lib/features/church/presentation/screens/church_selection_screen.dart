import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:church/app/theme.dart';
import 'package:church/core/logger/app_logger.dart';
import 'package:church/core/widgets/primary_button.dart';
import 'package:church/features/auth/presentation/providers/auth_provider.dart';
import 'package:church/features/church/data/church_model.dart';
import 'package:church/features/church/data/church_repository.dart';
import 'package:church/l10n/app_localizations.dart';

const _tag = 'ChurchSelectionScreen';

final churchRepositoryProvider = Provider<ChurchRepository>((ref) => ChurchRepository());

class ChurchSelectionScreen extends ConsumerStatefulWidget {
  const ChurchSelectionScreen({super.key});

  @override
  ConsumerState<ChurchSelectionScreen> createState() => _ChurchSelectionScreenState();
}

class _ChurchSelectionScreenState extends ConsumerState<ChurchSelectionScreen>
    with SingleTickerProviderStateMixin {
  // Selection hierarchy
  String? _selectedJurisdiction; // 'national' or 'diaspora'
  String? _selectedDioceseId;
  String? _selectedWoredaId;
  ChurchModel? _selectedChurch;

  late final AnimationController _entrance;

  @override
  void initState() {
    super.initState();
    log.i(_tag, '🖥️  Screen opened');

    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
  }

  @override
  void dispose() {
    _entrance.dispose();
    super.dispose();
  }

  Future<void> _onJoinPressed() async {
    final church = _selectedChurch!;
    final isChanging = ref.read(authStateProvider).user?.churchId != null;
    log.i(_tag, '🙏  JOIN → ${church.id}');
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

    // Step 1: Select Jurisdiction (National or Diaspora)
    if (_selectedJurisdiction == null) {
      return _buildJurisdictionSelection(l10n);
    }

    // Step 2: Select Diocese
    if (_selectedDioceseId == null) {
      return _buildDioceseSelection(l10n);
    }

    // Step 3: Select Woreda
    if (_selectedWoredaId == null) {
      return _buildWoredaSelection(l10n);
    }

    // Step 4: Select Church
    return _buildChurchSelection(l10n);
  }

  Widget _buildJurisdictionSelection(AppLocalizations l10n) {
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.selectChurch),
        elevation: 0,
        backgroundColor: AppTheme.royalEmerald,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Step 1: Select Level',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.royalEmerald,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'የቤተ ክህነት ግዛትዎን ይምረጡ',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 32),
              _buildJurisdictionCard(
                '👑 ብሔራዊ',
                'የኢትዮጵያ ኦርቶዶክስ አብያተ ክርስቲያናት',
                'national',
              ),
              const SizedBox(height: 16),
              _buildJurisdictionCard(
                '🌍 ድያስፖራ',
                'የውጭ ሀገር ሀገረ ስብከቶች',
                'diaspora',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildJurisdictionCard(String title, String subtitle, String value) {
    return GestureDetector(
      onTap: () => setState(() => _selectedJurisdiction = value),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF0F7F4),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.royalEmerald.withValues(alpha: 0.2), width: 1.5),
        ),
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.royalEmerald,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, color: AppTheme.royalEmerald, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDioceseSelection(AppLocalizations l10n) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ደረጃ 2፦ ሀገረ ስብከት ይምረጡ'),
        elevation: 0,
        backgroundColor: AppTheme.royalEmerald,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => setState(() => _selectedJurisdiction = null),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('dioceses')
            .where('jurisdiction', isEqualTo: _selectedJurisdiction)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('ምንም ሀገረ ስብከት አልተገኘም'));
          }

          final dioceses = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: dioceses.length,
            itemBuilder: (context, index) {
              final doc = dioceses[index];
              final name = doc['name'] ?? 'Unknown';
              final archbishop = doc['archbishop'] ?? 'N/A';

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GestureDetector(
                  onTap: () => setState(() => _selectedDioceseId = doc.id),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F7F4),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.royalEmerald.withValues(alpha: 0.2), width: 1),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: const BoxDecoration(
                            color: AppTheme.royalEmerald,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.location_city_rounded, color: Colors.white, size: 24),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: AppTheme.royalEmerald,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                archbishop,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.black.withValues(alpha: 0.5),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.arrow_forward_ios_rounded, color: AppTheme.royalEmerald, size: 18),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildWoredaSelection(AppLocalizations l10n) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ደረጃ 3፦ ወረዳ ይምረጡ'),
        elevation: 0,
        backgroundColor: AppTheme.royalEmerald,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => setState(() => _selectedDioceseId = null),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('woredas')
            .where('dioceseId', isEqualTo: _selectedDioceseId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('ምንም ወረዳ አልተገኘም'));
          }

          final woredas = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: woredas.length,
            itemBuilder: (context, index) {
              final doc = woredas[index];
              final name = doc['name'] ?? 'Unknown';

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GestureDetector(
                  onTap: () => setState(() => _selectedWoredaId = doc.id),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F7F4),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.royalEmerald.withValues(alpha: 0.2), width: 1),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: const BoxDecoration(
                            color: AppTheme.imperialGold,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.map_rounded, color: Colors.white, size: 24),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: AppTheme.royalEmerald,
                            ),
                          ),
                        ),
                        Icon(Icons.arrow_forward_ios_rounded, color: AppTheme.royalEmerald, size: 18),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildChurchSelection(AppLocalizations l10n) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ደረጃ 4፦ ቤተ ክርስቲያን ይምረጡ'),
        elevation: 0,
        backgroundColor: AppTheme.royalEmerald,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => setState(() => _selectedWoredaId = null),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('churches')
            .where('woredaId', isEqualTo: _selectedWoredaId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('ምንም ቤተ ክርስቲያን አልተገኘም'));
          }

          final churches = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: churches.length,
            itemBuilder: (context, index) {
              final doc = churches[index];
              final name = doc['name'] ?? 'Unknown';
              final type = doc['type'] ?? 'church';
              final clergy = doc['clergy'] ?? 'N/A';

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedChurch = ChurchModel(
                        id: doc.id,
                        name: name,
                        location: name,
                        diocese: _selectedDioceseId!,
                        dioceseName: 'Diocese',
                        woreda: _selectedWoredaId,
                        clergy: clergy,
                        isMonastery: type == 'monastery',
                      );
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F7F4),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.royalEmerald.withValues(alpha: 0.2), width: 1),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: const BoxDecoration(
                            color: AppTheme.royalEmerald,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            type == 'monastery' ? Icons.temple_buddhist_rounded : Icons.church_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: AppTheme.royalEmerald,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                clergy,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.black.withValues(alpha: 0.5),
                                ),
                              ),
                            ],
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
      bottomNavigationBar: _selectedChurch == null
          ? null
          : Padding(
              padding: const EdgeInsets.all(16),
              child: PrimaryButton(
                text: 'Join ${_selectedChurch!.name}',
                onPressed: _onJoinPressed,
              ),
            ),
    );
  }
}
