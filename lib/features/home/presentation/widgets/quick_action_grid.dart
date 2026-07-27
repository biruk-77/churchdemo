import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:church/app/theme.dart';
import 'package:church/l10n/app_localizations.dart';

class QuickActionGrid extends StatefulWidget {
  const QuickActionGrid({super.key});

  @override
  State<QuickActionGrid> createState() => _QuickActionGridState();
}

class _QuickActionGridState extends State<QuickActionGrid>
    with SingleTickerProviderStateMixin {
  late final AnimationController _stagger;
  late final List<Animation<double>> _fades;
  late final List<Animation<Offset>> _slides;

  static const _cardCount = 6;

  @override
  void initState() {
    super.initState();
    // Each card gets 80 ms head-start; total = 6×80 + 550 = 1030 ms
    _stagger = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..forward();

    _fades = List.generate(_cardCount, (i) {
      final start = i * 0.073;
      return Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _stagger,
          curve: Interval(start, (start + 0.3).clamp(0, 1.0), curve: Curves.easeOut),
        ),
      );
    });

    _slides = List.generate(_cardCount, (i) {
      final start = i * 0.073;
      return Tween<Offset>(
        begin: const Offset(0, 0.55),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _stagger,
          curve: Interval(start, (start + 0.5).clamp(0, 1.0), curve: Curves.easeOutBack),
        ),
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
    final actions = [
      _Item(l10n.monthly, Icons.calendar_month_rounded, Colors.teal, 'monthly'),
      _Item(l10n.bekuart, Icons.card_giftcard_rounded, AppTheme.primaryBlue, 'bekuart'),
      _Item(l10n.festival, Icons.celebration_rounded, Colors.orange, 'festival'),
      _Item(l10n.buildingFund, Icons.domain_rounded, Colors.indigo, 'buildingFund'),
      _Item(l10n.asrat, Icons.percent_rounded, AppTheme.primaryGold, 'asrat'),
      _Item(l10n.monastery, Icons.castle_rounded, Colors.deepOrange, 'monastery'),
    ];

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
          itemCount: actions.length,
          itemBuilder: (context, i) => FadeTransition(
            opacity: _fades[i],
            child: SlideTransition(
              position: _slides[i],
              child: _BreathingCard(item: actions[i]),
            ),
          ),
        );
      },
    );
  }
}

// Wraps a card in a subtle continuous scale "breathing" animation.
class _BreathingCard extends StatefulWidget {
  final _Item item;
  const _BreathingCard({required this.item});

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
    return ScaleTransition(scale: _scale, child: _CardFace(item: widget.item));
  }
}

class _CardFace extends StatelessWidget {
  final _Item item;
  const _CardFace({required this.item});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push('/contribute/amount', extra: item.type),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, item.color.withValues(alpha: 0.06)],
          ),
          border: Border.all(color: item.color.withValues(alpha: 0.22), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: item.color.withValues(alpha: 0.14),
              blurRadius: 14,
              offset: const Offset(0, 5),
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
              decoration: BoxDecoration(
                color: item.color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(item.icon, color: item.color, size: 22),
            ),
            Text(
              item.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

class _Item {
  final String title;
  final IconData icon;
  final Color color;
  final String type;
  const _Item(this.title, this.icon, this.color, this.type);
}
