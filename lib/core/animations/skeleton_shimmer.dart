import 'package:flutter/material.dart';

/// A shimmering placeholder box — drop it anywhere you're loading data.
class SkeletonShimmer extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const SkeletonShimmer({
    super.key,
    this.width = double.infinity,
    this.height = 16,
    this.borderRadius = 8,
  });

  @override
  State<SkeletonShimmer> createState() => _SkeletonShimmerState();
}

class _SkeletonShimmerState extends State<SkeletonShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _sweep;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
    _sweep = Tween<double>(begin: -1.5, end: 2.5).animate(
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
      animation: _sweep,
      builder: (_, _) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          gradient: LinearGradient(
            begin: Alignment(_sweep.value - 0.8, 0),
            end: Alignment(_sweep.value + 0.8, 0),
            colors: const [
              Color(0xFFEEEEEE),
              Color(0xFFF8F8F8),
              Color(0xFFEEEEEE),
            ],
          ),
        ),
      ),
    );
  }
}

/// Pre-built skeleton layout that mimics a transaction list item.
class SkeletonTxItem extends StatelessWidget {
  const SkeletonTxItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          const SkeletonShimmer(width: 44, height: 44, borderRadius: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SkeletonShimmer(height: 14, borderRadius: 6),
                const SizedBox(height: 8),
                SkeletonShimmer(width: MediaQuery.of(context).size.width * 0.4, height: 11, borderRadius: 5),
              ],
            ),
          ),
          const SizedBox(width: 14),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SkeletonShimmer(width: 70, height: 14, borderRadius: 6),
              SizedBox(height: 6),
              SkeletonShimmer(width: 48, height: 10, borderRadius: 5),
            ],
          ),
        ],
      ),
    );
  }
}

/// Pre-built skeleton layout that mimics a notification card.
class SkeletonNotificationItem extends StatelessWidget {
  const SkeletonNotificationItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SkeletonShimmer(width: 42, height: 42, borderRadius: 21),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SkeletonShimmer(height: 14, borderRadius: 6),
                const SizedBox(height: 8),
                const SkeletonShimmer(height: 11, borderRadius: 5),
                const SizedBox(height: 6),
                SkeletonShimmer(
                  width: MediaQuery.of(context).size.width * 0.5,
                  height: 11,
                  borderRadius: 5,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
