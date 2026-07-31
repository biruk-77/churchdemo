import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:church/app/theme.dart';

class QuickActionGrid extends ConsumerStatefulWidget {
  const QuickActionGrid({super.key});

  @override
  ConsumerState<QuickActionGrid> createState() => _QuickActionGridState();
}

class _QuickActionGridState extends ConsumerState<QuickActionGrid>
    with SingleTickerProviderStateMixin {
  late final AnimationController _stagger;
  late final List<Animation<double>> _fades = [];
  late final List<Animation<Offset>> _slides = [];

  @override
  void initState() {
    super.initState();
    _stagger = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..forward();
  }

  void _setupAnimations(int count) {
    _fades.clear();
    _slides.clear();

    for (int i = 0; i < count; i++) {
      final start = i * 0.073;
      _fades.add(
        Tween<double>(begin: 0, end: 1).animate(
          CurvedAnimation(
            parent: _stagger,
            curve: Interval(start, (start + 0.3).clamp(0, 1.0), curve: Curves.easeOut),
          ),
        ),
      );

      _slides.add(
        Tween<Offset>(
          begin: const Offset(0, 0.55),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _stagger,
            curve: Interval(start, (start + 0.5).clamp(0, 1.0), curve: Curves.easeOutBack),
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _stagger.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('contributionTypes')
          .where('status', isEqualTo: 'active')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildSkeletonGrid();
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildDefaultGrid();
        }

        final types = snapshot.data!.docs.map((d) {
          final data = d.data() as Map<String, dynamic>;
          return _ContributionType(
            name: data['name'] ?? 'Contribution',
            icon: data['icon'] ?? '💰',
            type: d.id,
            color: _parseColor(data['color'] as String?),
          );
        }).toList();

        _setupAnimations(types.length);

        return AnimatedBuilder(
          animation: _stagger,
          builder: (context, _) {
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.35,
              ),
              itemCount: types.length,
              itemBuilder: (context, i) => FadeTransition(
                opacity: _fades[i],
                child: SlideTransition(
                  position: _slides[i],
                  child: _BreathingCard(type: types[i]),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDefaultGrid() {
    // Fallback to defaults if no types in Firestore
    final defaults = [
      _ContributionType(
        name: 'Monthly Contribution',
        icon: '📅',
        type: 'monthly',
        color: AppTheme.royalEmerald,
      ),
      _ContributionType(
        name: 'Bekuart',
        icon: '🎁',
        type: 'bekuart',
        color: AppTheme.royalEmerald,
      ),
      _ContributionType(
        name: 'Festival Offering',
        icon: '🎊',
        type: 'festival',
        color: AppTheme.royalEmerald,
      ),
      _ContributionType(
        name: 'Building Fund',
        icon: '🏗️',
        type: 'buildingFund',
        color: AppTheme.royalEmerald,
      ),
      _ContributionType(
        name: 'Asrat (Tithe)',
        icon: '%',
        type: 'asrat',
        color: AppTheme.royalEmerald,
      ),
      _ContributionType(
        name: 'Monastery Support',
        icon: '🏰',
        type: 'monastery',
        color: AppTheme.royalEmerald,
      ),
    ];

    _setupAnimations(defaults.length);

    return AnimatedBuilder(
      animation: _stagger,
      builder: (context, _) {
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.35,
          ),
          itemCount: defaults.length,
          itemBuilder: (context, i) => FadeTransition(
            opacity: _fades[i],
            child: SlideTransition(
              position: _slides[i],
              child: _BreathingCard(type: defaults[i]),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSkeletonGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.35,
      children: List.generate(
        6,
        (_) => Container(
          decoration: BoxDecoration(
            color: Colors.grey.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Color _parseColor(String? hexColor) {
    if (hexColor == null || hexColor.isEmpty) return AppTheme.royalEmerald;
    try {
      return Color(int.parse(hexColor.replaceFirst('#', '0xff')));
    } catch (_) {
      return AppTheme.royalEmerald;
    }
  }
}

class _BreathingCard extends StatefulWidget {
  final _ContributionType type;
  const _BreathingCard({required this.type});

  @override
  State<_BreathingCard> createState() => _BreathingCardState();
}

class _BreathingCardState extends State<_BreathingCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _breathe;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _breathe = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat(reverse: true);
    _scale = Tween<double>(begin: 1.0, end: 1.018).animate(
      CurvedAnimation(parent: _breathe, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _breathe.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(scale: _scale, child: _CardFace(type: widget.type));
  }
}

class _CardFace extends StatelessWidget {
  final _ContributionType type;
  const _CardFace({required this.type});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push('/contribute/amount', extra: type.type),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF0F7F4),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.royalEmerald.withValues(alpha: 0.18), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: AppTheme.royalEmerald.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Text(type.icon, style: const TextStyle(fontSize: 22)),
            ),
            Text(
              type.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: AppTheme.royalEmerald,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContributionType {
  final String name;
  final String icon;
  final String type;
  final Color color;

  _ContributionType({
    required this.name,
    required this.icon,
    required this.type,
    required this.color,
  });
}
