import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Counts up from zero to [end] with an ease-out curve.
/// Set [currency] to true for comma-formatted numbers.
class AnimatedCountText extends StatefulWidget {
  final double end;
  final String prefix;
  final String suffix;
  final TextStyle? style;
  final Duration duration;
  final bool currency;

  const AnimatedCountText({
    super.key,
    required this.end,
    this.prefix = '',
    this.suffix = '',
    this.style,
    this.duration = const Duration(milliseconds: 1600),
    this.currency = false,
  });

  @override
  State<AnimatedCountText> createState() => _AnimatedCountTextState();
}

class _AnimatedCountTextState extends State<AnimatedCountText>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;
  final _fmt = NumberFormat('#,##0.00');

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration);
    _anim = Tween<double>(begin: 0, end: widget.end).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, _) {
        final val = widget.currency
            ? _fmt.format(_anim.value)
            : _anim.value.toStringAsFixed(2);
        return Text(
          '${widget.prefix}$val${widget.suffix}',
          style: widget.style,
        );
      },
    );
  }
}
