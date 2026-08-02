import 'dart:async';
import 'package:flutter/material.dart';

/// Affiche le texte comme si quelqu'un écrivait, avec un rythme naturel :
/// frappe rapide, légère pause entre les mots, plus longue à la ponctuation.
/// Chaque caractère apparaît en fondu (premium), sans curseur visible.
class TypeWriterText extends StatefulWidget {
  final String text;
  final bool animate;
  final TextStyle? style;
  final List<TextSpan> Function(String text) formatter;

  const TypeWriterText({
    super.key,
    required this.text,
    required this.animate,
    required this.formatter,
    this.style,
  });

  @override
  State<TypeWriterText> createState() => _TypeWriterTextState();
}

class _TypeWriterTextState extends State<TypeWriterText>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fadeCtrl;
  late final Animation<double> _fade;
  Timer? _timer;
  int _shown = 0;

  static const _endPunctuation = '.!?…:;';
  static const _midPunctuation = ',،-';

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 60));
    _fade = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _syncTimer();
  }

  @override
  void didUpdateWidget(TypeWriterText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_shown > widget.text.length) _shown = widget.text.length;
    if (oldWidget.animate != widget.animate || oldWidget.text != widget.text) {
      _syncTimer();
    }
  }

  /// Nombre de caractères révélés par tick : plus le texte est long, plus
  /// la frappe est rapide pour un affichage quasi instantané.
  int get _step => switch (widget.text.length) {
        > 1200 => 6,
        > 500 => 4,
        _ => 2,
      };

  /// Cadence ultra-rapide : les pauses sont minimisées.
  Duration _delayFor(int index) {
    final total = widget.text.length;
    final base = switch (total) {
      > 1200 => const Duration(milliseconds: 1),
      > 500 => const Duration(milliseconds: 2),
      _ => const Duration(milliseconds: 4),
    };
    final ch = widget.text[index];
    if (ch == '\n') return const Duration(milliseconds: 30);
    if (ch == ' ') return Duration(milliseconds: base.inMilliseconds + 10);
    if (_endPunctuation.contains(ch)) return const Duration(milliseconds: 30);
    if (_midPunctuation.contains(ch)) return const Duration(milliseconds: 12);
    return base;
  }

  void _syncTimer() {
    _timer?.cancel();
    _timer = null;
    if (widget.animate) {
      if (_shown < widget.text.length) {
        _timer = Timer(_delayFor(_shown), _tick);
      }
    } else {
      _shown = widget.text.length;
    }
  }

  void _tick() {
    if (!mounted) return;
    setState(() {
      _shown = (_shown + _step).clamp(0, widget.text.length);
      _fadeCtrl.forward(from: 0);
      if (_shown < widget.text.length) {
        _timer = Timer(_delayFor(_shown), _tick);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _fadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shown = _shown.clamp(0, widget.text.length);
    if (shown == 0) return const SizedBox.shrink();

    final visible = widget.text.substring(0, shown);
    final formatted = widget.formatter(visible);
    final spans = <InlineSpan>[...formatted];

    // Le tout dernier caractère apparaît en fondu pour un rendu fluide.
    final last = formatted.isNotEmpty ? formatted.last : null;
    final lastText = last?.text ?? '';
    if (last != null && lastText.isNotEmpty) {
      final style = last.style;
      final plain = TextSpan(
        text: lastText.substring(0, lastText.length - 1),
        style: style,
        children: last.children,
      );
      spans[spans.length - 1] = plain;
      spans.add(WidgetSpan(
        alignment: PlaceholderAlignment.baseline,
        baseline: TextBaseline.alphabetic,
        child: FadeTransition(
          opacity: _fade,
          child: Text(
            lastText.substring(lastText.length - 1),
            style: style,
            maxLines: 1,
          ),
        ),
      ));
    }

    return Text.rich(
      TextSpan(style: widget.style, children: spans),
    );
  }
}
