import 'dart:math';
import 'package:flutter/material.dart';
import '../config/theme.dart';

class XpPopup extends StatefulWidget {
  final int xp;
  final VoidCallback? onDone;
  const XpPopup({super.key, required this.xp, this.onDone});

  @override
  State<XpPopup> createState() => _XpPopupState();
}

class _XpPopupState extends State<XpPopup> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _scale = Tween(begin: 0.3, end: 1.0).animate(CurvedAnimation(parent: _ctrl, curve: const Interval(0.0, 0.3, curve: Curves.elasticOut)));
    _opacity = Tween(begin: 1.0, end: 0.0).animate(CurvedAnimation(parent: _ctrl, curve: const Interval(0.6, 1.0)));
    _slide = Tween(begin: Offset.zero, end: const Offset(0, -1.5)).animate(CurvedAnimation(parent: _ctrl, curve: const Interval(0.3, 0.8, curve: Curves.easeOut)));
    _ctrl.forward().then((_) => widget.onDone?.call());
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) => Opacity(
        opacity: _opacity.value,
        child: SlideTransition(
          position: _slide,
          child: Transform.scale(
            scale: _scale.value,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFFC5A028), Color(0xFFE8C547)]),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [BoxShadow(color: const Color(0xFFC5A028).withValues(alpha: 0.4), blurRadius: 20)],
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.star_rounded, color: Colors.white, size: 22),
                const SizedBox(width: 6),
                Text('+${widget.xp} XP', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18)),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

class CelebrationScreen extends StatefulWidget {
  final String lessonTitle;
  final int xpEarned;
  final VoidCallback onContinue;
  final VoidCallback? onAiRecap;
  const CelebrationScreen({super.key, required this.lessonTitle, required this.xpEarned, required this.onContinue, this.onAiRecap});

  @override
  State<CelebrationScreen> createState() => _CelebrationScreenState();
}

class _CelebrationScreenState extends State<CelebrationScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  final List<_Confetti> _confetti = [];
  final _random = Random();

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000));
    _genConfetti();
    _ctrl.forward();
  }

  void _genConfetti() {
    for (int i = 0; i < 50; i++) {
      _confetti.add(_Confetti(
        x: _random.nextDouble(),
        y: -0.1 - _random.nextDouble() * 0.3,
        speed: 0.3 + _random.nextDouble() * 0.7,
        size: 6 + _random.nextDouble() * 10,
        color: [
          const Color(0xFFC5A028), const Color(0xFFE74C3C), const Color(0xFF27AE60),
          const Color(0xFF2980B9), const Color(0xFF8E44AD), const Color(0xFFE67E22),
        ][_random.nextInt(6)],
        rotation: _random.nextDouble() * 360,
      ));
    }
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Stack(
        children: [
          ..._confetti.map((c) => AnimatedBuilder(
                animation: _ctrl,
                builder: (_, __) {
                  final progress = (_ctrl.value - c.delay).clamp(0.0, 1.0);
                  return Positioned(
                    left: c.x * MediaQuery.of(context).size.width,
                    top: (c.y + progress * c.speed * 1.8) * MediaQuery.of(context).size.height,
                    child: Transform.rotate(
                      angle: c.rotation * progress * 4,
                      child: Container(
                        width: c.size, height: c.size * 0.6,
                        decoration: BoxDecoration(color: c.color, borderRadius: BorderRadius.circular(2)),
                      ),
                    ),
                  );
                },
              )),
          SafeArea(
            child: Center(
              child: AnimatedBuilder(
                animation: _ctrl,
                builder: (context, _) {
                  final t = (_ctrl.value - 0.2).clamp(0.0, 1.0);
                  return Opacity(
                    opacity: t,
                    child: Transform.scale(
                      scale: 0.5 + 0.5 * t,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 100, height: 100,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(colors: [Color(0xFFC5A028), Color(0xFFE8C547)]),
                              shape: BoxShape.circle,
                              boxShadow: [BoxShadow(color: const Color(0xFFC5A028).withValues(alpha: 0.5), blurRadius: 30)],
                            ),
                            child: const Icon(Icons.emoji_events_rounded, size: 52, color: Colors.white),
                          ),
                          const SizedBox(height: 24),
                          const Text('LEÇON TERMINÉE !', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFFF5E6B8), letterSpacing: 2)),
                          const SizedBox(height: 8),
                          Text(widget.lessonTitle, textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.white)),
                          const SizedBox(height: 24),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(mainAxisSize: MainAxisSize.min, children: [
                              const Icon(Icons.star_rounded, color: Color(0xFFE8C547), size: 28),
                              const SizedBox(width: 8),
                              Text('+${widget.xpEarned} XP', style: const TextStyle(color: Color(0xFFE8C547), fontWeight: FontWeight.w900, fontSize: 28)),
                            ]),
                          ),
                          const SizedBox(height: 40),
                          SizedBox(
                            width: 220, height: 54,
                            child: ElevatedButton(
                              onPressed: widget.onContinue,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFE8C547),
                                foregroundColor: AppColors.primary,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                                textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                              ),
                              child: const Text('Continuer'),
                            ),
                          ),
                          if (widget.onAiRecap != null) ...[
                            const SizedBox(height: 12),
                            SizedBox(
                              width: 220, height: 44,
                              child: OutlinedButton.icon(
                                onPressed: widget.onAiRecap,
                                icon: const Icon(Icons.auto_awesome_rounded, size: 16),
                                label: const Text('Résumé IA', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFFF5E6B8),
                                  side: const BorderSide(color: Color(0xFFF5E6B8), width: 1.5),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Confetti {
  final double x, y, speed, size, rotation, delay;
  final Color color;
  _Confetti({required this.x, required this.y, required this.speed, required this.size, required this.color, required this.rotation})
      : delay = (x + y) * 0.2;
}
