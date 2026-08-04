import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' show FontFeature;
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';

/// Bulle de message vocal avec onde animée, play/pause et durée.
/// Réutilisable : dans le chat et dans l'aperçu avant envoi.
class VoiceBubble extends StatefulWidget {
  final String audioPath;
  final Color barColor;
  final bool autoplay;
  final bool small;
  final ValueChanged<bool>? onPlayingChanged;
  final VoidCallback? onAutoplayTriggered;

  const VoiceBubble({
    super.key,
    required this.audioPath,
    this.barColor = Colors.white,
    this.autoplay = false,
    this.small = false,
    this.onPlayingChanged,
    this.onAutoplayTriggered,
  });

  @override
  State<VoiceBubble> createState() => _VoiceBubbleState();
}

class _VoiceBubbleState extends State<VoiceBubble> with SingleTickerProviderStateMixin {
  final _player = FlutterSoundPlayer();
  late final AnimationController _anim;
  late final List<double> _staticHeights;
  StreamSubscription<PlaybackDisposition>? _sub;

  bool _playing = false;
  bool _ready = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  static const _barCount = 26;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat(reverse: true);
    _staticHeights = List.generate(_barCount, (i) {
      final seed = (i * 2654435761) % 100;
      return 5 + (seed % 18).toDouble();
    });
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    try {
      await _player.openPlayer();
      _sub = _player.onProgress?.listen((e) {
        if (!mounted) return;
        setState(() {
          _position = e.position;
          if (e.duration > Duration.zero) _duration = e.duration;
        });
      });
      final total = await _player.startPlayer(fromURI: widget.audioPath, whenFinished: () {
        if (!mounted) return;
        setState(() {
          _playing = false;
          _position = Duration.zero;
          _ready = false;
        });
        widget.onPlayingChanged?.call(false);
      });
      if (mounted) {
        setState(() {
          if (total != null) _duration = total;
          _ready = true;
        });
      }
      await _player.pausePlayer();
      if (widget.autoplay && mounted) {
        setState(() => _playing = true);
        await _player.resumePlayer();
        // Consomme le signal d'autoplay : l'audio ne doit être déclenché
        // qu'une seule fois, même si la bulle est reconstruite ensuite.
        widget.onAutoplayTriggered?.call();
      }
    } catch (e) {
      // Fichier indisponible ou moteur audio occupé
    }
  }

  Future<void> _toggle() async {
    try {
      if (_playing) {
        await _player.pausePlayer();
        if (mounted) setState(() => _playing = false);
        widget.onPlayingChanged?.call(false);
      } else if (_ready && _position > Duration.zero && _position < _duration) {
        await _player.resumePlayer();
        if (mounted) setState(() => _playing = true);
        widget.onPlayingChanged?.call(true);
      } else {
        await _player.startPlayer(fromURI: widget.audioPath, whenFinished: () {
          if (!mounted) return;
          setState(() {
            _playing = false;
            _position = Duration.zero;
            _ready = false;
          });
          widget.onPlayingChanged?.call(false);
        });
        if (mounted) setState(() => _playing = true);
        widget.onPlayingChanged?.call(true);
      }
    } catch (_) {}
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Widget _bars(double size, int count) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: List.generate(count, (i) {
            double h;
            if (_playing) {
              final wave = 0.5 + 0.5 * math.sin((i * 0.55) + _anim.value * math.pi * 4);
              h = size * (0.25 + wave * 0.75);
            } else {
              h = size * (0.2 + (_staticHeights[i] / 22) * 0.8);
            }
            return Container(
              width: 3,
              height: h.clamp(3.0, size),
              margin: const EdgeInsets.symmetric(horizontal: 1.5),
              decoration: BoxDecoration(
                color: widget.barColor.withValues(alpha: _playing ? 1.0 : 0.75),
                borderRadius: BorderRadius.circular(2),
              ),
            );
          }),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final buttonSize = widget.small ? 34.0 : 42.0;
    final iconSize = widget.small ? 16.0 : 20.0;
    final size = widget.small ? 14.0 : 18.0;
    final show = _duration.inSeconds > 0;

    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 10.0;
        const barSlot = 6.0;
        const durationTextWidth = 42.0;
        final availableWidth =
            constraints.maxWidth.isFinite ? constraints.maxWidth : double.infinity;
        final maxBars = availableWidth.isFinite
            ? ((availableWidth - buttonSize - gap - gap - durationTextWidth) / barSlot)
                .floor()
                .clamp(6, _barCount)
                .toInt()
            : _barCount;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: _toggle,
              child: Container(
                width: buttonSize,
                height: buttonSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.barColor.withValues(alpha: 0.15),
                  border: Border.all(color: widget.barColor.withValues(alpha: 0.4), width: 1),
                ),
                child: Icon(
                  _playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  size: iconSize,
                  color: widget.barColor,
                ),
              ),
            ),
            const SizedBox(width: 10),
            _bars(size, maxBars),
            const SizedBox(width: 10),
            Text(
              _playing ? _fmt(_position) : (show ? _fmt(_duration) : '00:00'),
              style: TextStyle(
                fontSize: widget.small ? 11 : 12.5,
                fontWeight: FontWeight.w600,
                color: widget.barColor.withValues(alpha: 0.9),
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _sub?.cancel();
    _player.stopPlayer();
    _player.closePlayer();
    _anim.dispose();
    super.dispose();
  }
}
