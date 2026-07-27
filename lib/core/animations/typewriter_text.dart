import 'package:flutter/material.dart';

/// Reveals text character-by-character with an optional cursor blink.
class TypewriterText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final TextAlign textAlign;
  final Duration perChar;
  final Duration startDelay;
  final bool showCursor;

  const TypewriterText({
    super.key,
    required this.text,
    this.style,
    this.textAlign = TextAlign.start,
    this.perChar = const Duration(milliseconds: 28),
    this.startDelay = Duration.zero,
    this.showCursor = true,
  });

  @override
  State<TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<TypewriterText>
    with TickerProviderStateMixin {
  late final AnimationController _typeCtrl;
  late final AnimationController _cursorCtrl;
  late final Animation<int> _charCount;
  bool _done = false;

  @override
  void initState() {
    super.initState();
    final dur = widget.perChar * widget.text.length;

    _typeCtrl = AnimationController(vsync: this, duration: dur);
    _charCount = IntTween(begin: 0, end: widget.text.length).animate(
      CurvedAnimation(parent: _typeCtrl, curve: Curves.linear),
    );

    _cursorCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);

    _typeCtrl.addStatusListener((s) {
      if (s == AnimationStatus.completed && mounted) {
        setState(() => _done = true);
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) _cursorCtrl.stop();
        });
      }
    });

    Future.delayed(widget.startDelay, () {
      if (mounted) _typeCtrl.forward();
    });
  }

  @override
  void dispose() {
    _typeCtrl.dispose();
    _cursorCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_charCount, _cursorCtrl]),
      builder: (_, _) {
        final visible = _charCount.value;
        final cursor = widget.showCursor && !_done
            ? (_cursorCtrl.value > 0.5 ? '|' : '')
            : '';
        return Text(
          widget.text.substring(0, visible) + cursor,
          style: widget.style,
          textAlign: widget.textAlign,
        );
      },
    );
  }
}
