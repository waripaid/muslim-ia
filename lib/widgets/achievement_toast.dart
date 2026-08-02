import 'package:flutter/material.dart';
import '../providers/memorize_provider.dart';

class AchievementToast {
  static void show(BuildContext context, Achievement achievement) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (ctx) => _AchievementOverlay(
        achievement: achievement,
        onDismiss: () => entry.remove(),
      ),
    );
    overlay.insert(entry);
    Future.delayed(const Duration(seconds: 3), () {
      if (entry.mounted) entry.remove();
    });
  }
}

class _AchievementOverlay extends StatefulWidget {
  final Achievement achievement;
  final VoidCallback onDismiss;
  const _AchievementOverlay({required this.achievement, required this.onDismiss});

  @override
  State<_AchievementOverlay> createState() => _AchievementOverlayState();
}

class _AchievementOverlayState extends State<_AchievementOverlay> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _slide;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 3000));
    _slide = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _ctrl, curve: const Interval(0.0, 0.15, curve: Curves.easeOut)));
    _opacity = Tween(begin: 1.0, end: 0.0).animate(CurvedAnimation(parent: _ctrl, curve: const Interval(0.7, 1.0, curve: Curves.easeIn)));
    _ctrl.forward().then((_) => widget.onDismiss());
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 8,
      left: 16, right: 16,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, child) => Opacity(
          opacity: _opacity.value,
          child: Transform.translate(
            offset: Offset(0, -20 * (1 - _slide.value)),
            child: child,
          ),
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFFC5A028), Color(0xFFE8C547)]),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [BoxShadow(color: const Color(0xFFC5A028).withValues(alpha: 0.4), blurRadius: 20, offset: const Offset(0, 4))],
          ),
          child: Row(children: [
            Container(width: 48, height: 48, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
              child: Center(child: Text(widget.achievement.icon, style: const TextStyle(fontSize: 24)))),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('SUCCÈS DÉBLOQUÉ !', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF5C4010), letterSpacing: 1)),
              const SizedBox(height: 2),
              Text(widget.achievement.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF3D2800))),
              Text(widget.achievement.description, style: const TextStyle(fontSize: 12, color: Color(0xFF5C4010))),
            ])),
            GestureDetector(onTap: widget.onDismiss, child: const Icon(Icons.close_rounded, color: Color(0xFF5C4010), size: 20)),
          ]),
        ),
      ),
    );
  }
}
