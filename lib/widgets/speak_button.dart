import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Bouton haut-parleur pour écouter la prononciation (arabe et autres).
class SpeakButton extends StatefulWidget {
  final String text;
  final String language;
  final double size;
  final Color? color;

  const SpeakButton({
    super.key,
    required this.text,
    this.language = 'ar-SA',
    this.size = 20,
    this.color,
  });

  @override
  State<SpeakButton> createState() => _SpeakButtonState();
}

class _SpeakButtonState extends State<SpeakButton> with SingleTickerProviderStateMixin {
  final _tts = FlutterTts();
  late final AnimationController _pulse;
  bool _speaking = false;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 500))..repeat(reverse: true);
    _tts.setSpeechRate(0.4);
    _tts.setVolume(1.0);
  }

  @override
  void dispose() {
    _pulse.dispose();
    _tts.stop();
    super.dispose();
  }

  Future<void> _speak() async {
    if (_speaking) {
      await _tts.stop();
      if (mounted) setState(() => _speaking = false);
      return;
    }
    try {
      await _tts.stop();
      await _tts.setLanguage(widget.language);
      if (!mounted) return;
      setState(() => _speaking = true);
      await _tts.awaitSpeakCompletion(true);
      await _tts.speak(widget.text);
      if (mounted) setState(() => _speaking = false);
    } catch (_) {
      if (mounted) setState(() => _speaking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? Theme.of(context).colorScheme.primary;
    return GestureDetector(
      onTap: _speak,
      child: AnimatedBuilder(
        animation: _pulse,
        builder: (_, child) => Transform.scale(
          scale: _speaking ? 1.15 + _pulse.value * 0.15 : 1.0,
          child: child,
        ),
        child: Icon(
          _speaking ? Icons.graphic_eq_rounded : Icons.volume_up_rounded,
          size: widget.size,
          color: color,
        ),
      ),
    );
  }
}
