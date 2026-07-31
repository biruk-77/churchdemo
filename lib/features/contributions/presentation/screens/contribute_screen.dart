import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:church/app/theme.dart';
import 'package:church/l10n/app_localizations.dart';

class ContributeScreen extends ConsumerStatefulWidget {
  const ContributeScreen({super.key});

  @override
  ConsumerState<ContributeScreen> createState() => _ContributeScreenState();
}

class _ContributeScreenState extends ConsumerState<ContributeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _stagger;
  late final List<Animation<double>> _fades;
  late final List<Animation<Offset>> _slides;

  static const _count = 16;

  @override
  void initState() {
    super.initState();
    _stagger = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..forward();

    _fades = List.generate(_count, (i) {
      final s = i * 0.045;
      return Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _stagger, curve: Interval(s, (s + 0.3).clamp(0, 1.0), curve: Curves.easeOut)),
      );
    });
    _slides = List.generate(_count, (i) {
      final s = i * 0.045;
      return Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
        CurvedAnimation(parent: _stagger, curve: Interval(s, (s + 0.45).clamp(0, 1.0), curve: Curves.easeOutBack)),
      );
    });
  }

  @override
  void dispose() {
    _stagger.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final items = _buildItems(l10n);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.selectContributionType), elevation: 0),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Text(
              l10n.selectContributionType,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.royalEmerald),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: AnimatedBuilder(
                animation: _stagger,
                builder: (context, _) {
                  return GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.25,
                    ),
                    itemCount: items.length,
                    itemBuilder: (context, i) => FadeTransition(
                      opacity: _fades[i],
                      child: SlideTransition(
                        position: _slides[i],
                        child: _ContributeCard(item: items[i]),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<_Item> _buildItems(AppLocalizations l10n) => [
        _Item(l10n.asrat, Icons.percent, AppTheme.royalEmerald, 'asrat'),
        _Item(l10n.bekuart, Icons.card_giftcard, AppTheme.royalEmerald, 'bekuart'),
        _Item(l10n.monthly, Icons.calendar_month, AppTheme.royalEmerald, 'monthly'),
        _Item(l10n.buildingFund, Icons.build_circle, AppTheme.royalEmerald, 'buildingFund'),
        _Item(l10n.charity, Icons.favorite, AppTheme.royalEmerald, 'charity'),
        _Item(l10n.festival, Icons.celebration, AppTheme.royalEmerald, 'festival'),
        _Item(l10n.candle, Icons.light, AppTheme.royalEmerald, 'candle'),
        _Item(l10n.memorial, Icons.history, AppTheme.royalEmerald, 'memorial'),
        _Item(l10n.monastery, Icons.castle, AppTheme.royalEmerald, 'monastery'),
        _Item(l10n.priest, Icons.person_pin, AppTheme.royalEmerald, 'priest'),
        _Item(l10n.sundaySchool, Icons.school, AppTheme.royalEmerald, 'sundaySchool'),
        _Item(l10n.youth, Icons.groups, AppTheme.royalEmerald, 'youth'),
        _Item(l10n.women, Icons.woman, AppTheme.royalEmerald, 'women'),
        _Item(l10n.development, Icons.developer_mode, AppTheme.royalEmerald, 'development'),
        _Item(l10n.emergency, Icons.warning_amber, AppTheme.royalEmerald, 'emergency'),
        _Item(l10n.specialCollection, Icons.stars_rounded, AppTheme.royalEmerald, 'specialCollection'),
      ];
}

class _ContributeCard extends StatefulWidget {
  final _Item item;
  const _ContributeCard({required this.item});

  @override
  State<_ContributeCard> createState() => _ContributeCardState();
}

class _ContributeCardState extends State<_ContributeCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _breathe;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _breathe = AnimationController(vsync: this, duration: const Duration(milliseconds: 2800))
      ..repeat(reverse: true);
    _scale = Tween<double>(begin: 1.0, end: 1.016).animate(
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
    final item = widget.item;
    return ScaleTransition(
      scale: _scale,
      child: InkWell(
        onTap: () => context.push('/contribute/amount', extra: item.type),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF0F7F4), // Smooth constant green-tinted card background
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
                child: Icon(item.icon, color: AppTheme.royalEmerald, size: 22),
              ),
              Text(
                item.label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: AppTheme.royalEmerald,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Item {
  final String label, type;
  final IconData icon;
  final Color color;
  const _Item(this.label, this.icon, this.color, this.type);
}
